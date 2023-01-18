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
;	Assumes 320x200 and VGA text mode
;		
;	
;	Funtion sweet_n_down does use an infinite loop for the animation.
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
SCREEN_WIDTH	EQU 0x140
SCREEN_HEIGHT	EQU 0xC8
LEFT_KEY	EQU 0x4B
RIGHT_KEY	EQU 0x4D
DOWN_KEY	EQU 0x50


;.CODE				;masm specific
	org 100h



;_start	PROC	NEAR		;masm specific
start:				;nasm specific
	mov	ax,0B800h
	mov	es,ax
	mov	di,0h
	mov	cx,0h

sweet_init:
	xor	di,di

sweet_n_setup:
	;mov 	di, 07D0h
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	jmp 	sweet_n

sweet_n_right:
	shl	di,1
	;mov	cx,0140h		;repeat 320 times[width of screen]
	mov	cx,4Ch		;repeat 320 times[width of screen]
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	rep	stosw
	jmp	sweet_n
	
sweet_n_left:
	shr	di,1
	;mov	cx,0140h		;repeat 320 times[width of screen]
	mov	cx,4Ch		;repeat 320 times[width of screen]
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	rep	stosw
	jmp	sweet_n

sweet_n_down:
	add	di,32h
	mov	ax,0
	mov 	cx,0
	mov	al,es:[di]
	add	ax,di
	mov	es:[di],al
	rep	stosw
	inc	cx
	rep 	stosw
	mov	ah,1h
	int	16h
	jnz	sweet_n_down
	jmp	sweet_n

sweet_n_intro:
	mov	ah,40h
	mov	bx,1
	mov	cx,b_len
	;mov	dx,offset b_msg			;masm specific
	lea	dx,b_msg			;nasm specific
	int	21h
	mov	ah,40h
	mov	bx,1
	;;mov	cx,c_len
	;mov	dx,offset c_msg			;masm specific
	;;lea	dx,c_msg			;nasm specific
	;;int	21h
	jmp	sweet_n





;******************************************************************************
;
;;copies new pixel values to VGA buffer 
;
;******************************************************************************

sweet_n:
	;inc	di
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

	;push	di
	mov	ah,0h
	int	16h
	
	;;check if keypress is Right arrow
	cmp	ah, RIGHT_KEY
	je	sweet_n_right
	
	;;check if keypress is Left arrow
	cmp	ah, LEFT_KEY
	je	sweet_n_left
	
	;;check if keypress is Down arrow
	cmp	ah, 50h
	je	sweet_n_down
	
	;;check if keypress is ESC
	cmp	al, 1Bh
	;pop di
	jnz	sweet_n_setup
	;jnz	sweet_init
	

;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************
	mov	ax,4C00h
	int	21h

;_start	ENDP				;masm specific

b_msg	db	"tysm hushcon, see y'all next time xoxo ~*ic3qu33n*~",0Dh,0Ah 
;;message to display to stdout

b_len	equ	$-b_msg

;	end	_start			;masm specific

