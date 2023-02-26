;model: small		;masm specific
;.286			;masm specific

;******************************************************************************
;	COM Program that installs a TSR to the IVT
;	The newly added ISR displays a string "TSR Infection completed!"
;	and then exits
;	 
;	
;	To be used in MS-DOS Emulator program 
;		(i.e. DOSBOX, FreeDOS in qemu, etc)
;	Must be compiled with a 16bit linker 
;		(i.e. ld86 or link16.exe with MASM32) 
;
;******************************************************************************
;	assume CS:TEXT, DS:TEXT
bits 16
.text:
	org 100h

;******************************************************************************
;	References technique for defining the original interrupt seg + offset
; 	in relation to DS register, used in Stoned.asm 
;

;ORIG_INT	dd	0x0
;_ORIG_INT_S	dd	0x0
;_ORIG_INT_O	dd	0x0


;ORIG_INT_S 	equ 	0x0000+_ORIGINT_S	;if making virus, get adr segment of target interrupt
;ORIG_INT_S 	equ 	0x07C00+_ORIGINT_S	;if making bootkit
;ORIG_INT_O 	equ 	0x0000+_ORIGINT_O	;;if making virus, get adr offset of target interrupt
;ORIG_INT_O 	equ 	0x07C00+_ORIGINT_O


;JUMP_HOOK_CODE_OFFSET
;JUMP_HOOK_CODE_SEGMENT
;SCREEN_MAX	equ	320*200
;DRAW_HALT	equ	320*50
;SCREEN_WIDTH	equ	0x140		;;320
;SCREEN_HEIGHT	equ	0xC8		;;200
;VGA_PAL_INDEX	equ	0x3C8
;VGA_PAL_DATA	equ	0x3C9
;
;LEFT_KEY	equ	0x4B		;;code for left arrow key
;RIGHT_KEY	equ	0x4D		;;code for right arrow key
;DOWN_KEY	equ	0x50		;;code for down arrow key

;******************************************************************************

;_start	PROC	NEAR ; masm
start:
	jmp 	setup_hook_interrupts


old_INT:
db	0EAh			;from Spanska Elvira, EAh is far call
_ORIG_INT	dd	? 	;this is also such a nice trick bc it avoids having to define these in a data segment
;;_ORIG_INT_ADR	dw	? 	;this is also such a nice trick bc it avoids having to define these in a data segment
;;_ORIG_INT_ISR	dw	?	;so there is no need to change the segment for loading cs w the correct value
iret

hook_int:
	;cmp	ah, 00h
	;;cmp	ax, 4B00h
	;;cmp	ax, 001Bh
	
	cmp	ax, 4B00h

	;;je 	NEW_INT
	;;mov 	cx, cs
	;;mov	ds, cx
	
	jne 	NO_INT
	pushf
	
	;jmp	[cs:ORIG_INT]
	;jne	[INT_PATCH_IVR+2]
NEW_INT:
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	si
	push	di
	;mov 	cx, cs
	;mov	ds, cx
	
	cli
	mov	ax, 0013h
	int	10h
	mov	ax,0xA000
	mov	es,ax
	;mov	ds,ax
	mov	di,0
	mov	cx, (6400/2)
	mov	ax,0202h
	cld
	repnz	stosw
	;;do things here xoxo
	;mov	bx, b_msg
	;mov	ax, 0303h
	;int	10h
	;mov	ah, 40h
	;mov	bx, 1
	;mov	cx,b_len
	;lea 	dx,b_msg
	;int	21h

	sti
;;INT_PATCH_A:
	;mov	ax, 0
	;mov	ds, ax
;INT_PATCH_IVR:
	;mov	dx, 0
	;mov	[0x21*4],dx
	;mov	[0x21*4 + 2],ax
	;stosw
	;mov	ax, ds
	;mov 	cs,ax
	;mov	[0x16*4],ax
	;mov	[0x16*4 + 2],dx
	;mov	[0x33*4],ax
	;mov	[0x33*4 + 2],dx
	;mov	[0x28*4],ax
	;mov	[0x28*4 + 2],dx
	;mov	[0x64],ds:dx
	;mov	[0x64 + 2],dx
	;call	[cs:0x58]
	;call	[cs:ORIG_INT]
	;mov	ax, 2516h
	;int 	21h
	;mov	ax, 0x03		;reset VGA mode back to text-mode
	;int	10h
	pop 	di
	pop	si
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	;;push 	cx
	;;;mov	cs, [ORIG_INT]
	;jmp 	far [cs:_ORIG_INT_O]
	;int 	85h	
	;;jmp	[ORIG_INT:_ORIG_INT_O]
	;call	far [cs:ORIG_INT]
	;;;pop 	cx
	push	ax
	mov	al, 0x20
	out	0x20, al
	pop	ax
	
NO_INT:
	call old_INT
	;jmp	[ORIG_INT]
	iret

setup_hook_interrupts:
	;push 	bp
	;mov	bp, sp
						;; make data addressable
						;; this is the same as doing the following:
						;; mov 	ax,cs
						;; mov	dx,ax
	push es	
	mov	ax,0
	mov	es, ax
	;mov	ds, ax
	;mov	si, 21*4
	;lodsw	
	;mov	ax, ds:[si]
	;es 	les bx,[0x58]			;;for int 16h
	;es 	les bx,[0xCC]			;;for int 33h
	;es 	les bx,[0xA0]			;;for int 28h
	es 	les bx,[0x84]			;;for int 21h
	;es 	les bx,[0x20]			;;for int 8h
						;;es:bx contains contents of address 0x84 (0000:0084)
	;mov	ax, [old_INT]
	;xchg	ax, es:[bx]
	;mov	[_ORIG_INT], ax
	
	;xor	ax,ax
	;es 	les bx,[0x86]			;;for int 21h
	;xchg	ax, [es:bx]
	;mov	[_ORIG_INT+2], ax
	
	;mov	ds:[_ORIG_INT_ADR], es		
	;mov	ds:[_ORIG_INT_ISR], bx
;	mov	[_ORIG_INT_ADR], ax
	;or	ax, ds:[si+2]
	;mov	[ORIG_INT], ax
	;;mov	ax, 3528h
	;mov	ax, 3516h
	;int	21h

;;	mov	[INT_PATCH_A+1], es

	;;mov	[ORIG_INT], es
	;;mov	[ORIG_INT], bx
	;;mov	[ORIG_INT], es

;;	mov	[INT_PATCH_IVR + 1], bx

	;;mov	[ORIG_INT+2], bx
	mov	[_ORIG_INT], bx
	mov	[_ORIG_INT+2], es
	;;mov	[ORIG_INT + 2], es
	;;mov	[_ORIG_INT_O], es
	;;mov	[_ORIG_INT_O], bx
	
	push 	es	
	pop 	ds
	mov	dx, bx				;ds:dx now == es:bx (seg:offset of int 21h)
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	mov 	al, 0x85			;; at IVT[0x85] or Interupt 21
	int	21h

	
	pop 	es

;	lea	dx, hook_int			;; address of TSR program passed in ds:dx
;	mov 	cx, cs
;	mov	ds, cx
;	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
;	mov 	al, 0x85			;; at IVT[0x85] or Interupt 133
;	int 	21
	mov 	cx, cs
	mov	ds, cx
	mov	dx, hook_int			;; address of TSR program passed in ds:dx
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	;mov 	al, 0x28			;; at IVT[0x28] or Interupt 28
	;mov 	al, 0x16			;; at IVT[0x16] or Interupt 16
	mov 	al, 0x21			;; at IVT[0x21] or Interupt 21
	;mov 	al, 0x8				;; at IVT[0x8] or Interupt 8
	;mov 	al, 0x33			;; at IVT[0x33] or Interupt 33
	int 	21h
	


	;pop	bp

install_tsr:
	mov	dx, ((256 + setup_hook_interrupts-start + 15) / 16)
	mov	ax, 0x3102
	int 	21h
;
pgm_len	equ	$-setup_hook_interrupts-start			;;Referencing Ray Duncan's trick for calculating program length
;					;; for specifying dx (memsize) of TSR, used in int 21h function 31h call

b_msg	db	"TSR Infection complete", 0Dh,0Ah
b_len	equ	$-b_msg
;;INT_LEN	equ	$-ORIG_INT

;get_int_addr:
;	mov	ax,0
;	mov	es, ax
;	es 	les bx,[0x84]
;	mov	word ds:[_ORIG10_S], es
;	mov	word ds:[_ORIG10_O], bx
;	jmp	install_new_isr
;	
;INT_LEN	equ	$-_ORIG_INT_ISR
;ISR_LEN	equ	$-_ORIG_INT_ISR
;
;;_start	ENDP				;masm specific
;	;end	_start			;masm specific

