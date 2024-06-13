global plot_xy
extern cor

plot_xy:
	push	bp
	mov		bp,sp
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	mov     ah,0ch
	mov     al,[cor]
	mov     bh,0
	mov     dx,479
	sub		dx,[bp+4]
	mov     cx,[bp+6]
	int     10h
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		4