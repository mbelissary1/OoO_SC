.text
addi $r1, $r1, 1
addi $r2, $r2, 1
sll $r3, $r2, 30
add $r4, $r3, $r3
bex exceptionDetected:
addi $r5, $r5, 1
exceptionDetected:
	addi $r6, $r6, 1 
	j done
addi $r7, $r7, 1
done:
	addi $r8, $r8, 1