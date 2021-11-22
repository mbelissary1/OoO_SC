.text
addi $r1, $r1, 65535
addi $r2, $r2, 65535
mul $r3, $r1, $r2
bex exceptionDetected:
addi $r5, $r5, 1
exceptionDetected:
	addi $r6, $r6, 1 
	j done
addi $r7, $r7, 1
done:
	addi $r8, $r8, 1