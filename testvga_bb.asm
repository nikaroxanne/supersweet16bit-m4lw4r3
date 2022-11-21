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
	mov	ah,40h
	mov	bx,1
	;;stdout == 1
	mov	dx,offset a$msg
	int	21h

	mov	bx,0B800h
	mov	es,ax
	mov	di,0h
	mov	cx,0h
	jmp	short crash

crash:
	add	di,031Dh
	cmp	di,3E80h
	jl	short crash_n
	sub	di,3E80h

crash_n:
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	inc	cx
	cmp	cx,65556h
	jl 	short crash
	ret

	
	mov	ax,4C00h
	int	21h

_start	ENDP

a$msg	db	'Hello, MS-DOS!',0Dh,0Ah,24h
;;message to display to stdout

;;msg_len	equ	$-msg
;;CODE	ends
	end	_hello
