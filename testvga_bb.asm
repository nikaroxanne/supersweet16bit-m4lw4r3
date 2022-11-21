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

_hello	PROC	NEAR
	mov	ah,40h
	mov	bx,1
	;;stdout == 1
	mov	dx,offset a$msg
	int	21h

	mov	bx,0B800h
	mov	es,ax
	mov	di,0h
	mov	bx,0h

crash:
	add	di,031Dh
	mov	al,es:[di]
	iadd	ax,di
	mov	al,es:[di]
	inc	cx
	cmp	cx,0255h
	jge 	crash
	ret

	
	mov	ax,4C00h
	int	21h

_hello	ENDP

a$msg	db	'Hello, MS-DOS!',0Dh,0Ah,24h
;;message to display to stdout

;;msg_len	equ	$-msg
;;CODE	ends
	end	_hello
