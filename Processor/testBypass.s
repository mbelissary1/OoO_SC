.text
addi $r1, $r1, 1
add $r2, $r1, $r1
add $r3, $r1, $r2
sub $r4, $r3, $r1
addi $r5, $r5, 5
sw $r5, 10($r2)
lw $r6, 10($r2)
addi $r7, $r7, 7
addi $r9, $r9, 9
sw $r7, 10($r9)
lw $r8, 10($r9)