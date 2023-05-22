bits 16
;.286			;masm specific
;.MODEL TINY		;masm specific

;******************************************************************************
;	COM Program that manipulates pixel values of command prompt 
;	by writing directly to VGA buffer
;	
;	To be used in DOSBOX (or similar) MS-DOS Emulator program 
;	Must be compiled with link16.exe (MASM32 preferably) 
;
;******************************************************************************

.CODE:
	org 100h

;******************************************************************************

SCREEN_MAX	equ	320*200
SCALED_SCREEN_MAX	equ	0x280
SCREEN_WIDTH	equ	0x140		;;320
SCALED_SCREEN_W	equ	0x20		;;320 / 10
SCREEN_HEIGHT	equ	0xC8		;;200
SCALED_SCREEN_H	equ	0x14		;;200 / 10 
VGA_PAL_INDEX	equ	0x3C8
VGA_PAL_DATA	equ	0x3C9
MBR_SIZE		equ 0x200

;******************************************************************************
;_start	PROC	NEAR ; masm

copy_mbr:
	mov ax, 0x201	;read one sector of disk
	mov	cx, 1
	mov dx, 0x80 	;from Side 0, drive C:
	lea bx, BUF		;to buffer BUF in DS
	int 13h


;******************************************************************************
;	Write back to hard disk drive C: sector 1 (MBR)
;******************************************************************************
	;mov ax,0x0301
	;mov bx,0x200
	;int 13h

vga_init:
	mov	ax,0xA000
	;mov	ax,0xB800
	mov	es,ax
	mov	dx,ax
	mov	di,0
	mov	ax, 0x13
	int	10h
	cld
;	jmp bmp_setup

set_pal:
	salc				;set carry flag in al, if carry flag set, al=0
	mov	dx,VGA_PAL_INDEX	;
	out	dx, al
	inc	dx
	pal_1:
		or	ax,0011111100110011b
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
	;jmp 	bmp_setup
	mov	cx, 20
	paint_loop:
		push 	di
		push	cx
		call 	mbr_paint
		pop		cx
		pop 	di
		add		di, 320
		dec 	cx
		jnz	paint_loop
	jmp key_check
	;jmp 	mbr_paint


mbr_paint:
	lea si, BUF
	mov bx, MBR_SIZE
	vga_mbr_y:
		push di
		mov cx, SCALED_SCREEN_W
		vga_mbr_x:
			movsb
			dec cx
			jnz vga_mbr_x
		pop di
		add di, 320
		dec bx
		jnz vga_mbr_y
	ret
	;jmp key_check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************
;Reads bitmap row,
;;copies new pixel values to VGA buffer 
;
;******************************************************************************


bmp_setup:
;	xor ax, ax
;	mov	ds,ax
	lea si, Bitmaptest
	;mov bx, SCREEN_HEIGHT
	mov bx, SCALED_SCREEN_MAX
	;mov bx, SCREEN_HEIGHT*SCREEN_WIDTH
;vga_y_block:
;	push si
	vga_main_y:
		push di
		;mov	cx, SCREEN_WIDTH
		;mov dh, 0xA
		mov	cx, SCALED_SCREEN_W
		vga_main_x:
			mov dx, 0xA
			pixgroup:
				push si
				movsb
				;jmp write_pix
				pop si
				dec dx
				;cmp dl,0
				jnz pixgroup
;			inc si
			dec cx
			jnz vga_main_x
		pop di
		;mov ax, es:[di]
		add di, 320
		;mov [si], ax
		dec bx
		jnz	vga_main_y
	jmp key_check
;	pop si
;	add si, 32
;	sub bx, 0xA
;	cmp bx, 0
;	jnz vga_y_block
;******************************************************************************
;
;	Reads char from buffer (function 0h,int16h)
; 	Char returned in al
; 	If char in al == 0x1b (ESC) then terminate program
;	Else, continue VGA *~pretty picture~* loop
;
;******************************************************************************
key_check:
	xor	ax,ax
	int	16h
	;;check if keypress is ESC
	;cmp	al, 1Bh
	cmp	al, 1
	jnz	baibai
	;jnz mbr_paint
;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************
;	mov	ax, 0x03		;reset VGA mode back to text-mode
;	int	10h
baibai:	
	mov	ax,4C00h		;terminate program
	int	21h


BUF:
	times 512-($-$$) db 0

