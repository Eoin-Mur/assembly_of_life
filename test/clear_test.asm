%macro clear_screen 0
	MOV EAX, 4
	MOV EBX, 1
	MOV ECX, CLS
	MOV EDX, 7 ;No point defining a var for this
	INT 0x80
%endmacro

section .data

CLS db 27, "[H", 27, "[2J"

section .text

	global _start

_start:
	
	clear_screen
	
	mov eax, 1
	int 0x80

