//include "gaussian.h"
#define BLOCK_SIZE 16

__global__ void
Gaussian_CUDA(int* A, int wA, int row, int* temp)
{
	int bx, tx, by, ty;

	// Block index
	//MODIFY HERE to get your block indexes
	bx=blockIdx.x;
	by=blockIdx.y;
	

	// Thread index
	//MODIFY HERE to get your thread indexes
	tx=threadIdx.x;
	ty=threadIdx.y;

	int index = wA * BLOCK_SIZE * by + BLOCK_SIZE * bx + wA * ty + tx;
    
	int index_col = BLOCK_SIZE * bx + tx;
	int index_row = BLOCK_SIZE * by + ty;

//	int i;
	__shared__ int s;

/*	
	if(index_row==row&&index_col==row)
	{
		for(i=row+1;i<wA;i++)
			temp[i]=A[(i*wA)+row]/A[(row*wA)+row];
	}
	__syncthreads();


	if(index_row>row)
		A[(index_row*wA)+index_col]-=(temp[(index_row)]*A[(row*wA)+index_col]);
	__syncthreads();	
	
*/
	if(index_row==row)
		temp[index_col]=A[(index_row*wA)+index_col];
	__syncthreads();

	if(index_row>row)
	{
		s=A[(index_row*wA)+row]/temp[row];
		__syncthreads();
		A[index]-=A[(row*wA)+index_col]*s;
	}
	__syncthreads();
	
}

