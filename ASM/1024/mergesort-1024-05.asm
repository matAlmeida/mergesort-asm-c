;
; nasm -felf mergesort.asm -o mergesort.o
; gcc -o mergesort mergesort.o
;
BITS 32

	global	main
	extern	printf

	section .text
main:
	mov edi, sorted
	mov esi, array
	mov ecx, 1024
	rep movsd

	push 1024
	push 0
	push sorted
	call mergesort
	add esp, 12

	push sorted
	push 1024
	call print
	add esp, 8
	ret

; 20	max
; 16	med
; 12	min
; 8	array
merge:
	push ebp
	mov ebp, esp
	push eax
	push ecx
	push edx
	push edi
	push esi

	;mov edi, temp
	;mov eax, 0
	;mov ecx, 10
	;rep stosw

	mov ecx, [ebp+20]
	sub ecx, [ebp+12]

	shl DWORD[ebp+12], 2
	shl DWORD[ebp+16], 2
	shl DWORD[ebp+20], 2

	mov edx, temp		; dest
	mov edi, [ebp+8]	; middle source
	add edi, [ebp+16]	;

	; messing with the stack. vamos somar aos 3 idxs o addr base

	mov esi, [ebp+8]
	add [ebp+12], esi
	add [ebp+16], esi
	add [ebp+20], esi
	mov esi, [ebp+12]

.next:
	; source != med
	cmp esi, [ebp+16]
	jnz .second
	; middle != max
	cmp edi, [ebp+20]
	jnz .first
	; sao os dois iguais. fim
	jmp .end

	; quatro condicoes manhosas... medo.
	; vao ser usadas totil de labels
.first:
	cmp esi, [ebp+16]
	jnz .second

	;vamos meter o edi no edx.
	mov eax, [edi]
	mov [edx], eax
	add edx, 4
	add edi, 4
	jmp .next

.second:
	cmp edi, [ebp+20]
	jnz .third

	;vamos meter o esi no edx
	mov eax, [esi]
	mov [edx], eax
	add edx, 4
	add esi, 4
	jmp .next

.third:
	mov eax, [esi]
	cmp eax, [edi]
	jnl .forth

	; meter o esi no edx
	mov [edx], eax
	add edx, 4
	add esi, 4
	jmp .next

.forth:
	mov eax, [edi]
	mov [edx], eax
	add edi, 4
	add edx, 4
	jmp .next
.end:

	;push temp
	;push 10
	;call print
	;add esp, 8

	mov esi, temp
	mov edi, [ebp+12]
	rep movsd

	;push DWORD[ebp+8]
	;push 10
	;call print
	;add esp, 8

	;push endl
	;call printf
	;add esp, 4

	pop esi
	pop edi
	pop edx
	pop ecx
	pop eax
	mov esp, ebp
	pop ebp
	ret

mergesort:
	push ebp
	mov ebp, esp
	push eax

	mov eax, DWORD[ebp+16]	; max
	sub eax, [ebp+12]	; min
	cmp eax, 2
	JL .end
		push edx
		push ebx
			xor edx, edx
			mov ebx, 2
			div ebx
		pop ebx
		pop edx
		add eax, [ebp+12]	; med

		; siga recursivar.
		push eax		; max
		push DWORD[ebp+12]	; min
		push DWORD[ebp+8]	; array
		call mergesort
		add esp, 12

		push DWORD[ebp+16]	; max
		push eax		; min
		push DWORD[ebp+8]	; array
		call mergesort
		add esp, 12

		push DWORD[ebp+16]	; max
		push eax		; med
		push DWORD[ebp+12]	; min
		push DWORD[ebp+8]	; array
		call merge
		add esp, 16
.end:
	pop eax
	mov esp, ebp
	pop ebp
	ret


print:
	push ebp	; Prologue
	mov ebp, esp
	push ecx
	push edx

	mov edx, [ebp+12]
	mov ecx, [ebp+8]

.args:
		push ecx
		push edx
		push DWORD[edx]
		push format
		call printf
		add esp, 8
		pop edx
		pop ecx
		add edx, 4
	LOOP .args

	push endl
	call printf
	add esp, 4

	pop edx		;
	pop ecx		;
	mov esp, ebp	;
	pop ebp		; Epilogue
	ret		;

format:
	db	' %2d', 0
endl:
	db	10, 0

array:
	dd	0,5,0,0,4,0,3,6,1,6,5,7,7,8,8,7,2,5,3,6,7,0,9,1,7,4,9,7,9,8,8,0,3,6,4,4,8,2,2,6,3,1,1,5,5,6,5,8,0,6,4,2,9,2,7,9,3,1,3,8,6,3,3,3,7,7,1,3,1,1,3,8,0,3,7,9,8,3,7,3,7,4,5,5,2,7,7,9,5,2,1,8,0,9,9,2,9,0,7,8,1,6,8,7,2,1,7,0,7,0,4,1,5,8,6,2,1,5,8,4,4,9,2,9,4,4,2,5,6,9,9,9,5,8,9,3,3,6,2,2,3,0,4,9,1,8,8,5,6,7,1,7,2,0,7,7,0,9,5,2,5,4,6,8,9,8,7,1,1,2,5,5,9,0,2,1,9,1,6,8,1,3,5,7,3,8,2,4,4,2,3,8,9,9,9,3,4,9,0,1,5,3,2,1,2,5,5,3,8,3,0,0,9,1,0,5,2,5,9,9,7,0,3,5,7,6,4,8,9,0,4,1,7,1,8,1,4,0,6,5,0,1,7,1,3,7,5,0,8,7,0,2,8,2,0,4,7,6,3,3,9,5,6,7,3,0,7,0,2,8,1,0,9,3,6,0,1,9,6,5,7,1,9,1,2,9,3,0,8,7,9,1,4,0,3,3,5,8,6,0,6,7,5,5,9,6,5,4,2,8,9,4,9,6,8,9,7,5,6,0,1,1,9,9,0,3,8,7,0,9,4,1,2,2,3,1,4,8,1,5,1,1,4,2,2,5,7,2,2,6,1,2,4,1,8,2,9,8,9,4,2,5,7,9,0,3,2,2,8,4,3,8,3,0,5,8,4,4,8,3,1,7,9,7,7,9,6,6,4,1,4,0,9,3,2,3,8,0,2,9,1,9,1,6,2,4,7,9,7,8,3,6,8,6,2,6,4,2,8,2,9,5,6,5,9,4,7,6,6,0,2,5,2,7,3,9,4,7,1,0,8,0,8,2,1,7,6,1,0,4,8,9,4,8,7,0,9,6,2,3,0,5,1,7,9,8,4,5,6,8,1,8,7,1,3,4,4,1,6,8,0,7,1,6,9,2,3,8,3,6,8,9,0,0,7,8,9,8,7,3,2,4,5,4,1,7,4,7,3,5,6,8,3,7,4,9,8,6,8,0,2,0,8,8,4,6,3,8,3,5,5,7,5,0,9,2,2,6,6,0,1,9,3,6,9,3,7,8,7,1,9,1,9,6,5,0,6,3,8,0,6,2,7,6,1,8,9,8,0,2,6,3,0,7,5,3,6,9,8,1,9,8,0,0,9,1,6,5,8,2,3,6,1,4,2,9,9,5,1,6,8,2,2,9,4,6,3,9,3,0,9,1,4,0,1,5,5,8,2,0,4,9,0,6,7,6,5,8,6,8,8,2,2,5,5,2,2,5,6,1,9,8,2,2,7,5,6,5,3,4,6,8,0,8,1,8,7,2,4,3,0,8,0,5,8,3,6,2,9,5,3,4,2,6,3,6,5,0,7,8,7,3,6,0,3,5,7,8,6,5,7,4,5,9,7,8,1,3,4,7,6,5,2,7,8,2,5,3,5,9,5,4,6,9,0,8,6,1,3,9,0,4,7,8,9,0,5,5,7,7,2,8,6,1,2,9,0,1,7,7,6,4,4,3,7,2,6,7,5,0,7,5,6,9,1,0,3,1,5,2,4,6,3,7,1,5,8,7,2,7,3,5,9,6,2,2,8,3,3,8,6,4,5,7,4,0,9,6,5,5,5,4,9,8,5,5,7,3,2,1,8,1,3,0,7,7,0,5,0,5,9,2,5,3,7,2,6,4,5,1,1,7,7,9,8,7,5,1,7,1,2,9,5,7,1,4,8,6,7,3,0,0,2,3,0,9,7,9,7,6,1,5,8,1,0,7,1,6,4,0,7,4,9,6,7,4,7,5,8,6,5,3,6,4,3,3,3,3,9,0,1,1,4,0,3,4,3,6,4,1,6,6,2,9,3,4,0,0,3,4,3,9,2,3,1,3,6,5,0,3,0,6,2,9,2,2,6,5,8,4,0,9,1,3,2,4,0,3,4,7,6,8,8,5,9,8,0,2,3,9,0,8,7,0,3,4,0,6,4,8,6,8,1,1,8,4,5,1,7,1,5,8,8,5,0,9,1,4,3,2,5,9,6,3,2,8,4,4,3,1,7,0,9,3,3,7,8,5,1,5,8,4,1,9,5,4,7,7,4,3,7,4,9,0,3,6,1,5,5,8,0,6,3,3,5,3,1,7,8,0,8,2,1,6


	section .bss
sorted:
	resd	1024
temp:
	resd	1024

