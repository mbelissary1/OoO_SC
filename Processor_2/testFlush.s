.text
addi $r1, $r1, 1
j branch
add $r2, $r1, $r1
branch:
	jal b
	addi $r3, $r3, 3
	j done
addi $r3, $r3, 4
b:
	bne $r1, $r2, blah
	addi $r5, $r5, 5
addi $r6, $r6, 6
blah:
	addi $r7, $r7, 7
	jr $r31
done: 
	addi $r8, $r8, 8
