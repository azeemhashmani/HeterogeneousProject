// includes, system
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <cuda.h>
#include "gaussian_kernel.cu"
#include <jni.h>
#include "Gaussian.h"
#define OUTPUT

void runTest(int argc, char** argv);

double gettime() {
	struct timeval t;
	gettimeofday(&t,NULL);
	return t.tv_sec+t.tv_usec*1e-6;
}

int
main(int argc, char** argv)
{
	//runTest(argc, argv);
}

//void runTest(int h_A, char** argv)
JNIEXPORT jint JNICALL Java_Gaussian_runTest
  (JNIEnv *env, jobject j_obj, jintArray j_A, jint dim)
{
	cudaError_t err;
    
    //display the test case
	/*
	for ( int m = 0 ; m < dim; m++){
		for ( int n = 0 ; n < dim; n++){
			printf("%d ", h_A[m * dim + n]);
		}
		printf("\n");
	}
	*/
	
	unsigned int size_A = dim * dim;
	unsigned int mem_size_A = sizeof(int) * size_A;
	printf("Inside CUDA code\n");
	jint *h_A = env->GetIntArrayElements(j_A, 0);

    // allocate device memory for the matrix A
	int* d_A;
	cudaMalloc((void**)&d_A,mem_size_A);
	
	//MODIFY HERE 
    
	int* temp; //temporary array to store dim number of integer elements
	//MODIFY HERE to allocate memory for temp array 
	//temp=(int*)malloc(dim*sizeof(int));
	cudaMalloc((void**)&temp,dim*sizeof(int));
	
	// copy host memory to device
	double timer1 = gettime();
	//MODIFY HERE Copy the Matrix A to GPU memory
	if((err=cudaMemcpy((void*)d_A,(void*)h_A,mem_size_A,cudaMemcpyHostToDevice))!=cudaSuccess)
		printf("Error: Host to Device copy%d\n",err);

	// setup execution parameters
	dim3 threads(BLOCK_SIZE, BLOCK_SIZE);
	dim3 grid(dim / threads.x, dim / threads.y);

	// execute the kernel
	for ( int i = 0 ; i < dim ; i++){
		Gaussian_CUDA<<< grid, threads >>>(d_A, dim, i, temp);
	}

	// copy result from device to host
	//MODIFY HERE
	if((err=cudaMemcpy((void*)h_A,(void*)d_A,mem_size_A, cudaMemcpyDeviceToHost))!=cudaSuccess)
		printf("Error:Device to Device copy%d\n",err);

	

	double timer2 = gettime();
	printf("GPU time = %lf\n",(timer2-timer1)*1000);

#ifdef OUTPUT

	//the result should be I(dim*dim)
	for ( int m = 0 ; m < dim; m++){
		for ( int n = 0 ; n < dim; n++){
			printf("%d ", h_A[m * dim + n]);
		}
		printf("\n");
	}
#endif

	env->ReleaseIntArrayElements(j_A, h_A, 0);
	//free(h_A);
	cudaFree(d_A);
	cudaFree(temp);
	return 0;
}
