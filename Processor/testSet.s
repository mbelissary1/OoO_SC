.text
bex branchException
setx 15
bex branchException
j done
branchException:
	addi $r1, $r1, 1
	j done
addi $r2, $r2, 1
done:
	addi $r3, $r3, 1