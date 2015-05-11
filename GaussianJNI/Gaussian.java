import java.util.Scanner;
import java.io.*;

public class Gaussian
{
	public native int runTest(int[] h_A, int dim);

	public static void main(String[] args)
    {
        System.out.println("In Main");
	System.load("/home/dg85l/HeterogeneousProject/GaussianJNI/libGaussian.so");
        Gaussian m = new Gaussian();
		int length = args.length;
		int dim;
                int[] h_A;

		//if (length == 1)
		//{
			//try {
				dim = Integer.parseInt(args[0]);
				System.out.printf("dim=%d\n",dim);
			/*}
			 catch (NumberFormatException nfe) {
				// The first argument isn't a valid integer.  Print
				// an error message, then exit with an error code.
				System.out.println("The first argument must be an integer.");
				System.exit(1);
			}*/

			//int[] h_A = new int[dim * dim];
			h_A = new int[dim * dim];
				// initialize host memory, generate a test case such as below
			//   1 1 1 1 ..
			//   1 2 2 2 ..
			//   1 2 3 3 ..
			//   1 2 3 4 ..
			//   ..........

			for( int i = 0; i < dim; i++){
				for (int j = 0 ; j < dim - i; j++){
					h_A[j + i + i * dim] = i + 1;
					h_A[j * dim + i + i * dim] = i + 1;
				}
			}

			/*
			for (int i = 0; i < dim; i++)
			{
 				for ( int j = 0; j < dim; j++)
				{
					System.out.printf("%3d",h_A[(i*dim)+j]);

				}
				System.out.println();

			}*/
			// call the native method, which in turn will execute kernel code on the device
			m.runTest(h_A, dim);
		//}
		//m.runTest(h_A, dim);
	}
}

