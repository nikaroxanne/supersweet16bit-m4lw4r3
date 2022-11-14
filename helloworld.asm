.286
.MODEL TINY

;******************************************************************************
;	Template asm file 
;	used for developing test COM programs for MS-DOS malware analysis 
;	Sample COM Program that prints "Hello, world!" to stdout 
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
	
	;;terminate program 	
	mov	ax,4C00h
	int	21h

_hello	ENDP

a$msg	db	'Hello, MS-DOS!',0Dh,0Ah,24h
;;message to display to stdout

;;msg_len	equ	$-msg
	end	_hello
