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
#              bex  setx    jr


# 20% branches; 15% for jumps; 35% for alu; 2% for exceptions; 15% lw and 8% sw?

while i < insn_num:
    insnToAdd = ""
    insnType = np.random.choice(All_Insn, p=insn_probs)
    if insnType in R_Type or insnType in I_Type or insnType in JII_Type:
        insnToAdd = insnType + " $r" + str(random.choice(range(0, 32))) + ","
        if insnType in R_Type or insnType in I_Type and insnType not in MEM_Type:
            insnToAdd = insnToAdd + " $r" + str(random.choice(range(0, 32))) + ","
            if insnType in R_Type:
                insnToAdd = insnToAdd + " $r" + str(random.choice(range(0, 32)))
            elif insnType in Branch_Type:
                insnToAdd = insnToAdd + " " + str(random.choice(range(insn_num+1)))
            else:
                insnToAdd = insnToAdd + " " + str(random.choice(range(0, 1000000)))
        elif insnType in MEM_Type:
            insnToAdd = insnToAdd + " " + str(random.choice(range(0, 1000000))) + "($r" + str(random.choice(range(0, 32))) + ")"
    if insnType in JI_Type:
        if insnType == "setx":
            insnToAdd = insnType + " " + str(random.choice(range(0, 100)))
        else:
            insnToAdd = insnType + " " + str(random.choice(range(i+1, insn_num+1)))
    insn_list.append(insnToAdd)
    i += 1

f = open("ProcTest_" + str(insn_num) + "_insns.s", "w")
f.write(".text\n")
for insn in insn_list:
    f.write(insn)
    f.write("\n")
f.close()
