.data


MsgJogoTitulo: .asciiz "\tJogo do 4-in-row\n"
menuMsg: .asciiz "\n[j]-jogar\n[e]-Pontuações\n[f]-Finalizar Programa\n"
menuMsgErro: .asciiz "\nIntroduza um caracter valido!\n"
Vitorias: .asciiz "\tVitorias de Jogador "
Empates: .asciiz "\nDraws: "
Pontos: .asciiz "\nPontos de Jogador " 
MsgJogadorPlay1: .asciiz "Jogador "
MsgJogadorPlay2: .asciiz " a jogar"
MsgNJogadores: .asciiz "\nQuanto jogadores vão jogar?\n"
OpcaoCol: .asciiz "Escolha uma coluna para colucar a peça\n"
ErroOpcaoCol:.asciiz "#ERRO#\nIntroduza um valor entre  "
mensagemErroColuna: .asciiz "Esta coluna ja esta cheia!\nInserir outra\n"
MsgErroNPlayers: .asciiz "O numero minimo de jogadores para jogar é 2, introduza um numero >1\n"
TabuleiroLimpo: .asciiz "\n\n\tO tabuleiro foi limpo!\n"
ErroColuna: .asciiz "(1-"
ErroColunaa: .asciiz "):\n"
doispontos: .asciiz ":"
Repetir: .asciiz "\nDeseja jogar novamente com o mesmo numero de jogadores?\n(1)-Sim\n(0)-Nao\n(2)-Voltar ao Menu\n"
MsgErroRepetir: .asciiz "Seleciona (1) para SIM ou (0) para NAO ou (2) para volta ao MENU\n"
MsgPontosErro: .asciiz "\nÉ necessario jogar pelo menos uma vez para dar display aos pontos\n"
EmpateMsg: .asciiz "O jogo ficou empatado, não há vencedores\n"
mat: .word 0
nPlayers: .word 0
BytesCelulas: .word 0
count_jogador: .word 0
ilustracao1: .asciiz "("
ilustracao2: .asciiz ")"
count_ilustracao: .word 0
jogadorwin: .asciiz " ganhou!!\n"
maiorcoluna: .word 0
maiorlinha: .word 0
GrelhaX: .word 0
GrelhaY: .word 0
EspacoX: .word 0
EspacoY: .word 0
bytesdiagonal: .word 0
vWins: .word 0:50					#Vetor que armazena as vitorias de cada jogador
vPoints: .word 0:50					#Vetor que armazena os pontos de cada jogador
vDesenho: .word 1:15				#Vetor que auxiliar o desenho (para amontoar as peças)
CorJogador: .word 0
Vencedor: .word 0
ImprimirPontos: .word 0					
helpPosi: .word 0
posWinner: .word 0
countjogadas: .word 0
draw: .word 0						#Onde se guarda o numero de empates
espacos: .word 0
MSGFim: .asciiz "\nPrograma terminado\n"
pos: .word 0						#Apenas ajuda a calcular bytes da coluna onde foi inserida a peça
endline: .asciiz	"\n"				#Paragrafo entre as linhas
tab:	.asciiz	"\t"					#Espaço entre os numeros
separador: .asciiz "-----------------------------------------"
.align 2
frameBuffer: .space 0x80000

.text



menu:
	li $v0, 4
	la $a0, MsgJogoTitulo				#Print da string
	syscall
	li $v0, 4
	la $a0, menuMsg					#Print da string
	syscall
	li $v0, 12					#Scan de um caracter
	syscall
	beq $v0,'j', main		
	beq $v0,'e', printPointsHelp
	beq $v0,'f', exit
	j ErroMenu					#Caso não introduza nenhuma das opções salta para o funcao ErroMenu
	
	
	j menu						
	
ErroMenu:
	li $v0, 4
	la , $a0, menuMsgErro				#Print à string de rro
	syscall
	j menu						#Salta novamente para o menu
	

main:						
	jal AskNPlayers					
	jal ilustracao	
	jal mat_print				
	j reset_player					
	
	
AskNPlayers:
	li $v0, 4
	la $a0, MsgNJogadores				#Print à string
	syscall
	li $v0, 5					#Le numero de jogadores
	syscall 
	beq $v0, 1, ErroNJogadores			#Caso o utilizador escolha apenas 1 jogar salta para funcao de erro
	move $t3, $v0
	lw $t5, nPlayers				#Load do numero de jogadores que irao jogar
	addi $t5, $t3, 1				#t5=Nplayers+1 
	sw $t5, nPlayers				#Guarda esse valor
	mul $t1,$t3, 3					#Linha= Njogadores x 3				
	sw $t1, maiorlinha				#Guarda o numero de linhas
	add $t2, $0, $t1 				#Colunas=Linhas
	sw $t2, maiorcoluna				#Guarda numero de linhas						
	mul $a0, $a1, $a2				#ColunasXLinhas para saber quantas celulas possui
	sll $a0, $a0 , 2				#Numero Total de celulas x 4 bytesmul $a0, $a1, $a2				
	li $v0, 9					#Alocar espaço para o tamanho da matriz	
	syscall						#Guarda o numero total de espaço.
	sw $a0, BytesCelulas				#Guarda o numero total de bytes de todas as celulas da matriz
	la $t0,mat
	sw $v0,0($t0)					#Guarda o numero total de bytes de todas as celulas da matriz						
	jr $ra
	
ErroNJogadores:
	li $v0, 4
	la $a0, MsgErroNPlayers				#Print da string
	syscall
	j AskNPlayers					#Volta para a função

mat_print:						#Funcao responsavel pela impressao da matriz(apartir de baixo)						
															
	lw $a1, maiorlinha				#Load numero de linhas			 				
	lw $a2, maiorcoluna				#Load do numero de colunas												
	la $s0, mat					#Load base adress				
	lw $s0,0($s0)	
	add $t3, $zero, $s0	 			#t3=a0 (indice da matriz)
	addi $a1 ,$a1, -1				#Linhas-1 pois 0 tambem conta
	add $t0, $zero, $a1				#t0=index[i]= ultima linha a contar de baixo.
			
	mat_print_while1:	
		 		 						
		slti 	$t7, $t0, 0	 		#While(i>=0);		
		bne	$t7, $0, mat_print_end		#Quando acaba primeiro ciclo significada que a matriz ja foi toda impressa
		add	$t1, $zero, $zero 		#index[j] =0;
	
	mat_print_while2: 				#Salta para o 2 clico, ciclos das coluns
				
		slt	$t6, $t1, $a2			#(j<Colunas);			
		beq	$t6, $zero, mat_print_end_line	#Se estivermos no fim da primeira linha, salta para a funcao \n
		mul	$t5, $t0, $a2			# $t5= $t0(Index[i] x NColunas
		add	$t5, $t5, $t1			#$t5= $t5+[i]Index
		sll	$t4, $t5, 2			#$t4=$t5x4bytes
		add	$t5, $t4, $t3	 		#$t5=v[i][j]=addr= BaseAdress(a0/t3)+(([i]Index/t0)*Colunas(a1)+([j]Index/t0))*TamanhoInteiros(4)/t4		
		li	$v0, 1				#Carregar um inteiro
		lw	$a0, 0($t5)			#Mete o inteiro na posicao [i][j]/adress	
		syscall 
		li	$v0, 4 				#Dar print de um tab entro os numeros apenas para estetica.
		la	$a0, tab					
		syscall
		addi	$t1, $t1, 1			#Proximo index mat[i][j+1]	
		j	mat_print_while2

	mat_print_end_line:					
		li	$v0, 4
		la	$a0, endline 			#Dar print de um \n entre as linhas apenas para estetica.
		syscall
		addi 	$t0, $t0, -1			#i=i-1;		
		j	mat_print_while1		#Salta para o primeiro ciclo.
			
	mat_print_end:						
		jr	$ra				#return da matriz
		
		
reset_player:
		lw $t0, Vencedor			#Reset ao vencedor da partida anterior(caso exista)
		addi $t0, $0, 0				#Jogador vencedor = nao existe (0)
		sw $t0, Vencedor			#Guarda esse valor
		
		lw $a0, count_jogador			#Load do jogador					
		addi $a0, $0, 1				#Começa o count a 1, pois nao existe jogar 0
		sw $a0, count_jogador			#Armazena o novo valor de count				
		
		lw $t0, maiorlinha			#Load do numero de linhas
		lw $t1, maiorcoluna			#Load do numero de colunas
		mul $t3, $t0, $t1			#Multiplica esse valor
		
		sw $t3, espacos				#Guarda esse valor
		j PlayJogador						
		
		
PlayJogador:
	j inicioX					#Funcao responsavel pelo bitmapdysplay (Descomentar para ativar)
	
	FIMDESENHOTABULEIRO:
	la $s0, mat
	lw $s0,0($s0)
							#Começa a contar as jogadas
	lw $t1, espacos					#Load dos espacos(celulas da mat+1)
	lw $t2, countjogadas				#Load do numero de jogadas
	beq $t1, $t2 ,JogoEmpatado			#Se foram iguais, quer dizer que até agr nao existiu nenhum vencedor e matriz ja está toda preenchila, logo o jogo empatou
	li  $v0,4   				
	la  $a0,MsgJogadorPlay1				#Print à string	
	syscall 
	lw $t0, count_jogador				#Print do jogador que está a jogar	
	li $v0,1
	move $a0,$t0
	syscall
	li  $v0,4   				
	la  $a0,MsgJogadorPlay2				#Print á string
	syscall 
	li $v0, 4
	la $a0, endline					#Print a um \n
	syscall
	li $v0, 4 					
	la $a0,OpcaoCol					#Print à string
	syscall
	li $v0, 5					#Lê o numero colocado
	syscall
	addi $v0,$v0,-1 				#Subtrai esse numero por 1, pois na programação 0 tambem conta
        mul $t0,$v0,4					#Multiplica por 4 para saber onde se encontra na matriz
        sw $t0, pos					#Da deve dessa posição ( para auxiliar em funcoes futuras)
        move $a0,$v0					#Passa para a0
	jal Validacao 					#Salta para a função de validação do numero.
	beq $v0,0, ColunaInvalidaPlayer			#Se o valor retornado da função "Validacao" for 0, ele ira imprimir msg de erro e volta a pedir outra coluna.
	lw $t5,count_jogador				#t5 será a peça , onde o jogador x terá a peça (x)
	jal VerificaoColuna 				#Salta para a função para verificar se a celula é valida ou nao
	sw $t5,0($v0) 					#Coloca esse valor na matriz na coluna que o utilizador colocou
	jal ilustracao					#Salta para a função de impressao do numero em cima das colunas
	jal mat_print					#Mostra o estado da matriz
	j peca
	FIMDESENHO:
	jal checkVertical				#Vê se existe algum 4 em linha na vertical
	beq $v0, 1 , PlayerWin				#Caso existe player x ganhou	
	jal checkhorizontal				#Vê se existe algum 4 em linha na horizontal
	beq $v0, 1 , PlayerWin				#Caso existe player x ganhou	
	jal check1stdiagonal				#Vê se existe algum 4 em linha na primeira diagonal
	beq $v0, 1 , PlayerWin				#Caso existe player x ganhou
	jal check2nddiagonal				#Vê se existe algum 4 em linha na segunda diagonal
	beq $v0, 1 , PlayerWin				#Caso existe player x ganhou
	jal counter_jogadas
	jal counter_players				#Muda para o proximo jogador
	lw $t3, nPlayers				#Da load do numero de jogadores
	beq $t3,$a1,reset_player			#Caso esse numero seja igual ao jogador atual, então irá dar reset para começar de novo o primeiro jogador a jogar
	
	j PlayJogador					#Fica em loop até haver um vencedor


counter_jogadas:
		lw $t0, countjogadas			#Load do numero de jogadas
		add $t0, $t0, 1				#Adiciona +1
		sw $t0, countjogadas			#Dá save
		jr $ra					#Retorna

counter_players:
		
		lw $a1, count_jogador			#Load do jogador
		addi $a1, $a1, 1			#Adiciona +1
		sw $a1, count_jogador			#Save do proximo jogador					
		jr $ra					#Retorna
		
						
VerificaoColuna:
	lw $t0, pos					#Da load da coluna onde foi colocado (x4 bytes)
        li $t4,0 					      
        la $s0, mat
        lw $s0, 0($s0) 
        add $s0,$s0,$t0      
        loop1:
         	lw $t2 ,0($s0)				#t2 fica com o valor que existe na posiçao da matriz			
                beq $t2 ,0 ,end1			#Se for 0, entao vai para o fim da funcao
                lw $t3 , maiorcoluna			#Se nao for 0, irá andar (4xNcolunas) bytes
                mul  $t3, $t3, 4			#Ou seja, vai exatamente para a posição de cima para verificar se é possivel colocar a peça lá      							
         	add $s0,$s0, $t3			#linha a cima	
         	j loop1					#Volta para o loop
        end1:
        	addi $v0,$s0,0				#$v0 será a localizaçao da peça
                jr $ra					#return v0;		
                
Validacao:
	la $s0, mat
        lw $s0, 0($s0) 
	lw $t2, maiorcoluna
	addi $t2, $t2, -1				#Colunas totais -1, pois 0 tambem conta
	bgt $a0,$t2, Invalido 				#Se o numero introduzido for maior que o numero de colunas total (-1), salta para funcao "Invalido"
       	blt $a0,0, Invalido 				#Ou se o numero for menor que 0 , tambam salta para a funcao "Invalido"
       	lw $t3, maiorcoluna				#load do numero de colunas
       	lw $t4, maiorlinha				#load do numero de linhas
       	addi $t4, $t4, -1				#Tira -1 ...
       	mul $t5, $t3, $t4				#Multiplicar pelo numero de colunas
       	add $t0,$a0,$t5
       							#t7 fica com o valor do ultima indice da matriz, mat[5][ColunaIntroduzida].
       	sll $t0,$t0,2 					#Multiplica numero por 4 bytes
       	add $s0,$s0,$t0
       	
        lw $t6, 0($s0) 					#Carrega o valor que está na celula da matriz
    	bne $t6 ,0 , ColunaCheia			#Se o valor que está na celula ultima celula da coluna for diferente de 0, salta para a funcao ColunaCheia
        li $v0,1 					#Se o valor for 0, a função retorna 1
        jr $ra 						#return 1;
              		
Invalido:
        li $v0,0 					#Se a celula estiver preenchida (ou seja diferente de 0) a função retorna 0
        jr $ra 						#return 0;
                
ColunaInvalidaPlayer:
	li $v0, 4
	la $a0, ErroOpcaoCol 				#Imprime Mensagem de erro da coluna e salta para o jogador x
	syscall 
	li $v0, 4
	la $a0, ErroColuna				#Imprime string
	syscall
	li $v0, 1
	lw $a0, maiorcoluna				#Imprime o numero da maior coluna
	syscall
	li $v0, 4
	la $a0, ErroColunaa				#Imprime string
	syscall	
	j PlayJogador
	
ColunaCheia:
	li $v0, 4
	la $a0, mensagemErroColuna 			#Imprime que a coluna está cheia e salta para o jogador x
	syscall
	

	j PlayJogador	

ilustracao:						#Função que apenas mostra o layout do tabuleiro para te ruma melhor perceção do numero de cada colun
	
		addi $t0, $0, 1				#t0 começa a 1
		
	LOOP:
					
		lw $t1, maiorcoluna			#Da load ao numero de colunas
		bgt  $t0, $t1, FIM			#Quando t0 foi maior que t1(numero maximo de colunas) salta para o fim
		li $v0, 4				
		la $a0, ilustracao1			#print da string (
		syscall
		lw $t2, count_ilustracao		#Load ao numero de coluana na memoria
		addi $t2, $t2, 1			#Adiciona 1
		sw $t2, count_ilustracao		#Guarda
		li $v0, 1
		lw $a0, count_ilustracao		#Da print a esse numero
		syscall
		li $v0, 4
		la $a0 , ilustracao2			#print da string )
		syscall
		li $v0, 4				
		la $a0, tab				#print de um tab
		syscall
		addi $t0, $t0, 1			#i=i+1
		
		j LOOP					#volta para o loop
		FIM:
		li $v0, 4
		la $a0, endline				#print de um \n
		syscall
		addi $t2, $0, 0
		sw $t2, count_ilustracao		#da reset ao numero da ilustracao para ser utilizado futuramente
		jr $ra
###################################################################################################################################		
							#REGRAS	

checkVertical:						#Utiliza o mesmo mecanismo que a funcao de print matriz so que nao analisa ao contra e sim de cima para baixo
	lw $a1, maiorlinha											
	lw $a2, maiorcoluna										
	lw $a3, count_jogador	
	
	la $s0, mat								
	lw $s0,0($s0)
	add $t3, $zero, $s0	 			
					
	add $t0, $zero, $0				
			

	mat_scan1111:	
		 		
			 						
		bge $t0, $a2, 	 mat_end				
							
		add	$t1, $zero, $zero 		
				
		 
	
	mat_scan2222: 				
				
		bge	$t1, $a2, mat_end_col1	
		mul	$t5, $t0, $a2			
		add	$t5, $t5, $t1			
		sll	$t4, $t5, 2			
		add	$t5, $t4, $t3	 		
		
		sll 	$t8, $a2, 2			#t8 sera o deslocador entre as posiçoes, dependendo do tamanho da matriz t8 terá o seu valor
		
		lw 	$a0, 0($t5)			#Load do numero na posicao base
		beq 	$a0, 0, NextPosicion1		#Se for 0 salta para o proximo j
		
		add $t5, $t5 , $t8			#t8 será o numero de bytes necessario para saber o valor da peça numa dada posicao
		lw 	$t9, ($t5)			#load do numero
		beq 	$t9, 0, NextPosicion1		#caso seja 0 salta para o proximo j
		
		add $t5, $t5 , $t8			#agora t5 terá o valor da posição para a 3 comparaçao	
		lw 	$t2, ($t5)			#load do numero
		beq 	$t2, 0,NextPosicion1		#Caso seja 0 salta para proximo j
		
		add $t5, $t5 , $t8			#agora t5 terá o valor da posicao para a 4 comparacao		
		lw 	$t6, ($t5)			#Da load a esse numero
		beq 	$t6, 0, NextPosicion1		#Caso seja 0 salta para proximo j		
		
		bne $a0, $t9, NextPosicion1		#compara primeiro elemento com segundo
		bne $t9, $t2, NextPosicion1		#depois segundo com o terceiro
		bne $t2, $t6, NextPosicion1		#depois terceiro com quarto
		 	
		j	WinHorizontal 			#caso estas 3 comparacoes sejam verdadeiras, quer dizer que existe um 4 em linha na vertical
	
	NextPosicion1: 
			addi $t1, $t1, 1		#proximo j
			j mat_scan2222			#salta para ciclo dos j
	mat_end_col1:					
		
		add 	$t0, $t0, 1			#proxima linha			
		j	mat_scan1111			#salta para ciclo das linhas
			
	mat_end1:	
							
		li $v0, 0				#caso no fim da funcao nao tenha encontrado nenhum 4 em linha, retorna 0
		jr $ra
WinVertical:
		
		li $v0, 1				#caso no fim da funcao tenha encontrado algum 4 em linha retorna 1
		jr $ra


checkhorizontal:					#Esta função funciona exatamente como a de cima, apenas nao precisa de um registo deslocador , porque apenas existe 4 em linha na horizontal quanto estao espaçados de 4 em 4, nao dependendo do tamanho da matriz
	
	lw $a1, maiorlinha								
	lw $a2, maiorcoluna										
	lw $a3, count_jogador		
	la $s0, mat	
	lw $s0,0($s0)								
	add $t3, $zero, $s0	 								
	add $t0, $zero, $0						

	mat_scan1:	
		 			 						
		bge $t0, $a2, 	 mat_end										
		add	$t1, $zero, $zero 		
				
	mat_scan2: 				
				
		bge	$t1, $a2, mat_end_col	
		mul	$t5, $t0, $a2			
		add	$t5, $t5, $t1			
		sll	$t4, $t5, 2			
		add	$t5, $t4, $t3	 		
		
		lw 	$a0, 0($t5)				#Load da posicao base
		beq 	$a0, 0, NextPosicion
		
		lw 	$t9, 4($t5)				#Load da posicao 4 bytes aseguir
		beq 	$t9, 0, NextPosicion
		
		lw 	$t2, 8($t5)				#load da posicao 8 bytes aseguir
		beq 	$t2, 0,NextPosicion
							
		lw 	$t6, 12($t5)				#load da posicao 12 bytes aseguir
		beq 	$t6, 0, NextPosicion				
		
		bne $a0, $t9, NextPosicion			#compara os 4 valores
		bne $t9, $t2, NextPosicion
		bne $t2, $t6, NextPosicion
		 
		j	WinHorizontal 				#se foram iguais encontrou um 4 em linha na horizontal
	
	NextPosicion: 
			addi $t1, $t1, 1
			j mat_scan2
	mat_end_col:					
		
			add $t0, $t0, 1				
			j mat_scan1		
			
	mat_end:	
							
		li $v0, 0
		jr $ra

WinHorizontal:
		li $v0, 1
		jr $ra

check2nddiagonal:						#Funciona exatamente como as outras, apenas diferencia o nymero de bytes deslocado, sendo (Ncolunas*4) +4
	
		lw $a1, maiorlinha								
		lw $a2, maiorcoluna										
		la $s0, mat
		lw $s0,0($s0)												
		add $t3, $zero, $s0	 			
		lw $t8, bytesdiagonal				
		add $t0, $zero, $0				
			
	mat_scan11:	
		 					 						
		bge  $t0, $a1,mat_endd											
		add  $t1, $zero, $zero 								 
	
	mat_scan22: 						
				
		bge	$t1, $a2, mat_end_coll	
		mul	$t5, $t0, $a2			
		add	$t5, $t5, $t1			
		sll	$t4, $t5, 2			
		add	$t5, $t4, $t3	 		

		sll  $t8, $a2, 2				#t8= Ncolunasx4
		addi $t8, $t8, 4				#t8=NColunasx4+4
		
		lw 	$t4, 0($t5)				
		beq 	$t4, 0, NextPosicionn			
		
		add 	$t5, $t5, $t8				
		lw 	$t9, ($t5)		 		
		beq 	$t9, 0, NextPosicionn					
		
		add 	$t5, $t5, $t8						
		lw 	$t2, ($t5)
		beq 	$t2, 0 ,NextPosicionn	
	
		add 	$t5, $t5, $t8												
		lw 	$t6, ($t5)
		beq 	$t6, 0, NextPosicionn			
		
		bne 	$t4, $t9, NextPosicionn
		bne 	$t9, $t2, NextPosicionn
		bne 	$t2, $t6, NextPosicionn
		 		
		j	Win2ndDiagonal
	
	NextPosicionn: 
						
			addi 	$t1, $t1, 1
			j 	mat_scan22
	mat_end_coll:					
		
			add 	$t0, $t0, 1				
			j	mat_scan11		
			
	mat_endd:	
							
			li $v0, 0
			jr $ra
	
	Win2ndDiagonal:
				
			li $v0, 1
			jr $ra

check1stdiagonal:						#Funciona exatamente comoo a de cima, so que agora a formula será (NColunas*4)-4

	lw 	$a1, maiorlinha								
	lw 	$a2, maiorcoluna										
	la 	$s0, mat
	lw 	$s0,0($s0)												
	add 	$t3, $zero, $s0	 			
	lw 	$t8, bytesdiagonal				
	add 	$t0, $zero, $0				
			

	mat_scan111:	
		 					 						
		bge 	$t0, $a1, 	 mat_enddd											
		add	$t1, $zero, $zero 								 
	
	mat_scan222: 						
				
		bge     $t1, $a2, mat_end_colll	
		mul	$t5, $t0, $a2			
		add	$t5, $t5, $t1			
		sll	$t4, $t5, 2			
		add	$t5, $t4, $t3	 		

		sll 	$t8, $a2, 2				#t8=NColunas*4
		addi 	$t8, $t8, -4				#t8=NColunas*4-4
		
		lw 	$t4, 0($t5)
		beq 	$t4, 0, NextPosicionnn			
		
		add 	$t5, $t5, $t8		
		lw 	$t9, ($t5)		 		
		beq 	$t9, 0, NextPosicionnn				
		
		add 	$t5, $t5, $t8						
		lw 	$t2, ($t5)
		beq 	$t2, 0 ,NextPosicionnn	
	
		add 	$t5, $t5, $t8												
		lw 	$t6, ($t5)
		beq 	$t6, 0, NextPosicionnn			
		
		bne $t4, $t9, NextPosicionnn
		bne $t9, $t2, NextPosicionnn
		bne $t2, $t6, NextPosicionnn
		 		
		j	Win1stDiagonal
	
	NextPosicionnn: 
						
			addi $t1, $t1, 1
			j mat_scan222
	mat_end_colll:					
		
		add 	$t0, $t0, 1				
		j	mat_scan111		
			
	mat_enddd:	
							
		li $v0, 0
		jr $ra
	
	Win1stDiagonal:
				
		li $v0, 1
		jr $ra
####################################################################################################################################
PlayerWin:

	li $v0, 4
	la $a0,MsgJogadorPlay1						#Print á string
	syscall
	li $v0, 1
	lw $a0, count_jogador						#Print ao jogador que está na memoria, ou seja o vencedor
	syscall
	li $v0, 4
	la $a0, jogadorwin						#Print á string
	syscall
	lw $t0, count_jogador						
	sw $t0, Vencedor						#Guarda o numero do vencedor (para funções futuras)
	jal stats							#Salta para a funcao das estatisticas
	j printPoints							#Salta para funcao de imprimir pontos

JogoEmpatado:								#Caso o count tenha chegado ao Nespacos+1
	li $v0, 4			
	la $a0, EmpateMsg						
	syscall
	lw $t4, draw							#Load do numero de draw
	addi $t4, $t4, 1						#Adiciona +1
	sw $t4, draw							#Da save
 	
 	lw $t0, nPlayers
	add $t1, $0, $0
	add $t2, $0, $0
	
	CICLOOOO:
		beq $t1, $t0 ,FIMCICLOOO				#Ciclo que percorre toda o arrya de pontos e adiciona +1 em todos os elementos
		lw $t3, vPoints($t2)
		addi $t3, $t3, 1
		sw $t3, vPoints($t2)
		addi $t1, $t1, 1
		addi $t2, $t2, 4
		j CICLOOOO
	FIMCICLOOO:
		j printPoints								
 										

									

stats:
	lw $t1, nPlayers						#Carrega numero de jogadores
	lw $t2, count_jogador						#Carrega jogador vencedor
	mul $t2, $t2, 4							#multiplica por 4
	addi $t2, $t2, -4						#Subtrai 4 , devido á posição 0
	sw $t2, posWinner						#Guarda esse valor na memoria
	add $t3, $0, $0							#t3=i
	add $t5, $0, $0							#t5 será a posiçao do array e comeca no 0
	
	L:
		sw $t5, helpPosi					#da save numa variavel de ajuda
		beq $t3, $t1, E						#Caso o ciclo tenha acabado, (i>numero de jogadores) salta para o fim
		beq $t5, $t2, EE					#Caso a posiçao do array seja a do vencendor, salta para EE
		lw $t4,vPoints($t5)					#Caso ambas as condiçoes em cima sejam respeitadas, da load do numero de pontos na posicao do array
		addi $t4, $t4,-1					#Subtrai -1 a esses pontos
		blt $t4, 0, ZeroPontos					#Caso esses pontos sejam negativos, salta para a funcao ZeroPontos
		sw $t4,vPoints($t5)					#Guarda esses pontos
		H:							#Funcao que auxiliar funcao "ZeroPontos"
			addi $t3, $t3, 1				#i++
			addi $t5, $t5, 4				#Proxima posicao do array
			j L
			EE:						#Funcao que soma os pontos do vencedor e a vitoria
				lw $t0, Vencedor			#$t0=jogador que ganhou
				mul $t0,$t0,4				#$t0=4 bytes, posicao do array	
				addi $t0,$t0,-4				#Tira 4 devido á primeira posição
				lw $t1, vPoints($t0)			#load dos pontos do vencedor
				addi $t1,$t1, 3				#Adiciona 3 pontos ao jogador, (3 pela vitoria +1 pela operacao acima)
				sw $t1, vPoints($t0)			#save desse valor
				addi $t3, $t3, 1			#i++
				addi $t5, $t5, 4			#Vai para a proxima posicao do array
				j L					#Salta para o inicio do ciclo
	E:
	lw $t6, vWins($t0)						#Da load da posiçao do array do vencedor
	addi $t6, $t6, 1						#Adiciona mais uma vitoria
	sw $t6, vWins($t0)						#Dá save
	jr $ra
	
	
ZeroPontos:
	lw $t5, helpPosi						#Da load onde existe uma pontuacao negativano array
	lw $t4, vPoints($t5)						#Da load do valor dessa posicao
	addi $t4, $0,0							#Torna o 0
	sw $t4, vPoints($t5)						#Da save
	j H								#Salta para funcao de ajuda
printPointsHelp:
		lw $t1, ImprimirPontos					#Funcao que auxiliar imprimir prontos atravez da main
		addi $t1, $0, 1
		sw $t1, ImprimirPontos
		j printPoints
						
printPoints:
	add $t4, $0, $0							#t4=posicao no array
	lw $t0, count_jogador						#load do jogador
	addi $t0, $0, 1							#adiciona 1
	sw $t0, count_jogador						#dá save
	lw $t1, nPlayers						#Load do numero de jogadores
	beq $t1, 0, printPointsMsgErro					#Se o numero de jogadores for 6, significa que ainda nao ouve nenhum jogo, entao vai para funcao de erro

	LOOOP: 
		lw $t0, count_jogador					#Load do numero de jogadores
		beq $t0, $t1 , FIMM					#Se numero do jogador for mais que o numeros de jogadores total, entao clico acaba
		li $v0, 4
		la $a0,Pontos						#print á string
		syscall
		
		lw $t0, count_jogador					#print do numero do jogador
		li $v0, 1
		move $a0, $t0
		syscall
		
		li $v0, 4
		la $a0, doispontos					#print á string
		syscall
	
		
		lw $t2, vPoints($t4)					#load do numero que está na posicao do jogador no array
		li $v0, 1						#Da print a esse numero
		move $a0, $t2
		syscall		
		
		li $v0, 4						#print da string
		la $a0, Vitorias	
		syscall
		
		lw $t0, count_jogador					#print do numero do jogador
		li $v0, 1
		move $a0, $t0
		syscall
		
		li $v0, 4
		la $a0, doispontos					#print da string
		syscall
		
		lw $t2, vWins($t4)					#print do numero que esta na posicao do jogador no array
		li $v0, 1
		move $a0, $t2
		syscall
		
		addi $t0, $t0,1						#da reset ao numero do jogador
		addi $t4, $t4, 4						#salta para as proximas posiçoes do array
		sw $t0, count_jogador
	
		j LOOOP
FIMM:

		li $v0 4
		la $a0, Empates						#print a string
		syscall
		
		lw $t2, draw						#load do numero de empates
		li $v0, 1						#print a esse numero
		move $a0, $t2
		syscall
		lw $t5,ImprimirPontos
		
		bne $t5, 0, menu
		j pontosend						#salta para pontos end

printPointsMsgErro:
	li $v0, 4
	la $a0, MsgPontosErro						#Print da string de erro
	syscall
	j menu


pontosend:
jal Cleanmatriz
jal CleanDesenho							#Funcao para meter a 1's o vetor que auxilia o desenho
#j   CleanBitMap 							#Funcao de limpar o bitmap( descomentar para ativar, nao funciona muito bem)
j AskRepetir

CleanDesenho:								#Funcao que reseta a 1's o vetor que auxiliar o desenho
	 add $t0, $0, $0
	 add $t2, $0, $0
	 lw $t3, maiorlinha
	 CICLO11:
	 	beq  $t0, $t3, FIM11
	 	lw $t1, vDesenho($t2)
	 	addi $t1, $0, 1
	 	sw $t1, vDesenho($t2)
	 	addi $t0, $t0, 1
	 	addi $t2, $t2, 4
	 	j CICLO11
	 FIM11:
	 jr $ra	
	 
AskRepetir:

	li $v0, 4
	la $a0, Repetir							#print á string
	syscall
	li $v0, 5							#Le o valor
	syscall
	beq $v0, 1, RepetirJogo						#Se for 1 repete jogo com mesmo numero de jogadores
	beq $v0, 0, ResetPoints						#Se for 0 pergunta um novo numero de jogadores
	beq $v0, 2, menu						#Se for 2 irá voltar ao menu para futuras utilizacoes
	j ErroAskRepetir



ResetPoints:								#funcao que da reset aos vetores de pontos e wins quando  se muda o n de jogadores
	add $t0, $0, $0
	add $t1, $0, $0
	lw $t2, nPlayers
		clic:
		beq $t0, $t2, fimmmm
		lw $t4, vPoints($t1)
		add $t4, $0, $0
		sw $t4, vPoints($t1)
		lw $t5, vWins($t1)
		add $t5, $0, $0
		sw $t5, vWins($t1)
		addi $t0, $t0, 1
		addi $t1, $t1, 4
		j clic
	fimmmm:
	lw $t6, draw
	add $t6, $0, $0
	sw $t6, draw
	j main

RepetirJogo:
	lw $t0, posWinner						#Load da pos winner dos vetores
	add $t0, $0, $0							
	sw $t0, posWinner						#Da reset ao dados da posWinnier
	jal mat_print
	j reset_player

ErroAskRepetir:
	li $v0, 4
	la $a0, MsgErroRepetir						#print de msg de erro
	syscall
	j AskRepetir

Cleanmatriz:
	lw $a1, maiorlinha								
	lw $a2, maiorcoluna										
	lw $a3, count_jogador		
	la $s0, mat	
	lw $s0,0($s0)								
	add $t3, $zero, $s0	 								
	add $t0, $zero, $0						

	mat_scan11111:	
		 			 						
		bge $t0, $a2, 	 mat_enddddd										
		add	$t1, $zero, $zero 		
				
	mat_scan22222: 				
				
		bge	$t1, $a2, mat_end_collllll	
		mul	$t5, $t0, $a2			
		add	$t5, $t5, $t1			
		sll	$t4, $t5, 2			
		add	$t5, $t4, $t3	 		
		
		lw 	$a0, 0($t5)				
		add $a0, $0, $0						#Reseta a posicao da matriz e coloca a 0
		sw $a0, 0($t5)
		 
		 				
	
	 
			addi $t1, $t1, 1
			j mat_scan22222
	mat_end_collllll:					
		
			add $t0, $t0, 1				
			j mat_scan11111		
			
	mat_enddddd:	
		lw $t8, countjogadas
		add $t8, $0, $0
		sw $t8, countjogadas
		jr $ra					
		





####################################################################################################################################
inicioX:
	lw $t1, GrelhaX					#Tamanho do espaçamento estre as colunas
	addiu $t1, $0, 0
	sw $t1, GrelhaX					
	lw $t1, maiorlinha				#Load do numero de linhas
	addiu $t6, $0, 512				#t6=largura do display
	divu $t6, $t1					#Divide tamanho do display pelo n de coluns
	mflo $t7 					#fica apenas com a parte inteira
	addiu $t7, $t7, -1					
	sw $t7, EspacoX
	addiu $t5, $0, 0					#i=0

DesenhoTabX:
	lw $t9,maiorlinha				#Load do numero de linhas em t9
	bgt $t5, $t9, ENDD				#Enquanto i<Colunas
	
	
	lw $a0, GrelhaX 				#Cordenadas do X
	li $a1,7 					#Pixeis largura (Nesta caso das riscas da grelha)
	li $a2,0					#Cordenadas do Y	
	li $a3,256					#Pixeis altura	
	li $t0, 0x0000FF				#cor azul
	
	jal rectangle					#Funcao de desenhar
	
	lw $t8, GrelhaX					#Da load do espaçamento
	addu $t8, $t8,$t7				#Adiciona esse valor a ele propio mais o espaçamento (t7)
	sw $t8, GrelhaX					#Da save
	addiu $t5, $t5, 1				#i++
	j DesenhoTabX

ENDD: 
j inicioY						#Salta para desenhar as linhas 

inicioY:
	lw $t1, GrelhaY					#Tamanho do espaçamento entre as linhas
	addiu $t1, $0, 0					#Da reset
	sw $t1, GrelhaY					#Da save
	lw $t1, maiorlinha				#Load do numero de linhas
	addiu $t6, $0, 256				#t6 fica com o valor da altura dos display
	divu $t6, $t1					#Divide altura do dysplay pelo numero de linhas
	mflo $t7 					#Fica com a parte inteira
	addiu $t7, $t7,-1				#Ajusta
	sw $t7, EspacoY
	addiu $t5, $0, 0					#i=0

DesenhoTabY:
	lw $t9,maiorlinha				#load do numero de linhas
	bgt $t5, $t9, END				#Enquanto o i<linhas
		
	li $a0,0					#Cordenada do X
	li $a1,512					#Pixeis largura
	lw  $a2,GrelhaY					#Cordenada do Y
	li $a3,7					#Pixeis altura
	li $t0, 0x0000FF
	jal rectangle					#Funcao de desenhar
	lw $t8, GrelhaY					#Load das cordenadas de y
	addu $t8, $t8,$t7				#Adiciona o espaçamento
	sw $t8, GrelhaY					#Da save
	addiu $t5, $t5, 1				#i++
	

	j DesenhoTabY
 
rectangle:
							# $a0 is xmin (i.e., left edge; must be within the display)
							# $a1 is width (must be nonnegative and within the display)
							# $a2 is ymin  (i.e., top edge, increasing down; must be within the display)
							# $a3 is height (must be nonnegative and within the display)

	beq $a1,$zero,rectangleReturn 			# zero width: draw nothing
	beq $a3,$zero,rectangleReturn 			# zero height: draw nothing

							# color: blue
	la $t1,frameBuffer
	add $a1,$a1,$a0 				# simplify loop tests by switching to first too-far value
	add $a3,$a3,$a2
	sll $a0,$a0,2 					# scale x values to bytes (4 bytes per pixel)
	sll $a1,$a1,2
	sll $a2,$a2,11 					# scale y values to bytes (512*4 bytes per display row)
	sll $a3,$a3,11
	addu $t2,$a2,$t1 				# translate y values to display row starting addresses
	addu $a3,$a3,$t1
	addu $a2,$t2,$a0 				# translate y values to rectangle row starting addresses
	addu $a3,$a3,$a0
	addu $t2,$t2,$a1 				# and compute the ending address for first rectangle row
	li $t4,0x800 					# bytes per display row

rectangleYloop:
	move $t3,$a2 					# pointer to current pixel for X loop; start at left edge

rectangleXloop:
	sw $t0,($t3)
	addiu $t3,$t3,4
	bne $t3,$t2,rectangleXloop 			# keep going if not past the right edge of the rectangle

	addu $a2,$a2,$t4 				# advace one row worth for the left edge
	addu $t2,$t2,$t4 				# and right edge pointers
	bne $a2,$a3,rectangleYloop 			# keep going if not off the bottom of the rectangle

rectangleReturn:	
	jr $ra

END:
	j FIMDESENHOTABULEIRO
	

peca:	
	lw $s4, count_jogador
	beq $s4, 1 , PecaJogador1					#Pixeis altura	
	beq $s4, 2 , PecaJogador2
	beq $s4, 3 , PecaJogador3
	beq $s4, 4 , PecaJogador4
	beq $s4, 5 , PecaJogador5
	pecahelp:
	lw $t0, CorJogador
	lw $s2, pos
	lw $t7, EspacoY	
		
	lw $s0, vDesenho($s2)
	mul $t7, $t7, $s0
	addu $t8, $0, 256					#t8=256
	addu $t8, $t8, -7					#t8=256-7
	sub $t8, $t8, $t7					#t8=256-7-x
	lw $t9, EspacoX
	divu $s3, $s2, 4
	mul $t9, $t9, $s3
	addiu $t9, $t9, 7
	
	addu $a0,$t9  , $0					#Cordenadas do X
	lw $a1,EspacoX						#Pixeis largura (Nesta caso das riscas da grelha)
	subu $a1, $a1 , 7
	addu $a2,$t8, $0					#Cordenadas do Y	
	lw $a3,EspacoY
	

	
	jal rectangle						#Funcao de desenhar
	lw $s0, vDesenho($s2)
	addiu $s0, $s0, 1
	sw $s0, vDesenho($s2)
	j FIMDESENHO
	
	
PecaJogador1:
	li $t0, 0xFFFF00
	sw $t0, CorJogador
	j pecahelp
PecaJogador2:
	li $t0, 0xFF0000
	sw $t0, CorJogador
	j pecahelp
PecaJogador3:
	li $t0, 0xFF00FF
	sw $t0, CorJogador
	j pecahelp
PecaJogador4:
	li $t0, 0x00FF00
	sw $t0, CorJogador
	j pecahelp
PecaJogador5:
	li $t0, 0xFFFFFF
	sw $t0, CorJogador
	j pecahelp
CleanBitMap:
	
		
	li $a0,0					#Cordenada do X
	li $a1,512					#Pixeis largura
	li  $a2,0					#Cordenada do Y
	li $a3,256					#Pixeis altura
	li $t0, 0x000000				#Cor preta
	jal rectangle					#Funcao de desenhar
	j AskRepetir						
					
####################################################################################################################################

exit:
li $v0, 4
la $a0,MSGFim						#Print da string
syscall
li $v0, 10						#Fim do programa
syscall


