.286			;masm specific
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

.CODE:
	org 100h

;******************************************************************************
;	References technique for defining the original interrupt seg + offset
; 	in relation to DS register, used in Stoned.asm 
;

_ORIG16_O	dd	0x0
_ORIG16_S	dd	0x0
_ORIG9_O	dd	0x0
_ORIG9_S	dd	0x0
_ORIG10_O	dd	0x0
_ORIG10_S	dd	0x0

ORIG_INT	dw	0x0
_ORIG_INT_ADR	dd	0x0
_ORIG_INT_ISR	dd	0x0


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
	;mov	cx, 1
	xor	si, si
	mov	ds, si
	;mov	dx, 0
	intloop:
		;mov 	bx,dx
		;shr	bx,2
		;mov	ax, es:[bx]
		;mov 	ds:_ORIG_INT_ADR, ax
		;mov 	ds:_ORIG_INT_ADR, ax
		;inc	bx
		;inc	bx
		;mov	ax, es:[bx]
		;mov 	ds:_ORIG_INT_ISR, ax
		
		push es	
		mov	ax,0
		mov	es, ax
		mov	ax, [si]
		or	ax, [si+2]
		mov	[ORIG_INT], ax
		

		mov	ah, 40h
		mov	bx, 1
		mov	cx,INT_LEN
		;lea 	dx,_ORIG_INT_ADR
		lea 	dx,ORIG_INT
		int	21h
		;mov	ah, 40h
		;mov	bx, 1
		;mov	cx,ISR_LEN
		;lea 	dx,_ORIG_INT_ISR
		;int	21h
		pop 	es
		inc 	si
		inc 	si
		mov	ax,si	
		cmp	ax,cx
		jl	intloop
	;loop 	print_interrupts
	ret	
;
;hook_interrupts:
;	jmp	get_int_addr
;
;;get_int_9_addr:
;;	mov	ah,0x35				;int 21h, func 35h=get interrupt vector
;;	mov	al,0x9				;interrupt vector 9h
;;	int	21
;;	mov	ds:_ORIG9_S, es		;store segment address of int9h in a var
;;	mov	ds:_ORIG9_O, bx		;store offset address of int9h in a var
;get_int_addr:
;	mov	ax,0
;	mov	es, ax
;	es 	les bx,[0x84]
;	mov	word ds:[_ORIG10_S], es
;	mov	word ds:[_ORIG10_O], bx
;	jmp	install_new_isr
;	
;
hook_int:
	cmp	al,25h
;	jne	back_2_orig
	jne	INT_PATCH_A
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	si
	push	di
	push	bp
	mov 	cx, cs
	mov	ds, cx
	
	;call 	ORIG_INT_16_O
						;; mov 	ax,cs
						;; mov	dx,ax
	cli
	;;do things here xoxo
	mov	ah, 40h
	mov	bx, 1
	mov	cx,b_len
	lea 	dx,b_msg
	int	21h

	sti
INT_PATCH_A:
	mov	ax, 0
	mov	ds, ax
INT_PATCH_IVR:
	mov	dx, 0
	mov	ax, 2521h
	int 	21h
	;;mov	ax, 0x03		;reset VGA mode back to text-mode
	;;int	10h
	pop 	sp
	pop 	di
	pop	si
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	iret
;
;back_2_orig:
;	sti
;	call 	_ORIG10_S:_ORIG10_O
;	iret
;	
;
;install_new_isr:
;	;lea	dx, vga_init			;; address of TSR program passed in ds:dx
;	lea	dx, hook_int			;; address of TSR program passed in ds:dx
;	mov 	cx, cs
;	mov	ds, cx
;	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
;	mov 	al, 0x85			;; at IVT[0x85] or Interupt 133
;	int 	21
;	;;lea	dx, vga_init			;; address of TSR program passed in ds:dx
;	;;lea	dx, hook_int			;; address of TSR program passed in ds:dx
;	lea	dx, [0x0214]			;; address of TSR program passed in ds:dx
;	mov 	cx, cs
;	mov	ds, cx
;	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
;	mov 	al, 0x21			;; at IVT[0x85] or Interupt 133
;	int 	21
;	jmp 	short install_tsr
;
;install_tsr:
;	lea	dx, ((256 + pgm_len + 15) / 16)
;	lea	dx, ((pgm_len + 15) / 16) + 10
;	mov	ax, 0x31
;	int 	21
;
;pgm_len	equ	3569JXZghikmsstart			;;Referencing Ray Duncan's trick for calculating program length
;					;; for specifying dx (memsize) of TSR, used in int 21h function 31h call
;
;.data: 

b_msg	db	"TSR Infection complete", 0Dh,0Ah
b_len	equ	$-b_msg
INT_LEN	equ	$-ORIG_INT
;INT_LEN	equ	$-_ORIG_INT_ISR
;ISR_LEN	equ	$-_ORIG_INT_ISR
;
;
;;_start	ENDP				;masm specific
;	;end	_start			;masm specific
;
;

