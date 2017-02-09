	%macro write_string 2
		mov eax, 4
		mov ebx, 1
		mov ecx, %1
		mov edx, %2
		int 0x80
	%endmacro

section .data
	
	NL db 0xa
	NL_S equ $-NL
	ARRAY times 50 dd '1'
	ARRAY_SIZE equ $-ARRAY

section .bss
	cur_out resd 1

section .text

	global _start

_start:

	mov ecx, 0 ;put start index on counter

print_array:
	
	mov eax, ecx ;move index to check
	push ecx ; push so we dont overwrite

	; turns out you cannot pass the direct value to the
	; std_out sys call need to pass via reference.... 
	; this took an hour to figure out :(
	
	mov edx, [ARRAY+eax*4]
	mov [cur_out], edx
	write_string cur_out, 1 ; write current index

	pop ecx ;get back our counter

	inc ecx 
	cmp ecx, 50
	jl print_array
	
write_string NL, NL_S

exit:
	mov eax, 1
	int 0x80
