#!/usr/bin/env python3
import re
import sys
import argparse

def parse_disassembly(disasm_file):
    instr_dict = {}
    with open(disasm_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            match = re.match(
                r'^\s*([0-9a-fA-F]+):\s+([0-9a-fA-F]{2,8})\s+(\S.*?)(\s*#|$)', 
                line
            )
            if match:
                raw_addr = match.group(1).lstrip('0') or '0'
                addr = int(raw_addr, 16)
                encoding = match.group(2).zfill(8)
                full_instr = match.group(3).strip()
                instr_dict[addr] = (encoding, full_instr)
    return instr_dict

def process_trace(trace_file, disasm_dict, output_file):
    with open(trace_file, 'r') as fin, open(output_file, 'w') as fout:
        for line_num, line in enumerate(fin, 1):
            line = line.strip()
            if not line:
                continue
            
            if ':' not in line:
#                print(f"Line {line_num} format error: {line}")
                continue
                
            prefix_part, pc_part = line.split(':', 1)
            pc_hex = pc_part.strip()
            
            try:
                pc_value = int(pc_hex, 16)
                encoding, full_instr = disasm_dict.get(pc_value, ('??????????', 'unknown'))
                output_line = f"{prefix_part.strip():<20}:{pc_hex}    {encoding}    {full_instr}\n"
                fout.write(output_line)
            except ValueError:
                print(f"Line {line_num} invalid PC: {pc_hex}")

def main():
    parser = argparse.ArgumentParser(description='Enhanced instruction trace logger')
    parser.add_argument('pc_trace_log', help='Input trace log file')
    parser.add_argument('disasm_file', help='Disassembly file')
    parser.add_argument('-o', '--output', default='dyn_inst_trace.log', help='Output file')
    
    args = parser.parse_args()

    try:
#        print("Parsing disassembly file...")
        disasm_data = parse_disassembly(args.disasm_file)
#        print(f"Loaded instructions: {len(disasm_data)}")
        
#        print("Generating enhanced log...")
        process_trace(args.pc_trace_log, disasm_data, args.output)
        
#        print(f"Successfully generated: {args.output}")
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
