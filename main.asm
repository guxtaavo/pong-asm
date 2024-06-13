; Sistemas Embarcados I - 2024/01 – UFES
; Projeto ASM
; Camila Audibert e Gustavo Nunes

; Para se fazer as interrupções e leitura de teclado, foi tomado como referência o seguinte documento:
; https://www.ic.unicamp.br/~celio/mc404-2004/service_interrupts#int21h

extern line, full_circle, cursor, caracter, plot_xy, full_rectangle, sair
global cor

; Inicializa os registradores
segment code
..start:
                        
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    mov sp,stacktop

; Inicializa o modo de vídeo
    mov ah,0Fh
    int 10h
    mov [modo_anterior],al
    mov al,12h
    mov ah,0
    int 10h

; Função wait_enter funciona como um loop infinito. Ele fica verificando
; se o jogador pressionou enter para inicializar a partida, caso contrário,
; irá continuar no loop esperando.
wait_enter:

; Mostra a mensagem na tela
    mov     ah, 09h
    mov     dx, msg_enter
    int     21h

    mov     ah, 01h           ; lê o caractere da entrada padrão, o resultado é armazenado em AL.
    int     21h

    cmp     al, 0Dh           ; Verifica se a tecla 'enter' foi pressionada (0Dh código da tecla enter)
    je      inicializa_jogo   ; Se sim, inicia o jogo
    jmp     wait_enter        ; Senão, continua esperando


; Inicialização da parte gráfica do jogo
inicializa_jogo:
    call desenhar_blocos
	mov byte[cor],branco_intenso
	call desenhar_bordas
    call desenhar_raquete
    call desenhar_bolinha

;----------------------------------------------------------------------------
; Loop principal do jogo (movimentação da raquete e bolinha)
jogo:

; Função check_pause verifica se o [pausado] é igual a 1
; Caso o [pausado] for igual a 1, o jogo está em pause, e então,
; entra em um loop de espera chamado wait_for_resume, que funciona da mesma maneira
; da verificação do enter, porém, vai verificar a tecla 'P', e caso for despausado, continua 
; a execução da partida
check_pause:
    mov     al, [pausado]
    cmp     al, 1
    jne     resume_game       ; Pula para resume_game se [pausado] == 0
    jmp     wait_for_resume

; Se pausado, entra no loop de espera
wait_for_resume:
    ; Verifica se há uma tecla pressionada (sem bloquear)
    mov     ah, 01h
    int     16h               ; Chamada de interrupção 16h (BIOS) para verificar o status do teclado
    jz      wait_for_resume   ; Se não há tecla pressionada, continua esperando

    ; Lê a tecla pressionada (sem exibi-la na tela)
    mov     ah, 00h
    int     16h               ; Chamada de interrupção 16h (BIOS) para ler a tecla pressionada

    cmp     al, 'p'           ; Verifica se a tecla 'P' foi pressionada
    jne     wait_for_resume   ; Se não, continua esperando

    mov     al, [pausado]
    xor     al, 1             ; Inverte o valor de [pausado]
    mov     [pausado], al

    jmp     resume_game       ; Continua o jogo

; Inicia de fato o jogo
resume_game:
	inc		word[modo_pixel]
	call 	testa_teclas
    mov		byte[cor],preto
	call	desenhar_bolinha	;irá criar a interface da bolinha na tela
	call	raqueteMover		;irá mover a raquete na tela
	call	desenhar_raquete	;ira criar a interface da raquete na tela

;ajustando a posicao da raquete no eixo X e Y  (ajusta X e Y)
	mov		dx,[raquete_posicaoY]		
	cmp		dx,371

raqueteAjustaPosicaoX:
; Deslocamento da posição da bola em x (decrementa X)
	xor		ax,ax
	mov		cx,[bola_movimento]
	mov		al,[bola_velocidadeX]
	inc		ax
	cmp		al,0
	jbe		bolaDecrementaX
	add		word[bola_posicaoX],cx
	jmp		bolaIncrementaY

bolaDecrementaX:
	sub		word[bola_posicaoX],cx	

; Deslocamento da posição da bola em y (incrementa e decrementa Y)
bolaIncrementaY:
	xor		ax,ax
	mov		al,[bola_velocidadeY]
	cmp		al,0
	js		bolaDecrementaY
	add		word[bola_posicaoY],cx			
	jmp		colisao_bolinha_raquete
bolaDecrementaY:
	sub		word[bola_posicaoY],cx


; Tratamento de colisao com a raquete e bolinha
colisao_bolinha_raquete:
	mov		byte[cor],branco_intenso
	call	desenhar_bolinha
	call	colisao
	call 	colisao_bloco
	call	verifica_se_ganhou
	jmp		jogo
; ---------------------------------------------------------------------------

; divisórias da interface
desenhar_bordas:
	mov		byte[cor],branco_intenso
	mov		ax,1
	push	ax
	mov		ax,1
	push	ax
	mov		ax,1
	push	ax
	mov		ax,479
	push	ax
	call	line

	mov		byte[cor],branco_intenso
	mov		ax,1
	push	ax
	mov		ax,479
	push	ax
	mov		ax,639
	push	ax
	mov		ax,479
	push	ax
	call	line

	mov		byte[cor],branco_intenso
	mov		ax,639
    push	ax
	mov		ax,1
	push	ax
	mov		ax,639
	push	ax
	mov		ax,479
	push	ax
	call	line
ret

desenhar_blocos:
;bloco para apagar a msg na parte superior esquerda caso seja reiniciado o jogo
	mov		byte[cor],preto
	mov		ax,1 		;x
	push	ax
	mov		ax,250		;y
	push	ax
	mov		ax,639		;comprimento
	push	ax
	mov		ax,100		;largura
	push	ax
	call	full_rectangle

;bloco para apagar a parte de baixo (raquete e bolinha) caso seja reiniciado o jogo
	mov		byte[cor],preto
	mov		ax,1
	push	ax
	mov		ax,0
	push	ax
	mov		ax,639
	push	ax
	mov		ax, 80
	push	ax
	call	full_rectangle

;bloco para apagar a mensagem do pressione enter
	mov		byte[cor],preto
	mov		ax,0
	push	ax
	mov		ax,400
	push	ax
	mov		ax,400
	push	ax
	mov		ax,80
	push	ax
	call	full_rectangle

	mov		byte[cor],vermelho
	mov		ax,22
	push	ax
	mov		ax,435
	push	ax
	mov		ax,598
	push	ax
	mov		ax,20
	push	ax
	call	full_rectangle

	mov		byte[cor],azul
	mov		ax,22
	push	ax
	mov		ax,405
	push	ax
	mov		ax,598
	push	ax
	mov		ax,20
	push	ax
	call	full_rectangle

	mov		byte[cor],preto
	mov		ax,315
	push	ax
	mov		ax,405
	push	ax
	mov		ax,10
	push	ax
	mov		ax,50
	push	ax
	call	full_rectangle

	mov		byte[cor],preto
	mov		ax,113
	push	ax
	mov		ax,405
	push	ax
	mov		ax,10
	push	ax
	mov		ax,50
	push	ax
	call	full_rectangle

	mov		byte[cor],preto
	mov		ax,214
	push	ax
	mov		ax,405
	push	ax
	mov		ax,10
	push	ax
	mov		ax,50
	push	ax
	call	full_rectangle

	mov		byte[cor],preto
	mov		ax,416
	push	ax
	mov		ax,405
	push	ax
	mov		ax,10
	push	ax
	mov		ax,50
	push	ax
	call	full_rectangle

	mov		byte[cor],preto
	mov		ax,517
	push	ax
	mov		ax,405
	push	ax
	mov		ax,10
	push	ax
	mov		ax,50
	push	ax
	call	full_rectangle
ret


; função para desenhar a bolinha
desenhar_bolinha:
	mov			cx,[bola_posicaoX]
	push		cx
	mov			cx,[bola_posicaoY]
	push		cx
	mov			cx,bola_raio
	push		cx
	call		full_circle
ret

; função para desenhar a raquete
desenhar_raquete:
	mov		byte[cor],branco_intenso
	mov		ax,[raquete_posicaoX]
	push	ax
	mov		ax,10
	push	ax
	mov		ax,90
	push	ax
	mov		ax,10
	push	ax
	call	full_rectangle
ret		

; Interface ganhou
ganhou:
    mov     ah, 02h        ; Função 02h: Definir a posição do cursor
    mov     bh, 0          ; Página de vídeo
    mov     dh, 10         ; Linha
    mov     dl, 15         ; Coluna
    int     10h            ; Chamada de interrupção de BIOS de vídeo

    mov     ah, 09h        ; Função 09h: Exibir uma string na tela
    mov     dx, msg_ganhou ; Endereço da mensagem
    int     21h            ; Chamada de interrupção

    ; Loop infinito para manter a mensagem na tela
fim:
    jmp fim                ; Loop infinito

ret

; Rotina para ajustar a raquete
raqueteMover:
	xor		ax,ax                     ; Zera o registrador AX
	mov		al,byte[raquete_checa]    ; Move o valor de raquete_checa para AL
	cmp		al,0                     
	ja		raquetePara               ; Se AL for maior que 0, pula para raquetePara
	mov		dx,[raquete_posicaoX]     ; Se nao, move a posição atual da raquete em X para DX
	mov		cx,[raquete_movimento]    ; Move o valor de raquete_movimento para CX
	mov		ah,[raquete_velocidade]   ; Move a velocidade da raquete para AH
	inc		ah                        ; Incrementa AH (velocidade da raquete)
	cmp		ah,1                      ; Compara AH com 1
	jz		raqueteFinal              ; Se AH for igual a 1, pula para raqueteFinal
	ja		raquetePosicao            ; Se AH for maior que 1, pula para raquetePosicao

raquete_oposto:
	cmp		dx,10                     ; Compara a posição X da raquete com 10
	jb		raqueteFinal              ; Se DX for menor que 10, pula para raqueteFinal

	mov		byte[cor],preto           ; ; Desenha um retangulo preto pra apagar a posiçao anterior da raquete
	mov		ax,[raquete_posicaoX]     
	push	ax                        
	mov		ax,10                    
	push	ax                   
	mov		ax,91                    
	push	ax                        
	mov		ax,10                
	push	ax                        
	call	full_rectangle            ; Chama a função full_rectangle para desenhar um retângulo

	; Mudando para a nova posição
	sub		[raquete_posicaoX],cx    ; Subtrai o movimento da raquete da posição X
	mov		byte[raquete_checa],1    ; Define raquete_checa para 1, permitindo movimento a cada 1 frame
	jmp		raqueteFinal             ; Pula para raqueteFinal

raquetePosicao:
	cmp		dx,538                   ; Compara a posição X da raquete com 538 (corresponde a quando ela chega no final da tela)
	ja		raqueteFinal             ; Se DX for maior que 538, pula para raqueteFinal

	mov		byte[cor],preto          ; Desenha um retangulo preto pra apagar a posiçao anterior da raquete
	mov		ax,[raquete_posicaoX]    
	push	ax                       
	mov		ax,10                 
	push	ax                      
	mov		ax,89                   
	push	ax                       
	mov		ax,10                
	push	ax                       
	call	full_rectangle           

	; Mudando para a nova posição
	add		[raquete_posicaoX],cx    ; Adiciona o movimento da raquete à posição X
	mov		byte[raquete_checa],1    ; Define raquete_checa para 1, permitindo movimento a cada 1 frame
	jmp		raqueteFinal             ; Pula para raqueteFinal

raquetePara:
	dec		byte[raquete_checa]      ; Decrementa raquete_checa

raqueteFinal:
	mov		byte[raquete_velocidade],0 ; Define a velocidade da raquete para 0
	ret                             ; Retorna da rotina


; Tratamento de colisão
colisao:

; Verificando colisão com a bola
	mov 	bx,[bola_posicaoX]		;coloca a posiçao atual do centro da bola em x em bx
	mov		dx,[bola_posicaoY]		;coloca a posiçao atual do centro da bola em y em dx

; Verificando colisão com a raquete em y
	cmp		dx,20+bola_raio			;verifica se o centro da bola chegou em y 28(posiçao do topo da raquete+raio, sempre levamos o raio em consideraçao na colisao para aparentar uma colisao com as bordas da bola)
	ja		raquete_nao_colidiu	;se a posiçao y for maior, a bolinha nao esta na altura da raquete, o que ja desqualifica a colisao

; Verificando colisão com a raquete em x
	mov		ax,[raquete_posicaoX]   ;coloca a posiçao atual da extremidade esqauerda da raquete em ax 
	cmp		bx,ax					;compara a posiçao atual da raquete com a posiçao atual da bolinha em x
	jb		raquete_nao_colidiu		;se for menor, descarta a colisao
	add		ax,raquete_tamanho		;adiciona o tamanho da raquete na posiçao inicial da extremidade esqauerda, para analisar agora a extremidade direita 
	cmp		bx,ax					;compara com a posiçao x da bola
	ja		raquete_nao_colidiu		; se for maior, descarta colisao
	jmp 	raquete_colidiu			 ;se chegou aqui, é porque a bolinha esta entre a extremidade esquerda e direita da raquete, e na sua altura em y, ou seja, houve colisao

raquete_nao_colidiu:
	jmp		colisaoX				;se nao houve colisao com a raquete, testa se houve com as paredes

raquete_colidiu:
	neg		byte[bola_velocidadeY]  ;se houve colisao, inverte os sinais da velocidade da bolinha em y, fazendo ela subir
	jmp 	colisaoRET				

; Verificando colisão com as paredes
colisaoX:
	cmp		bx,639-bola_raio		;compara se a borda da bola colidiu com a parede direita 
	jae		colidiu_X		;se sim, colisao efetivada
	cmp		bx,10+bola_raio			;compara se a borda da bola colidiu com a parede esquerda
	jbe		colidiu_X      ;se sim, colisao efetivada
	jmp		colisaoY				;se nao, verifica colisao no no teto e no chao

colidiu_X:
	neg	    byte[bola_velocidadeX]  ;se houve colisao na parede direita ou esquerda, inverte a velocidade em x(invertendo a direçao do movimento para esquerda ou direita)

colisaoY:
	call	desenhar_bordas			;desenha bordas pois devido a animaçao desenhar uma bolinha preta no caminho da bola, acaba apagando um pixel da parede onde colidiu
	cmp		dx,478-bola_raio		;compara se a borda da bola colidiu com o teto
	jae		colidiu_Y		;se sim, colisao efetivada
	cmp		dx,1+bola_raio			;compara se a borda da bola colidiu com o chao
	jbe		game_over 				;se colidiu com o chao, o jogador perdeu, entao chama a função de game over
	jmp		colisaoRET				;se nao houve colisao, vai sair

colidiu_Y:
	neg		byte[bola_velocidadeY]	;inverte a direçao do movimento em y

colisaoRET:
	ret
; Definir a posição do cursor para exibir a mensagem "Game Over"
game_over:
    mov     ah, 02h        ; posição do cursor
    mov     bh, 0          ; pag de vídeo
    mov     dh, 10         ; linha
    mov     dl, 15         ; coluna
    int     10h

; exibir a mensagem na tela
    mov     ah, 09h
    mov     dx, msg_game_over
    int     21h

game_over2:
    ; Verifica se uma tecla foi pressionada
    mov     ah, 00h
    int     16h

    ; Verifica se a tecla 'Y' foi pressionada, e chama função para reiniciar o jogo
    cmp     al, 'y'
    je      reiniciar_jogo

    ; Verifica se a tecla 'N' foi pressionada, e chama a função para sair do jogo
    cmp     al, 'n'
    je      sair_game_over

; se nenhuma tecla esperada foi pressionada, vai voltar para o game_over2, onde
; vai ficar nesse loop, até que alguma tecla esperada seja pressionada
    jmp     game_over2

sair_game_over:
    call    sair
    ret


; Função para reiniciar o jogo
reiniciar_jogo:
    ; Redefinir todas as variáveis do jogo para seus valores iniciais
	; para que se possa reiniciar o jogo corretamente
    mov byte [pausado], 0
    mov byte [jogo_iniciado], 0
    mov byte [raquete_velocidade], 15
    mov byte [raquete_movimento], 10
    mov byte [raquete_checa], 0
    mov byte [raquete_colisao], 0
    mov word [raquete_posicaoY], 20
    mov word [raquete_posicaoX], 275
    mov byte [bola_velocidadeX], 1
    mov word [bola_posicaoX], 320
    mov byte [bola_velocidadeY], -1
    mov word [bola_posicaoY], 33
    mov word [blocoy1], 405
    mov word [blocoy2], 405
    mov word [blocoy3], 405
    mov word [blocoy4], 405
    mov word [blocoy5], 405
    mov word [blocoy6], 405

	; Pula para o inicio do código, com as váriaveis redefinidas, assim, reiniciando a partida.
    jmp inicializa_jogo

; Tratamento de colisão bloco
colisao_bloco:
; Verificando colisão com a bola
	mov 	bx,[bola_posicaoX]		;coloca a posiçao atual do centro da bola em x em bx
	mov		dx,[bola_posicaoY]		;coloca a posiçao atual do centro da bola em y em dx

; Verificando colisão com o bloco em y
	mov		ax,[blocoy1]            ;move o y da parte inferior do bloco da fileira 1, ou se ele ja foi quebrado do bloco 2, para ax
	sub		ax,bola_raio			;leva o raio da bola em consideraçao
	cmp		dx,ax					;compara se a borda da bola colidiu com a parte inferior do bloco 1
	jae		verif_x1				;se for maior ou igual, significa que existe a chance de colisao e deve ser verificadas as coordenadas x
continua1:							;repete para o bloco 2
	mov		ax,[blocoy2]
	sub		ax,bola_raio
	cmp		dx,ax
	jae		verif_x2
continua2:							;repete para o bloco 3
	mov		ax,[blocoy3]
	sub		ax,bola_raio
	cmp		dx,ax
	jae		verif_x3
continua3:							;repete para o bloco 4
	mov		ax,[blocoy4]
	sub		ax,bola_raio
	cmp		dx,ax
	jae		verif_x4
continua4:							;repete para o bloco 5
	mov		ax,[blocoy5]
	sub		ax,bola_raio
	cmp		dx,ax
	jae		verif_x5
continua5:							;repete para o bloco 6
	mov		ax,[blocoy6]
	sub		ax,bola_raio
	cmp		dx,ax
	jae		verif_x6		
	jmp		BlocoColisaoNegada

; Verificando colisão com o bloco em x
verif_x1:
	mov		ax,22-bola_raio			;move para ax a posiçao da borda esquerda do bloco menos o raio da bola 
	cmp		bx,ax					;compara com a posiçao da bola
	jb		continua1				;se for menor, a bola esta a esquerda do bloco e nao colidiu, entao volta pra verificar a colisão em y os outros blocos
	add		ax,91+bola_raio			;move para ax a posiçao da borda direita do bloco mais o raio da bola 
	cmp		bx,ax					;compara com a posiçao da bola
	ja		continua1				;se for maior, a bola esta a direita do bloco e nao colidiu, entao volta para verificar a colisão em y nos outros blocos
	jmp 	Bloco1ColisaoEfetivada	;se for menor, a bola esta entre a esquerda e direita do bloco, e ja foi visto que esta em y do bloco, ou seja, houve colisao
	
verif_x2:							;repete para o bloco 2
	mov		ax,123-bola_raio
	cmp		bx,ax
	jb		continua2
	add		ax,91+bola_raio
	cmp		bx,ax
	ja		continua2
	jmp 	Bloco2ColisaoEfetivada

verif_x3:							;repete para o bloco 3
	mov		ax,224-bola_raio
	cmp		bx,ax
	jb		continua3
	add		ax,91+bola_raio
	cmp		bx,ax
	ja		continua3
	jmp 	Bloco3ColisaoEfetivada

verif_x4:							;repete para o bloco 4
	mov		ax,326-bola_raio
	cmp		bx,ax
	jb		continua4
	add		ax,91+bola_raio
	cmp		bx,ax
	ja		continua4
	jmp 	Bloco4ColisaoEfetivada

verif_x5:							;repete para o bloco 5
	mov		ax,427-bola_raio
	cmp		bx,ax
	jb		continua5
	add		ax,91+bola_raio
	cmp		bx,ax
	ja		continua5
	jmp 	Bloco5ColisaoEfetivada

verif_x6:							;repete para o bloco 6
	mov		ax,528-bola_raio
	cmp		bx,ax
	jb		BlocoColisaoNegada
	add		ax,91+bola_raio
	cmp		bx,ax
	ja		BlocoColisaoNegada
	jmp 	Bloco6ColisaoEfetivada	

BlocoColisaoNegada:
	jmp		colisao_blocoRET

Bloco1ColisaoEfetivada:
	cmp     dx,[blocoy1]				;compara a posiçao em y da bola com o y do bloco
	jae		colisaoLateral1				;se for maior significa que a colisao ocorreu lateralmente (a colisao detecta impacto da borda da bola embaixo do bloco e inverte a velocidade, ou seja se o centro da bola esta acima de blocoy1 a colisao nao veio de baixo)
	jmp		colisaoEmbaixo1				;se for menor significa que a bola veio de baixo
colisaoLateral1:	
	neg		byte[bola_velocidadeX]		;se a colisao ocorreu lateralmente a bola muda de direçao horizontal
	jmp		apagaBloco1
colisaoEmbaixo1:						;se a colisao ocorrei de baixo a bola muda de direçao verticalmente
	neg		byte[bola_velocidadeY]
	jmp		apagaBloco1
apagaBloco1:		
	mov		byte[cor],preto				;desenha um retangulo preto pra apagar o bloco onde ocorreu a colisao, usa os parametros x,largura e comprimento fixos de cada bloco e o que muda é o y para corresponder ao bloco superior ou inferior					
	sub		ax,91
	push	ax
	mov		ax,[blocoy1]
	push	ax
	mov		ax,95
	push	ax
	mov		ax,20
	push	ax
	call	full_rectangle
	add		word[blocoy1],30			;adiciona 30 ao y do bloco da coluna pois é a distancia entre o y do bloco inferior e superior, para a proxima colisao ser detectada no proximo bloco
	jmp 	colisao_blocoRET

Bloco2ColisaoEfetivada:							;repete para o bloco 2
	cmp     dx,[blocoy2]
	jae		colisaoLateral2
	jmp		colisaoEmbaixo2
colisaoLateral2:
	neg		byte[bola_velocidadeX]
	jmp		apagaBloco2
colisaoEmbaixo2:	
	neg		byte[bola_velocidadeY]
	jmp		apagaBloco2
apagaBloco2:		
	mov		byte[cor],preto
	mov		ax,123
	push	ax
	mov		ax,[blocoy2]
	push	ax
	mov		ax,95
	push	ax
	mov		ax,20
	push	ax
	call	full_rectangle
	add		word[blocoy2],30	
	jmp 	colisao_blocoRET
	
Bloco3ColisaoEfetivada:							;repete para o bloco 3
	cmp     dx,[blocoy3]
	jae		colisaoLateral3
	jmp		colisaoEmbaixo3
colisaoLateral3:
	neg		byte[bola_velocidadeX]
	jmp		apagaBloco3
colisaoEmbaixo3:	
	neg		byte[bola_velocidadeY]
	jmp		apagaBloco3
apagaBloco3:
	mov		byte[cor],preto
	sub		ax,91
	push	ax
	mov		ax,[blocoy3]
	push	ax
	mov		ax,95
	push	ax
	mov		ax,20
	push	ax
	call	full_rectangle
	add		word[blocoy3],30
	call	desenhar_bordas
	jmp 	colisao_blocoRET

Bloco4ColisaoEfetivada:							;repete para o bloco 4
	cmp     dx,[blocoy4]
	jae		colisaoLateral4
	jmp		colisaoEmbaixo4
colisaoLateral4:
	neg		byte[bola_velocidadeX]
	jmp		apagaBloco4
colisaoEmbaixo4:	
	neg		byte[bola_velocidadeY]
	jmp		apagaBloco4
apagaBloco4:
	mov		byte[cor],preto
	sub		ax,91
	push	ax
	mov		ax,[blocoy4]
	push	ax
	mov		ax,95
	push	ax
	mov		ax,20
	push	ax
	call	full_rectangle
	call	desenhar_bordas
	add		word[blocoy4],30
	call	desenhar_bordas	
	jmp 	colisao_blocoRET

Bloco5ColisaoEfetivada:							;repete para o bloco 5
	cmp     dx,[blocoy5]
	jae		colisaoLateral5
	jmp		colisaoEmbaixo5
colisaoLateral5:
	neg		byte[bola_velocidadeX]
	jmp		apagaBloco5
colisaoEmbaixo5:	
	neg		byte[bola_velocidadeY]
	jmp		apagaBloco5
apagaBloco5:
	mov		byte[cor],preto
	sub		ax,91
	push	ax
	mov		ax,[blocoy5]
	push	ax
	mov		ax,95
	push	ax
	mov		ax,20
	push	ax
	call	full_rectangle
	add		word[blocoy5],30	
	call	desenhar_bordas
	jmp 	colisao_blocoRET

Bloco6ColisaoEfetivada:							;repete para o bloco 6
	cmp     dx,[blocoy6]
	jae		colisaoLateral6
	jmp		colisaoEmbaixo6
colisaoLateral6:
	neg		byte[bola_velocidadeX]
	jmp		apagaBloco6
colisaoEmbaixo6:	
	neg		byte[bola_velocidadeY]
	jmp		apagaBloco6
apagaBloco6:
	mov		byte[cor],preto
	sub		ax,91
	push	ax
	mov		ax,[blocoy6]
	push	ax
	mov		ax,95
	push	ax
	mov		ax,20
	push	ax
	call	full_rectangle
	add		word[blocoy6],30
	call	desenhar_bordas	
	jmp 	colisao_blocoRET

colisao_blocoRET:
	ret
	
verifica_se_ganhou:						;se todos os blocos foram apagados, o y de todos eles vai ser maior do que Yinicial + 30(primeira colisao)+30(segunda colisao)=465
	cmp		word[blocoy1],464
	jb		Ganhou_ret
	cmp		word[blocoy2],464
	jb		Ganhou_ret
	cmp		word[blocoy3],464
	jb		Ganhou_ret
	cmp		word[blocoy4],464
	jb		Ganhou_ret
	cmp		word[blocoy5],464
	jb		Ganhou_ret
	cmp		word[blocoy6],464
	jb		Ganhou_ret
	call	ganhou 					;se chegou aqui significa que todos os blocos foram quebrados e o jogo acabou, entao chama a funçao que finaliza o jogo e mostra a mensagem de ganhou o jogo
	
Ganhou_ret:
	ret

; Função para sair do programa
sair_do_jogo:
    call sair
	ret

; Função para alternar o estado de pausa
pause:
    mov     al, [pausado]
    xor     al, 1
    mov     [pausado], al
    jmp 	jogo

; Testa a tecla via Interrupção de Hardware (Utilizado o int 16h, link de ref no inicio do código)
testa_teclas:	
; Verifica se há uma tecla pressionada (funcao 01h)
    mov     ah, 01h
    int     16h
    jz      no_key_pressed ; Se ZF = 1, nenhuma tecla foi pressionada
	; assim, evita que o jogo fique travado

; Se uma tecla foi pressionada, vai ler a tecla e posteriormente comparar
    mov     ah, 00h
    int     16h

; Verifica se a tecla 'Q' foi pressionada, e chama a função sair_do_jogo
    cmp     al, 'q'
    je      sair_do_jogo

; Verifica se a tecla 'P' foi pressionada, e chama a função pause
    cmp     al, 'p'
    je      pause

; Verifica se a tecla 'D' foi pressionada, e chama a função testa_seta_direita
    cmp     al, 'd'
    je      testa_seta_direita

; Verifica se a tecla 'A' foi pressionada, e chama a função testa_seta_esquerda
    cmp     al, 'a'
    je      testa_seta_esquerda

no_key_pressed:
    ret

; Move a raquete para direita
testa_seta_direita:
	mov		byte[raquete_velocidade],1
	ret

; Move a raquete para esquerda 
testa_seta_esquerda:
	mov		byte[raquete_velocidade],-1
	ret

; Para evitar com que se digite todo segmento de data novamente em arquivos
%include "Data.asm"
