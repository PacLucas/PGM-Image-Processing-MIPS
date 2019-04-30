.data
finput:	.asciiz "read.pgm"
foutput:	.asciiz "write.pgm"
space:	.space 3
end:
.text

OpenRead:
	# Abrindo arquivo para leitura 
	li $v0, 13
	la $a0, finput
	li $a1, 0	
	li $a2, 0
	syscall
	move $s6, $v0

ReadFile:
	# Lendo o arquivo
	li $v0, 14	
	move $a0, $s6
	la $a1, space
	li $a2, 1
	syscall

CloseFile:
# Fechar arquivo
li $v0, 16		#syscall para fechar arquivo
move $a0, $s6	# arquivo que vai fechar
syscall

OpenWrite:
# Abrindo arquivo para escrita 
li $v0, 13
la $a0, foutput
li $a1, 1
li $a2, 0
syscall
move $s6, $v0

WriteFile:
li $v0, 15		# syscall para escrita no arquivo
move $a0, $s6	# movendo arquivo p/  $a0
la $a1, space	# o que vai ser escrito
li $a2, 1		# tamanho do buffer
syscall
