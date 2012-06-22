[bits 32]
[org 0xb000]




start:

	mov ax,16
	mov ds,ax
	mov es,ax
	
	
	mov si, msg
	
	int 41
	
	
	mov dx, 0x3d4
	
	mov al, 0xf
	out dx, al
	
	mov dx, 0x3d5
	mov al, 79
	out dx, al
	
	mov dx, 0x3d4
	
	mov al, 0xe
	out dx, al
	
	mov dx, 0x3d5
	mov al, 0
	out dx, al
	
	
	
	;mov ax, 0
	;out 0x3d5, ax
	
	;mov ax, 0xf
	;out 0x3d4, ax
	;mov ax, 16
	;out 0x3d5, ax
	
	jmp $

msg db 10, "Raptor217 , A 32-bit, protected mode OS",10, "Author: Appu Sajeev",10,"Contact: appusajeev@gmail.com, http://appusajeev.wordpress.com",10,"Language: NASM 2.07"
