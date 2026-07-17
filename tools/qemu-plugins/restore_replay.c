/* Validate a system-mode checkpoint replay against a user-mode ROI end state. */
#include <glib.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "qemu-plugin.h"

QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

struct tb_info {
    uint64_t pc;
    uint64_t insns;
};

static GArray *registers;
static struct qemu_plugin_register *privilege_register;
static const char *outfile = "restore_replay.regs";
static uint64_t start_pc;
static uint64_t target_insns;
static uint64_t replay_insns;
static bool active;
static bool finished;
static bool exit_after;

static bool parse_u64_arg(const char *arg, const char *prefix, uint64_t *value)
{
    char *endptr = NULL;

    if (!g_str_has_prefix(arg, prefix)) {
        return false;
    }
    *value = g_ascii_strtoull(arg + strlen(prefix), &endptr, 0);
    if (endptr == arg + strlen(prefix) || *endptr != '\0') {
        fprintf(stderr, "restore_replay: invalid %s\n", arg);
        exit(1);
    }
    return true;
}

static void print_hex_bytes(FILE *out, const GByteArray *buffer)
{
    fputs("0x", out);
    for (gint i = (gint)buffer->len - 1; i >= 0; i--) {
        fprintf(out, "%02x", buffer->data[i]);
    }
}

static uint64_t read_u64_register(struct qemu_plugin_register *handle)
{
    GByteArray *buffer = g_byte_array_new();
    uint64_t value = 0;
    int size = qemu_plugin_read_register(handle, buffer);

    if (size > 0) {
        size_t limit = buffer->len < sizeof(value) ? buffer->len : sizeof(value);
        for (size_t i = 0; i < limit; i++) {
            value |= (uint64_t)buffer->data[i] << (8 * i);
        }
    }
    g_byte_array_unref(buffer);
    return value;
}

static void dump_state(unsigned int vcpu_index, const struct tb_info *tb,
                       const char *status)
{
    FILE *out = fopen(outfile, "w");
    GByteArray *buffer;

    if (!out) {
        perror("restore_replay: fopen");
        exit(1);
    }
    fprintf(out, "vcpu %u\n", vcpu_index);
    fputs("checkpoint 0\n", out);
    fprintf(out, "target_insns %" PRIu64 "\n", target_insns);
    fprintf(out, "observed_insns %" PRIu64 "\n", replay_insns);
    fprintf(out, "boundary_error_insns %" PRIu64 "\n",
            replay_insns >= target_insns ? replay_insns - target_insns
                                          : target_insns - replay_insns);
    fprintf(out, "tb_pc 0x%" PRIx64 "\n", tb->pc);
    fprintf(out, "tb_insns %" PRIu64 "\n", tb->insns);
    fprintf(out, "replay_status %s\n", status);

    buffer = g_byte_array_new();
    for (guint i = 0; registers && i < registers->len; i++) {
        qemu_plugin_reg_descriptor reg =
            g_array_index(registers, qemu_plugin_reg_descriptor, i);
        int size;

        g_byte_array_set_size(buffer, 0);
        size = qemu_plugin_read_register(reg.handle, buffer);
        if (size < 0) {
            continue;
        }
        fprintf(out, "reg %s size %d value ", reg.name, size);
        print_hex_bytes(out, buffer);
        fputc('\n', out);
    }
    g_byte_array_unref(buffer);
    fputs("end_checkpoint\n", out);
    fclose(out);
    finished = true;
}

static void vcpu_init(qemu_plugin_id_t id, unsigned int vcpu_index)
{
    (void)id;
    (void)vcpu_index;
    registers = qemu_plugin_get_registers();
    for (guint i = 0; registers && i < registers->len; i++) {
        qemu_plugin_reg_descriptor reg =
            g_array_index(registers, qemu_plugin_reg_descriptor, i);
        if (g_strcmp0(reg.name, "priv") == 0) {
            privilege_register = reg.handle;
            break;
        }
    }
}

static void vcpu_tb_exec(unsigned int vcpu_index, void *userdata)
{
    const struct tb_info *tb = userdata;

    if (finished) {
        return;
    }
    if (!active) {
        if (tb->pc != start_pc) {
            return;
        }
        active = true;
    }
    if (privilege_register && read_u64_register(privilege_register) != 0) {
        dump_state(vcpu_index, tb, "left_user_mode");
    } else if (replay_insns >= target_insns) {
        dump_state(vcpu_index, tb, "ok");
    } else {
        replay_insns += tb->insns;
        return;
    }
    if (exit_after) {
        exit(0);
    }
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
    if (registers) {
        g_array_free(registers, true);
        registers = NULL;
    }
}

QEMU_PLUGIN_EXPORT int qemu_plugin_install(qemu_plugin_id_t id,
                                           const qemu_info_t *info,
                                           int argc, char **argv)
{
    (void)info;
    for (int i = 0; i < argc; i++) {
        if (parse_u64_arg(argv[i], "start_pc=", &start_pc) ||
            parse_u64_arg(argv[i], "instructions=", &target_insns)) {
            continue;
        }
        if (g_str_has_prefix(argv[i], "outfile=")) {
            outfile = argv[i] + strlen("outfile=");
            continue;
        }
        if (g_strcmp0(argv[i], "exit_after=1") == 0) {
            exit_after = true;
            continue;
        }
        fprintf(stderr, "restore_replay: unknown option '%s'\n", argv[i]);
        return -1;
    }
    if (!start_pc || !target_insns) {
        fprintf(stderr, "restore_replay: start_pc and instructions are required\n");
        return -1;
    }
    qemu_plugin_register_vcpu_init_cb(id, vcpu_init);
    qemu_plugin_register_vcpu_tb_trans_cb(id, vcpu_tb_trans);
    qemu_plugin_register_atexit_cb(id, plugin_exit, NULL);
    return 0;
}
