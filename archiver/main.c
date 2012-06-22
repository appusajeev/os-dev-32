#include<stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "archiver.h"
int main(int argc, char *argv[])
{
	
	filePos Files[10];
	int i,x,cnt;

	if (argc<2) 
	{
		x=parseMapFile(Files);
		for (i=0;i<x;i++)
			printf("Reading archive: File \'%s\' is at  offset  %lu , size: %lu B\n", Files[i].name, Files[i].offset,Files[i].size);
		
		extractFiles(Files, x);

	 return;
	
	}


	cnt = mergeFiles(++argv,argc-1,Files);

	for (i=0;i<cnt;i++)
			printf("Written File \'%s\' is at offset %lu, size: %lu B\n", Files[i].name, Files[i].offset,Files[i].size);
		
	writeMapFile(Files, cnt);
	printf("Map file created... Done\n");
	exit(0);
		
}
