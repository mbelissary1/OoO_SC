.text
addi $r1, $r0, 3
addi $r2, $r0, 4
add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0
bne $r1, $r2, NotEqual
addi $r3, $r0, 1
add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0

NotEqual:
	addi $r4, $r0, 4
	addi $r5, $r0, 4

add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0
blt $r1, $r3, LessThan
addi $r6, $r0, 6
bne $r4, $r1, NotEqual2

LessThan:
	addi $r7, $r0, 7
	addi $r8, $r0, 8
	addi $r9, $r0, 9
	add $r0, $r0, $r0
	j done

NotEqual2:
	addi $r10, $r0, 10
	addi $r11, $r0, 11
	addi $r12, $r0, 12

done:
	add $r0, $r0, $r0

add $r0, $r0, $r0
add $r0, $r0, $r0
add $r0, $r0, $r0