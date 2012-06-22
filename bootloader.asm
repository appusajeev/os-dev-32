%define loader1_sect 3
%define ftab_sect 2
%define rdisk_sect 4
[bits 16]
[org 0]

jmp 0x7c0:start

start:

	mov ax,cs
	mov ds,ax
	mov es,ax
	
	add ax, 200
	mov ss, ax
	mov sp, ax

	mov al,14h
	mov ah,0
	int 10h	

	mov ax,loader1_seg
	mov es,ax
	mov cl,loader1_sect ; sector
	mov al,1 ; number of sectors

	call loadsector

	mov ax,(filetab_loc)/16
	mov es,ax
	mov cl,ftab_sect ; sector
	mov al,1 ; number of sectors

	call loadsector


	mov ax,(rd_loc)/16
	mov es,ax
	mov cl,rdisk_sect ; sector
	mov al,10; number of sectors

	call loadsector
	
	

	call checkIBF
	mov al, 0xd0	;read output port through 0x60
	out 0x64, al
	
	call checkOBE
	in al, 0x60	;output port value
	push ax
	
	call checkIBF
	mov al, 0xd1	;write output port through 0x60
	out 0x64, al
	
	call checkIBF
	pop ax
	or ax, 2
	out 0x60, al
	
	;check if attempt was succesful
	
	call checkIBF
	mov al, 0xd0
	out 0x64, al
	
	call checkOBE
	in al, 0x60
	test al, 2
	jz a20err
	
	jmp loader1_seg:0000 ; jump to our os

	
checkOBE:
	in al, 0x64
	test al, 1
	jz checkOBE
	ret
checkIBF:
	in al, 0x64
	test al, 2
	jnz checkIBF
	ret
a20err:
	mov si,msg2	
	call print
	jmp $

loadsector:
	mov bx,0
	mov dl,drive ; drive
	mov dh,0 ; head
	mov ch,0 ; track
	mov ah,2
	int 0x13
	jc err
	ret
err:
	mov si,erro
	call print
	ret
print:
	mov bp,sp
	cont:
		lodsb
		or al,al
		jz dne
		mov ah,0x0e
		mov bx,0
		int 10h
		jmp cont
dne:
	mov sp,bp
	ret

msg db "Booting Successful..",10,13,"Press any key to continue !",10,13,10,13,0
msg2 db "Unable to enable A20. Aborting..", 10, 13,0
erro db "Error loading sector ",10,13,0
times 510 - ($-$$) db 0
dw 0xaa55
