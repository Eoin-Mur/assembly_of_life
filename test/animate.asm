%macro write_string 2
	mov eax, 4
	mov ebx, 1
	mov ecx, %1
	mov edx, %2
	int 0x80
%endmacro

%macro clear_screen 0
	MOV EAX, 4
	MOV EBX, 1
	MOV ECX, CLS
	MOV EDX, 7 ;No point defining a var for this
	INT 0x80
%endmacro

section .data
	CLS db 27, "[H", 27, "[2J"
	FOWARD db '/'
	BACKWARD db '\'
	WAIT_VAL dd 8000

section .text

	global _start

_start:

	clear_screen
	write_string FOWARD, 1
	call wait1sec
	clear_screen
	write_string BACKWARD, 1
	call wait1sec

	jmp _start

; need to find out how to get the cpus clock value
wait1sec:
	mov ax, [WAIT_VAL]
	mov bx, [WAIT_VAL]
	l1:
		nop
		l2:
			nop
			dec bx
			cmp bx, 0
			jnz l2	
		dec ax
		cmp ax, 0
		jnz l1
	ret