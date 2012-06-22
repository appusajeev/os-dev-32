[bits 32]
[org shell_loc]


mov ax, 16
mov ds, ax
mov es, ax

mov dl, 'a'
int 40


mov eax, 0
cpuid

mov [icpu], ebx
mov [icpu+4], edx
mov [icpu+8], ecx

mov si, vid
int 41
mov si, icpu
int 41

mov esi, icpu2

mov edi, 0x80000002

mov ecx, 3
lx:
	push ecx
	mov eax, edi
	cpuid
	mov [esi], eax
	mov [esi+4], ebx
	mov [esi+8], ecx
	mov [esi+12], edx

	add esi, 16
	inc edi
	pop ecx
	loop lx	
	
mov si, brand
int 41
mov si, icpu2
int 41

mov eax, 1
cpuid

mov ebx, eax

mov ecx, 3
mov di,ptrs
l0:
	mov edx, ebx
	and edx, 15
	mov si, [di]
	int 41
	mov eax, edx
	int 43

	shr ebx, 4
	add di, 2
loop l0

jmp $
	
;readstring:
;	pusha
;	mov ebp, esp
;	
;	mov di, cmd
;	
;	.l1:
;		int 46
;	
;		cmp dl, 10
;		je .l0
;	
;		mov al, dl
;		stosb
;	
;		jmp .l1
;	.l0:
;	
;		mov esp, ebp
;		popa
;		ret
;
;
;jmp $


vid db 10,"Vendor Id: ",0
step db 10, "Stepping: ", 0
model db 10, "Model: ",0
family db 10, "Family: ",0
brand db 10, "Brand: ", 0

ptrs dw step, model, family

icpu times 13 db 0
icpu2 times 50 db 0
