;.286			;masm specific
;.MODEL TINY		;masm specific

CPU 286			;nasm specific
BITS 16                 ;nasm specific
;******************************************************************************
;	Hooks BIOS Interrupts to draw pretty pictureds to terminal screen
;	Intro to COM Programs for Hushcon Seattle 2022 Presentation
;	MTV Reboot: My Super Sweet 16-Bit Malware:
;	~*MS-DOS Edition*~
;
;	COM Program that manipulates pixel values of command prompt 
;	by writing directly to VGA buffer
;	controls animation using INT 16h keypress return values
;	Assumes 320x200 and CGA text mode
;	
;	Also importantly: There are NO FLASHING LIGHTS IN THIS PROGRAM.
;
;	Same note as previous:
;
;	I promised you a pretty one, here's a pretty bb.
;	Without the malicious payload, of course.
;	No malicious manipulation of MBRs. No no, never.
;	There are some brighter pixel values 
;	There are also what might be considered garish color schemes
;	but this is my art so 
;
;	To be used in MS-DOS Emulator program 
;		(i.e. DOSBOX, FreeDOS in qemu, etc)
;	Must be compiled with a 16bit linker 
;		(i.e. ld86 or link16.exe with MASM32) 
;
;	This program is for educational purposes only.
;	Use at your own risk and practice at least some modicum of discretion
;******************************************************************************
;.CODE				;masm specific
	org 100h

;_start	PROC	NEAR		;masm specific
start:				;nasm specific
	mov	ax,0B800h
	mov	es,ax
	mov	di,0h
	mov	cx,0h

sweet_init:
	xor	di,di

sweet_n_setup:
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	jmp 	sweet_n

sweet_n_right:
	add	di,4Ch
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	stosw
	jmp	sweet_n
	
sweet_n_left:
	sub	di,4Ch
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	stosw
	jmp	sweet_n

sweet_n_down:
	add	di, 0C8h
	mov	ax,0
	mov 	cx,0
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	rep	stosw
	inc	cx
	rep 	stosw
	mov	ah,1h
	int	16h
	jnz	sweet_n_down
	jmp	sweet_n

sweet_n_intro:
	mov	ah,40h
	mov	bx,1
	mov	cx,b_len
	;mov	dx,offset b_msg			;masm specific
	lea	dx,b_msg			;nasm specific
	int	21h
	mov	ah,40h
	mov	bx,1
	jmp	sweet_n

;******************************************************************************
;
;;copies new pixel values to VGA buffer 
;
;******************************************************************************
sweet_n:
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	stosw
	
;******************************************************************************
;
;	Reads char from buffer (function 0h,int16h)
; 	Char returned in al
; 	If char in al == 0x1b (ESC) then terminate program
;	Else, continue VGA *~pretty picture~* loop
;
;******************************************************************************
	mov	ah,0h
	int	16h
	
	;;check if keypress is Right arrow
	cmp	ah, 0x4D
	je	sweet_n_right
	
	;;check if keypress is Left arrow
	cmp	ah, 0x4B
	je	sweet_n_left
	
	;;check if keypress is Down arrow
	cmp	ah, 0x50
	je	sweet_n_down
	
	;;check if keypress is ESC
	cmp	al, 01Bh
	jnz	sweet_n_setup

;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************
	mov	ax,4C00h
	int	21h

;;messages to display to stdout
b_msg	db	'My Super Sweet 16-Bit Malware:',0Dh,0Ah,1FH
c_msg	db	'MS-DOS Edition',0Dh,0Ah,0Eh

b_len	equ	$-b_msg
c_len	equ	$-c_msg

;_start	ENDP				;masm specific
;	end	_start			;masm specific

