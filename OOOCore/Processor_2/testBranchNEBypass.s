.text
addi $r2, $r2, 10
addi $r3, $r3, 5
addi $r1, $r1, 10
bne $r1, $r2, branchTaken
sub $r4, $r1, $r3
j done
branchTaken:
addi $r5, $r5, 5
done:
addi $r6, $r6, 5