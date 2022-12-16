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
;	Up arrow: Draw line of pixels from bottom row to top row of screen 
;	Down arrow: Draw line of pixels from top row to bottom row  of screen 
;	Left arrow: Draw line of pixels from left col to right col of screen 
;	Left arrow: Draw line of pixels from right col to left col of screen 
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
	cmp	al, 01Bh
	jnz	near ptr crash
	


;;
;;	inc	cx
;;	cmp	cx,65556h
;;	jl 	short crash
;;	ret

;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************

	
	mov	ax,4C00h
	int	21h

_start	ENDP

	end	_start
