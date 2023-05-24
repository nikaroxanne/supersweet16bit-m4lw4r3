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
SCREEN_WIDTH	equ	0x140		;;320
SCALED_SCREEN_W	equ	0x20		;;320 / 10
SCREEN_HEIGHT	equ	0xC8		;;200
SCALED_SCREEN_H	equ	0x14		;;200 / 10 
VGA_PAL_INDEX	equ	0x3C8
VGA_PAL_DATA	equ	0x3C9

;******************************************************************************
;_start	PROC	NEAR ; masm

vga_init:
	mov	ax,0xA000
	;mov	ax,0xB800
	mov	es,ax
	mov	dx,ax
	mov	di,0
	mov	ax, 0x13
	int	10h
	cld
	jmp 	bmp_setup

;******************************************************************************
;	Palette routine adapted from "Symetrie" and "Atraktor" by Rrrola
;	 https://abaddon.hu/256b/colors.html 
;
;******************************************************************************
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
	jmp 	bmp_setup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************
;Reads bitmap row,
;;copies new pixel values to VGA buffer 
;
;******************************************************************************

bmp_setup:
	mov si, Bitmaptest
	;mov bx, SCREEN_HEIGHT
	mov bx, SCALED_SCREEN_H
	;mov	dh, 0xA
vga_y_block:
	push si
	vga_main_y:
		push di
		;mov	cx, SCREEN_WIDTH
		mov dh, 0xA
		mov	cx, SCALED_SCREEN_W
		vga_main_x:
			mov dl, 0xA
			pixgroup:
				movsb
				dec dl
				dec si
				cmp dl,0
				jnz pixgroup
			;sub cx,10
			inc si
			dec cx
			jnz vga_main_x
		pop di
		mov ax, es:[di]
		add di, 320
		mov si, ax
		dec dh
		jnz	vga_main_y
	pop si
	add si, 32
	dec bx
	jnz vga_y_block
;******************************************************************************
;
;	Reads char from buffer (function 0h,int16h)
; 	Char returned in al
; 	If char in al == 0x1b (ESC) then terminate program
;	Else, continue VGA *~pretty picture~* loop
;
;******************************************************************************
	xor	ax,ax
	int	16h
	;;check if keypress is ESC
	cmp	al, 1Bh
	jz	baibai
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

Bitmaptest:
db 0xce,0xdb,0xd1,0x58,0x2b,0xd2,0xdd,0xe2,0xe4,0xea,0xe4,0xe7,0xea,0xea,0xf1,0xf1,0xea,0xe8,0xe2,0xe4,0xe9,0xf1,0xf8,0xf7,0xf7,0xf8,0xf6,0xf6,0xed,0xf3,0xf2,0xfc
db 0x12,0x28,0x58,0x2d,0x1d,0xd6,0xe3,0xee,0xef,0xec,0xec,0xec,0xef,0xeb,0xee,0xee,0xe7,0xdf,0xd8,0xdf,0xe0,0xe3,0xea,0xed,0xe7,0xf3,0xf3,0xe6,0xe3,0xe6,0xf0,0xfc
db 0x3c,0x1d,0x1b,0x58,0xd1,0xf5,0xf5,0xf8,0xf5,0xf5,0xf9,0xf9,0xf8,0xf4,0xf1,0xee,0xf4,0xe5,0xe0,0xe2,0xe0,0xdb,0xd7,0xd8,0xde,0xde,0xdb,0xda,0xdd,0xdd,0xf0,0xfc
db 0xfa,0xe8,0xd1,0xd6,0xda,0xd9,0xd9,0xd9,0xd9,0xd6,0xd8,0xdb,0xd8,0xd8,0xd7,0xd2,0xca,0xc6,0xc0,0xd0,0xda,0xda,0xd4,0xcd,0xcd,0xcd,0xd4,0xd4,0xd0,0xc9,0xfa,0xff
db 0xcb,0x9f,0x9f,0x9f,0x95,0x8d,0x7f,0x7f,0x7f,0x7e,0x7e,0x7e,0x7e,0x6c,0x6c,0x6c,0x65,0x65,0x5a,0x65,0x6d,0x6d,0x73,0x6d,0x73,0x80,0x8e,0x8e,0x8e,0x8e,0xf2,0xfe
db 0x4e,0x48,0x4b,0x4d,0x4d,0x4d,0x4b,0x4e,0x4e,0x48,0x3c,0x3c,0x3c,0x3f,0x34,0x34,0x34,0x33,0x32,0x33,0x34,0x37,0x37,0x37,0x37,0x3a,0x40,0x3f,0x3a,0x3f,0x9f,0xfd
db 0x76,0x86,0x87,0x86,0x7a,0x6e,0x63,0x61,0x57,0x57,0x57,0x5f,0x57,0x54,0x51,0x51,0x51,0x4c,0x46,0x46,0x46,0x46,0x45,0x44,0x3d,0x38,0x30,0x2f,0x2d,0x2d,0x2f,0xad
db 0x9e,0xa8,0xab,0xa8,0xa4,0x9b,0x9b,0x8f,0x89,0x81,0x75,0x81,0x74,0x66,0x50,0x36,0x36,0x2b,0x2b,0x36,0x52,0x64,0x64,0x64,0x5c,0x66,0x67,0x5c,0x5c,0x62,0x51,0x1d
db 0xb0,0xb9,0xb9,0xb4,0xb2,0xb2,0xb1,0xb1,0xb2,0xb8,0xb1,0xa3,0x99,0x82,0x75,0x72,0x72,0x78,0x74,0x82,0x97,0x9d,0x98,0x96,0x98,0x96,0x9a,0x9a,0x9b,0x9a,0x38,0x1
db 0x9e,0xc5,0xc0,0xbb,0xbb,0xc0,0xc5,0xc5,0xbf,0xb5,0xaf,0x9d,0x97,0x96,0x83,0x72,0x69,0x71,0x69,0x6b,0x71,0x75,0x81,0x81,0x8f,0x9a,0x9b,0xa0,0xa0,0x7d,0x1b,0x9
db 0xbe,0xca,0xca,0xc8,0xc7,0xc7,0xcc,0xcc,0xc2,0xb3,0xb3,0xa3,0x9d,0x96,0x74,0x78,0x70,0x5c,0x46,0x49,0x5b,0x67,0x68,0x67,0x71,0x89,0x82,0x7d,0x72,0x4a,0x9,0x28
db 0xc7,0xd0,0xd0,0xd7,0xd5,0xd5,0xd5,0xd0,0xc8,0xc6,0xc1,0xbb,0xbd,0xc3,0xb7,0xa9,0x92,0x6e,0x51,0x59,0x7c,0xa2,0xab,0xab,0xa9,0xa6,0x92,0x8b,0x87,0x62,0x28,0xcb
db 0xcf,0xae,0xa5,0xa5,0xae,0xaf,0xb0,0xaf,0xa8,0xa8,0xa8,0xa7,0xaa,0xa7,0x91,0x91,0x86,0x6f,0x5f,0x5f,0x76,0x7a,0x77,0x78,0x77,0x77,0x76,0x70,0x7a,0x55,0xbe,0xfe
db 0x95,0x5a,0x4f,0x5a,0x5a,0x5a,0x5a,0x5a,0x5a,0x50,0x50,0x4b,0x4b,0x4b,0x41,0x41,0x3b,0x3b,0x2b,0x2b,0x2c,0x30,0x38,0x2d,0x2f,0x2e,0x30,0x2c,0x30,0x2b,0xdc,0xfe
db 0x48,0x3c,0x3c,0x3b,0x3d,0x44,0x44,0x44,0x31,0x31,0x31,0x2a,0x24,0x24,0x24,0x24,0x24,0x21,0x1e,0x21,0x21,0x21,0x21,0x16,0x10,0x10,0x10,0x10,0x11,0x16,0xbe,0xfd
db 0x62,0x6a,0x6a,0x61,0x5e,0x5d,0x5d,0x43,0x42,0x26,0x42,0x43,0x23,0x1a,0x1a,0x1a,0x1a,0x25,0x26,0x25,0x23,0x18,0x1a,0x1a,0xa,0x4,0x1,0x1,0x4,0x7,0x1f,0xf2
db 0x82,0x89,0x87,0x7d,0x70,0x6e,0x6a,0x53,0x53,0x42,0x25,0x19,0x13,0x5,0x0,0x5,0xb,0x14,0x18,0x19,0x19,0x18,0x15,0x13,0x13,0xe,0xb,0x7,0x2,0x1,0x24,0xfb
db 0xa5,0xa8,0xa4,0xa0,0x94,0x91,0x93,0x92,0x84,0x84,0x5d,0x42,0x23,0xe,0x7,0x7,0xb,0xa,0x0,0x3,0xc,0x15,0xe,0xe,0xd,0xa,0x7,0x4,0x2,0x3,0x10,0xe1
db 0xba,0xba,0xb8,0xb4,0xac,0xb6,0xb6,0xb6,0xb6,0xa9,0x8c,0x84,0x84,0x6e,0x5e,0x53,0x3e,0x29,0x1c,0x16,0x16,0x1c,0x1c,0x27,0x29,0x29,0x29,0x24,0xf,0x7,0xf,0xce
db 0xbe,0xc4,0xc4,0xbc,0xb8,0xbc,0xbc,0xc3,0xc3,0xbc,0xac,0xa6,0xa6,0x93,0x91,0xa2,0xa2,0xa1,0x8b,0x7b,0x7c,0x8a,0x8a,0x90,0x90,0x90,0x8c,0x8c,0x7b,0x60,0x5e,0x0
