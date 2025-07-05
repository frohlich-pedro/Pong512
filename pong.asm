bits 16
org 0x7c00

_start:
	mov	ax,	0x3
	int	0x10
	mov	ah,	0x1
	mov	cx,	0x2000
	int	0x10
    
	mov	al,	40
	mov	[b_x],	al
	mov	al,	12
	mov	[b_y],	al
	mov	al,	1
	mov	[b_dx],	al
	mov	[b_dy],	al
	mov	al,	10
	mov	[p1_y],	al
	mov	[p2_y],	al
    
	mov	ax,	[b_x]
	mov	[p_b],	ax
	mov	ax,	[p1_y]
	mov	[p_p],	ax
    
	xor	bl,	bl

border:
	mov	ah,	0x2
	xor	bh,	bh
	xor	dh,	dh
	mov	dl,	bl
	int	0x10
	mov	ah,	0x9
	mov	al,	'-'
	mov	bl,	0xf
	mov	cx,	1
	int	0x10
	mov	dh,	24
	mov	ah,	0x2
	int	0x10
	mov	ah,	0x9
	int	0x10
	mov	bl,	dl
	inc	bl
	cmp	bl,	80
	jl	border
    
game_loop:
	mov	ah,	0x2
	xor	bh,	bh
	mov	dl,	[p_b]
	mov	dh,	[p_b+1]
	int	0x10
	mov	ah,	0xa
	mov	al,	' '
	mov	cx,	1
	int	0x10

	mov	dl,	2
	mov	dh,	[p_p]
	call	erase_pad
	mov	dl,	77
	mov	dh,	[p_p+1]
	call	erase_pad

	mov	ah,	0x1
	int	0x16
	jz	no_key
	mov	ah,	0x0
	int	0x16

	cmp	al,	'q'
	je	p1_up
	cmp	al,	'a'
	je	p1_down
	cmp al, 'p'
	je	p2_up
	cmp	al,	'l'
	je	p2_down
	jmp	no_key
    
p1_up:
	cmp	byte	[p1_y],	1
	jle	no_key
	dec	byte	[p1_y]
	jmp	no_key
    
p1_down:
	cmp	byte	[p1_y],	20
	jge	no_key
	inc	byte	[p1_y]
	jmp	no_key
    
p2_up:
	cmp	byte	[p2_y],	1
	jle	no_key
	dec	byte	[p2_y]
	jmp	no_key
    
p2_down:
	cmp	byte	[p2_y],	20
	jge	no_key
	inc	byte	[p2_y]
    
no_key:
	mov	al,	[b_x]
	add	al,	[b_dx]
	mov	[b_x],	al
	mov	al,	[b_y]
	add	al,	[b_dy]
	mov	[b_y],	al

	cmp	byte	[b_y],	1
	jle	flip_y
	cmp	byte	[b_y],	23
	jge	flip_y
	jmp	check_x
    
flip_y:
	neg	byte	[b_dy]
    
check_x:
	cmp	byte	[b_x],	3
	jne	check_right
	mov	al,	[b_y]
	mov	bl,	[p1_y]
	cmp	al,	bl
	jl	check_right
	add	bl,	3
	cmp	al,	bl
	jg	check_right
	neg	byte	[b_dx]
    
check_right:
	cmp	byte	[b_x],	76
	jne	check_reset
	mov	al,	[b_y]
	mov	bl,	[p2_y]
	cmp	al,	bl
	jl	check_reset
	add	bl,	3
	cmp	al,	bl
	jg	check_reset
	neg	byte	[b_dx]
    
check_reset:
	cmp	byte	[b_x],	0
	je	reset_ball
	cmp	byte	[b_x],	79
	jne	draw_game
    
reset_ball:
	mov	al,	40
	mov	[b_x],	al
	mov	al,	12
	mov	[b_y],	al
	neg	byte	[b_dx]
    
draw_game:
	mov	ax,	[b_x]
	mov	[p_b],	ax
	mov	ax,	[p1_y]
	mov	[p_p],	ax

	mov	dl,	2
	mov	dh,	[p1_y]
	call	draw_pad
	mov	dl,	77
	mov	dh,	[p2_y]
	call	draw_pad

	mov	ah,	0x2
	xor	bh,	bh
	mov	dl,	[b_x]
	mov	dh,	[b_y]
	int	0x10
	mov	ah,	0x9
	mov	al,	'O'
	mov	bl,	0xf
	mov	cx,	1
	int	0x10

	mov	cx,	0x1
	xor	dx,	dx
	mov	ah,	0x86
	int	0x15

	jmp	game_loop

draw_pad:
	mov	cx,	4

dp_loop:
	mov	ah,	0x2
	xor	bh,	bh
	int	0x10
	mov	ah,	0x9
	mov	al,	'|'
	mov	bl,	0xf
	push	cx
	mov	cx,	1
	int	0x10
	pop	cx
	inc	dh
	loop	dp_loop
	ret

erase_pad:
	mov	cx,	4

ep_loop:
	mov	ah,	0x2
	xor	bh,	bh
	int	0x10
	mov	ah,	0xa
	mov	al,	' '
	push	cx
	mov	cx,	1
	int	0x10
	pop	cx
	inc	dh
	loop	ep_loop
	ret

b_x:	db	40
b_y:	db	12
b_dx:	db	1
b_dy:	db	1
p1_y:	db	10
p2_y:	db	10
p_b:	dw	0
p_p:	dw	0

times	510-($-$$)	db	0
dw	0xaa55
