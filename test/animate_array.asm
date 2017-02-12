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
	NL db 0xa
	NL_S equ $-NL

	ARRAY times 200 dd 0
	ARRAY_LEN dd 200
	ROW_LEN dd 20

	WAIT_VAL dd 8000

	CURRENT db 0

section .bss
	cur_out resd 1

section .text

	global _start

_start:
	
	clear_screen
	call print_array
	mov eax, [CURRENT]
	mov [ARRAY+eax], dword 1
	inc byte [CURRENT]

	call wait_loop

	cmp byte [CURRENT], 200
	jne _start

	clear_screen
	call print_array
	jmp exit

; Prints out the contents of the array variable
; TODO write it so you push pointer to array, len, and row num
; to the stack as the procs params
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

wait_loop:
	mov ax, [WAIT_VAL]
	mov bx, [WAIT_VAL]
	wait_loop_i1:
		nop
		wait_loop_i2:
			nop
			dec bx
			cmp bx, 0
			jnz wait_loop_i2	
		dec ax
		cmp ax, 0
		jnz wait_loop_i1
	ret

exit:
	mov eax, 1
	int 0x80
