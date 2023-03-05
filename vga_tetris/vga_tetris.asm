;.286			;masm specific
;.MODEL TINY		;masm specific

;******************************************************************************
;	Hooks BIOS Interrupts to draw pretty pictureds to terminal screen
;	Intro to COM Programs for Hushcon Seattle 2022 Presentation
;	MTV Reboot: My Super Sweet 16-Bit Malware:
;	~*MS-DOS Edition*~
;
;	COM Program that manipulates pixel values of command prompt 
;	by writing directly to VGA buffer
;	controls animation using INT 16h keypress return values
;	Assumes 320x200 and VGA text mode
;	
;	Funtion vga-tetris_n_down does use an infinite loop for the animation.
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
SCREEN_WIDTH	EQU 0x140
SCREEN_HEIGHT	EQU 0xC8
LEFT_KEY	EQU 0x4B
RIGHT_KEY	EQU 0x4D
DOWN_KEY	EQU 0x50


;.CODE				;masm specific
	org 100h

;_start	PROC	NEAR		;masm specific
start:				;nasm specific
	mov	ax,0B800h
	mov	es,ax
	mov	di,0h
	mov	cx,0h

vga-tetris_init:
	xor	di,di

vga-tetris_n_setup:
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	jmp 	vga-tetris_n

vga-tetris_n_right:
	shl	di,1
	mov	cx,4Ch		;repeat 320 times[width of screen]
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	rep	stosw
	jmp	vga-tetris_n
	
vga-tetris_n_left:
	shr	di,1
	mov	cx,4Ch		;repeat 320 times[width of screen]
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	rep	stosw
	jmp	vga-tetris_n

vga-tetris_n_down:
	add	di,32h
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
	jnz	vga-tetris_n_down
	jmp	vga-tetris_n

vga-tetris_n_intro:
	mov	ah,40h
	mov	bx,1
	mov	cx,b_len
	;mov	dx,offset b_msg			;masm specific
	lea	dx,b_msg			;nasm specific
	int	21h
	mov	ah,40h
	mov	bx,1
	jmp	vga-tetris_n

;******************************************************************************
;
;;copies new pixel values to VGA buffer 
;
;******************************************************************************
vga-tetris_n:
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
	cmp	ah, RIGHT_KEY
	je	vga-tetris_n_right
	
	;;check if keypress is Left arrow
	cmp	ah, LEFT_KEY
	je	vga-tetris_n_left
	
	;;check if keypress is Down arrow
	cmp	ah, 50h
	je	vga-tetris_n_down
	
	;;check if keypress is ESC
	cmp	al, 1Bh
	jnz	vga-tetris_n_setup

;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************
	mov	ax,4C00h
	int	21h

;;message to display to stdout
b_msg	db	"I <3 VGA graphics", 0Dh, 0Ah
b_len	equ	$-b_msg

;_start	ENDP				;masm specific
;	end	_start			;masm specific

