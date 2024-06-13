global sair

; Função para sair do programa
sair:
    mov     ah,0            ; set video mode
	mov     al,[modo_anterior]      ; modo anterior
	int     10h
	mov     ax,4c00h
	int     21h

%include "Data.asm"