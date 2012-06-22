[bits 32]
[org PIC_loc]


picinit:

	mov ax, 16
	mov ds, ax
	mov es, ax


	mov al, 0x11	;ICW 1 - Init
	out 0x20, al
	out 0xa0, al
	
	mov al, 0x20	;ICW 2 - Remap Interrupt;   research here
	out 0x21, al
	mov al, 0x20
	out 0xa1, al
	
	mov al, 0x4	;ICW 3 - Master-Slave connection
	out 0x21, al
	mov al, 0x2
	out 0xa1, al
	
	mov al, 1	; ICW 4
	out 0x21, al
	out 0xa1, al
	
	mov al, 0xfe;	mask all others except timer
	out 0x21, al

	sti
	
	mov dx, SYSCLOCK_FREQ
	mov al, 0b00110100
	out 0x43, al
	
	mov ax, dx
	out 0x40, al
	xchg ah, al
	out 0x40, al	
	
	mov si, pic
	int 41	

	;mov eax, 2361
	;int 43
	
	
	mov si, gdtfile
	mov dh, 9
	int 47


	
	
	jmp 80:0
	;jmp 0shell_loc
	
	
pic db "Programmable Interrupt Controller remapped..Keyboard enabled..", 10, "System Timer initialized with 1ms resolution..",10,0	
gdtfile db "shell.bin", 0
