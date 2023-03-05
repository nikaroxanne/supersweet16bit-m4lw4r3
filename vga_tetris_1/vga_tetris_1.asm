.286
.MODEL TINY
;******************************************************************************
;	COM Program that manipulates pixel values of command prompt 
;	by writing directly to VGA buffer
;	controls animation using INT 16h keypress return values
;	Assumes 320x200 text mode
;
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

crash:
	xor	di,di
	add	di,051Dh
	cmp	di,3E80h
	jl	near ptr crash_n_setup
	sub	di,3E80h

crash_n_setup:
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
	
;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************
	mov	ax,4C00h
	int	21h

_start	ENDP
	end	_start
