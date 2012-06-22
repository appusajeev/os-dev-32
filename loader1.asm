[bits 16]
[org 0]


start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ax,0x7000	
	mov ss,ax	; stack segment initialisation
	mov sp,ss

	mov ax,(filetab_loc)/16	;address where the file table is loaded
	mov gs,ax
	mov bx,0

	
	mov byte [charcount], 7
	push gdtfile
	call search
	push word (GDT_loc/16)
	call load
	
	push gdtfile
	call print
	push loaded
	call print
	add sp, 4

	mov byte [charcount], 7
	push idtfile
	call search
	push word (IDT_loc/16)
	call load

	push idtfile
	call print
	push loaded
	call print
	add sp, 4
	
	mov byte [charcount], 7
	push picfile
	call search
	push word (PIC_loc/16)
	call load
	add sp, 4
	
	jmp (IDT_loc/16):0000

	



;================================FUNCTIONS======================================


search:		; search the filetable for the file
	pusha
	mov bp,sp 

	;cmp ax,ax ; to set zero flag
	
	mov di,[bp+18]

	mov bx,0
	cld


	cont_chk:
		mov al,[gs:bx]
		cmp al,'}'
		
		je complete	
		cmp al,[di]
		je chk
		inc bx
		jmp cont_chk

	chk:
		push bx
		mov cx, [charcount] 
	check:
		mov al,[gs:bx]
		inc bx
		
		scasb
		loope check
		
		je succ

		mov di,[bp+18]
		pop bx
		inc bx
		jmp cont_chk
	
	complete:
		push fail
		call print
		mov word [bp+18] , 0
		jmp en
	succ:
		
		inc bx
		sub sp, 4
		
		push  bx
		call findparams
		pop word [offset]

		call findparams
		pop word [size]

	en:
		mov sp,bp
		popa
		ret


load:
	pusha
	mov bp, sp

	mov cx, [size]
	cld
	push es
	push ds
	push word [offset]
	mov ax, [bp + 18]
	mov es, ax
	mov di,0
	mov ax, (rd_loc)/16
	mov ds, ax
	pop si
	rep movsb
	pop ds
	pop es

	mov sp, bp
	popa
	ret

findparams:	; find the sector containing the given file	
	pusha
	mov bp,sp
	mov bx,[bp+18]
	cld
	mov word [param],0
	mov cx,10
	
	cont_st:
		
		mov al,[gs:bx]
		inc bx

		cmp al,','
		jz finish
		cmp al,'|'
		jz finish
		cmp al,48
		jl mismatch
		cmp al,58
		jg mismatch

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

			mov [bp+20], bx

			mov ax, [param]
			mov [bp+18], ax

		mismatch_end:
			mov sp,bp
			popa
			ret
		mismatch:
			push fail
			call print
			jmp mismatch_end
		
print:	;print a zero terminated string
	pusha
	mov bp,sp
	mov si,[bp+18] 
	cont:
		lodsb
		or al,al
		jz dne
		mov ah,0x0e
		mov bx,0
		mov bl,7
		int 10h
		jmp cont
	dne:
		mov sp,bp
		popa
		ret



idtfile db "idt.bin", 0
gdtfile db "gdt.bin", 0
picfile db "pic.bin", 0

loaded db " File Loaded..",10,13,0
fail db "File not found !",0
nl db 10,13,0
charcount dw 0

param dw 0
offset dw 0
size dw 0




