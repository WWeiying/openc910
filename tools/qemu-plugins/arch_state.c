/* Capture C910 architectural state when the smart_run PASS/FAIL magic appears. */
#include <glib.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "qemu-plugin.h"

QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

struct insn_info {
    uint64_t pc;
};

static GMutex lock;
static GArray *registers;
static struct qemu_plugin_register *gp_register;
static const char *outfile;
static uint64_t pass_magic = UINT64_C(0x444333222);
static uint64_t fail_magic = UINT64_C(0x2382348720);
static uint64_t executed_instructions;
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
        fprintf(stderr, "arch_state: invalid %s\n", arg);
        exit(1);
    }
    return true;
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

static void print_hex_bytes(FILE *stream, const GByteArray *buffer)
{
    fputs("0x", stream);
    for (gint index = (gint)buffer->len - 1; index >= 0; index--) {
        fprintf(stream, "%02x", buffer->data[index]);
    }
}

static void print_json_string(FILE *stream, const char *value)
{
    fputc('"', stream);
    for (const unsigned char *cursor = (const unsigned char *)value;
         *cursor; cursor++) {
        if (*cursor == '"' || *cursor == '\\') {
            fputc('\\', stream);
        }
        fputc(*cursor, stream);
    }
    fputc('"', stream);
}

static void dump_state(unsigned int vcpu_index, const struct insn_info *insn,
                       const char *status)
{
    FILE *stream = fopen(outfile, "w");
    GByteArray *buffer;
    bool first = true;

    if (!stream) {
        perror("arch_state: fopen");
        exit(1);
    }
    fprintf(stream,
            "{\n  \"format\": \"openc910-qemu-arch-state-v1\",\n"
            "  \"status\": \"%s\",\n  \"vcpu\": %u,\n"
            "  \"terminal_pc\": \"0x%" PRIx64 "\",\n"
            "  \"executed_instructions\": %" PRIu64 ",\n"
            "  \"registers\": {\n",
            status, vcpu_index, insn->pc, executed_instructions);

    buffer = g_byte_array_new();
    for (guint index = 0; registers && index < registers->len; index++) {
        qemu_plugin_reg_descriptor descriptor =
            g_array_index(registers, qemu_plugin_reg_descriptor, index);
        int size;

        g_byte_array_set_size(buffer, 0);
        size = qemu_plugin_read_register(descriptor.handle, buffer);
        if (size < 0) {
            continue;
        }
        fprintf(stream, "%s    ", first ? "" : ",\n");
        print_json_string(stream, descriptor.name);
        fputs(": \"", stream);
        print_hex_bytes(stream, buffer);
        fputc('"', stream);
        first = false;
    }
    g_byte_array_unref(buffer);
    fputs("\n  }\n}\n", stream);
    fclose(stream);
}

static void vcpu_init(qemu_plugin_id_t id, unsigned int vcpu_index)
{
    (void)id;
    (void)vcpu_index;
    registers = qemu_plugin_get_registers();
    for (guint index = 0; registers && index < registers->len; index++) {
        qemu_plugin_reg_descriptor descriptor =
            g_array_index(registers, qemu_plugin_reg_descriptor, index);

        if (g_strcmp0(descriptor.name, "gp") == 0) {
            gp_register = descriptor.handle;
            break;
        }
    }
}

static void vcpu_insn_exec(unsigned int vcpu_index, void *userdata)
{
    const struct insn_info *insn = userdata;
    uint64_t gp;
    int exit_status = 0;

    g_mutex_lock(&lock);
    if (finished) {
        g_mutex_unlock(&lock);
        return;
    }
    gp = gp_register ? read_u64_register(gp_register) : 0;
    if (gp == pass_magic || gp == fail_magic) {
        const char *status = gp == pass_magic ? "PASS" : "FAIL";

        dump_state(vcpu_index, insn, status);
        finished = true;
        exit_status = gp == pass_magic ? 0 : 1;
    } else {
        executed_instructions++;
    }
    g_mutex_unlock(&lock);
    if (finished && exit_after) {
        exit(exit_status);
    }
}

static void vcpu_tb_trans(qemu_plugin_id_t id, struct qemu_plugin_tb *tb)
{
    (void)id;
    for (size_t index = 0; index < qemu_plugin_tb_n_insns(tb); index++) {
        struct qemu_plugin_insn *insn = qemu_plugin_tb_get_insn(tb, index);
        struct insn_info *info = g_new0(struct insn_info, 1);

        info->pc = qemu_plugin_insn_vaddr(insn);
        qemu_plugin_register_vcpu_insn_exec_cb(
            insn, vcpu_insn_exec, QEMU_PLUGIN_CB_R_REGS, info);
    }
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
    for (int index = 0; index < argc; index++) {
        if (parse_u64_arg(argv[index], "pass_magic=", &pass_magic) ||
            parse_u64_arg(argv[index], "fail_magic=", &fail_magic)) {
            continue;
        }
        if (g_str_has_prefix(argv[index], "outfile=")) {
            outfile = argv[index] + strlen("outfile=");
            continue;
        }
        if (g_strcmp0(argv[index], "exit_after=1") == 0) {
            exit_after = true;
            continue;
        }
        fprintf(stderr, "arch_state: unknown option '%s'\n", argv[index]);
        return -1;
    }
    if (!outfile) {
        fprintf(stderr, "arch_state: outfile is required\n");
        return -1;
    }
    g_mutex_init(&lock);
    qemu_plugin_register_vcpu_init_cb(id, vcpu_init);
    qemu_plugin_register_vcpu_tb_trans_cb(id, vcpu_tb_trans);
    qemu_plugin_register_atexit_cb(id, plugin_exit, NULL);
    return 0;
}
