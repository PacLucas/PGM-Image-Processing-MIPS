.data
string1:	.asciiz "Nome padrao dos arquivos: "
string2:	.asciiz "Quantidade de arquivos: "
name:		.space 10
space:	.space 1
end:
.text
# $t0 - Total Arquivos
# $t6 - Count Arquivos
# $t1 - Nome Aruivos
# $t2 - Count Loop

li $v0, 4
la $a0, string1
syscall

li $v0, 8
la $a0, name
li $a1, 10
syscall
