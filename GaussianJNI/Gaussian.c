// includes, system
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
//#include <cuda.h>
//#include "gaussian_kernel.cu"

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
	runTest(argc, argv);
}

void
runTest(int argc, char** argv)
{
	int dim;
	int i,j,k,m,n;
	if (argc == 2)
	{
		dim = atoi(argv[1]);
	}
	else{
		printf("Wrong Usage\n");
		exit(1);
	}


	// allocate host memory for matrices A and B
	unsigned int size_A = dim * dim;
	unsigned int mem_size_A = sizeof(int) * size_A;
	int* h_A = (int*) malloc(mem_size_A);
	

    	// initialize host memory, generate a test case such as below
	//   1 1 1 1 ..
	//   1 2 2 2 ..
	//   1 2 3 3 ..
	//   1 2 3 4 ..
	//   ..........
  
	for( i = 0; i < dim; i++){
		for (j = 0 ; j < dim - i; j++){
			h_A[j + i + i * dim] = i + 1;
			h_A[j * dim + i + i * dim] = i + 1;
		}
	}

    	//display the test case
	/*
	for ( m = 0 ; m < dim; m++){
		for ( n = 0 ; n < dim; n++){
			printf("%d ", h_A[m * dim + n]);
		}
		printf("\n");
	}*/
	


	//convert to upper triangular form
	double timer1 = gettime();
	for (k=0; k<dim-1; k++) {
	for (i=k+1; i<dim; i++) {
		float s = h_A[(i*dim)+k] / h_A[(k*dim)+k]; 
		for(j=0; j<dim; j++) 
			h_A[(i*dim)+j] -= h_A[(k*dim)+j] * s; 
		//b[i]=b[i]-b[k] * s; 
	}
	}
	/*
	for ( m = 0 ; m < dim; m++){
		for ( n = 0 ; n < dim; n++){
			printf("%d ", h_A[(m * dim) + n]);
		}
		printf("\n");
	}*/
	double timer2 = gettime();
	printf("GPU time = %lf\n",(timer2-timer1)*1000);
}
