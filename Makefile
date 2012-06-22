
dev = /dev/sdb

QARG = -fda $(dev) -d int 

SRCMAIN = bootloader.asm loader1.asm 

SRCAUX =  gdt.asm idt.asm pic.asm cpuinfo.asm about.asm shell.asm

BINAUX = $(SRCAUX:.asm=.bin)

BINMAIN = $(SRCMAIN:.asm=.bin)

IMAGES = $(BINMAIN) $(BINAUX) installer map image


MACROS = -Ddrive=0x80		\
	 -Dloader1_seg=0x1000	\
	 -Dfiletab_loc=0x2000	\
	 -Drd_loc=0x3000	\
	 -DIDT_loc=0x5000	\
	 -DGDT_loc=0x6000	\
	 -DPIC_loc=0x7000	\
	 -Dshell_loc=0xb000	\
	 -Dvidmem=32 		\
	 -DSYSCLOCK_FREQ=1000	\

all:clean installer  image $(BINMAIN)
	./installer $(dev) bootloader.bin map loader1.bin image
	/usr/bin/bochs

image: $(BINAUX)
	archiver $(BINAUX)

installer: installer.c
	cc $< -o $@ -lm

.SUFFIXES: .asm .bin

.asm.bin:
	nasm -fbin $< -o $@ -l lst/$<.lst $(MACROS)

zip:
	zip -r os *

clean:
	rm -f $(IMAGES)
	rm -f lst/*
	rm -f bochsout.txt
	rm -f os.zip
	rm -f *~
