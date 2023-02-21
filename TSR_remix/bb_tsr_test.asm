;.MODEL: TINY		;masm specific
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
.code:
	org 100h

;******************************************************************************
;	References technique for defining the original interrupt seg + offset
; 	in relation to DS register, used in Stoned.asm 
;

ORIG_INT	dw	0x0
_ORIG_INT_ADR	dw	0x0
_ORIG_INT_ISR	dw	0x0


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


hook_int:
;	cmp	al,25h
;	jne	INT_PATCH_A
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
	
	cli
	mov	ax, 13h
	int	10h
	mov	ax,0xA000
	mov	es,ax
	;mov	ds,ax
	mov	di,0
	mov	cx, (64000/2)
	mov	ax,0202h
	cld
	rep	stosw
	;;do things here xoxo
	mov	ax, 0003h
	int	10h
	mov	bx, b_msg
	mov	ax, 0303h
	int	10h
	;mov	ah, 40h
	;mov	bx, 1
	;mov	cx,b_len
	;lea 	dx,b_msg
	;int	21h

	sti
INT_PATCH_A:
	mov	ax, 0
	mov	ds, ax
INT_PATCH_IVR:
	mov	dx, 0
	;mov	[28*4],ds
	;mov	[28*4 + 2],dx
	mov	[16*4],ds
	mov	[16*4 + 2],dx
	;;mov	ax, 2528h
	;;int 	21h
	;mov	ax, 0x03		;reset VGA mode back to text-mode
	;int	10h
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

setup_hook_interrupts:
	push 	bp
	mov	bp, sp
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
	es 	les bx,[0x84]
	;mov	ds:[_ORIG_INT_ADR], es
	;mov	ds:[_ORIG_INT_ISR], bx
;	mov	[_ORIG_INT_ADR], ax
	;or	ax, ds:[si+2]
	;mov	[ORIG_INT], ax
	;;mov	ax, 3528h
	;mov	ax, 3516h
	;int	21h
	mov	[INT_PATCH_A+1], es
	mov	[INT_PATCH_IVR + 1], bx
	
	pop 	es

;	lea	dx, hook_int			;; address of TSR program passed in ds:dx
;	mov 	cx, cs
;	mov	ds, cx
;	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
;	mov 	al, 0x85			;; at IVT[0x85] or Interupt 133
;	int 	21
	lea	dx, hook_int			;; address of TSR program passed in ds:dx
	mov 	cx, cs
	mov	ds, cx
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	;mov 	al, 0x28			;; at IVT[0x85] or Interupt 133
	mov 	al, 0x16			;; at IVT[0x85] or Interupt 133
	int 	21h
	pop	bp

install_tsr:
	mov	dx, ((256 + setup_hook_interrupts-start + 15) / 16)
	mov	ax, 0x31
	int 	21h
;
pgm_len	equ	$-setup_hook_interrupts-start			;;Referencing Ray Duncan's trick for calculating program length
;					;; for specifying dx (memsize) of TSR, used in int 21h function 31h call

b_msg	db	"TSR Infection complete", 0Dh,0Ah
b_len	equ	$-b_msg
INT_LEN	equ	$-ORIG_INT

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

