/*
 * Minimal SimPoint BBV plugin for QEMU user-mode runs.
 *
 * Output format matches SimPoint text frequency vectors:
 *   T:<block-id>:<count> :<block-id>:<count> ...
 *
 * Optional map format:
 *   <block-id> <pc-hex> <tb-insns>
 */
#include <glib.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "qemu-plugin.h"

QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

struct block_info {
    uint64_t id;
    uint64_t pc;
    uint64_t insns;
    uint64_t count;
};

static GMutex lock;
static GHashTable *pc_to_block;
static GPtrArray *blocks;
static FILE *out;
static const char *mapfile;
static bool append_output;
static uint64_t id_offset;
static uint64_t next_block_id = 1;
static bool pid_namespace;
static pid_t namespace_pid;
static uint64_t interval_insns = 100000000ULL;
static uint64_t current_insns;
static uint64_t skip_intervals;
static uint64_t skipped_intervals;
static uint64_t max_intervals;
static uint64_t dumped_intervals;
static bool exiting_early;

static void clear_counts_locked(void)
{
    if (!blocks) {
        return;
    }

    for (guint i = 0; i < blocks->len; i++) {
        struct block_info *block = g_ptr_array_index(blocks, i);

        block->count = 0;
    }
}

static void refresh_pid_namespace_locked(void)
{
    pid_t pid;

    if (!pid_namespace) {
        return;
    }
    pid = getpid();
    if (pid == namespace_pid) {
        return;
    }

    /* A forked QEMU child inherits plugin counters and translated blocks. */
    namespace_pid = pid;
    next_block_id = id_offset + ((uint64_t)(uint32_t)pid << 32) + 1;
    current_insns = 0;
    skipped_intervals = 0;
    dumped_intervals = 0;
    exiting_early = false;
    clear_counts_locked();
}

static bool dump_interval_locked(void)
{
    bool any = false;

    if (!out || !blocks || blocks->len == 0) {
        return false;
    }

    for (guint i = 0; i < blocks->len; i++) {
        struct block_info *block = g_ptr_array_index(blocks, i);

        if (block->count != 0) {
            if (!any) {
                fputs("T", out);
            }
            fprintf(out, ":%" PRIu64 ":%" PRIu64 " ", block->id, block->count);
            block->count = 0;
            any = true;
        }
    }
    if (!any) {
        return false;
    }
    fputc('\n', out);
    fflush(out);
    dumped_intervals++;
    return true;
}

static void dump_map_locked(void)
{
    FILE *map;

    if (!mapfile || !blocks) {
        return;
    }

    map = fopen(mapfile, append_output ? "a" : "w");
    if (!map) {
        perror("simple_bbv: fopen mapfile");
        return;
    }

    for (guint i = 0; i < blocks->len; i++) {
        struct block_info *block = g_ptr_array_index(blocks, i);

        fprintf(map, "%" PRIu64 " 0x%" PRIx64 " %" PRIu64 "\n",
                block->id, block->pc, block->insns);
    }

    fclose(map);
}

static void vcpu_tb_exec(unsigned int vcpu_index, void *userdata)
{
    struct block_info *block = userdata;

    (void)vcpu_index;

    g_mutex_lock(&lock);

    refresh_pid_namespace_locked();

    if (exiting_early) {
        g_mutex_unlock(&lock);
        return;
    }

    block->count += block->insns;
    current_insns += block->insns;
    while (current_insns >= interval_insns) {
        if (skipped_intervals < skip_intervals) {
            clear_counts_locked();
            skipped_intervals++;
        } else {
            dump_interval_locked();
        }
        current_insns -= interval_insns;
        if (max_intervals != 0 && dumped_intervals >= max_intervals) {
            exiting_early = true;
            dump_map_locked();
            if (out) {
                fclose(out);
                out = NULL;
            }
            g_mutex_unlock(&lock);
            exit(0);
        }
    }

    g_mutex_unlock(&lock);
}

static void vcpu_tb_trans(qemu_plugin_id_t id, struct qemu_plugin_tb *tb)
{
    uint64_t pc = qemu_plugin_tb_vaddr(tb);
    size_t n_insns = qemu_plugin_tb_n_insns(tb);
    struct block_info *block;
    gpointer key = (gpointer)(uintptr_t)pc;

    (void)id;

    g_mutex_lock(&lock);
    refresh_pid_namespace_locked();
    block = g_hash_table_lookup(pc_to_block, key);
    if (!block) {
        block = g_new0(struct block_info, 1);
        block->id = next_block_id++;
        block->pc = pc;
        block->insns = n_insns;
        g_hash_table_insert(pc_to_block, key, block);
        g_ptr_array_add(blocks, block);
    }
    g_mutex_unlock(&lock);

    qemu_plugin_register_vcpu_tb_exec_cb(tb, vcpu_tb_exec,
                                         QEMU_PLUGIN_CB_NO_REGS, block);
}

static void plugin_exit(qemu_plugin_id_t id, void *userdata)
{
    (void)id;
    (void)userdata;

    g_mutex_lock(&lock);
    refresh_pid_namespace_locked();
    if (skipped_intervals < skip_intervals) {
        clear_counts_locked();
    } else {
        dump_interval_locked();
    }
    dump_map_locked();
    if (out) {
        fclose(out);
        out = NULL;
    }
    g_mutex_unlock(&lock);
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
        fprintf(stderr, "simple_bbv: invalid %s\n", arg);
        exit(1);
    }

    *value = parsed;
    return true;
}

QEMU_PLUGIN_EXPORT int qemu_plugin_install(qemu_plugin_id_t id,
                                           const qemu_info_t *info,
                                           int argc, char **argv)
{
    const char *outfile = "qemu.bbv";

    (void)info;

    for (int i = 0; i < argc; i++) {
        if (parse_u64_arg(argv[i], "interval=", &interval_insns)) {
            continue;
        }
        if (parse_u64_arg(argv[i], "id_offset=", &id_offset)) {
            continue;
        }
        if (parse_u64_arg(argv[i], "skip_intervals=", &skip_intervals)) {
            continue;
        }
        if (parse_u64_arg(argv[i], "max_intervals=", &max_intervals)) {
            continue;
        }
        if (g_str_has_prefix(argv[i], "outfile=")) {
            outfile = argv[i] + strlen("outfile=");
            continue;
        }
        if (g_str_has_prefix(argv[i], "mapfile=")) {
            mapfile = argv[i] + strlen("mapfile=");
            continue;
        }
        if (g_strcmp0(argv[i], "append=1") == 0) {
            append_output = true;
            continue;
        }
        if (g_strcmp0(argv[i], "pid_namespace=1") == 0) {
            pid_namespace = true;
            continue;
        }
        fprintf(stderr, "simple_bbv: unknown option '%s'\n", argv[i]);
        return -1;
    }

    if (interval_insns == 0) {
        fprintf(stderr, "simple_bbv: interval must be non-zero\n");
        return -1;
    }

    namespace_pid = 0;
    if (pid_namespace) {
        refresh_pid_namespace_locked();
    } else {
        next_block_id = id_offset + 1;
    }
    out = fopen(outfile, append_output ? "a" : "w");
    if (!out) {
        perror("simple_bbv: fopen");
        return -1;
    }

    pc_to_block = g_hash_table_new(g_direct_hash, g_direct_equal);
    blocks = g_ptr_array_new();

    qemu_plugin_register_vcpu_tb_trans_cb(id, vcpu_tb_trans);
    qemu_plugin_register_atexit_cb(id, plugin_exit, NULL);

    return 0;
}
