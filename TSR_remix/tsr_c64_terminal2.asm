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
SCREEN_MAX	equ	320*200
DRAW_HALT	equ	320*50
SCREEN_WIDTH	equ	0x140		;;320
SCREEN_HEIGHT	equ	0xC8		;;200
VGA_PAL_INDEX	equ	0x3C8
VGA_PAL_DATA	equ	0x3C9
;
;******************************************************************************

;_start	PROC	NEAR 		; masm-specific
start:
	jmp 	setup_hook_interrupts

old_INT:
db	0EAh			;from Spanska Elvira, EAh is far call
_ORIG_INT	dd	? 	;this is also such a nice trick bc it avoids having to define these in a data segment
iret				;so there is no need to change the segment for loading cs w the correct value


tsr_hook_int:
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
	vga_init:
		mov	ax, 0013h
		int	10h
		mov	ax,0xA000
		mov	es,ax
		mov	ds,ax
		mov	di,0
		mov	ax,0202h
		cld
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
			jmp 	vga_x
			
		vga_x:	
			xor	di,di
			mov	cx, SCREEN_MAX
			vga_loop:
				mov 	ax, es:[di]
				add 	ax, di
				and	ax, 0xff
				;mov	es:[di], al
				;mov	es:[di+2], ah
				;add 	di,2
				rep	stosb		;moves ax into es:[di]
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
;	int 	85h
	push	ax
	mov	al, 0x20
	out	0x20, al
	pop	ax
	jmp 	old_INT
;	iret

setup_hook_interrupts:
	push es	
	mov	ax,0
	mov	es, ax
	es 	les bx,[0x84]			;;for int 21h
						;;es:bx contains contents of address 0x84 (0000:0084)
	mov	[_ORIG_INT], bx
	mov	[_ORIG_INT+2], es
	
;	push 	es	
;	pop 	ds
;	mov		dx, bx				;ds:dx now == es:bx (seg:offset of int 21h)
;	mov		ah, 0x25			;; new IVR (interrupt vector routine) installed
;	mov 	al, 0x85			;; at IVT[0x85] or Interupt 21
;	int		21h
;	pop 	es

;******************************************************************************
; Set the interrupt vector of our target interrupt to point to the TSR routine
;******************************************************************************
	mov cx, cs				;;make data addressable
	mov	ds, cx
	mov	dx, tsr_hook_int			;; address of TSR program passed in ds:dx
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	mov al, 0x21			;; at IVT[0x21] or Interupt 21
	int 21h

;******************************************************************************
; Calculate size of memory to reserve for TSR, using the following values:
; 256 (0x100) = size of PSP
;
; length of program 
;; [Referencing Ray Duncan's trick for calculating program length
;; for specifying dx (memsize) of TSR, used in int 21h function 31h call]
;
; pgm_len equ $-{function following TSR}-{start of TSR}
;
; in this case, 
;
; pgm_len	equ	3569JXZghikmssetup_hook_interrupts-start	
; 
; and the additional adjustment for aligning on a 16-byte paragraph boundary,
; which can be done by adding 15 to our total program length (program len + 256)
; and dividing by 16
;
; The final formula is as follows:
; ((256 + pgm_len + 15) / 16)
						
; move this memory size into dx
; call the MS-DOS TSR function with 31 (subfunction number) in AH
; and return value (0, 1, 2, take your pick) in AL
;******************************************************************************
install_tsr:
	mov	dx, ((256 + setup_hook_interrupts-start + 15) / 16)
	mov	ax, 0x3102
	int 	21h

pgm_len	equ 	$-setup_hook_interrupts-start	;;Referencing Ray Duncan's trick for calculating program length
						;; for specifying dx (memsize) of TSR, used in int 21h function 31h call

;;_start	ENDP				;masm specific
;;end	_start			;masm specific

