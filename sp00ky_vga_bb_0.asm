.286
.MODEL TINY

;******************************************************************************
;	COM Program that manipulates pixel values of command prompt 
;	by writing directly to VGA buffer
; 	uses techniques of CRASH virus for VGA animation
;	avoids infinite loop of crash virus using conditionals for buffer bounds
;	controls animation using INT 16h keypress return values
;	Assumes 320x200 text mode
;	R/r: change to rainbow palette
;	Up arrow: Draw line of pixels from bottom to top row of screen 
;	Down arrow: Draw line of pixels from top to bottom row  of screen 
;	Left arrow: Draw line of pixels from right>left col of screen 
;	Right  arrow: Draw row of pixels from left>right col of screen
;
;	Spooky scary Addams family 16-bit vibes (maybe not, but humor me)
;	**WARNING** FLASHING LIGHTS - Do not run this program if you are
; 	sensitive to rapidly flashing lights; it's everywhere in this one
;	Other programs will be added that do not use the blinking effect
;	
;	To be used in DOSBOX (or similar) MS-DOS Emulator program 
;	Must be compiled with link16.exe (MASM32 preferably) 
;
;******************************************************************************

.CODE
	org 100h

_start	PROC	NEAR

	mov	ax,0B800h
	mov	es,ax
	mov	di,0h
	mov	cx,0h
	jmp	short crash

crash:
	xor	di,di

	add	di,051Dh
	cmp	di,3E80h
	jl	near ptr crash_n_setup
	sub	di,3E80h


crash_n_setup:
	;mov 	di, 07D0h
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	
crash_n_right:
	add	di,4
	jmp	crash_n

crash_n_down:
	add	di,160
	jmp	crash_n



;******************************************************************************
;
;;copies new pixel values to VGA buffer 
;
;******************************************************************************

crash_n:
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
	cmp	al, 4Dh
	jnz	crash_n_right
	
	;;check if keypress is Down arrow
	cmp	al, 50h
	jnz	crash_n_down
	
	;;check if keypress is <
	cmp	al, 01Bh
	jnz	crash_n_setup
	

;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************

	
	mov	ax,4C00h
	int	21h

_start	ENDP

	end	_start
