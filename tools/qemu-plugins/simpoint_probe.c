/*
 * SimPoint boundary probe for QEMU user-mode runs.
 *
 * This is an architectural checkpoint capture probe, not an RTL restore
 * implementation. It records registers and readable guest mappings near one or
 * more instruction boundaries, then counts syscalls in requested ROI windows.
 */
#include <glib.h>
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "qemu-plugin.h"

QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

struct tb_info {
    uint64_t pc;
    uint64_t insns;
};

struct roi_window {
    uint64_t start;
    uint64_t end;
    uint64_t syscalls;
    GHashTable *syscall_counts;
};

static GMutex lock;
static GArray *registers;
static const char *outfile = "simpoint_probe.regs";
static const char *mapsfile;
static const char *memory_prefix;
static const char *windowsfile;
static uint64_t guest_limit = 0x4000000000ULL;
static bool dump_memory;
static uint64_t interval_insns = 100000000ULL;
static uint64_t target_interval;
static uint64_t current_insns;
static bool exit_after_dump;
static GArray *targets;
static GArray *memory_targets;
static GArray *windows;
static guint next_target;
static uint64_t syscall_count;
static bool maps_dumped;
static bool windows_dumped;

static bool array_contains_u64(const GArray *values, uint64_t target)
{
    if (!values) {
        return false;
    }
    for (guint i = 0; i < values->len; i++) {
        if (g_array_index(values, uint64_t, i) == target) {
            return true;
        }
    }
    return false;
}

static bool parse_u64_arg(const char *arg, const char *prefix, uint64_t *value)
{
    char *endptr = NULL;
    uint64_t parsed;

    if (!g_str_has_prefix(arg, prefix)) {
        return false;
    }

    parsed = g_ascii_strtoull(arg + strlen(prefix), &endptr, 0);
    if (endptr == arg + strlen(prefix) || *endptr != '\0') {
        fprintf(stderr, "simpoint_probe: invalid %s\n", arg);
        exit(1);
    }

    *value = parsed;
    return true;
}

static void print_hex_bytes(FILE *out, const GByteArray *buf)
{
    fputs("0x", out);
    for (gint i = (gint)buf->len - 1; i >= 0; i--) {
        fprintf(out, "%02x", buf->data[i]);
    }
}

static void dump_process_maps(void)
{
    FILE *source;
    FILE *destination;
    char buffer[8192];
    size_t size;

    if (!mapsfile || maps_dumped) {
        return;
    }
    source = fopen("/proc/self/maps", "r");
    destination = fopen(mapsfile, "w");
    if (!source || !destination) {
        perror("simpoint_probe: dump /proc/self/maps");
        if (source) {
            fclose(source);
        }
        if (destination) {
            fclose(destination);
        }
        return;
    }
    while ((size = fread(buffer, 1, sizeof(buffer), source)) != 0) {
        if (fwrite(buffer, 1, size, destination) != size) {
            perror("simpoint_probe: write mapsfile");
            break;
        }
    }
    fclose(source);
    fclose(destination);
    maps_dumped = true;
}

static void print_json_string(FILE *out, const char *value)
{
    fputc('"', out);
    for (const unsigned char *p = (const unsigned char *)value; *p; p++) {
        switch (*p) {
        case '"':
        case '\\':
            fputc('\\', out);
            fputc(*p, out);
            break;
        case '\n':
            fputs("\\n", out);
            break;
        case '\r':
            fputs("\\r", out);
            break;
        case '\t':
            fputs("\\t", out);
            break;
        default:
            if (*p < 0x20) {
                fprintf(out, "\\u%04x", *p);
            } else {
                fputc(*p, out);
            }
        }
    }
    fputc('"', out);
}

static gint compare_i64_keys(gconstpointer lhs, gconstpointer rhs)
{
    int64_t a = *(const int64_t *)lhs;
    int64_t b = *(const int64_t *)rhs;

    return (a > b) - (a < b);
}

static void dump_roi_windows_locked(void)
{
    FILE *out;

    if (!windowsfile || windows_dumped) {
        return;
    }
    out = fopen(windowsfile, "w");
    if (!out) {
        perror("simpoint_probe: fopen windowsfile");
        return;
    }
    fputs("{\n  \"format\": \"openc910-spec-l3-syscall-windows-v1\",\n"
          "  \"windows\": [\n", out);
    for (guint i = 0; windows && i < windows->len; i++) {
        struct roi_window *window = &g_array_index(windows, struct roi_window, i);
        GList *keys = g_hash_table_get_keys(window->syscall_counts);
        bool first = true;

        keys = g_list_sort(keys, compare_i64_keys);
        fprintf(out,
                "%s    {\"index\": %u, \"roi_start_instruction\": %" PRIu64
                ", \"roi_end_instruction\": %" PRIu64
                ", \"roi_syscalls\": %" PRIu64 ", \"syscall_counts\": {",
                i ? ",\n" : "", i, window->start, window->end,
                window->syscalls);
        for (GList *item = keys; item; item = item->next) {
            int64_t *number = item->data;
            uint64_t *count = g_hash_table_lookup(window->syscall_counts, number);

            fprintf(out, "%s\"%" PRId64 "\": %" PRIu64,
                    first ? "" : ", ", *number, *count);
            first = false;
        }
        fputs("}}", out);
        g_list_free(keys);
    }
    fputs("\n  ]\n}\n", out);
    fclose(out);
    windows_dumped = true;
}

static bool dump_guest_memory(guint checkpoint_index, uint64_t *dumped_bytes,
                              char **image_name, char **map_name)
{
    FILE *maps = NULL;
    FILE *image = NULL;
    FILE *map = NULL;
    int memory_fd = -1;
    char *buffer = NULL;
    char line[8192];
    bool first = true;
    bool ok = false;

    if (!dump_memory || !memory_prefix) {
        return true;
    }
    *image_name = g_strdup_printf("%s.checkpoint_%u.memory.bin",
                                  memory_prefix, checkpoint_index);
    *map_name = g_strdup_printf("%s.checkpoint_%u.memory_map.json",
                                memory_prefix, checkpoint_index);
    maps = fopen("/proc/self/maps", "r");
    memory_fd = open("/proc/self/mem", O_RDONLY);
    image = fopen(*image_name, "wb");
    map = fopen(*map_name, "w");
    buffer = g_malloc(1024 * 1024);
    if (!maps || memory_fd < 0 || !image || !map || !buffer) {
        perror("simpoint_probe: open guest memory dump");
        goto done;
    }

    fprintf(map,
            "{\n  \"format\": \"openc910-spec-l3-memory-v1\",\n"
            "  \"guest_base\": \"0x0\",\n"
            "  \"guest_limit\": \"0x%" PRIx64 "\",\n"
            "  \"segments\": [\n",
            guest_limit);
    while (fgets(line, sizeof(line), maps)) {
        unsigned long long start;
        unsigned long long end;
        unsigned long long file_offset;
        char permissions[5];
        int consumed = 0;
        char *path;
        uint64_t image_offset;
        uint64_t length;

        if (sscanf(line, "%llx-%llx %4s %llx %*s %*s %n",
                   &start, &end, permissions, &file_offset, &consumed) < 4) {
            continue;
        }
        if (start >= end || end > guest_limit) {
            continue;
        }
        path = line + consumed;
        while (*path == ' ' || *path == '\t') {
            path++;
        }
        path[strcspn(path, "\r\n")] = '\0';
        length = end - start;
        image_offset = (uint64_t)ftello(image);
        if (permissions[0] == 'r') {
            for (uint64_t offset = 0; offset < length;) {
                size_t request = length - offset > 1024 * 1024
                                     ? 1024 * 1024
                                     : (size_t)(length - offset);
                ssize_t actual = pread(memory_fd, buffer, request,
                                       (off_t)(start + offset));

                if (actual <= 0 || (size_t)actual != request) {
                    fprintf(stderr,
                            "simpoint_probe: pread guest 0x%llx failed: %s\n",
                            start + offset, strerror(errno));
                    goto done;
                }
                if (fwrite(buffer, 1, request, image) != request) {
                    perror("simpoint_probe: write guest memory image");
                    goto done;
                }
                offset += request;
            }
        }
        if (!first) {
            fputs(",\n", map);
        }
        first = false;
        fprintf(map,
                "    {\"guest_start\": \"0x%llx\", \"length\": %" PRIu64
                ", \"host_permissions\": \"%s\", \"restore_permissions\": \"%s\", "
                "\"file_offset\": \"0x%llx\", "
                "\"captured\": %s, \"image_offset\": ",
                start, length, permissions,
                permissions[0] == 'r'
                    ? (permissions[1] == 'w' ? "rw-" : "r-x")
                    : "---",
                file_offset,
                permissions[0] == 'r' ? "true" : "false");
        if (permissions[0] == 'r') {
            fprintf(map, "%" PRIu64, image_offset);
        } else {
            fputs("null", map);
        }
        fputs(", \"path\": ", map);
        print_json_string(map, path);
        fputc('}', map);
        if (permissions[0] == 'r') {
            *dumped_bytes += length;
        }
    }
    fputs("\n  ]\n}\n", map);
    ok = true;

done:
    if (maps) {
        fclose(maps);
    }
    if (memory_fd >= 0) {
        close(memory_fd);
    }
    if (image) {
        fclose(image);
    }
    if (map) {
        fclose(map);
    }
    g_free(buffer);
    if (!ok) {
        if (*image_name) {
            unlink(*image_name);
        }
        if (*map_name) {
            unlink(*map_name);
        }
    }
    return ok;
}

static void dump_registers_locked(unsigned int vcpu_index,
                                  const struct tb_info *tb,
                                  uint64_t target_insns,
                                  guint checkpoint_index)
{
    FILE *out = fopen(outfile, checkpoint_index == 0 ? "w" : "a");
    GByteArray *buf;
    uint64_t memory_bytes = 0;
    char *memory_image = NULL;
    char *memory_map = NULL;
    uint64_t state_insns = current_insns - tb->insns;

    if (!out) {
        perror("simpoint_probe: fopen outfile");
        return;
    }
    dump_process_maps();
    bool capture_memory = dump_memory &&
        (!memory_targets || memory_targets->len == 0 ||
         array_contains_u64(memory_targets, target_insns));
    bool memory_ok = capture_memory &&
        dump_guest_memory(checkpoint_index, &memory_bytes,
                          &memory_image, &memory_map);

    fprintf(out, "vcpu %" PRIu32 "\n", vcpu_index);
    fprintf(out, "checkpoint %u\n", checkpoint_index);
    fprintf(out, "target_insns %" PRIu64 "\n", target_insns);
    fprintf(out, "interval_insns %" PRIu64 "\n", interval_insns);
    fprintf(out, "observed_insns %" PRIu64 "\n", state_insns);
    fprintf(out, "boundary_error_insns %" PRIu64 "\n",
            target_insns - state_insns);
    fprintf(out, "observed_syscalls %" PRIu64 "\n", syscall_count);
    fprintf(out, "tb_pc 0x%" PRIx64 "\n", tb->pc);
    fprintf(out, "tb_insns %" PRIu64 "\n", tb->insns);
    if (capture_memory) {
        fprintf(out, "memory_status %s\n", memory_ok ? "ok" : "error");
        if (memory_ok) {
            fprintf(out, "memory_bytes %" PRIu64 "\n", memory_bytes);
            fprintf(out, "memory_image %s\n", memory_image);
            fprintf(out, "memory_map %s\n", memory_map);
        }
    } else if (dump_memory) {
        fputs("memory_status skipped\n", out);
    }

    if (!registers) {
        fprintf(out, "registers unavailable\n");
        fclose(out);
        return;
    }

    buf = g_byte_array_new();
    for (guint i = 0; i < registers->len; i++) {
        qemu_plugin_reg_descriptor reg =
            g_array_index(registers, qemu_plugin_reg_descriptor, i);
        int size;

        g_byte_array_set_size(buf, 0);
        size = qemu_plugin_read_register(reg.handle, buf);
        if (size < 0) {
            fprintf(out, "reg %s unreadable\n", reg.name);
            continue;
        }
        fprintf(out, "reg %s size %d value ", reg.name, size);
        print_hex_bytes(out, buf);
        fputc('\n', out);
    }

    g_byte_array_unref(buf);
    fputs("end_checkpoint\n", out);
    fclose(out);
    g_free(memory_image);
    g_free(memory_map);
}

static void vcpu_init(qemu_plugin_id_t id, unsigned int vcpu_index)
{
    (void)id;
    (void)vcpu_index;

    if (!registers) {
        registers = qemu_plugin_get_registers();
    }
}

static void vcpu_tb_exec(unsigned int vcpu_index, void *userdata)
{
    struct tb_info *tb = userdata;

    g_mutex_lock(&lock);

    current_insns += tb->insns;
    while (targets && next_target < targets->len) {
        uint64_t target_insns = g_array_index(targets, uint64_t, next_target);

        if (current_insns < target_insns) {
            break;
        }
        dump_registers_locked(vcpu_index, tb, target_insns, next_target);
        next_target++;
    }
    bool windows_complete = !windows || windows->len == 0 ||
        current_insns >= g_array_index(windows, struct roi_window,
                                       windows->len - 1).end;

    if (exit_after_dump && targets && next_target == targets->len &&
        windows_complete) {
        dump_roi_windows_locked();
        g_mutex_unlock(&lock);
        exit(0);
    }

    g_mutex_unlock(&lock);
}

static void vcpu_syscall(qemu_plugin_id_t id, unsigned int vcpu_index,
                         int64_t num, uint64_t a1, uint64_t a2,
                         uint64_t a3, uint64_t a4, uint64_t a5,
                         uint64_t a6, uint64_t a7, uint64_t a8)
{
    (void)id;
    (void)vcpu_index;
    (void)a1;
    (void)a2;
    (void)a3;
    (void)a4;
    (void)a5;
    (void)a6;
    (void)a7;
    (void)a8;
    g_mutex_lock(&lock);
    syscall_count++;
    for (guint i = 0; windows && i < windows->len; i++) {
        struct roi_window *window = &g_array_index(windows, struct roi_window, i);
        gint64 lookup = num;
        uint64_t *count;

        if (current_insns < window->start || current_insns >= window->end) {
            continue;
        }
        window->syscalls++;
        count = g_hash_table_lookup(window->syscall_counts, &lookup);
        if (!count) {
            gint64 *key = g_new(gint64, 1);

            *key = num;
            count = g_new0(uint64_t, 1);
            g_hash_table_insert(window->syscall_counts, key, count);
        }
        (*count)++;
    }
    g_mutex_unlock(&lock);
}

static void vcpu_tb_trans(qemu_plugin_id_t id, struct qemu_plugin_tb *tb)
{
    struct tb_info *info = g_new0(struct tb_info, 1);

    (void)id;
    info->pc = qemu_plugin_tb_vaddr(tb);
    info->insns = qemu_plugin_tb_n_insns(tb);
    qemu_plugin_register_vcpu_tb_exec_cb(tb, vcpu_tb_exec,
                                         QEMU_PLUGIN_CB_R_REGS, info);
}

static void plugin_exit(qemu_plugin_id_t id, void *userdata)
{
    (void)id;
    (void)userdata;

    g_mutex_lock(&lock);
    dump_roi_windows_locked();
    g_mutex_unlock(&lock);
    if (registers) {
        g_array_free(registers, true);
        registers = NULL;
    }
    if (targets) {
        g_array_free(targets, true);
        targets = NULL;
    }
    if (memory_targets) {
        g_array_free(memory_targets, true);
        memory_targets = NULL;
    }
    if (windows) {
        for (guint i = 0; i < windows->len; i++) {
            struct roi_window *window =
                &g_array_index(windows, struct roi_window, i);

            g_hash_table_destroy(window->syscall_counts);
        }
        g_array_free(windows, true);
        windows = NULL;
    }
}

static int compare_u64(gconstpointer lhs, gconstpointer rhs)
{
    uint64_t a = *(const uint64_t *)lhs;
    uint64_t b = *(const uint64_t *)rhs;

    return (a > b) - (a < b);
}

static bool parse_targets_arg(const char *arg)
{
    char **items;

    if (!g_str_has_prefix(arg, "targets=")) {
        return false;
    }
    items = g_strsplit(arg + strlen("targets="), ":", -1);
    for (guint i = 0; items[i]; i++) {
        char *endptr = NULL;
        uint64_t value = g_ascii_strtoull(items[i], &endptr, 0);

        if (endptr == items[i] || *endptr != '\0') {
            fprintf(stderr, "simpoint_probe: invalid target '%s'\n", items[i]);
            g_strfreev(items);
            exit(1);
        }
        g_array_append_val(targets, value);
    }
    g_strfreev(items);
    return true;
}

static bool parse_memory_targets_arg(const char *arg)
{
    char **items;

    if (!g_str_has_prefix(arg, "memory_targets=")) {
        return false;
    }
    items = g_strsplit(arg + strlen("memory_targets="), ":", -1);
    for (guint i = 0; items[i]; i++) {
        char *endptr = NULL;
        uint64_t value = g_ascii_strtoull(items[i], &endptr, 0);

        if (endptr == items[i] || *endptr != '\0') {
            fprintf(stderr, "simpoint_probe: invalid memory target '%s'\n",
                    items[i]);
            g_strfreev(items);
            exit(1);
        }
        g_array_append_val(memory_targets, value);
    }
    g_strfreev(items);
    return true;
}

static bool parse_windows_arg(const char *arg)
{
    char **items;

    if (!g_str_has_prefix(arg, "windows=")) {
        return false;
    }
    items = g_strsplit(arg + strlen("windows="), ":", -1);
    for (guint i = 0; items[i]; i++) {
        char *separator = strchr(items[i], '-');
        char *endptr = NULL;
        struct roi_window window = {0};

        if (!separator) {
            fprintf(stderr, "simpoint_probe: invalid ROI window '%s'\n", items[i]);
            g_strfreev(items);
            exit(1);
        }
        *separator = '\0';
        window.start = g_ascii_strtoull(items[i], &endptr, 0);
        if (endptr == items[i] || *endptr != '\0') {
            fprintf(stderr, "simpoint_probe: invalid ROI start '%s'\n", items[i]);
            g_strfreev(items);
            exit(1);
        }
        window.end = g_ascii_strtoull(separator + 1, &endptr, 0);
        if (endptr == separator + 1 || *endptr != '\0' ||
            window.end <= window.start) {
            fprintf(stderr, "simpoint_probe: invalid ROI end '%s'\n", separator + 1);
            g_strfreev(items);
            exit(1);
        }
        window.syscall_counts = g_hash_table_new_full(
            g_int64_hash, g_int64_equal, g_free, g_free);
        g_array_append_val(windows, window);
    }
    g_strfreev(items);
    return true;
}

static int compare_windows(gconstpointer lhs, gconstpointer rhs)
{
    const struct roi_window *a = lhs;
    const struct roi_window *b = rhs;

    return (a->start > b->start) - (a->start < b->start);
}

QEMU_PLUGIN_EXPORT int qemu_plugin_install(qemu_plugin_id_t id,
                                           const qemu_info_t *info,
                                           int argc, char **argv)
{
    (void)info;
    bool explicit_targets = false;

    targets = g_array_new(false, false, sizeof(uint64_t));
    memory_targets = g_array_new(false, false, sizeof(uint64_t));
    windows = g_array_new(false, false, sizeof(struct roi_window));

    for (int i = 0; i < argc; i++) {
        if (parse_u64_arg(argv[i], "interval=", &interval_insns)) {
            continue;
        }
        if (parse_u64_arg(argv[i], "target=", &target_interval)) {
            continue;
        }
        if (parse_memory_targets_arg(argv[i])) {
            continue;
        }
        if (parse_targets_arg(argv[i])) {
            explicit_targets = true;
            continue;
        }
        if (parse_windows_arg(argv[i])) {
            continue;
        }
        if (g_str_has_prefix(argv[i], "outfile=")) {
            outfile = argv[i] + strlen("outfile=");
            continue;
        }
        if (g_str_has_prefix(argv[i], "mapsfile=")) {
            mapsfile = argv[i] + strlen("mapsfile=");
            continue;
        }
        if (g_str_has_prefix(argv[i], "memory_prefix=")) {
            memory_prefix = argv[i] + strlen("memory_prefix=");
            continue;
        }
        if (g_str_has_prefix(argv[i], "windowsfile=")) {
            windowsfile = argv[i] + strlen("windowsfile=");
            continue;
        }
        if (parse_u64_arg(argv[i], "guest_limit=", &guest_limit)) {
            continue;
        }
        if (g_strcmp0(argv[i], "dump_memory=1") == 0) {
            dump_memory = true;
            continue;
        }
        if (g_strcmp0(argv[i], "exit_after=1") == 0) {
            exit_after_dump = true;
            continue;
        }
        fprintf(stderr, "simpoint_probe: unknown option '%s'\n", argv[i]);
        return -1;
    }

    if (interval_insns == 0) {
        fprintf(stderr, "simpoint_probe: interval must be non-zero\n");
        return -1;
    }
    if (!explicit_targets) {
        uint64_t target_insns = target_interval * interval_insns;

        g_array_append_val(targets, target_insns);
    }
    if (targets->len == 0) {
        fprintf(stderr, "simpoint_probe: targets must not be empty\n");
        return -1;
    }
    if (dump_memory && !memory_prefix) {
        fprintf(stderr, "simpoint_probe: dump_memory requires memory_prefix\n");
        return -1;
    }
    if (windows->len && !windowsfile) {
        fprintf(stderr, "simpoint_probe: windows requires windowsfile\n");
        return -1;
    }
    g_array_sort(targets, compare_u64);
    g_array_sort(memory_targets, compare_u64);
    g_array_sort(windows, compare_windows);

    qemu_plugin_register_vcpu_init_cb(id, vcpu_init);
    qemu_plugin_register_vcpu_tb_trans_cb(id, vcpu_tb_trans);
    qemu_plugin_register_vcpu_syscall_cb(id, vcpu_syscall);
    qemu_plugin_register_atexit_cb(id, plugin_exit, NULL);

    return 0;
}
