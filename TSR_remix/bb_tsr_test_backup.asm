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
.TEXT:
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

;print_interrupts:
;	mov	cx, 1024
;	xor	si, si
;	mov	ds, si
;	;mov	dx, 0
;	intloop:
;		;mov 	bx,dx
;		;shr	bx,2
;		;mov	ax, es:[bx]
;		;mov 	ds:_ORIG_INT_ADR, ax
;		;mov 	ds:_ORIG_INT_ADR, ax
;		;inc	bx
;		;inc	bx
;		;mov	ax, es:[bx]
;		;mov 	ds:_ORIG_INT_ISR, ax
;		
;		push es	
;		mov	ax,0
;		mov	es, ax
;		mov	ax, ds:[si]
;		mov	[_ORIG_INT_ADR], ax
;		or	ax, ds:[si+2]
;		mov	[ORIG_INT], ax
;		
;
;		mov	ah, 40h
;		mov	bx, 1
;		mov	cx,INT_LEN
;		;lea 	dx,_ORIG_INT_ADR
;		lea 	dx,ORIG_INT
;		int	21h
;		pop 	es
;		inc 	si
;		inc 	si
;		mov	ax,si	
;		cmp	ax,cx
;		jl	intloop
	;loop 	print_interrupts
	ret	
;
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
setup_hook_interrupts:
	push 	bp
	mov	bp, sp
	push 	ds
	push	cs				;; make data addressable
	pop	ds				;; this is the same as doing the following:
						;; mov 	ax,cs
						;; mov	dx,ax
	push es	
	mov	ax,0
	mov	es, ax
	mov	si, 21*4
	mov	ax, ds:[si]
	mov	[_ORIG_INT_ADR], ax
	or	ax, ds:[si+2]
	mov	[ORIG_INT], ax
	pop 	es

	lea	dx, hook_int			;; address of TSR program passed in ds:dx
	mov 	cx, cs
	mov	ds, cx
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	mov 	al, 0x85			;; at IVT[0x85] or Interupt 133
	int 	21
	;;lea	dx, vga_init			;; address of TSR program passed in ds:dx
	lea	dx, hook_int			;; address of TSR program passed in ds:dx
	;lea	dx, [0x0214]			;; address of TSR program passed in ds:dx
	mov 	cx, cs
	mov	ds, cx
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	mov 	al, 0x21			;; at IVT[0x85] or Interupt 133
	int 	21
	pop	bp
	ret
	;jmp 	short install_tsr

install_tsr:
	lea	dx, ((256 + pgm_len + 15) / 16)
;	lea	dx, ((pgm_len + 15) / 16) + 10
	mov	ax, 0x31
	int 	21
;
pgm_len	equ	$-setup_hook_interrupts-start			;;Referencing Ray Duncan's trick for calculating program length
;pgm_len	equ	$-start			;;Referencing Ray Duncan's trick for calculating program length
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

