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
;	org 100h

;******************************************************************************
;	References technique for defining the original interrupt seg + offset
; 	in relation to DS register, used in Stoned.asm 
;
.data :

_ORIG16_O	dd	0x0
_ORIG16_S	dd	0x0
_ORIG9_O	dd	0x0
_ORIG9_S	dd	0x0
_ORIG10_O	dd	0x0
_ORIG10_S	dd	0x0

_ORIG_INT_ADR	db	"IVT address is at ", 0Dh, 0Ah
_ORIG_INT_ISR	db	0


ORIG_INT_16_S 	equ 	0x0000+_ORIG16_S	;if making virus, get adr segment of target interrupt
;ORIG_INT_16_S 	equ 	0x07C00+_ORIG16_S	;if making bootkit
ORIG_INT_16_O 	equ 	0x0000+_ORIG16_O	;;if making virus, get adr offset of target interrupt
;ORIG_INT_16_O 	equ 	0x07C00+_ORIG16_O

ORIG_INT_9_S 	equ 	0x0000+_ORIG9_S		;if making virus, get adr segment of target interrupt
;ORIG_INT_9_S 	equ 	0x07C00+_ORIG9_S	;if making bootkit
ORIG_INT_9_O 	equ 	0x0000+_ORIG9_O		;;if making virus, get adr offset of target interrupt
;ORIG_INT_9_O 	equ 	0x07C00+_ORIG9_O
ORIG_INT_9	equ	_ORIG9_S+_ORIG9_O
ORIG_INT_10	equ	_ORIG10_S+_ORIG10_O


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
.text:
	org 100h

;_start	PROC	NEAR ; masm
start:
	push 	bp
	mov	bp, sp
	push 	ds
	push	cs				;; make data addressable
	pop	ds				;; this is the same as doing the following:
	call 	print_interrupts
	pop	bp
	ret
;	mov	ax,0xA000
;	mov	es,ax
;	mov	ds,ax
;	mov	di,0
;	jmp	short vga_init


;get_save_adr:
;	sti
;	mov	dx,cs
;	lea	di,_vga_routine
;	iret

print_interrupts:
	push es	
	mov	ax,0
	mov	es, ax
	mov	cx, 1
	mov	dx, 0
	intloop:
		mov 	bx,dx
		;shl	bx,2
		mov	ax, word es:[bx]
		;mov 	ds:_ORIG_INT_ADR, ax
		;inc	bx
		;inc	bx
		;mov	ax, es:[bx]
		mov 	[_ORIG_INT_ISR], ax
		
		intprint:
						;;print number: one digit at a time
						;; number in ax
			mov	dx, 0		;; zero out dx to hold the remainder
						;; ax will hold the quotient
			mov	cx, 10			;; cx holds divisor
			div	cx			;;
						;; ax/cx
						;;	ax = ax/10
						;;	dx = ax % 10
						;;
						;; We then recursively do the following:
			push	ax		;; save the value in ax (current quotient) by pushing it onto the stack
			add	dl, "0"		;; convert number in dl (remainder, in lower 8 bits of ax) to ascii char
			mov	ah, 02h		;; print the char in dl
			int	21h		;;
						;;
			pop	ax		;; restore the value in ax by popping saved value from stack
			cmp 	ax, 0		;; check if ax == 0
			jnz	intprint	;; if yes, no more characters to print, so return
						;; else, there are digits remaining, so loop

		;mov	ah, 02h
		;mov	bx, 1
		;mov	cx,INT_LEN
		;mov 	dx,_ORIG_INT_ADR
		;add	dl, "0"
		;int	21h
		;mov	ah, 40h
		;mov	bx, 1
		;mov	cx,ISR_LEN
		;lea 	dx,_ORIG_INT_ISR
		;int	21h
		pop 	es
		;mov	ax,dx	
		;inc 	dx
		;inc 	dx
		;cmp	bx,cx
		;jl	intloop
	;loop 	print_interrupts
	pop es
	ret	
.data: 

b_msg	db	"TSR Infection complete", 0Dh,0Ah
b_len	equ	$-b_msg
INT_LEN	equ	$-_ORIG_INT_ISR
ISR_LEN	equ	$-_ORIG_INT_ISR
