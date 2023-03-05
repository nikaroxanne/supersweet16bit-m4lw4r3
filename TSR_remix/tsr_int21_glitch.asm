;model: small		;masm specific
;.286			;masm specific

;******************************************************************************
;	COM Program that installs a TSR to the IVT
;	The newly added ISR does the following:
;	-hooks interrupt 21h 
;	-installs a routine that (when function 4Bh is invoked) will
;	-change the graphics mode of COMMAND.COM to mode 13h (256 VGA mode)
;	-draws a bar of green to the VGA buffer (displayed in command prompt)
;	-returns control to int21h ISR
;	-and then exits
;	 
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
;	assume CS:TEXT, DS:TEXT		;masm-specific
bits 16
.text:
	org 100h

;******************************************************************************
;	References technique for defining the original interrupt seg + offset
; 	in relation to DS register, used in Stoned.asm 
;

TARGET_INT	dd	0x21
IVT_OFFSET	dd	TARGET_INT * 4

;******************************************************************************

;_start	PROC	NEAR 		; masm-specific
start:
	jmp 	setup_hook_interrupts


old_INT:
db	0EAh			;technique from Spanska Elvira, EAh is far call
_ORIG_INT	dd	? 	;this is also such a nice trick bc it avoids having to define these in a data segment
iret				;so there is no need to change the segment for loading cs w the correct value

hook_int:
	cmp	ax, 4B00h
	jne 	NO_INT
	pushf
NEW_INT:
	push 	ax		;save all registers to preserve state before invocation of new ISR
	push 	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	si
	push	di
	
	;;this is the body of our routine that will be invoked if a call to int21h is made, with subfunction 4Bh	
	;;do things here xoxo
	cli			;disable system interrupts (prevents other interrupts from interfering with the new ISR)
	mov	ax, 0013h
	int	10h
	mov	ax,0xA000
	mov	es,ax
	mov	di,0
	mov	cx, (6400/2)
	mov	ax,0202h
	cld
	repnz	stosw
	;mov	bx, b_msg
	;mov	ax, 0303h
	;int	10h
	;mov	ah, 40h
	;mov	bx, 1
	;mov	cx,b_len
	;lea 	dx,b_msg
	;int	21h

	sti			;re-enabled system interrupts at the conclusion of our ISR
	pop 	di		;restore all registers of saved state, after conslusion of new ISR
	pop	si
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	push	ax
	mov	al, 0x20
	out	0x20, al
	pop	ax
	
NO_INT:
	call old_INT
	iret

setup_hook_interrupts:
	push es	
	mov	ax,0				;;move address for target interrupt into es:bx
	mov	es, ax                          ;; in this case, IVT_OFFSET==0x84 (0000:0084)
	es 	les bx,[IVT_OFFSET]		;;so es == [0x84] (segment) and bx==[0x86] (offset) 
						
	mov	[_ORIG_INT], bx			;save those address values (segment and offset)
	mov	[_ORIG_INT+2], es		;to variables in our TSR 
	
	push 	es	
	pop 	ds
	mov	dx, bx				;ds:dx now == es:bx (seg:offset of int 21h)
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	mov 	al, 0x85			;; at IVT[0x85] or Interupt 21
	int	21h
	pop 	es

	mov 	cx, cs				;;make data addressable
	mov	ds, cx
	mov	dx, hook_int			;; address of TSR program passed in ds:dx
	mov	ah, 0x25			;; new IVR (interrupt vector routine) installed
	mov 	al, 0x21			;; at IVT[0x21] or Interupt 21
	int 	21h

install_tsr:
	mov	dx, ((256 + setup_hook_interrupts-start + 15) / 16)
	mov	ax, 0x3102
	int 	21h

pgm_len	equ	$-setup_hook_interrupts-start	;;Referencing Ray Duncan's trick for calculating program length
						;; for specifying dx (memsize) of TSR, used in int 21h function 31h call

b_msg	db	"TSR Infection complete", 0Dh,0Ah
b_len	equ	$-b_msg

;;_start	ENDP				;masm specific
;	;end	_start			;masm specific

