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
i = 0 # Increment from 1 to avoid hitting zero
while i < len(opcode) - 1:
    
    # Screen for dependencies
    first_insn = opcode[i]
    second_insn = opcode[i + 1]
    first_insn_split = split_asm_file[i + 1].split(" ")
    second_insn_split = split_asm_file[i + 2].split(" ")
    flush = False
    first_insn_dest_reg = first_insn_split[2]

    if len(second_insn_split) >= 4:
        flush = (second_insn_split[3] in first_insn_dest_reg) # If the second instruction's first source reg is the dest reg
    if not flush and len(second_insn_split) >= 5:
        flush = (second_insn_split[4] in first_insn_dest_reg) # If the second instruction's second source reg is the dest reg
    
    if flush:
        print("Data dependency, must flush out stage 2")

    # Path 1
    first_latency = 0
    if first_insn == "'bne" or first_insn == "'blt":
        target = first_insn_split[4]
        if not random.choice(range(0, 100)) < 95:
            first_latency = 15
            print("Branch mispredict! Flushing and penalizing 15 cycles!")
            i = max(0, i - 3)
            flush = True
        else:
            if random.choice(range(0, 100)) < 60: # If the branch is taken (60% was chosen arbitrarily...)
                first_latency = 1
                target = first_insn_split[4]
                i = int(target) - 1
                print("Branch taken! FLushing and branching to index " + str(i))
                flush = True
            else: # If the branch is *NOT* taken (40% because, well, math...)
                print("Branch not taken! No need to flush!")
                first_latency = 1
                i += 1
    elif "j" in first_insn: # j, jal, jr...
        first_latency = 2
        target = first_insn_split[2]
        i = int(target) - 1
        flush = True
    else: 
        first_latency = insn_dict[first_insn]
        i += 1

    # Path 2
    second_latency = 0
    if not flush:
        if second_insn == "'bne" or second_insn == "'blt":
            target = second_insn_split[4]
            if not random.choice(range(0, 100)) < 95:
                second_latency = 15
                print("Branch mispredict! Penalizing 15 cycles!")
                i = max(0, i - 3)
            else:
                if random.choice(range(0, 100)) < 60: # If the branch is taken (60% was chosen arbitrarily...)
                    second_latency = 1
                    target = second_insn_split[4]
                    i = int(target) - 1
                    print("Branch taken! Branching to index " + str(i))
                else: # If the branch is *NOT* taken (40% because, well, math...)
                    print("Branch not taken!")
                    second_latency = 1
                    i += 1
        elif "j" in second_insn: # j, jal, jr...
            second_latency = 2
            target = second_insn_split[2]
            i = int(target) - 1
        else: 
            second_latency = insn_dict[second_insn]
            i += 1
    else:
        print("FLUSHING!")

    cycles_to_complete += max(first_latency, second_latency)

print("Cycles to complete execution: " + str(cycles_to_complete))