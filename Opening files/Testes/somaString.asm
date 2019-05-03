
.data 
.align 4
	vetorInt:	.space 20 # Espaço para um vetor de 5 posições (4 * 5 = 20 Bytes)
	string0: 	.asciiz "Vetor com 5 posições \n"
	string1:	.asciiz "Digite um valor para a posição "
	string2: 	.asciiz ": "
.text
	
	li $v0, 4
	la $a0, string0
	syscall
	
	addi $t0, $zero, 5		# Total de posições do vetor
	add $t6, $zero, $zero		# Contador posição vetor
	la $t1, vetorInt		# Carrega o vetor no END base $t1
	add $t2, $zero, $zero		# Contador loopPreenche
	
	loopPreenche:
		beq $t0, $t2, somaVetor
		li $v0, 4
		la $a0, string1
		syscall
		
		li $v0, 1
		move $a0, $t6
		syscall
		
		li $v0, 4
		la $a0, string2
		syscall
		
		li $v0, 5
		syscall
		move $t3, $v0
		
		sw $t3, 0($t1)
		addi $t1, $t1, 4
		addi $t2, $t2, 1
		addi $t6, $t6, 1
		j loopPreenche
		
	somaVetor:
		la $t4, vetorInt
		add $t7, $zero, $zero
		add $t5, $zero, $zero
			
		loopSoma:
			beq $t0, $t5, imprimeSoma
			lw $s0, 0($t4)
			add $t7, $t7, $s0
			addi $t4, $t4, 4
			addi $t5, $t5, 1
			j loopSoma
	
	imprimeSoma:
		li $v0, 1
		move $a0, $t7
		syscall
		j exit
		
	exit:
		li $v0, 10
		syscall   
	
	
