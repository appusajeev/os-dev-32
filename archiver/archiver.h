typedef struct 
{
	char name[200];
	unsigned long offset;
	unsigned long size;
}filePos;

//---------------------------------------------------------------


short mergeFiles(char *argv[], int argc, filePos *files) //Merge all files into a single archive
{
	int i,fp_arg,fp, off =0,cnt = 0,tmp;

	char buf[100];

	fp = open("image",O_CREAT|O_RDWR);
	if (fp<0) fp = open("image",O_WRONLY);
	assert(fp>=0);

	printf("Image opened\n",fp);

	for (i=0;i<argc;i++)
	{

		fp_arg = open(argv[i],O_RDONLY);
		
		strcpy(files[i].name,argv[i]);


		files[i].offset = off;

		
		memset(buf,0,100);

		cnt =0;
		while ( (tmp= read(fp_arg,buf,100)))
		{
			write(fp,buf,tmp);
			cnt += tmp;
			memset(buf,0,100);
		}
		off += cnt;

		files[i].size = off - files[i].offset;



		close(fp_arg);
	}
	close(fp);
	return argc;
}

short extractFiles(filePos *files, int count) //extract files from the archive
{

	int i, fp,fp_main, cnt, tmp;

	char buf[100000];

	char temp[100],t[100];

	fp_main = open("image",O_RDONLY);

	for (i=0;i<count;i++)
	{
		memset(t,0,100);

		strcat(t,files[i].name);
	
		strcat(t, "_");

		printf("Extracting file: %s\n", t);
		
		fp = open(t, O_CREAT|O_WRONLY);

		assert(fp>=0);

		lseek(fp_main,files[i].offset,SEEK_SET);
		
		cnt = 0;

		while(cnt< files[i].size)
		{
			tmp = read(fp_main, buf, 1);
			write(fp, buf, tmp);
			cnt++;
		}
		printf("\tExtracted: %d B, Original size: %lu B\n", cnt, files[i].size);
		assert(cnt==files[i].size);

		close(fp);

	}
	
	close(fp_main);
}

void writeMapFile(filePos *files, int count)//create map file containing the offsets and size of each file
{
	int i, fp;
	char off[10];
	fp = open("map", O_CREAT|O_WRONLY);
	assert(fp>=0);
	write(fp, "{" , 1);
	for(i=0; i < count; i++)
	{
		write(fp, files[i].name, strlen(files[i].name));
		write(fp, ",", 1);

		memset(off,0,10);
		sprintf(off, "%lu", files[i].offset);

		write(fp, off, strlen(off));

		write(fp,",", 1);
	
		memset(off,0,10);
		sprintf(off, "%lu", files[i].size);
		write(fp, off, strlen(off) );
		write(fp,"|" ,1);

		
		
		
	}
	write(fp, "}" , 1);
	close(fp);

}

void store(filePos *file, char *str)//extract and store the offset and size value of a file from the map file into a filepos structure
{
	char t[100];
	int i=0,j=0;
	memset(t,0,100);
	memset(file->name,0,200);
	while (str[i] != 0)	
	{	
		j=0;
		while (str[i] != ',' ) file->name[j++] = str[i++];
		i++;j=0;memset(t,0,100);

		while (str[i] != ',' ) t[j++] = str[i++];
		file->offset = atoi(t);

		i++;j=0;memset(t,0,100);
		while (str[i] != 0) t[j++] = str[i++];
		file->size = atoi(t);//printf("[size: %s]\n", t);
	}	

}
short parseMapFile(filePos *files)
{

	int fp,i=0,j,k=0,x=0;

	char buf[1000], temp[100];
	fp = open("map",O_RDONLY);
	memset(buf,0,1000);
	while (read(fp,&buf[i++],1));
	
	//printf("<%s>\n", buf);	

	close(fp);

	i = 1;

	while( buf[i] !='}')
	{	
		j=0;memset(temp,0,100);
		while ( buf [i] != '|')	temp[j++] = buf[i++];			
		//printf("[%s]-", temp);	
		store(files++, temp);		
		x++;
		i++;
	
	}
	return x;

}




