segment data

	cor		db		branco_intenso

	;	I R G B COR
	;	0 0 0 0 preto
	;	0 0 0 1 azul
	;	0 0 1 0 verde
	;	0 0 1 1 cyan
	;	0 1 0 0 vermelho
	;	0 1 0 1 magenta
	;	0 1 1 0 marrom
	;	0 1 1 1 branco
	;	1 0 0 0 cinza
	;	1 0 0 1 azul claro
	;	1 0 1 0 verde claro
	;	1 0 1 1 cyan claro
	;	1 1 0 0 rosa
	;	1 1 0 1 magenta claro
	;	1 1 1 0 amarelo
	;	1 1 1 1 branco intenso

	preto		equ		0
	azul		equ		1
	verde		equ		2
	cyan		equ		3
	vermelho	equ		4
	magenta		equ		5
	marrom		equ		6
	branco		equ		7
	cinza		equ		8
	azul_claro	equ		9
	verde_claro	equ		10
	cyan_claro	equ		11
	rosa		equ		12
	magenta_claro	equ		13
	amarelo		equ		14
	branco_intenso	equ		15
	linha   	dw  		0
	coluna  	dw  		0
	deltax		dw		0
	deltay		dw		0	

;variáveis para o modo de animação
	modo_anterior		db		0
	modo_pixel			dw		0

;mensagem que irá ser escrita
	msg_game_over       db      'Game Over =( Press "Y" to continue or "N" to leave', 0,0,13,10,'$'
	msg_ganhou			db		'Congratulations! You won! =)$', 0,0,13,10,'$'
	msg_enter 			db 		'Press enter to start...', 0,0,13,10,'$'

;variáveis para a raquete
	raquete_posicaoY        dw  20 
	raquete_posicaoX        dw  275 
	raquete_tamanho		    equ	90
	raquete_velocidade		db  15
	raquete_movimento		db  10
	raquete_checa			db  0
	raquete_colisao			db	0	

; variáveis para a bola
	bola_posicaoX			dw 320 ; Posição inicial 
	bola_velocidadeX		db      1
	bola_colisaoX	        db      0	; Bit que indica se houve colisão com parede em x no frame anterior
	bola_posicaoY			dw  	33 ; Posição inicial y
	bola_velocidadeY		db      -1
	bola_colisaoY	        db      0	; Bit que indica se houve colisão com parede em y no frame anterior
	bola_movimento      	dw  6
	bola_raio				equ 8

; variáveis para verificar se o jogo está pausado
	pausado db 0
	
; variáveis para verificar se o jogo foi iniciado com 'enter'
	jogo_iniciado db 0

;variáveis para colisão dos blocos
	blocoy1					dw		405
	blocoy2					dw		405
	blocoy3					dw		405
	blocoy4					dw		405
	blocoy5					dw		405
	blocoy6					dw		405

segment stack stack
    		resb 		512
stacktop:
