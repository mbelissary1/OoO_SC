.text

###
##
#       ECE350 Fall 2020: Sample MIPS file
#       Note: the code doesn't test any kind of functionality; it serves to
#             illustrate the syntax of instructions supported
##
###


add     $r0, $r1, $r2
addi    $r2, $r3, 100
sub     $r4, $r5, $r6
and     $r7, $r8, $r9
or      $r10, $r11, $r12
sll     $r11, $r12, 5
sra     $r10, $r11, 6
mul     $r1, $r2, $r3
div     $r4, $r5, $r6
sw      $r7, 10($r8)
lw      $r9, 5($r10)
j       100
bne     $r0, $r1, here
j       there

here:
    jal     overthere

there:
    bex     overthere
    setx    15
    jr      $r31

overthere:
    blt     $r0, $r1, -1
