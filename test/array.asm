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

	ARRAY times 200 db 0
	ARRAY_LEN dd 200
	ROW_LEN dd 20

section .bss
	cur_out resd 1

section .text

	global _start

_start:

	call print_array
	
	jmp exit

; Prints out the contents of the array variable
; TODO write it so you push pointer to array, len, and row num
print_array:
	mov ecx, 0 ;put start index on counter

	l1:
		mov eax, ecx ;move index to check
		push ecx ; push so we dont overwrite

		mov edx, [ARRAY+eax]
		add edx, '0' ; convert the value to ascii for printing
		mov [cur_out], edx
		write_string cur_out, 1 ; write current index

		pop ecx ;get back our counter

		inc ecx
		call end_of_row

		cmp ecx, [ARRAY_LEN]
	jl l1

	ret

; checks if the index in the ecx register corrisponds to the end of 
; a row, if so prints a new line
end_of_row: ; assumes current index of the array is in ecx
	push ecx ; push counter to stack avoid an overwrite
	mov edx, 0
	mov eax, ecx
	mov bx, [ROW_LEN]
	idiv bx
	cmp edx, 0
	je isend
	pop ecx
	ret
	isend:
		write_string NL, NL_S	
		pop ecx
		ret

exit:
	mov eax, 1
	int 0x80
