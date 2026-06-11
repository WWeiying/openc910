#!/usr/bin/env python3
import subprocess
import sys
import re

def get_symbol_addresses(elf_file):
    cmd = ['riscv64-unknown-elf-objdump', '-t', elf_file]
    try:
        output = subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        print(f"Error executing objdump: {e.output}")
        sys.exit(1)
    
    symbols = {}
    for line in output.splitlines():
        line = line.strip()
        match = re.match(
            r'^([0-9a-fA-F]+)\s+(\S)(?:\s+(\S+))?\s+(\S+)\s+(\S+)\s+(\S+)$',
            line
        )
        if not match:
            continue
        
        addr_str, binding, visibility, section, size, sym_name = match.groups()
        
        if binding == 'g' and section == '.text' and sym_name in ['main', '__exit', 'perf_monitor_start', 'perf_monitor_end']:
            addr = int(addr_str, 16)
            addr_40 = addr & 0xFFFFFFFFFF
            symbols[sym_name] = f'40\'h{addr_40:08x}'
    
    return symbols

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <ELF_FILE>")
        sys.exit(1)
    
    elf_file = sys.argv[1]
    symbols = get_symbol_addresses(elf_file)
    
    required = ['main', '__exit', 'perf_monitor_start', 'perf_monitor_end'] 
    missing = [sym for sym in required if sym not in symbols]
    if missing:
        print(f"Warning: Symbols not found - {', '.join(missing)}")
    
    addr_map = {
        'main':                symbols.get('main',                "40'h0000000000"),
        '__exit':              symbols.get('__exit',              "40'h0000000000"),
        'perf_monitor_start':  symbols.get('perf_monitor_start',  "40'h0000000000"),
        'perf_monitor_end':    symbols.get('perf_monitor_end',    "40'h0000000000"),
    }

    with open('symbols.svh', 'w') as f:
        for sym, val in addr_map.items():
            f.write(f'`define {sym}_ADDR {val}\n')

    # plusargs format for runtime passing to simv (decouples RTL compile from program addresses)
    def to_hex(verilog_val):
        return verilog_val.split("'h")[1].lstrip('0') or '0'

    with open('symbols.args', 'w') as f:
        f.write(f'+sym_main={to_hex(addr_map["main"])}\n')
        f.write(f'+sym_exit={to_hex(addr_map["__exit"])}\n')
        f.write(f'+sym_perf_start={to_hex(addr_map["perf_monitor_start"])}\n')
        f.write(f'+sym_perf_end={to_hex(addr_map["perf_monitor_end"])}\n')

if __name__ == '__main__':
    main()
