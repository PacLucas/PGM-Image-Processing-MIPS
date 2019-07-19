 .data
 buffer:	.space 1024
local:		.space 200
lcl:		.space 200
wrd:		.word 1
	
name: 		.asciiz "\imagem"
ppm: 		.asciiz ".ppm"
pgm: 		.asciiz ".pgm"
	
next:		.asciiz "\n"
spc:		.asciiz " "
sharp:		.asciiz "#"  # Verificação existência comentário
StrIm: 		.asciiz "\nQuantidade imagens(de 2 à 9):\n"   #Inserção quantidade imagens
StrLo: 		.asciiz "\nDiretório das imagens(Inserir barra invertida no fianl): \n"   #Inserção local
StrFor: 	.asciiz "\nExtensão imagens(0 para .PGM e 1 para .PPM):\n"   #Inserção formato
	
.text
  # Set variáveis
  lb $s3, next
  li $s1, 100
  li $s2, 10 

#~~~~~~~~~~~~~ Local ~~~~~~~~~~~~~# 
  li $v0, 4       
  la $a0, StrLo          
  syscall
  li $v0, 8       
  la $a0, local
  la $a1, 200 
  syscall

#~~~~~~~~~~~~~ Quantidade Imagens ~~~~~~~~~~~~~# 
  li $v0, 4       
  la $a0, StrIm           
  syscall
  li $v0, 5       
  syscall
  move $s0, $v0    
  
  
#~~~~~~~~~~~~~ Extensão ~~~~~~~~~~~~~# 
  li   $v0, 4       
  la   $a0, StrFor           
  syscall
  li   $v0, 5       
  syscall
  move $s1, $v0
  
#~~~~~~~~~~~~~ Manipulação Vetor ~~~~~~~~~~~~~# 
  li $t0, 0
  li $t1, 0
  li $t2, 0
  li $t3, 0 
  li $t4, 0 

#~~~~~~~~~~~~~ Leitura Local ~~~~~~~~~~~~~# 
  Call:
  lb $t5, local($t0)
  beq $t5, $zero, FimCall1
  sb $t5, lcl($t0)
  addi $t0, $t0, 1
  j Call        

  # Inserindo nome da imagem
  FimCall1:
  subi $t0, $t0, 1
  Call1:
  lb $t5, name($t1)
  beq $t5, $zero, FimCall2
  sb $t5, lcl($t0)
  addi $t0, $t0, 1
  addi $t1, $t1, 1	 
  j Call1
  
  # Inserindo extensão
  FimCall2:	
  add $t9, $t0, $zero
  addi $t0, $t0, 1
  beq $s1, $zero, Call2.2
  Call2.1:
  lb $t5, ppm($t2)
  beq $t5, $zero, FimCall
  sb $t5, lcl($t0)
  addi $t0, $t0, 1
  addi $t2, $t2, 1
  j Call2.1
  Call2.2:
  lb $t5, pgm($t2)
  beq $t5, $zero, FimCall
  sb $t5, lcl($t0)
  addi $t0, $t0, 1
  addi $t2, $t2, 1
  j Call2.2

  FimCall:
  addi $t8, $t4, 48
  sb $t8, lcl($t9) 
 
 #~~~~~~~~~~~~~ Arquivo Saída ~~~~~~~~~~~~~# 
  li $v0, 13
  la $a0, lcl
  li $a1, 1        
  li $a2, 1        
  syscall            
  move $s6, $v0
  la $t6, wrd
 #~~~~~~~~~~~~~ Abertura Imagens ~~~~~~~~~~~~~# 
  Laço: 
  beq $t4, $s0, FimLaço
  addi $t4, $t4, 1
  addi $t8, $t4, 48
  sb $t8, lcl($t9)

# Abrindo arquivos
  li $v0, 13 
  la $a0, lcl
  li $a1, 0        
  li $a2, 0        
  syscall    
  sw $v0, 0($t6)
  addi $t6, $t6, 4 
   j Laço
  FimLaço: 
  li $t4, 0
  la $t6, wrd
 
  # Leitura primeiro arquivo
  Call3:
  beq $t4, $s0, FimCall3
  addi $t4, $t4, 1
  lw $s5, 0($t6)
  addi $t6, $t6, 4
 Call12:
  li $v0, 14     
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1     
  syscall
  lb $t1, buffer
  beq $t1, $s3, Call3
  j Call12  
  
  # Inserindo novo arquivo
  FimCall3:
  li $t1, 80
  sb $t1, buffer
  li $v0, 15
  move $a0, $s6     
  la $a1, buffer  
  li $a2, 1       
  syscall
  #Extensão arquivo novo
  beq $s1, $zero, ExPGM
  li $t1, 51
  j ExPPM
  ExPGM: li $t1, 50 
  ExPPM: 
  sb $t1, buffer
  li $v0, 15	
  move $a0, $s6     
  la $a1, buffer  
  li $a2, 1       
  syscall 
  sb $s3, buffer
  li $v0, 15
  move $a0, $s6     
  la $a1, buffer  
  li $a2, 1       
  syscall
  
  la $t6, wrd
  lb $s4, spc
  lb $s7, sharp
  li $t4, 0
  Call4: 
  addi $t4, $t4, 1
  beq $s0, $t4, FimCall4
  lw $s5, 0($t6)
  addi $t6, $t6, 4
 
#~~~~~~~~~~~~~ Leitura Arquivo ~~~~~~~~~~~~~# 
  Call5:
  li $v0, 14     
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1     
  syscall
  lb $t1, buffer
  beq $s7, $t1, Call11
  beq $s4, $t1, Call4
  beq $s3, $t1, Call4
  j Call5
  # Verificação existência de comentários
  Call11:
  li $v0, 14     
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1     
  syscall
  lb $t1, buffer	
  beq $s3, $t1, Call5
  j Call11
  FimCall4:
  li $t4, 0
  lw $s5, 0($t6)
  
  Call6:
  li $v0, 14  
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1     
  syscall
  lb $t1, buffer 
  beq $s7, $t1, Call10
  beq $s4, $t1, FimCall6
  beq $s3, $t1, FimCall6
  addi $t4, $t4, 1
 	
 #Gravando novo arquivo tamanho
  li   $v0, 15
  move $a0, $s6     
 la   $a1, buffer  
  li   $a2, 1       
  syscall 
  j Call6
 # Existência comentário
  Call10:
  li $v0, 14     
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1     
  syscall
  lb $t1, buffer	
  beq $s3, $t1, Call6
  j Call10
  #Inserindo espaço        	                
  FimCall6:
  sb $s4, buffer
  li $v0, 15
  move $a0, $s6     
  la $a1, buffer  
  li $a2, 1       
  syscall 
  la $t6, wrd
  li $t4, 0
 #Largura
  Call7:
  addi $t4, $t4, 1
  beq $s0, $t4, FimCall7
  lw $s5, 0($t6)
  addi $t6, $t6, 4
  #Altura
  Call8:
  li $v0, 14 
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1     
  syscall
  lb $t1, buffer 
  beq $s3, $t1, Call7
  j Call8

  FimCall7: 
  li $t4, 0
  lw $s5, 0($t6)

  Call9:
  li $v0, 14     
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1     
  syscall
  lb $t1, buffer 
  beq $t1, $s3, FimCall9
  addi $t4, $t4, 1
  #Gravando altura novo arquivo
  li $v0, 15
  move $a0, $s6     
  la $a1, buffer  
  li $a2, 1       
  syscall 
  j Call9
 	
  FimCall9:
  sb $s3, buffer
  li $v0, 15
  move $a0, $s6     
  la $a1, buffer  
  li $a2, 1       
  syscall 	
  						
  lb $s3, next 	
  li $s1, 100
  li $s2, 10 
 
  #Gravar todos pixels saída
  Laço1:
  li $t0, 0
  li $t4, 0
  li $s7, 0
  la $t6, wrd

  Laço2:
  beq $t4, $s0, FimLaço2
 
  lw $s5, 0($t6)
  addi $t6, $t6, 4
 
  # Ler primeiro pixel arquivo
  li   $v0, 14 	 
  move $a0, $s5      
  la   $a1, buffer  
  li   $a2, 1      
  syscall
  lb $t1, buffer  
  move $t8,$v0
  beq $t8, $zero, Fim # Verifica final do arquivo
  # Char -> Inteiro
  subi $t1, $t1, 48 
  
  li $v0, 14 	     
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1      
  syscall
  lb $t2, buffer
  
  beq $s3, $t2, Sv
 
  subi $t2, $t2, 48

  li $v0, 14    
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1      
  syscall
  lb $t3, buffer
  # Tamnho número pixel	
  bne $s3, $t3, Dig
  # 2 dígitos
  mul $t1, $t1, $s2
  add $t1, $t1, $t2 
  j Sv 
  # 3 Dígitos
  Dig:	
  subi $t3, $t3, 48
  mul $t2, $t2, $s2
  mul $t1, $t1, $s1
  add $t1, $t1, $t2
  add $t1, $t1, $t3

  li $v0, 14 		      
  move $a0, $s5      
  la $a1, buffer  
  li $a2, 1      
  syscall
  #Salvando pixel
  Sv:
  add $s7, $s7, $t1
  addi $t4, $t4, 1
  j Laço2
  
  FimLaço2:
  div $t0, $s7, $s0	
  slt $t5, $t0, $s1 
  bne $t5, $zero, Case
  # Inteiro -> String
  div $t1, $t0, $s1
  mul $t2, $t1, $s2
  mul $t3, $t1, $s1
  addi $t1, $t1, 48
  #Salva resultado
  sb $t1, buffer
  #Gravda resultado
  li $v0, 15 		      
  move $a0, $s6      
  la $a1, buffer  
  li $a2, 1      
  syscall
 #Avança pixel
  div $t1, $t0, $s2
  sub $t1, $t1, $t2
  mul $t2, $t1, $s2
  addi $t1, $t1, 48
  #Grava resultado
  sb $t1, buffer
  li $v0, 15 		      
  move $a0, $s6      
  la $a1, buffer  
  li $a2, 1      
  syscall
  #Avança pixel
  sub $t1, $t0, $t2 
  sub $t1, $t1, $t3
  addi $t1, $t1, 48
  #Grava resultado
  sb $t1, buffer
  li $v0, 15 		      
  move $a0, $s6      
  la $a1, buffer  
  li $a2, 1      
  syscall
  j Prox
	 
  Case: slt $t5, $t0, $s2 	   
  bne $t5, $zero, Case2
  # Avança pixel
  div $t1, $t0, $s2
  mul $t2, $t1, $s2
  addi $t1, $t1, 48
  # Grava resultado
  sb $t1, buffer
  li $v0, 15 		      
  move $a0, $s6      
  la $a1, buffer  
  li $a2, 1      
  syscall
  # Avança pixel 
  sub $t1, $t0, $t2 
  addi $t1, $t1, 48
  # Grava resultado
  sb $t1, buffer
  li $v0, 15 		      
  move $a0, $s6      
  la $a1, buffer  
  li $a2, 1      
  syscall
  j Prox
  # Apenas 1 dígito
  Case2: addi $t0, $t0, 48
  # Grava Resultado
  sb $t0, buffer
  li $v0, 15 		      
  move $a0, $s6      
  la $a1, buffer  
  li $a2, 1      
  syscall
  # Avança pixel
  Prox:
  li $v0, 15 		      
  move $a0, $s6      
  la $a1, next  
  li $a2, 1      
  syscall
  j Laço1
 
 #~~~~~~~~~~~~~ Finalização ~~~~~~~~~~~~~# 
  Fim: 
  li $v0, 10
  syscall