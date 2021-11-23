.text
addi $r1, $r1, 50
addi $r2, $r2, 5
div $r8, $r1, $r2
lw $r6, 10($r17)
addi $r21, $r21, 8
sub $r25, $r20, $r21
sra $r24, $r1, 2
addi $r5, $r5, 1000
addi $r6, $r6, 90
bne $r1, $r2, 18
addi $r5, $r5, 5
sub $r7, $r4, $r5
mul $r3, $r1, $r2
addi $r5, $r5, 1000
addi $r6, $r6, 90
addi $r21, $r21, 8
sub $r22, $r20, $r21
sra $r24, $r22, 2       # BNE taken
sub $r7, $r4, $r5
addi $r21, $r21, 8
sub $r22, $r20, $r21
sra $r24, $r22, 2
lw $r3, 10($r8)
mul $r3, $r1, $r2
lw $r12, 10($r1)
lw $r17, 10($r2)
mul $r30, $r12, $r22
addi $r5, $r5, 1000
blt $r1, $r2, 32
addi $r5, $r5, 5
addi $r6, $r6, 90
sub $r7, $r4, $r5        # BLT taken
mul $r13, $r11, $r22
mul $r4, $r8, $r23