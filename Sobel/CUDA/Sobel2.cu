#include <stdlib.h>
#include <stdio.h>
#include<math.h>
#include<string.h>
#include<cuda.h>
#include <sys/time.h>


#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr

#define DEF_IN "mri" //name of default input image file
#define DEF_OUT "part1_edge" //name of default filtered output image

C
C
#define DEF_BINARY "part1_binary_edge"
#define def_xsize 256    //default X axis size
#define def_ysize 256    //default Y axis size
#define BLOCK_SIZE 16	//block size for parallel gpu


double gettime() {
        struct timeval t;
        gettimeofday(&t,NULL);
        return t.tv_sec+t.tv_usec*1e-6;
}


__global__ void mykernel(float *temp2,float *out3,int xsize,int ysize,float *outH, float *outV)
{
	int bx, tx, by, ty;

        // Block index
        bx=blockIdx.x;
        by=blockIdx.y;


        // Thread index
        tx=threadIdx.x;
        ty=threadIdx.y;

        //int index = wA * BLOCK_SIZE * by + BLOCK_SIZE * bx + wA * ty + tx;

        int index_col = BLOCK_SIZE * bx + tx;
        int index_row = BLOCK_SIZE * by + ty;
	
	int k,l;
	float sobelH[9]={-1,-2,-1,0,0,0,1,2,1};
        float sobelV[9]={-1,0,1,-2,0,2,-1,0,1};


	for(k=-1;k<=1;k++)
	for(l=-1;l<=1;l++)
	{	
		outH[(index_row*xsize)+index_col]+=(temp2[((index_row+1+k)*(xsize+2))+(index_col+1+l)]*sobelH[(k+1)*3+(l+1)]);
		outV[(index_row*xsize)+index_col]+=(temp2[((index_row+1+k)*(xsize+2))+(index_col+1+l)]*sobelV[(k+1)*3+(l+1)]);
	}

	out3[(index_row*xsize)+index_col]=abs(outH[(index_row*xsize)+index_col])+abs(outV[(index_row*xsize)+index_col]);
	
	//__syncthreads();
}


void norm_output(float *output[],int xsize,int ysize, FILE *fp_out)
{
    int i,j;
    float max,min;
    unsigned char pixel;
   
    min=output[0][0];
    max=output[0][0];

    for(i=0;i<ysize;i++)
    for(j=0;j<xsize;j++)
    {
        if(output[i][j]<min)
            min=output[i][j];
        if(output[i][j]>max)
            max=output[i][j];
    }
   
    //printf("min is %f and max is %f\n",min,max);
    for(i=0;i<ysize;i++)
    for(j=0;j<xsize;j++)
    {
        output[i][j]=((output[i][j]-min)/(max-min))*255;
        pixel=(unsigned char)output[i][j];
	fwrite(&pixel,sizeof(char),1,fp_out);
    }
}
 
void sobel_Filter(float *sobel[], int xsize, int ysize)
{
	int i,j;
	
	float *temp;
	float *out1;

	float *d_temp1;
	float *d_out1;

	
	float *outH,*outV;
	cudaError_t err;	
	
	if((err=cudaMalloc((void**)&outH,(ysize*xsize)*sizeof(float)))!=cudaSuccess)
		printf("Malloc outH %d\n",err);
	cudaMemset(outH,0,(ysize*xsize)*sizeof(float));
	
	if((err=cudaMalloc((void**)&outV,(ysize*xsize)*sizeof(float)))!=cudaSuccess)
		printf("Malloc outV %d\n",err);
	cudaMemset(outV,0,(ysize*xsize)*sizeof(float));
	

    	temp=(float *)calloc((ysize+2)*(xsize+2),sizeof(float));


	out1=(float *)calloc((ysize*xsize),sizeof(float));
   
	cudaMalloc((void**)&d_out1,(xsize)*sizeof(float)*ysize);
	
	if((err=cudaMalloc((void**)&d_temp1,(xsize+2)*sizeof(float)*(ysize+2)))!=cudaSuccess)
		printf("Malloc out1 %d\n",err);

	for(i=0;i<(ysize);i++)
	for(j=0;j<(xsize);j++)
		temp[((i+1)*(xsize+2))+j+1]=sobel[i][j];
	
	/*	
	for(i=0;i<(ysize);i++)
        {
		for(j=0;j<(xsize);j++)
		{
			printf("%f  ",temp[((i+1)*(xsize+2))+j+1]);
		}
		printf("\n\n");
	}*/

	if((err=cudaMemcpy(d_temp1,temp,(xsize+2)*(ysize+2)*sizeof(float),cudaMemcpyHostToDevice))!=cudaSuccess)
		printf("Copy Host to Device %d\n",err);

	double timer1 = gettime();
	dim3 threads(BLOCK_SIZE, BLOCK_SIZE);
     	dim3 grid((xsize) / threads.x, (xsize) / threads.y);


	mykernel<<<grid,threads>>>(d_temp1,d_out1,xsize,ysize,outH,outV);
	
	if((err=cudaMemcpy(out1,d_out1,xsize*sizeof(float)*ysize,cudaMemcpyDeviceToHost))!=cudaSuccess)
		printf("Copy Device to Host %d\n",err);
       
	double timer2 = gettime();
        printf("\n\nGPU time = %lf\n",(timer2-timer1)*1000);
	
	for(i=0;i<(ysize);i++)
        {
		for(j=0;j<(xsize);j++)
		{
                	sobel[i][j]=out1[(i*xsize)+j];
			//sobel[i][j]=temp[((i+1)*(xsize+2))+j+1];
			//printf("%f   ",sobel[i][j]);
		}
	//	printf("\n");
	}

	free(out1);
	cudaFree(d_out1);
	cudaFree(outH);
	cudaFree(outV);
	cudaFree(d_temp1);
}				
			
int main(int argc,char *argv[])
{
    int xsize=def_xsize,ysize=def_ysize,i,j;
    unsigned char pixel;
    unsigned char **data;
    float **sobel;
    char fn_inp[20]=DEF_IN;
    char fn_out[20]=DEF_OUT;
    FILE *fp_inp;
    FILE *fp_out;

    if(argc==4)    //check if arguments are there
    {
        strcpy(fn_inp,argv[1]);    //Take input file name from arg1
        xsize=atoi(argv[2]);    //Take X-Size from arg2
        ysize=atoi(argv[3]);    //Take Y-Size from arg3
    }
    else
    {/*
	printf("\nNo Command line arguments entered.\n");
	printf("Taking Default Parameters as\n");
	printf("Default input image file : 'mri' of size 256*256\n"); */
    }
    //printf("Output file for sobel output of image: %s\n",fn_out);
   
    //Allocate 2d array memory to process image
    data=(unsigned char **)malloc(sizeof(unsigned char*)*ysize);
    for(i=0;i<ysize;i++)
        data[i]=(unsigned char *)malloc(sizeof(unsigned char)*xsize);

    //open input image
    if((fp_inp=fopen(fn_inp,"r"))==NULL) exit(0);
    for(i=0;i<ysize;i++)
    for(j=0;j<xsize;j++)
    {
        //read pixel by pixel and store it in array data
        fread(&pixel,sizeof(char),1,fp_inp);
        data[i][j]=pixel;
    }
    fclose(fp_inp);   
    sobel=(float **)malloc(sizeof(float *)*ysize);
        for(i=0;i<ysize;i++)
                sobel[i]=(float *)malloc(sizeof(float)*xsize);
 

    for(i=0;i<ysize;i++)
    for(j=0;j<xsize;j++)
    {   
        pixel=data[i][j];
        sobel[i][j]=(float)pixel;
    }
    sobel_Filter(sobel,xsize,ysize);
 
    if((fp_out=fopen(fn_out,"w"))==NULL) exit(0);
    norm_output(sobel,xsize,ysize,fp_out);
    fclose(fp_out);

    return(0);    
}

