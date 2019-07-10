 .data
	msg1: 		.asciiz "Quantas imagens deseja inserir\n"
	msg2: 		.asciiz "Qual é diretorio das imagens finalizado com barra invertida \n"
	msg3: 		.asciiz "Qual formato da imagem\n0-pgm\n1-ppm\n"
	imagem: 	.asciiz "\imagem"
	ppm: 		.asciiz ".ppm"
	pgm: 		.asciiz ".pgm"
	barran:		.asciiz "\n"
	espaço:		.asciiz " "
	comentario:	.asciiz "#"
	assinatura:	.asciiz "#Created by Guilherme Ortiz Santos"
	buffer:		.space 1024
	diretorio:	.space 300
	arq:		.space 300
	dir:		.word 1
.text

  ##############################################################
  # salvando futuras condições 
  lb $s7, barran 	# s7 contem \n
  addi $s5, $zero, 100  # s5 contem 100
  addi $s4, $zero, 10 	# s4 contem 10
  ###############################################################
  # gerar a primeira mensagem (msg1)
  li   $v0, 4       
  la   $a0, msg1           
  syscall
  ###############################################################
  # salvar em s6 quantidade de imagens
  li   $v0, 5       
  syscall
  move $s6, $v0    
   ###############################################################
  # gerar a segunda mensagem (msg2)
  li   $v0, 4       
  la   $a0, msg2          
  syscall
  ###############################################################
  # salvar em diretorio, o diretorio do arquivo
  li   $v0, 8       
  la   $a0, diretorio
  la   $a1, 300 
  syscall
  ###############################################################
   # gerar a terceira mensagem (msg3)
  li   $v0, 4       
  la   $a0, msg3           
  syscall
  ###############################################################
  # salvar em s5 fomrato
  li   $v0, 5       
  syscall
  move $s5, $v0
  ###############################################################
  addi $t3, $zero, 0 # bytes que serao usados para salvar em vetor
  addi $t6, $zero, 0  # contador
  addi $t1, $zero, 0 
  addi $t2, $zero, 0 
  ###############################################################
  addi $t0, $zero, 0 # bytes que serao usados para salvar em vetor
  ###############################################################
  #leitura do diretorio
  rep:
  	lb $t7, diretorio($t0)
  	beq $t7, $zero, endrep1
  	sb $t7, arq($t0)
  	addi $t0, $t0, 1
  j rep        
  ###############################################################
  #acrecentando a palavara imagem
  endrep1:
  subi $t0, $t0, 1
  rep1:
   	lb $t7, imagem($t1)
   	beq $t7, $zero, endrep2
  	sb $t7, arq($t0)
  	addi $t0, $t0, 1
   	addi $t1, $t1, 1	 
  j rep1
  ###############################################################
    #acrecentando a palavara do formato 
  endrep2:	add $t9, $t0, $zero
   		addi $t0, $t0, 1
   		beq $s5, $zero, rep2.2
  rep2.1:
   	lb $t7, ppm($t2)
   	beq $t7, $zero, endrep
  	sb $t7, arq($t0)
   	addi $t0, $t0, 1
   	addi $t2, $t2, 1
  j rep2.1
  rep2.2:
   	lb $t7, pgm($t2)
   	beq $t7, $zero, endrep
  	sb $t7, arq($t0)
   	addi $t0, $t0, 1
   	addi $t2, $t2, 1
  j rep2.2
  ###############################################################
  #gerando numero da imagem
  endrep:
  addi $t8, $t6, 48
  sb $t8, arq($t9) 
  #############################################################
  # gerar arquivo onde sera armazenado a nova string
  li   $v0, 13       # abrir arquivo
  la   $a0, arq     # selecionar fout
  li   $a1, 1        
  li   $a2, 1        
  syscall            
  move $s0, $v0     # salvando em s0
  #############################################################
  la $t4, dir #abrir primeira imagem
  #############################################################
  while: #abrir todas as imagens
  	beq $t6, $s6, endwhile # de 0 ate n imagens
  ###############################################################  
  	addi $t6, $t6, 1  # contador
  ###############################################################
  	addi $t8, $t6, 48
  	sb $t8, arq($t9)
  ############################################################### 
  # abrir arquivos(imagem)
  	li   $v0, 13       # abrir arquivo
  	la   $a0, arq     # selecionar arq n
  	li   $a1, 0        
  	li   $a2, 0        
  	syscall    
  	sw $v0, 0($t4) #salvando endereço do arquivo
  	addi $t4, $t4, 4 #proximo variavel do vetor
   j while
  ##############################################################
  #condições
  endwhile: 
  	addi $t6, $zero, 0  # contador
  	la $t4, dir #lendo priemira imagem
 ##############################################################
  rep3: # ler arquivo 1 - p2 ou p3
  	beq $t6, $s6, endrep3 # de 0 ate n imagens
  	addi $t6, $t6, 1  # contador
  	lw $s1, 0($t4) # le 1 dos arquivos em ordem crescente em s1
  	addi $t4, $t4, 4 #proxima imagem
 rep12:
  	li   $v0, 14 		#ler arquivo      
  	move $a0, $s1      
  	la   $a1, buffer  
  	li   $a2, 1     
  	syscall
  	lb $t1, buffer
  	beq $t1, $s7, rep3
  j rep12  
  ##############################################################
  endrep3:  # imprimir em novo arquivo  - p2 ou p3
  addi $t1, $zero, 80
  sb $t1, buffer
  li   $v0, 15		#escrever arquivo
  move $a0, $s0     
  la   $a1, buffer  
  li   $a2, 1       
  syscall
 ##############################################################
 #vereficar se é pgm ou ppm para extensão de nobo arquivo
  beq $s5, $zero, conpgm
  addi $t1, $zero, 51
  j endppm
  conpgm: addi $t1, $zero, 50 
  endppm: 
  sb $t1, buffer
   li   $v0, 15		#escrever arquivo
  move $a0, $s0     
  la   $a1, buffer  
  li   $a2, 1       
  syscall 
   ##############################################################
   #gravando \n
  sb $s7, buffer
   li   $v0, 15		#escrever arquivo
  move $a0, $s0     
  la   $a1, buffer  
  li   $a2, 1       
  syscall
  ##############################################################
  # gravando autentificação do trabalho
  sb $s7, buffer
   li   $v0, 15		#escrever arquivo
  move $a0, $s0     
  la   $a1, assinatura  
  li   $a2, 36       
  syscall
  ##############################################################
   #gravando \n
  sb $s7, buffer
   li   $v0, 15		#escrever arquivo
  move $a0, $s0     
  la   $a1, buffer  
  li   $a2, 1       
  syscall
  ##############################################################
  #ler altura da imagem
  la $t4, dir
  lb $s2, espaço
  lb $s3, comentario
  addi $t6, $zero, 0
  rep4: 
 	 addi $t6, $t6, 1
 	 beq $s6, $t6, endrep4
 	 lw $s1, 0($t4) # le 1 dos arquivos em ordem crescente em s1
  	addi $t4, $t4, 4
  ##############################################################
  rep5:   # ler arquivo n - largura
  	li   $v0, 14 		#ler arquivo      
 	move $a0, $s1      
 	la   $a1, buffer  
  	li   $a2, 1     
  	syscall
 	lb $t1, buffer
  	beq $s3, $t1, rep11
 	beq $s2, $t1, rep4
  	beq $s7, $t1, rep4
  j rep5
 ##############################################################
  rep11: #caso aja comentario ele iria sair para chegar em altura
  	li   $v0, 14 		#ler arquivo      
 	move $a0, $s1      
  	la   $a1, buffer  
  	li   $a2, 1     
 	syscall
  	lb $t1, buffer	
  	beq $s7, $t1, rep5
  j rep11
  ##############################################################
  endrep4:
  addi $t6, $zero, 0
  lw $s1, 0($t4)
  ##############################################################
  rep6: # ler ultimo arquivo - largura
  	li   $v0, 14 		#ler arquivo      
  	move $a0, $s1      
  	la   $a1, buffer  
  	li   $a2, 1     
  	syscall
  	lb $t1, buffer 
  	beq $s3, $t1, rep10
  	beq $s2, $t1, endrep6
  	beq $s7, $t1, endrep6
  	addi $t6, $t6, 1
  ##############################################################
  #gravar em novo arquivo - largura
  	li   $v0, 15		#escrever arquivo
  	move $a0, $s0     
 	la   $a1, buffer  
  	li   $a2, 1       
  	syscall 
  j rep6
  ##############################################################
  rep10: #caso aja comentario ele iria sair para chegar em altura
  	li   $v0, 14 		#ler arquivo      
  	move $a0, $s1      
  	la   $a1, buffer  
  	li   $a2, 1     
  	syscall
  	lb $t1, buffer	
  	beq $s7, $t1, rep6
  j rep10
  ##############################################################                                     
  endrep6: #gravando espaço
  sb $s2, buffer
  li   $v0, 15		#escrever arquivo
  move $a0, $s0     
  la   $a1, buffer  
  li   $a2, 1       
  syscall 
  la $t4, dir
  addi $t6, $zero, 0
  ##############################################################  
  rep7: # ler arquivo n - largura
  	addi $t6, $t6, 1
  	beq $s6, $t6, endrep7
  	lw $s1, 0($t4) # le 1 dos arquivos em ordem crescente em s1
  	addi $t4, $t4, 4
  ##############################################################
  rep8:   # ler arquivo n - altura
  	li   $v0, 14 		#ler arquivo      
 	move $a0, $s1      
  	la   $a1, buffer  
  	li   $a2, 1     
  	syscall
  	lb $t1, buffer 
 	beq $s7, $t1, rep7
  j rep8
  ##############################################################
  endrep7: 
  addi $t6, $zero, 0
  lw $s1, 0($t4)
  ##############################################################
  rep9: # ler ultimo arquivo - largura
  	li   $v0, 14 		#ler arquivo      
  	move $a0, $s1      
 	la   $a1, buffer  
  	li   $a2, 1     
  	syscall
  	lb $t1, buffer 
  	beq $t1, $s7, endrep9
  	addi $t6, $t6, 1
  ##############################################################
    #gravar em novo arquivo - altura
  li   $v0, 15		#escrever arquivo
  move $a0, $s0     
  la   $a1, buffer  
  li   $a2, 1       
  syscall 
  j rep9
  ##############################################################		
  endrep9: #gravando \n	
  sb $s7, buffer
  li   $v0, 15		#escrever arquivo
  move $a0, $s0     
  la   $a1, buffer  
  li   $a2, 1       
  syscall 		
  ##############################################################
  #condições					
  lb $s7, barran 	# s7 contem \n
  addi $s5, $zero, 100  # s5 contem 100
  addi $s4, $zero, 10 	# s4 contem 10
  ##############################################################
  loop:   # loop que vaio de 0 ate /0 para gravar todos os pixel do fout
  ###############################################################
  addi $t0, $zero, 0 # bytes que serao usados para salvar em vetor
  addi $t6, $zero, 0  # contador 0
  addi $s3, $zero, 0  # zerando para nao pegar lixo
  la $t4, dir
  ##############################################################
  for:  #abrir todas as imagens para obter-se os pixel para um futuro algoritmo
  beq $t6, $s6, endfor # contador q abre uma linha de pixel de topdas as n imegem(ns)
  ##############################################################
  lw $s1, 0($t4) # le 1 dos arquivos em ordem crescente em s1
  addi $t4, $t4, 4
  ##############################################################
  # ler arquivo n - primeiro pixel da linha
  li   $v0, 14 		#ler arquivo      
  move $a0, $s1      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  lb $t1, buffer  #salva primeiro numero da linha em t1 formato char 
  ##############################################################
  # caso seja \0 em vez de numero chama stop para encerrar programa
  move $t8,$v0
  beq $t8, $zero, stop
  ##############################################################
  #transforma char em inteiro para se poder fazer fazer o algoritmo
  subi $t1, $t1, 48 
  ##############################################################
  # ler arquivo n -  segundo pixel da linha
  li   $v0, 14 		#ler arquivo      
  move $a0, $s1      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  lb $t2, buffer  #salva segunbo numero da linha em t2 formato char
  ##############################################################
  # vereficar se pixel tem apenas dois digitos
  beq $s7, $t2, con
  ##############################################################	
  #transforma char em inteiro para se poder fazer fazer o algoritmo
  subi $t2, $t2, 48
  ##############################################################
  li   $v0, 14 		#ler arquivo      
  move $a0, $s1      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  lb $t3, buffer #salva terceiro numero da linha em t3 formato char
  ##############################################################
   # vereficar se pixel tem tres digitos	
  bne $s7, $t3, if
  ##############################################################
  #fatores para 2 digitos
  mul $t1, $t1, $s4
  add $t1, $t1, $t2 
  j con 
  ##############################################################  
 #fatores para 3 digitos 
  if:	subi $t3, $t3, 48
  	mul $t2, $t2, $s4
  	mul $t1, $t1, $s5
  	add $t1, $t1, $t2
  	add $t1, $t1, $t3
  ############################################################## 
  # lendo \n para quando a 3 digitos	
  li   $v0, 14 		      
  move $a0, $s1      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  ###############################################################
  con: # salvando pixel da linhado arq n 
  	add $s3, $s3, $t1
  	addi $t6, $t6, 1
  	j for
  ##############################################################
  endfor: #soma aritimetica
  div $t0, $s3, $s6
  ##############################################################
  #t7 vai ser 1 se somente se t0 for menor que 100	
  slt $t7, $t0, $s5 
  bne $t7, $zero, L1
  ##############################################################
  #converte de inteiro para string
  div $t1, $t0, $s5
  mul $t2, $t1, $s4
  mul $t3, $t1, $s5
  addi $t1, $t1, 48
  ##############################################################
  #salvando em em buffer o resultado
  sb $t1, buffer
  ##############################################################
  # gravando resultado de uma linha de um byte de um pixel para fout
  li   $v0, 15 		      
  move $a0, $s0      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  ##############################################################
  # proximo pixel 
  div $t1, $t0, $s4
  sub $t1, $t1, $t2
  mul $t2, $t1, $s4
  addi $t1, $t1, 48
   ##############################################################
  # gravando resultado de uma linha de um byte de um pixel para fout 
  sb $t1, buffer
  li   $v0, 15 		      
  move $a0, $s0      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  ##############################################################
  # proximo pixel  
  sub $t1, $t0, $t2 
  sub $t1, $t1, $t3
  addi $t1, $t1, 48
  ##############################################################
  # gravando resultado de uma linha de um byte de um pixel para fout
  sb $t1, buffer
  li   $v0, 15 		      
  move $a0, $s0      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  j conloop
  ##############################################################
  #t7 vai ser 1 se somente se t0 for menor que 10  	 
  L1: slt $t7, $t0, $s4 	   
  bne $t7, $zero, L2
  ##############################################################
  # proximo pixel  
  div $t1, $t0, $s4
  mul $t2, $t1, $s4
  addi $t1, $t1, 48
  ##############################################################
  # gravando resultado de uma linha de um byte de um pixel para fout
  sb $t1, buffer
  li   $v0, 15 		      
  move $a0, $s0      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  ##############################################################
  # proximo pixel  
  sub $t1, $t0, $t2 
  addi $t1, $t1, 48
  ##############################################################
  # gravando resultado de uma linha de um byte de um pixel para fout
  sb $t1, buffer
  li   $v0, 15 		      
  move $a0, $s0      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  j conloop
  ##############################################################
  #quando tem 1 numero apenas
  L2: addi $t0, $t0, 48
  ##############################################################
  # gravando resultado de uma linha de um byte de um pixel para fout
  sb $t0, buffer
  li   $v0, 15 		      
  move $a0, $s0      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  ##############################################################
  # gravando \n em fout para proximo pixel
  conloop:
  li   $v0, 15 		      
  move $a0, $s0      
  la   $a1, barran  
  li   $a2, 1      
  syscall
  j loop
  ##############################################################
  stop: 
  li $v0, 10  # Finalizar programa 
  syscall
