#!/usr/bin/env python3

import random
import numpy as np

# Initialize lists to hold the different kind of instructions
R_Type = ["add", "sub", "and", "or", "sll", "sra"]
I_Type = ["addi", "sw", "lw", "blt", "bne"]
MEM_Type = ["sw", "lw"]
Branch_Type = ["blt", "bne"]
JI_Type = ["j", "jal", "bex", "setx"]
JII_Type = ["jr"]
All_Insn = ["add", "sub", "and", "or", "sll", "sra", "addi", "sw", "lw", "blt", "bne", "j", "jal", "bex", "setx", "jr"]

# Initalize variables for number of instructions and list of full instructions
insn_num = 100
i = 0
insn_list = []
#              add      sub      and     or     sll     sra    addi    sw    lw   blt  bne     j     jal
insn_probs = [0.0499, 0.0499, 0.0499, 0.0499, 0.0499, 0.0499, 0.0499, 0.08, 0.15, 0.1, 0.1, 0.0667, 0.067,
              0.01, 0.01, 0.067]
#              bex  setx   jr


while i < insn_num:
    insnToAdd = ""

    # Chose an instruction with the probabilities above
    insnType = np.random.choice(All_Insn, p=insn_probs)

    # Set the string to have the instruction name and the $rd register if present
    if insnType in R_Type or insnType in I_Type or insnType in JII_Type:
        insnToAdd = insnType + " $r" + str(random.choice(range(0, 32))) + ","

        # Set the string to have also have the $rs register if not an lw or sw
        if insnType in R_Type or insnType in I_Type and insnType not in MEM_Type:
            insnToAdd = insnToAdd + " $r" + str(random.choice(range(0, 32))) + ","

            # Set the string have have an $rt register if an R Type
            if insnType in R_Type:
                insnToAdd = insnToAdd + " $r" + str(random.choice(range(0, 32)))

            # Set the string to have the branching target
            elif insnType in Branch_Type:
                insnToAdd = insnToAdd + " " + str(random.choice(range(insn_num+1)))

            # Set the string to have the the immediate for addi's
            else:
                insnToAdd = insnToAdd + " " + str(random.choice(range(0, 1000000)))

        # Format the string to have the "INSN $rd IMM($rs)" format
        elif insnType in MEM_Type:
            insnToAdd = insnToAdd + " " + str(random.choice(range(0, 1000000))) + "($r" + str(random.choice(range(0, 32))) + ")"

    if insnType in JI_Type:
        # Set string to have setx formating
        if insnType == "setx":
            insnToAdd = insnType + " " + str(random.choice(range(0, 100)))

        #Set string to have downward jumps and bex's w/ proper formating
        else:
            insnToAdd = insnType + " " + str(random.choice(range(i+1, insn_num+1)))
    insn_list.append(insnToAdd)
    i += 1

# Create a file and write each instruction to it on a newline
f = open("ProcTest_" + str(insn_num) + "_insns.s", "w")
f.write(".text\n")
for insn in insn_list:
    f.write(insn)
    f.write("\n")
f.close()
