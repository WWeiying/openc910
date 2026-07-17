/*
 * Dynamic architectural trace for smart_run kernel characterization.
 *
 * The plugin records the exact instruction stream and memory accesses between
 * perf_monitor_start (exclusive) and perf_monitor_end (exclusive).  Records
 * use a fixed binary format so expensive simulations only need to run once;
 * workload metrics are derived offline.
 */
#include <glib.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "qemu-plugin.h"

QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

enum record_kind {
    RECORD_INSN = 1,
    RECORD_MEM = 2,
};

enum record_flags {
    RECORD_MEM_STORE = 1,
};

struct trace_header {
    char magic[8];
    uint32_t version;
    uint32_t record_size;
    uint64_t start_pc;
    uint64_t end_pc;
    uint64_t reserved[4];
};

struct trace_record {
    uint8_t kind;
    uint8_t size;
    uint8_t flags;
    uint8_t reserved;
    uint32_t aux;
    uint64_t sequence;
    uint64_t pc;
    uint64_t value;
};

struct insn_info {
    uint64_t pc;
    uint64_t raw;
    uint8_t size;
};

static GMutex lock;
static FILE *trace_file;
static const char *trace_path;
static uint64_t start_pc;
static uint64_t end_pc;
static uint64_t max_instructions;
static uint64_t sequence;
static uint64_t instruction_count;
static uint64_t memory_count;
static bool enabled;
static bool seen_start;
static bool finished;
static bool stop_at_end = true;

static void write_record_locked(const struct trace_record *record)
{
    if (fwrite(record, sizeof(*record), 1, trace_file) != 1) {
        perror("kernel_trace: fwrite");
        exit(1);
    }
}

static void finish_locked(const char *reason)
{
    if (finished) {
        return;
    }
    finished = true;
    enabled = false;
    if (trace_file) {
        fflush(trace_file);
        fclose(trace_file);
        trace_file = NULL;
    }
    fprintf(stderr,
            "kernel_trace: %s, instructions=%" PRIu64
            ", memory_accesses=%" PRIu64 "\n",
            reason, instruction_count, memory_count);
}

static void instruction_exec(unsigned int vcpu_index, void *userdata)
{
    const struct insn_info *info = userdata;
    struct trace_record record = {0};

    (void)vcpu_index;
    g_mutex_lock(&lock);

    if (finished) {
        g_mutex_unlock(&lock);
        return;
    }
    if (info->pc == start_pc) {
        enabled = true;
        seen_start = true;
        /* RTL snapshots counters when the start-PC instruction retires. */
        g_mutex_unlock(&lock);
        return;
    }
    if (enabled && info->pc == end_pc) {
        finish_locked("reached end marker");
        g_mutex_unlock(&lock);
        if (stop_at_end) {
            exit(0);
        }
        return;
    }
    if (!enabled) {
        g_mutex_unlock(&lock);
        return;
    }

    sequence++;
    instruction_count++;
    record.kind = RECORD_INSN;
    record.size = info->size;
    record.sequence = sequence;
    record.pc = info->pc;
    record.value = info->raw;
    write_record_locked(&record);

    if (max_instructions && instruction_count >= max_instructions) {
        finish_locked("reached instruction limit before end marker");
        g_mutex_unlock(&lock);
        exit(2);
    }
    g_mutex_unlock(&lock);
}

static void memory_access(unsigned int vcpu_index, qemu_plugin_meminfo_t meminfo,
                          uint64_t vaddr, void *userdata)
{
    const struct insn_info *info = userdata;
    struct trace_record record = {0};
    unsigned int shift = qemu_plugin_mem_size_shift(meminfo);

    (void)vcpu_index;
    g_mutex_lock(&lock);
    if (!enabled || finished || info->pc == start_pc) {
        g_mutex_unlock(&lock);
        return;
    }

    memory_count++;
    record.kind = RECORD_MEM;
    record.size = shift < 8 ? (uint8_t)(1U << shift) : 0;
    record.flags = qemu_plugin_mem_is_store(meminfo) ? RECORD_MEM_STORE : 0;
    record.sequence = sequence;
    record.pc = info->pc;
    record.value = vaddr;
    write_record_locked(&record);
    g_mutex_unlock(&lock);
}

static uint64_t copy_instruction_bits(const void *data, size_t size)
{
    uint64_t raw = 0;

    if (size > sizeof(raw)) {
        size = sizeof(raw);
    }
    memcpy(&raw, data, size);
    return raw;
}

static void translate_tb(qemu_plugin_id_t id, struct qemu_plugin_tb *tb)
{
    size_t count = qemu_plugin_tb_n_insns(tb);

    (void)id;
    for (size_t i = 0; i < count; i++) {
        struct qemu_plugin_insn *insn = qemu_plugin_tb_get_insn(tb, i);
        struct insn_info *info = g_new0(struct insn_info, 1);
        size_t size = qemu_plugin_insn_size(insn);

        info->pc = qemu_plugin_insn_vaddr(insn);
        info->size = size <= UINT8_MAX ? (uint8_t)size : 0;
        info->raw = copy_instruction_bits(qemu_plugin_insn_data(insn), size);
        qemu_plugin_register_vcpu_insn_exec_cb(
            insn, instruction_exec, QEMU_PLUGIN_CB_NO_REGS, info);
        qemu_plugin_register_vcpu_mem_cb(
            insn, memory_access, QEMU_PLUGIN_CB_NO_REGS,
            QEMU_PLUGIN_MEM_RW, info);
    }
}

static void plugin_exit(qemu_plugin_id_t id, void *userdata)
{
    (void)id;
    (void)userdata;
    g_mutex_lock(&lock);
    if (!finished) {
        finish_locked(seen_start ? "guest exited before end marker"
                                 : "guest exited before start marker");
    }
    g_mutex_unlock(&lock);
}

static bool parse_u64(const char *arg, const char *prefix, uint64_t *value)
{
    char *end = NULL;

    if (!g_str_has_prefix(arg, prefix)) {
        return false;
    }
    *value = g_ascii_strtoull(arg + strlen(prefix), &end, 0);
    if (end == arg + strlen(prefix) || *end != '\0') {
        fprintf(stderr, "kernel_trace: invalid option '%s'\n", arg);
        exit(1);
    }
    return true;
}

QEMU_PLUGIN_EXPORT int qemu_plugin_install(qemu_plugin_id_t id,
                                           const qemu_info_t *info,
                                           int argc, char **argv)
{
    struct trace_header header = {
        .magic = {'K', 'T', 'R', 'A', 'C', 'E', '1', '\0'},
        .version = 1,
        .record_size = sizeof(struct trace_record),
    };

    (void)info;
    for (int i = 0; i < argc; i++) {
        if (parse_u64(argv[i], "start=", &start_pc) ||
            parse_u64(argv[i], "end=", &end_pc) ||
            parse_u64(argv[i], "max_instructions=", &max_instructions)) {
            continue;
        }
        if (g_str_has_prefix(argv[i], "outfile=")) {
            trace_path = argv[i] + strlen("outfile=");
            continue;
        }
        if (g_strcmp0(argv[i], "stop_at_end=0") == 0) {
            stop_at_end = false;
            continue;
        }
        fprintf(stderr, "kernel_trace: unknown option '%s'\n", argv[i]);
        return -1;
    }
    if (!trace_path || start_pc == end_pc) {
        fprintf(stderr,
                "kernel_trace: outfile, distinct start and end are required\n");
        return -1;
    }

    trace_file = fopen(trace_path, "wb");
    if (!trace_file) {
        perror("kernel_trace: fopen");
        return -1;
    }
    header.start_pc = start_pc;
    header.end_pc = end_pc;
    if (fwrite(&header, sizeof(header), 1, trace_file) != 1) {
        perror("kernel_trace: header fwrite");
        fclose(trace_file);
        trace_file = NULL;
        return -1;
    }

    qemu_plugin_register_vcpu_tb_trans_cb(id, translate_tb);
    qemu_plugin_register_atexit_cb(id, plugin_exit, NULL);
    return 0;
}
