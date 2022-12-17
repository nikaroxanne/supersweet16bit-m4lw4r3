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
;	Assumes 320x200 and CGA text mode
;		
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
;	
;	To be used in DOSBOX (or similar) MS-DOS Emulator program 
;	Must be compiled with link16.exe (MASM32 preferably) 
;
;******************************************************************************

;.CODE				;masm specific
	org 100h

;_start	PROC	NEAR		;masm specific
start:				;nasm specific
	mov	ax,0B800h
	mov	es,ax
	mov	di,0h
	mov	cx,0h
	;jmp	short crash

sweet_init:
	xor	di,di

sweet_n_setup:
	;mov 	di, 07D0h
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al

	
sweet_n_right:
	add	di,4
	;mov	cx,4Dh
	mov	cx,0050h		;repeat 320 [0x140h] times[width of screen] / 4 [bytes per pixel val]
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	rep	stosw

sweet_n_down:
	add	di,160
	mov	cx,4Dh
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	rep	stosw

sweet_n_intro:
	mov	ah,40h
	mov	bx,1
	mov	cx,b_len
	;mov	dx,offset b_msg			;masm specific
	;lea	dx,b_msg			;nasm specific
	int	21h
	mov	ah,40h
	mov	bx,1
	mov	cx,c_len
	;mov	dx,offset c_msg			;masm specific
	lea	dx, c_msg			;nasm specific
	int	21h
	jmp	sweet_n





;******************************************************************************
;
;;copies new pixel values to VGA buffer 
;
;******************************************************************************

sweet_n:
	inc	di
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
	cmp	al, 004Dh
	je	sweet_n_right
	
	;;check if keypress is Left arrow
	;cmp	al, 004Bh
	;je	sweet_n_left
	
	;;check if keypress is Down arrow
	cmp	al, 0050h
	je	sweet_n_intro
	
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

;_start	ENDP				;masm specific


;	end	_start			;masm specific

