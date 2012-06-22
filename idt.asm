[bits 16]
[org 0]

	mov ax, cs
	mov ds, ax
	mov es, ax
	
	mov ax, 0x4000
	mov ss, ax
	mov sp, 400


	cli
	lidt [idt_ptr]

	mov di, startIDT
	mov bx, 0
	mov cx, 16
	fill:
		mov si, [ptrs + bx]
		add si, IDT_loc
		mov word [di],  si
		mov word [di+2], 8
		mov byte [di + 4], 0
		mov byte [di + 5], 0b10001110
		mov word [di + 6], 0
		add di, 8
		add bx, 2
	loop fill

	jmp (GDT_loc/16):0


[bits 32] ;------------------------------------------------------------------ handlers
search:		; search the filetable for the file
	pusha
	;push ds
	
	;mov ax, 64
	;mov ds, ax
	mov ebp,esp 

	;cmp ax,ax ; to set zero flag
	
	mov di,si

	mov ebx,0
	mov ecx, 0

	cld

	mov ax, 72
	mov gs, ax

	hlt 
	cont_chk:
		;mov dl,[gs:bx]
		mov al, [gs:bx]
		;push dx
		;mov dl, al
		;int 40
		;pop dx

		cmp al,'}'
		
		je complete	
		cmp al,[di]
		je chk
		inc bx
		jmp cont_chk

	chk:
		push bx
		mov cl, dh
		mov ch, 0
	check:
		mov al,[gs:bx]
		;mov dl, [gs:bx]
		;int 40
		inc bx
		
		scasb
		loope check
		
		je succ
		;int 40
		;jmp $
		mov di,si
		pop bx
		inc bx
		jmp cont_chk
	
	complete:
		push ds
		mov ax, 64
		mov ds, ax
		mov si, fail
		int 41
		pop ds
		jmp en
	succ:
		;jmp $
		inc bx
		
		;
		;sub sp, 4
		
		push  bx
		call findparams
		
		
		pop word [offset]

		;jmp $

		mov eax, [offset]
		;int 43

		;pop word [offset]
		;mov eax, [offset]
		;int 43


		;jmp $
		call findparams

		pop word [size]

		mov eax, [size]
		;int 43
		;jmp $
		call load

	en:
		mov esp,ebp
		;pop ds
		popa

		iretd


load:
	pusha
	mov ebp, esp

	mov ecx, 0
	mov cx, [size]

	
	cld
	
	push es
	push ds
	
	push  word [offset]
	
	mov ax, 16
	mov ds, ax
	
	mov ax, 16
	mov es, ax
		
	mov edi,shell_loc
	mov esi, 0
	
	pop si
	add si, rd_loc
	rep movsb
		
		
	pop ds
	pop es

	
	mov sp, bp
	popa
	ret

findparams:	; find the sector containing the given file	
	pusha
	push ds
	mov ebp,esp
	mov bx,[ebp+ 40 ]
	
	;mov eax, ebx
	;int 43
	;jmp $

	cld
	mov ax, 64
	mov ds, ax

	mov word [param],0
	mov cx,10
	
	cont_st:
		
		mov al,[gs:bx]
		;mov dl, al
		;int 40

		inc bx

		cmp al,','
		jz finish
		cmp al,'|'
		jz finish
		cmp al,48
		jl mismatch
		cmp al,58
		jg mismatch

		;mov dl, al
		;;int 40
		sub al,48
		mov ah,0
		push ax
		mov ax,word [param]

		mul cx

		pop dx
		add ax,dx
		mov word [param],ax		

		jmp cont_st

		finish:

			;mov eax, [param]
			;int 43
			;jmp $
			;inc bx
			mov [ebp+42], ebx
			;mov eax, [ebp + 42 ] 
			;int 43

			mov ax, [param]
			mov [ebp+40], ax

		mismatch_end:
			mov esp,ebp
			pop ds
			popa
			ret
		mismatch:
			mov si, fail
			int 41
			jmp mismatch_end

scroll:
	pusha

	
	mov ax, vidmem
	mov gs, ax
	
	mov ecx, 1600
	mov ebx, 0
	mov si, 160
	
	scro:
	
	mov ax,[gs:si]
	mov [gs:bx], ax
	add bx, 2
	add si, 2
	loop scro
	
	mov bx , [current]	
	sub bx, 160
	mov [current], bx
		
	popa
	ret
clrscr:
	pusha
	push ds
	mov ax, vidmem
	mov gs, ax
	
	mov ecx, 2000
	mov ebx, 0
	clrs:
		mov byte [gs:bx], 0
		mov byte [gs:bx+1],0x10
		add ebx, 2
		loop clrs
	mov ax, 64
	mov ds, ax
	mov word [current], 0
	pop ds
	popa
	iretd
printchar:
	pusha
	push ds
	push gs

	mov ax,vidmem
	mov gs, ax
	
	mov ax, 64
	mov ds, ax
	
	mov bx, [current]
	
	cmp bx, 3999
	
	jle .l0
	
	int 42
	mov bx, [current]
	
	.l0:
	cmp dl, 10
	jz nl
	
	mov byte [gs:bx], dl
	mov byte [gs:bx + 1], 0x1f
	add bx, 2
	mov [current], bx
	
	shr bx, 1
	mov dx, 0x3d4
	mov al, 0xf
	out dx, al
	
	mov dx, 0x3d5
	mov al, bl
	out dx, al
	
	mov dx, 0x3d4
	mov al, 0xe
	out dx, al
	
	mov dx, 0x3d5
	mov al, bh
	out dx, al
	
	foo:
		pop gs
		pop ds
		popa
		iretd
	
	nl:
		mov ax, [current]
		shr ax, 1
		mov dl, 80
		div dl
		
		inc al
		mov ah, 0
		mov dl, 80
		mul dl
		shl ax, 1
		mov [current], ax
		jmp foo		
	
printstr:
	pusha
	c:
		mov dl, [si]
		cmp dl, 0
		jz done
		int 40
		inc si
		jmp c
	done:
		popa
		iretd
	
tohex:
	pusha
	push ds
	mov dx, 64
	mov ds, dx
	mov si, hex
	int 41
	mov si, hexc
	mov di, 0
	.cont:
		mov edx,0
		mov ecx, 16
		div ecx
		mov bx, dx
		mov dl, [si+bx]
		push dx
		inc di
		cmp eax, 0
		jz .fin
		jmp .cont
	.fin:
		mov ecx, 0
		mov cx,di
	.pr:
		pop dx
		int 40
	loop .pr
	pop ds
	popa
	iretd
	
kbdhandler:
	cli
	push eax
	push ebx
	push ds
	
	mov ax, 64
	mov ds, ax
	
	mov eax, 0
	in al, 0x60
	
	test al, 128
	jnz .skpp

	
	mov ebx, scanmap
	
	xlat
	
	mov dl, al
	int 40

	.skpp:
	mov al, 0x20
	out 0x20, al	
	
	sti
	pop ds
	pop ebx
	pop ebx
	iretd
	
timerhandler:
	cli
	pusha
	push ds
	mov ax, 64
	mov ds, ax
	
	inc dword [systime]
	
	mov al, 0x20
	out 0x20, al	
	pop ds
	popa
	sti
	iretd	
getTime:
	push ds
	mov ax, 64
	mov ds, ax
	
	mov eax, [systime]
	pop ds
	iretd
sleep:
	pusha
	int 44
	add ebx, eax
	spin:
		int 44
		cmp eax, ebx
		jle spin
	popa
	iretd
retkbd:
	push ax
	mov al, 0xfc
	out 0x21, al
	mov dl, 0
	l0:
		cmp dl, 0
	jz l0
	mov al, 0xfe
	out 0x21, al
	pop ax
	iretd
[bits 16]

idt_ptr:
	dw eoIDT - startIDT
	dd IDT_loc + startIDT

startIDT:
times 256 db 0
	dw  IDT_loc + timerhandler
	dw 8
	db 0
	db 0b10001111
	dw 0
	
	dw  IDT_loc + kbdhandler
	dw 8
	db 0
	db 0b10001111
	dw 0
times 	48 db 0

mine:
	dw  IDT_loc + printchar
	dw 8
	db 0
	db 0b10001111
	dw 0
	
	dw  IDT_loc  + printstr
	dw 8
	db 0
	db 0b10001111
	dw 0
	
	dw  IDT_loc + clrscr
	dw 8
	db 0
	db 0b10001111
	dw 0

	dw  IDT_loc + tohex
	dw 8
	db 0
	db 0b10001111
	dw 0
	
	dw  IDT_loc + getTime
	dw 8
	db 0
	db 0b10001111
	dw 0
	
	dw  IDT_loc + sleep
	dw 8
	db 0
	db 0b10001111
	dw 0

	dw  IDT_loc + retkbd
	dw 8
	db 0
	db 0b10001111
	dw 0

	dw  IDT_loc + search
	dw 8
	db 0
	db 0b10001111
	dw 0


eoIDT:

[bits 32]
isr0:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int0
	int 41
	
	pop ds
	popa
	jmp $
isr1:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, intr1
	int 41
	pop ds
	popa
	jmp $
isr2:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int2
	int 41
	pop ds
	popa
	jmp $
isr3:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, intr3
	int 41
	pop ds
	popa
	jmp $
isr4:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int4
	int 41
	pop ds
	popa
	jmp $
isr5:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int5
	int 41
	pop ds
	popa
	jmp $
isr6:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int6
	int 41
	pop ds
	popa
	jmp $
isr7:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int7
	int 41
	pop ds
	popa
	jmp $
isr8:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int8
	int 41
	pop ds
	popa
	jmp $
isr9:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int9
	int 41
	pop ds
	popa
	jmp $
isr10:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int10
	int 41
	pop ds
	popa
	jmp $
isr11:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int11
	int 41
	pop ds
	popa
	jmp $
isr12:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int12
	int 41
	pop ds
	popa
	jmp $
isr13:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int13
	int 41
	mov dl, '-'
	int 40
	mov eax, [esp + 40]
	int 43
	mov dl, ':'
	int 40
	mov eax, [esp + 36]
	int 43
	pop ds
	popa
	jmp $
isr14:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int14
	int 41
	pop ds
	popa
	jmp $
isr16:
	pusha
	push ds
	mov ax, 64
	mov ds,ax
	mov si, int16
	int 41
	pop ds
	popa
	jmp $
	
idtrl db "Loading IDTR next...>",0
idtrld db "IDTR loaded.............", 0

hex db "0x",0
hexc db "0123456789ABCDEF"


int0 db "Divide by 0",0
intr1 db "Single Step",0
int2 db "NMI",0
intr3 db "Breakpoint",0
int4 db "Overflow",0
int5 db "Bounds Check",0
int6 db "Undefined OPCode",0
int7 db "Device not available",0
int8 db "Double Fault",0
int9 db "CSO, Reserved",0
int10 db "Invalid TSS",0
int11 db "Segment Not Present",0
int12 db "Stack Fault",0
int13 db "General Protection Fault",0
int14 db "Page Fault",0
int16 db "x87 FPU Error",0
fail db "File not found !",0

ptrs: dw isr0, isr1, isr2, isr3, isr4, isr5, isr6, isr7, isr8, isr9, isr10, isr11, isr12, isr13, isr14, isr16

scanmap: db 0, 0,'1','2','3','4','5','6','7',\
	'8','9','0','-','=','',0,0,'q','w','e','r','t','y','u','i','o','p','[',']',\
	10,0,'a','s','d','f','g','h','j','k','l',';', 39 ,0,0,0,'z','x','c','v','b','n','m', \
	44,'.',0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	    
current dw 0
non_zero db 0
systime dd 0
param dw 0
offset dw 0
size dw 0
charcount dw 0
