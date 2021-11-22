#!/usr/bin/env python3

import sys

# Read the file in
asm_file = open(sys.argv[1])
asm_file = asm_file.readlines()
split_asm_file = str(asm_file).split("\\n")

# Iterate over the file, splitting each insn and extracting the opcode
i = 0
while i < len(split_asm_file):
    if ".text" in str(split_asm_file[i]) or ":" in str(split_asm_file[i]):
        continue
    split_insn = str(split_asm_file[i]).split(" ")
    if "mul" in split_insn[1] or "div" in split_insn[1] or "lw" in split_insn[1]:
        new_line_number = i
        while new_line_number > 0:
            if "j" in split_asm_file[new_line_number]: # If jumps only go forwards, then we don't need to worry about changing target values
                continue
