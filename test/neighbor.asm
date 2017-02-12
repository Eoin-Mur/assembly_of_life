%macro write_string 2
	mov eax, 4
	mov ebx, 1
	mov ecx, %1
	mov edx, %2
	int 0x80
%endmacro

section .data

	ARRAY db 0,0,0,0,1,0,0,0,0


	ROW_LEN dd 3
	COL_LEN dd 3
	ARRAY_LEN dd 9

	NL db 0xa
	NL_S equ $-NL

	msg db 'index : '
	msg_s equ $-msg
	space db ' '

section .bss
	cur_out resd 1

section .text

	global _start

_start:

	call print_array
	mov ecx, 0
	l1:
		mov eax, ecx
		add eax, '0'
		mov [cur_out], eax
		push ecx
		write_string msg, msg_s
		write_string cur_out, 1
		write_string space, 1

		pop ecx
		mov eax, ecx
		push ecx
		call left_neighbor
		add eax, '0'
		mov [cur_out], eax
		write_string cur_out, 1

		pop ecx
		mov eax, ecx
		push ecx
		call right_neighbor
		add eax, '0'
		mov [cur_out], eax
		write_string cur_out, 1

		pop ecx
		mov eax, ecx
		push ecx
		call top_neighbor
		add eax, '0'
		mov [cur_out], eax
		write_string cur_out, 1

		pop ecx
		mov eax, ecx
		push ecx
		call bottom_neighbor
		add eax, '0'
		mov [cur_out], eax
		write_string cur_out, 1

		write_string NL, NL_S
		pop ecx
		inc ecx
		cmp ecx, [ARRAY_LEN]
		jl l1

	jmp exit


; i == 0 || i % r == 0
left_neighbor: 
	cmp eax, 0 
	je left_neighbor_false 
	mov edx, 0
	mov bx, [ROW_LEN]
	idiv bx
	cmp edx, 0 
	je left_neighbor_false
	mov eax, 0
	ret
	left_neighbor_false:
		mov eax, 1
		ret

; (i+1) % c == 0
right_neighbor:
	mov edx, 0
	add eax, 1
	mov bx, [COL_LEN]
	idiv bx
	cmp edx, 0
	je right_neighbor_false
	mov eax, 0
	ret
	right_neighbor_false:
		mov eax, 1
		ret

 ; i < c

top_neighbor:
	cmp eax, [COL_LEN]
	jl top_neighbor_false
	mov eax, 0
	ret
	top_neighbor_false:
		mov eax, 1
		ret

; i > (l-1) - c
bottom_neighbor: 
	mov edx, [ARRAY_LEN]
	sub edx, 1
	sub edx, [COL_LEN]
	cmp eax, edx
	jg bottom_neighbor_false
	mov eax, 0
	ret
	bottom_neighbor_false:
		mov eax, 1
		ret

print_array:
	mov ecx, 0 ;put start index on counter

	print_array_l1:
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
		jl print_array_l1

	ret

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
