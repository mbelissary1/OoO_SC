.text
addi $r1, $r1, 10
jal jump1:
addi $r2, $r2, 10
jump1:
	addi $r3, $r3, 10
	jal jump2
	addi $r4, $r4, 10
	j done
jump2:
	addi $r5, $r5, 10
	jr $r31
done:
addi $r6, $r6, 5