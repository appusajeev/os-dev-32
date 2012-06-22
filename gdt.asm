; access byte   -  { 1 | privilege Level | cs/sys descr | cs/ds | x | r+w | 0 }

; granularity byte - { G| 32/16 bit |0|0| seg limit high(4) }

[bits 16]
[org 0]


mov ax, cs
mov ds, ax
mov ax, 100
mov sp, ax


cli
lgdt [gdt_ptr]
mov eax, cr0
or eax, 1
mov cr0, eax

jmp 0x8:GDT_loc + mode32

[bits 32]

mode32:
	mov ax, 24
	mov ds, ax
	mov es, ax
	
	mov ax, 56
	mov ss, ax
	mov esp, 0xfff - 1

	mov ax, 48
	ltr ax
	

	
	int 42
		
	
	
	mov si, msg
	int 41
	
	
	jmp 0x8:PIC_loc


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-GDT start-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=

[bits 16]

gdt_ptr:
	dw eoGDT - null_entry - 1
	dd GDT_loc + null_entry	

null_entry: 	;0
	dd 0
	dd 0

kernel_code:	;8
	dw 0xffff	
	dw 0x0		
	db 0		
	db 0b10011010	
	db 0b11001111 
	db 0		
kernel_data:	;16
	dw 0xffff
	dw 0
	db 0
	db 0b10010010	
	db 0b11001111
	db 0
GDT_ds:		;24
	dw 0x2		
	dw GDT_loc	
	db 0		
	db 0b10010010   
	db 0b11000000   
	db 0		

videomem:	;32
	dw 4000		
	dw 0x8000	
	db 0xb		
	db  0x92 	
	db 0x0   	
	db 0		

kernel_stack:	;40
	dw 0xffff	
	dw 0x9000	
	db 0		
	db 0b10010010   
	db 0b01000000   
	db 0		
task_seg:	;48
	dw 104
	dw GDT_loc + TSS
	db 0
	db 0x89
	db 0x40
	db 0
user_stack:		;56
	dw 0xfff		
	dw 0x8000	
	db 0		
	db 0b10010010   
	db 0b01000000   
	db 0		

IDT_ds:			;64
	dw 0xfff	
	dw IDT_loc	
	db 0		
	db 0b10010010   
	db 0b11000000   
	db 0

ftab_seg:		;72
	dw 0xfff	
	dw filetab_loc
	db 0		
	db 0b10010010   
	db 0b11000000   
	db 0
	
shell_seg:		;80
	dw 0xffff	
	dw shell_loc
	db 0		
	db 0b10011010   
	db 0b11000000   
	db 0

eoGDT:

TSS:
	dd 0
	dd 0x5ff
	dw 40
	dw 0 
	dd 0x5ff
	dw 56
	dw 0
	dd 0x5ff
	dw 56
	dw 0
	times 80 db 0

msg db "Now in Protected Mode..",10
db "A20 Enabled..",10
db "IDT Loaded..",10
db "GDT Loaded..",10
db "Interrupts and Exception Handlers installed..", 10, 0
