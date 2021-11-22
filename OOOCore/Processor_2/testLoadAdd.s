.text
addi $r1, $r1, 100
addi $r2, $r2, 2
sw $r1, 10($r2)
lw $r3, 10($r2)
add $r4, $r3, $r2