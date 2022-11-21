.286
.MODEL TINY

;******************************************************************************
;	Sample COM Program that manipulates pixel values of command prompt 
;	by writing directly to VGA buffer
; 	uses techniques of CRASH virus for VGA animation
;	avoids infinite loop of crash virus using counter
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
	add	di,051Dh
	cmp	di,3E80h
	jl	near ptr crash_n
	sub	di,3E80h

;******************************************************************************
;
;;copies new pixel values to VGA buffer 
;
;******************************************************************************

crash_n:
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al

	
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

;;a$msg	db	'Hello, MS-DOS!',0Dh,0Ah,24h
;;message to display to stdout

;;msg_len	equ	$-msg
	end	_start
