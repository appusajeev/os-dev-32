#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>

//argv[1] = device file
//argv [2] = bootloader
//argv[3] = mapfile
//argv[4] = os
int main(int argc,char *argv[])
{
	int i,size,k=2,ftab,sect=3;

	char buf[512];
	char vbuf;
	int dev,fp,off=0;

	fp=open(argv[2],O_RDONLY); //bootloader
	assert(fp>0);
	read(fp,buf,512);
	close(fp);

	printf("Bootsector file: %s\n",argv[2]);
	

	dev=open(argv[1],O_RDWR); // device file
	assert(dev>0);
	write(dev,buf,512); // write bootloader

	//write other files given as arguments, in order
	off =0;
	k = 1;
	for(i=3;i<argc;i++)
	{	
		off=off + (k * 512);
		lseek(dev,off,SEEK_SET);

		fp=open(argv[i],O_RDONLY);
		assert(fp>0);
		size=0;		
		while((read(fp,&vbuf,1))!=0) 
		{
			size++;
			write(dev,&vbuf,1);
		
		}
		k = (size>512)? ((size/512)+1) :1;
		close(fp);

		printf("Input file \'%s\' written at offset %d\n",argv[i],off);
	}
	close (dev);
}
