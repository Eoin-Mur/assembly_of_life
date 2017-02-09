%macro write_string 2
	MOV EAX, 4
	MOV EBX, 1
	MOV ECX, %1
	MOV EDX, %2
	INT 0x80
%endmacro

section .text
	MSG DD "Hello World"
	MSG_LEN equ $ - MSG

section .data

	global _start

_start:

main:

	write_string MSG, MSG_LEN

	mov eax, 1
	int 0x80