.text
addi $r1, $r1, 1
add $r2, $r1, $r1
bne $r1, $r2, nE
addi $r3, $r3, 3
addi $r4, $r4, 4
nE:
	addi $r5, $r5, 5
	blt $r2, $r5, lT
	addi $r6, $r6, 6
addi $r7, $r7, 7
addi $r8, $r8, 8
lT:
	addi $r9, $r9, 9
	j done
addi $r10, $r10, 10
done:
	addi $r11, $r11, 11