;.286			;masm specific
;.MODEL TINY		;masm specific

;******************************************************************************
;	COM Program that manipulates pixel values of command prompt 
;	by writing directly to VGA buffer
; 	uses techniques of CRASH virus for VGA animation
;	avoids infinite loop of crash virus using conditionals for buffer bounds
;	controls animation using INT 16h keypress return values
;
;
;	
;	To be used in DOSBOX (or similar) MS-DOS Emulator program 
;	Must be compiled with link16.exe (MASM32 preferably) 
;
;******************************************************************************

;.CODE
	org 100h

;******************************************************************************
;	References technique for defining the original interrupt seg + offset
; 	in relation to DS register, used in Stoned.asm 
;

_ORIG16_O	dd	0x0
_ORIG16_S	dd	0x0



ORIG_INT_16_S 	equ 	0x0000+_ORIG16_S	;if making virus
;ORIG_INT_16_S 	equ 	0x07C00+_ORIG16_S	;if making bootkit
ORIG_INT_16_O 	equ 	0x0000+_ORIG16_O
;ORIG_INT_16_O 	equ 	0x07C00+_ORIG16_O
;JUMP_HOOK_CODE_OFFSET
;JUMP_HOOK_CODE_SEGMENT
SCREEN_MAX	equ	320*200
DRAW_HALT	equ	320*50
SCREEN_WIDTH	equ	0x140		;;320
SCREEN_HEIGHT	equ	0xC8		;;200
VGA_PAL_INDEX	equ	0x3C8
VGA_PAL_DATA	equ	0x3C9

LEFT_KEY	equ	0x4B		;;code for left arrow key
RIGHT_KEY	equ	0x4D		;;code for right arrow key
DOWN_KEY	equ	0x50		;;code for down arrow key

;******************************************************************************

;_start	PROC	NEAR ; masm
start:
	mov	ax,0xA000
	mov	es,ax
	mov	ds,ax
	mov	di,0
	jmp	short vga_init

vga_init:
	;mov	ax,0A000h
	;mov	es,ax
	mov	ax, 0x13
	int	10h
	cld

set_pal:
	salc				;set carry flag in al, if carry flag set, al=0
	mov	dx,VGA_PAL_INDEX
	out	dx, al
	inc	dx
	pal_1:
		or	ax,1111110011110011b
		push	ax
		shr	ax, 10
		out	dx,al
		mul	al
		shr	ax, 6
		out 	dx,al
		pop	ax
		out	dx,al
		inc	ax
		jnz	pal_1
	jmp 	vga_x
	
vga_x:	
	;cwd
	;;alternate method of same functionality:
	;mov	ax, di
	;;;mov	bx, 320		;width of screen
	;div	bx
	;xor 	ax,dx
	;add	ax,320*8
	;mov	al, 0x09
	;stosb
	xor	di,di
	mov	cx, SCREEN_WIDTH


	vga_loop:
		mov 	ax, es:[di]
		add	ax, 02020h
		mov	es:[di], ax
		inc 	di
		dec 	cx
		cmp 	cx,0
		loop	vga_loop

	;inc	di
	;xor	ax,ax
	;mov 	di, VGA_PAL_DATA
	;;add	di,8		;;di+=8
	;mov	bx, es:[di]
	;mov 	ax, 
	;mov	bx, SCREEN_WIDTH
	;div	bx		;;ax = ax/bx; bx = ax % bx
	;xor	bl, bh		;;ax % 320 = x (num_cols)
	;mov	dx, di		;;ax / 320 = y (num rows)
	
	;mov 	al, bl
	;xor	ax, di
	;and 	ax,0xffff
	rep	stosw		;moves ax into es:[di]
	jmp vga_main


	;shl	di, 5		;;multiply di*3
	
	
	;;push	ax
	;mov	dx,es:[di]
	
	;;div	bx
	;;mov	dx,ax
	;;xor	bx,dx
	;;mov	ax,bx
	
	;;add 	ax,0x9
	;;div	bx
	;;shl	bx,3
	

	;pop 	ax	
	;;xor	ax,dx
	;;add	ax,di
	
	;;;add	ax,di
	;;;and 	ax,0xff
	
	;mov	es:[di], al
	
	;;;rep	stosb		;moves ax into es:[di]
	
	;inc	cx
	;dec	cx
	;cmp 	cx, DRAW_HALT
	;cmp 	cx, SCREEN_MAX
	;;;jnz	vga_loop
	;loop 	vga_x
	
	;;method of drawing an XOR pattern to the screen in 320x200x256 VGA Mode
	;inc	cx
	;mov	ax, cx		;moves column (val in cx) to ax (in ah)
	;mov	al, ah
	;mov	ah, 0x0C	
	;and	al, 32+8
	;jmp 	short vga_x
	
	;;
	;;mov	al,es:[di]
	;add	ax,di*8 + 32
	;;and	al, 32+8
	;;mov	[di],ax
	;;stosw
	;loop	vga_x
	
	;mov 	di, 07D0h
	;mov	al,es:[di]
	;add	ax,di
	;mov	es:[di],al




;get_save_adr:
;	sti
;	mov	dx,cs
;	lea	di,_vga_routine
;	iret

;get_int_16_addr:
;	mov	ah,0x35
;	mov	al,0x16
;	int	21
;	mov	ORIG_INT_16_S, ds
;	mov	ORIG_INT_16_O, dx


	

;hook_int_16:

;install_new_isr:


;return_to_orig16:













;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

vga_main_setup:
	;mov 	di, VGA_PAL_DATA
	;;add	di,2
	mov	cx, 8
	mov	al,es:[di]
	add	ax,0202h
	;;mov	es:[di],al
	rep	stosb
	jmp vga_main
	
vga_tetris_right:
	mov	cx, SCREEN_WIDTH
	mov 	bx,di
	div 	cx
	sub	cx,bx
	mov	al,es:[di]
	;add	ax,di
	;xor 	ah,al
	;;;mov	es:[di],al
	rep	stosb
	jmp	vga_main

vga_tetris_left:
	mov	cx, SCREEN_WIDTH
	mov	al,es:[di]
	add	ax,di
	;mov	es:[di],al
	rep	stosb
	jmp	vga_main

vga_tetris_down:
	mov	bx,SCREEN_WIDTH
	push	di
	add	di,SCREEN_WIDTH
	pop	ax
	div	bx
	mov 	cx,SCREEN_HEIGHT
	sub	cx,ax
	;mov	ax,0
	mov	al,es:[di]
	add	ax,di
	rep	stosb
	jmp	vga_main




;******************************************************************************
;


;******************************************************************************
;
;;copies new pixel values to VGA buffer 
;
;******************************************************************************

vga_main:
	;add	di,4
	mov	ax,es:[di]
	;add	ax,di
	add	ax,0202h
	;mov	es:[di],al
	stosw

	
;******************************************************************************
;
;	Reads char from buffer (function 0h,int16h)
; 	Char returned in al
; 	If char in al == 0x1b (ESC) then terminate program
;	Else, continue VGA *~pretty picture~* loop
;
;******************************************************************************

	;mov	ah,0h
	xor	ah,ah
	int	16h
	;;cmp	al, 01Bh
;	jnz	near ptr vga_main_setup		;masm specific
	;;jnz	vga_main_setup		;nasm specific
	
	;push	di
	;;mov	ah,0h
	;;int	16h
	
	;;check if keypress is Right arrow
	;cmp	ah, RIGHT_KEY
	cmp	al, RIGHT_KEY
	je	vga_tetris_right
	
	;;check if keypress is Left arrow
	cmp	al, LEFT_KEY
	je	vga_tetris_left
	
	;;check if keypress is Down arrow
	cmp	al, DOWN_KEY
	je	vga_tetris_down
	
	;;check if keypress is ESC
	cmp	al, 1Bh
	;pop di
	jnz	vga_loop



;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************

	mov	ax, 0x03		;reset VGA mode back to text-mode
	int	10h
	
	mov	ax,4C00h		;terminate program
	int	21h

;_start	ENDP				;masm specific
	;end	_start			;masm specific

