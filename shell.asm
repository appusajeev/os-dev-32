[bits 32]
[org shell_loc]

mov ax, 16
mov ds, ax
mov es, ax


l0:

mov si, prompt
int 41

;call readstring

;mov si, cmd
;int 41

mov si, cmd
mov dh, 11
int 47

jmp $

jmp l0

readstring:
	pusha
	mov ebp, esp
	
	mov di, cmd
	mov word [len], 0
	.l1:
		int 46
	
		cmp dl, 10
		je .l0
	
		mov al, dl
		stosb
		inc word [len]
		jmp .l1
	.l0:
		mov al, 0
		stosb
		mov esp, ebp
		popa
		ret
prompt db 10, ">>",0
len dw 0
cmd db "cpuinfo.bin", 0
;cmd times 20 db 0
