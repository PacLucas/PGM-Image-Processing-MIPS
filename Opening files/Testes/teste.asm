.data
.align 4
name: 	.space 10
string1:	.asciiz "Nome arquivo: "
.text

li $v0, 4
la $a0, string1
syscall

li $v0, 8
la $a0, name
li $a1, 10
syscall

li $v0, 4
la $a0, name
syscall


loop:


exit:
li $v0, 10
syscall
