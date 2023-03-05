.286
.MODEL TINY

;******************************************************************************
;	Template asm file 
;	used for developing test COM programs for MS-DOS malware analysis 
;	Sample COM Program that prints "Hello, world!" to stdout 
;
;	To be used in MS-DOS Emulator program 
;		(i.e. DOSBOX, FreeDOS in qemu, etc)
;	Must be compiled with a 16bit linker 
;		(i.e. ld86 or link16.exe with MASM32) 
;
;	This TSR is for educational purposes only.
;	Use at your own risk and practice at least some modicum of discretion
;
;******************************************************************************
.CODE
	org 100h

_hello	PROC	NEAR
	mov	ah,40h
	mov	bx,1			;;stdout == 1
	mov	dx,offset a$msg
	int	21h
	
	;;terminate program 	
	mov	ax,4C00h
	int	21h

_hello	ENDP

;;message to display to stdout
a$msg	db	'Hello, MS-DOS!',0Dh,0Ah,24h

	end	_hello
