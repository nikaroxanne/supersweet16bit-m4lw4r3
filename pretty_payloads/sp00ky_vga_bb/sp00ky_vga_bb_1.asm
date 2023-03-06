.286
.MODEL TINY

;******************************************************************************
;	COM Program that manipulates pixel values of command prompt 
;	by writing directly to VGA buffer
;	avoids infinite loop using conditionals for buffer bounds
;	controls animation using INT 16h keypress return values
;	Assumes 320x200 text mode
;	
;	R/r: change to rainbow palette
;	Up arrow: Draw line of pixels from bottom to top row of screen 
;	Down arrow: Draw line of pixels from top to bottom row  of screen 
;	Left arrow: Draw line of pixels from right>left col of screen 
;	Right  arrow: Draw row of pixels from left>right col of screen
;
;	Spooky scary Addams family 16-bit vibes (maybe not, but humor me)
;	**WARNING** FLASHING LIGHTS - Do not run this program if you are
; 	sensitive to rapidly flashing lights; it's everywhere in this one
;	Other programs in this repo do not use the blinking effect,
;	please refer to those to avoid photosensitivity triggers
;	
;	To be used in MS-DOS Emulator program 
;		(i.e. DOSBOX, FreeDOS in qemu, etc)
;	Must be compiled with a 16bit linker 
;		(i.e. ld86 or link16.exe with MASM32) 
;
;	This program is for educational purposes only.
;	Use at your own risk and practice at least some modicum of discretion
;******************************************************************************

.CODE
	org 100h

_start	PROC	NEAR

	mov	ax,0B800h
	mov	es,ax
	mov	di,0h
	mov	cx,0h

sp00kyfx:
	xor	di,di
	add	di,051Dh
	cmp	di,3E80h
	jl	near ptr sp00kyfx_n_setup
	sub	di,3E80h

;******************************************************************************
;
;;Clears the screen by writing 2000 black pixels to the terminal window 
;terminal window VGA buffer at 0xB800h 
;
;******************************************************************************
sp00kyfx_n_setup:
	mov	al,es:[di]
	add	ax,di
	mov	cx,2000h
	mov	es:[di],al
	rep	stosw
	
sp00kyfx_n_right:
	add	di,4
	jmp	sp00kyfx_n

sp00kyfx_n_down:
	add	di,160
	jmp	sp00kyfx_n

;******************************************************************************
;
;;copies new pixel values to VGA buffer 
;
;******************************************************************************

sp00kyfx_n:
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
	jnz	sp00kyfx_n_right
	
	;;check if keypress is Down arrow
	cmp	al, 50h
	jnz	sp00kyfx_n_down
	
	;;check if keypress is <
	cmp	al, 01Bh
	jnz	sp00kyfx_n_setup
	

;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************
	mov	ax,4C00h
	int	21h

_start	ENDP
	end	_start
