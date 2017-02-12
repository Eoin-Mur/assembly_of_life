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

	; 1 1 0
	; 0 0 0
	; 0 1 0
	ARRAY dd 1,1,0,0,0,0,0,1,0

	ROW_LEN dd 3
	COL_LEN dd 3
	ARRAY_LEN dd 9

	msg db 'index : '
	msg_s equ $-msg
	space db ' '

section .bss 

	alive_neighbors resb 1
	cur_out resd 1 

section .text
	
	global _start

_start:
	call print_array
	mov ecx, 0

	search_loop:

		push ecx
		add ecx, '0'
		mov [cur_out],ecx
		write_string msg, msg_s
		write_string cur_out,1
		write_string space,1

		pop ecx
		call check_all_neighbors
		mov ax, [alive_neighbors]
		add ax, '0'
		mov [alive_neighbors], ax

		push ecx
		write_string alive_neighbors, 1
		write_string NL, NL_S

		pop ecx
		inc ecx
		cmp ecx,[ARRAY_LEN]
		jne search_loop
	jmp exit

; assumes the element whose neighbors we are checking is in the ecx
; register
; returns in the alive_neighborss var the total number of alive(1)neighbors
check_all_neighbors:
	mov byte [alive_neighbors], 0 ;initalise our count var
	call check_left_neighbors
	call check_right_neighbors
	call check_top_neighbor
	call check_bottom_neighbor
	ret 

check_left_neighbors:
	push ecx
	mov eax, ecx
	call has_left_neighbors
	cmp eax, 0 ; if it has neighbors to the left
	je get_lalivem
	pop ecx
	ret
	get_lalivem:
		mov eax, ecx
		sub eax, 1 ; move to the left
		mov edx, [ARRAY+eax*4]
		cmp edx, 1
		jne get_lalivet ; if not alive check next
		inc byte [alive_neighbors]
	get_lalivet:
		mov eax, ecx
		call has_top_neighbors
		cmp eax, 0
		jne get_laliveb ; if doesnt have top neighbors skip
		mov eax, ecx
		sub eax, 1 ; move to the left
		sub eax, [COL_LEN] ; move up a row
		mov edx, [ARRAY+eax*4]
		cmp edx, 1
		jne get_laliveb ; if not alive check next
		inc byte [alive_neighbors]
	get_laliveb:
		mov eax, ecx
		call has_bottom_neighbors
		cmp eax, 0
		jne check_left_neighbors_end ; if doesnt have bottom neighbors skip
		mov eax, ecx
		sub eax, 1 ; move to the left
		add eax, [COL_LEN] ; go down row
		mov edx, [ARRAY+eax*4]
		cmp edx, 1
		jne check_left_neighbors_end ; if not alive check next
		inc byte [alive_neighbors]
	check_left_neighbors_end:
		pop ecx
		ret

check_right_neighbors:
	push ecx
	mov eax, ecx
	call has_right_neighbors
	cmp eax, 0 ; if it has neighbors to the left
	je get_ralivem
	pop ecx
	ret
	get_ralivem:
		mov eax, ecx
		add eax, 1 ; move to the right
		mov edx, [ARRAY+eax*4]
		cmp edx, 1
		jne get_ralivet ; if not alive check next
		inc byte [alive_neighbors]
	get_ralivet:
		mov eax, ecx
		call has_top_neighbors
		cmp eax, 0
		jne get_raliveb ; if doesnt have top neighbors skip
		mov eax, ecx
		add eax, 1 ; move to the right
		sub eax, [COL_LEN] ; move up a row
		mov edx, [ARRAY+eax*4]
		cmp edx, 1
		jne get_raliveb ; if not alive check next
		inc byte [alive_neighbors]
	get_raliveb:
		mov eax, ecx
		call has_bottom_neighbors
		cmp eax, 0
		jne check_right_neighbors_end ; if doesnt have top neighbors skip
		mov eax, ecx
		add eax, 1 ; move to the left
		add eax, [COL_LEN] ; go down row
		mov edx, [ARRAY+eax*4]
		cmp edx, 1
		jne check_right_neighbors_end ; if not alive last check return
		inc byte [alive_neighbors]
	check_right_neighbors_end:
		pop ecx
		ret

check_top_neighbor:
	push ecx
	mov eax, ecx
	call has_top_neighbors
	cmp eax, 0
	je get_talive
	pop ecx
	ret
	get_talive: ; only need to check directly above as the l and r checks do horiz
		mov eax, ecx
		sub eax, [COL_LEN] ; go up a row
		mov edx, [ARRAY+eax*4]
		cmp edx, 1
		jne check_top_neighbor_end
		inc byte [alive_neighbors]
	check_top_neighbor_end:
		pop ecx
		ret

check_bottom_neighbor:
	push ecx
	mov eax, ecx
	call has_bottom_neighbors
	cmp eax, 0
	je get_balive
	pop ecx
	ret
	get_balive:
		mov eax, ecx
		add eax, [COL_LEN] ; go down a row
		mov edx, [ARRAY+eax*4]
		cmp edx, 1
		jne check_bottom_neighbor_end
		inc byte [alive_neighbors]
	check_bottom_neighbor_end:
		pop ecx
		ret

; i == 0 || i % r == 0
has_left_neighbors: 
	cmp eax, 0 
	je has_left_neighbors_false 
	mov edx, 0
	mov bx, [ROW_LEN]
	idiv bx
	cmp edx, 0 
	je has_left_neighbors_false
	mov eax, 0
	ret
	has_left_neighbors_false:
		mov eax, 1
		ret

; (i+1) % c == 0
has_right_neighbors:
	mov edx, 0
	add eax, 1
	mov bx, [COL_LEN]
	idiv bx
	cmp edx, 0
	je has_right_neighbors_false
	mov eax, 0
	ret
	has_right_neighbors_false:
		mov eax, 1
		ret

 ; i < c

has_top_neighbors:
	cmp eax, [COL_LEN]
	jl has_top_neighbors_false
	mov eax, 0
	ret
	has_top_neighbors_false:
		mov eax, 1
		ret

; i > (l-1) - c
has_bottom_neighbors: 
	mov edx, [ARRAY_LEN]
	sub edx, 1
	sub edx, [COL_LEN]
	cmp eax, edx
	jg has_bottom_neighbors_false
	mov eax, 0
	ret
	has_bottom_neighbors_false:
		mov eax, 1
		ret

print_array:
	mov ecx, 0 ;put start index on counter

	print_array_l1:
		mov eax, ecx ;move index to check
		push ecx ; push so we dont overwrite

		mov edx, [ARRAY+eax*4]
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