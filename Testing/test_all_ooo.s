.text
addi $r1, $r1, 10
addi $r2, $r2, 10
mul $r3, $r1, $r2
mul $r4, $r3, $r3
addi $r5, $r5, 1000
addi $r6, $r6, 90
sub $r7, $r4, $r5
div $r8, $r7, $r6
bne $r8, $r3, 11
blt $r1, $r5, 13
addi $r9, $r9, 999
j 35
addi $r10, $r10, 65535
mul $r11, $r10, $r10
bex 17
addi $r12, $r12, 12
addi $r13, $r13, 13
lw $r14, 13($r13)
sw $r3, 13($r13)
sub $r24, $r14, $r2
addi $r15, $r15, 15
mul $r18, $r15, $r1
addi $r16, $r15, 1
sll $r17, $r16, 2
jal 28
sub $r1, $r1, $r21
sub $r2, $r2, $r21
j 34
addi $r19, $r19, 20
add $r20, $r19, $r19
addi $r21, $r21, 8
sub $r22, $r20, $r21
sra $r24, $r22, 2
addi $r5, $r0, 5
addi $r23, $r23, 100