.data
fout:		.asciiz "output.txt"
buffer:	.asciiz "Alo som, 1 2 3 testando som!"
.text


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


# Abrindo arquivo que nao existe para escrita
li $v0,  13		# syscall para abrir arquivo
la $a0, fout		# nome novo arquivo
li $a1, 1		# abrindo p/ escrita   -> 1: escrita   0: leitura
li $a2, 0		# mode is ignored  (???)
syscall
move $s6, $v0	# salva o arquivo em $s6


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


# Escrevendo no arquivo aberto
li $v0, 15		# syscall para escrita no arquivo
move $a0, $s6	# movendo arquivo p/  $a0
la $a1, buffer	# o que vai ser escrito
li $a2, 28		# tamanho do buffer
syscall


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


# Fechar arquivo
li $v0, 16		#syscall para fechar arquivo
move $a0, $s6	# arquivo que vai fechar
syscall		


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
