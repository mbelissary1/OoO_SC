#!/usr/bin/env python3

import random
import sys

# Create a dict of the insns to latencies
insn_dict = {
    "'add" : 1,
    "'sub" : 1,
    "'and" : 1,
    "'or" : 1,
    "'sll" : 1,
    "'sra" : 1,
    "'addi" : 1,
    "'mul" : 16,
    "'div" : 32,
    "'sw" : 1,
    "'lw" : 8,
    "'bex" : 1,
    "'setx" : 1,
}

cycles_to_complete = 0

# Read the file in
asm_file = open(sys.argv[1])
asm_file = asm_file.readlines()
split_asm_file = str(asm_file).split("\\n")

# Iterate over the file, splitting each insn and extracting the opcode
opcode = []
for i in split_asm_file:
    if ".text" in str(i) or ":" in str(i):
        continue
    split_insn = str(i).split(" ")
    opcode.append(split_insn[1])


# Increment total instruction count and total latency
i = 0
while i < len(opcode):
    cur_opcode = opcode[i]
    if cur_opcode == "'bne" or cur_opcode == "'blt":
        cur_asm_line = split_asm_file[i + 1].split(" ")
        target = cur_asm_line[4]
        if not random.choice(range(0, 100)) < 95:
            cycles_to_complete += 15
            print("Branch mispredict! Penalizing 15 cycles!")
            i = max(0, i - 3)
        else:
            if random.choice(range(0, 100)) < 60: # If the branch is taken (60% was chosen arbitrarily...)
                cycles_to_complete += 1
                cur_asm_line = split_asm_file[i + 1].split(" ")
                target = cur_asm_line[4]
                i = int(target) - 1
                print("Branch taken! Branching to index " + str(i))
            else: # If the branch is *NOT* taken (40% because, well, math...)
                print("Branch not taken!")
                cycles_to_complete += 1
                i += 1
    elif "j" in cur_opcode: # j, jal, jr...
        cycles_to_complete += 2
        cur_asm_line = split_asm_file[i + 1].split(" ")
        target = cur_asm_line[2]
        i = int(target) - 1
    else: 
        cycles_to_complete += insn_dict[cur_opcode]
        i += 1
print("Cycles to complete execution: " + str(cycles_to_complete))