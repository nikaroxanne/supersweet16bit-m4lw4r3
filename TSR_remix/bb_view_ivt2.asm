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
bits 16
;.code:
	org 100h

;******************************************************************************
;	References technique for defining the original interrupt seg + offset
; 	in relation to DS register, used in Stoned.asm 
;
;.data:
_ORIG_INT_ADR	db	"        $"
_ORIG_INT_ISR	db	0


;ORIG_INT_16_S 	equ 	0x0000+_ORIG16_S	;if making virus, get adr segment of target interrupt
;ORIG_INT_16_S 	equ 	0x07C00+_ORIG16_S	;if making bootkit
;ORIG_INT_16_O 	equ 	0x0000+_ORIG16_O	;;if making virus, get adr offset of target interrupt
;ORIG_INT_16_O 	equ 	0x07C00+_ORIG16_O

;ORIG_INT_9_S 	equ 	0x0000+_ORIG9_S		;if making virus, get adr segment of target interrupt
;ORIG_INT_9_S 	equ 	0x07C00+_ORIG9_S	;if making bootkit
;ORIG_INT_9_O 	equ 	0x0000+_ORIG9_O		;;if making virus, get adr offset of target interrupt
;ORIG_INT_9_O 	equ 	0x07C00+_ORIG9_O
;ORIG_INT_9	equ	_ORIG9_S+_ORIG9_O
;ORIG_INT_10	equ	_ORIG10_S+_ORIG10_O

;JUMP_HOOK_CODE_OFFSET
;JUMP_HOOK_CODE_SEGMENT
;SCREEN_MAX	equ	320*200
;DRAW_HALT	equ	320*50
;SCREEN_WIDTH	equ	0x140		;;320
;SCREEN_HEIGHT	equ	0xC8		;;200
;VGA_PAL_INDEX	equ	0x3C8
;VGA_PAL_DATA	equ	0x3C9

;LEFT_KEY	equ	0x4B		;;code for left arrow key
;RIGHT_KEY	equ	0x4D		;;code for right arrow key
;DOWN_KEY	equ	0x50		;;code for down arrow key

;******************************************************************************

start:
	push 	bp
	mov	bp, sp
	;push 	ds
	;push	cs			;; make data addressable
	;pop	ds			;; this is the same as doing the following:
	call 	print_interrupts
	pop	bp
	ret
print_interrupts:
	;;push 	es	
	;;mov	ax,0
	;;mov	es, ax
	;mov	cx, 1
	;mov	dx, 0
	;mov 	bx, 1234
	;mov 	bx, 0000
	mov	si, 0
	mov	ds, si
	;intloop:
		;mov 	bx,dx
		;shl	bx,2
	;;mov	ax, word es:[bx]
	mov	ax, ds:[si]
	lea 	di, _ORIG_INT_ADR
	add	di, 7
	;mov	[di], ax
	;;mov	[_ORIG_INT_ADR], ax
	;lodsw	ax, es:[bx]
	;stosw
	;mov	ds:[_ORIG_INT_ADR], ax
	;	mov	ax, 2
		;mov 	ds:_ORIG_INT_ADR, ax
		;inc	bx
		;inc	bx
		
		;mov	ax, es:[bx]
		;mov 	[_ORIG_INT_ISR], ax	
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
		add	dl, '0'		;; convert number in dl (remainder, in lower 8 bits of ax) to ascii char
		dec	di
		mov	ds:[di], dl
		mov	ah, 02h		;; print the char in dl
		int	21h		;;
					;;
		pop	ax		;; restore the value in ax by popping saved value from stack
		cmp 	ax, 0		;; check if ax == 0
		jnz	intprint	;; if yes, no more characters to print, so return
					;; else, there are digits remaining, so loop
	push 	es	
	mov	ax, 0xb800
	mov	es, ax
	
	mov	bx, 1
	lea	dx, _ORIG_INT_ADR
	mov	ah, 09h		;; print the char in dl
	int	21h		;;
	pop es
	ret	

