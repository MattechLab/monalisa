// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <omp.h>
#include <cmath>
#include <cstdio>

void bmImCrossMean2_omp(int size_x, int size_y, float* in_ptr0, float* out_ptr0, int nBlockPerThread);
int myModulo(int a, int b);

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

	// input arguments initial    
	int  size_x;
	int  size_y;
	float* in_ptr0;
	int nBlockPerThread; 

	// output arguments initial
	float* out_ptr0;


	// input arguments definition
	size_x			= (int)mxGetScalar(prhs[0]);
	size_y			= (int)mxGetScalar(prhs[1]);
	in_ptr0			= (float*)mxGetPr(prhs[2]);
	nBlockPerThread = (int)mxGetScalar(prhs[3]);

	// output arguments definition
	mwSize* out_size = new mwSize[2];
	out_size[0] = (mwSize)size_x;
	out_size[1] = (mwSize)size_y;
	mwSize out_ndims = (mwSize)2;


	plhs[0] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_ptr0 = (float*)mxGetPr(plhs[0]);



	// function call
	bmImCrossMean2_omp(size_x, size_y, in_ptr0, out_ptr0, nBlockPerThread);

	// delete[]
	delete[] out_size;
}


void bmImCrossMean2_omp(int size_x_shared, int size_y_shared, float* in_ptr0_shared, float* out_ptr0_shared, int nBlockPerThread)
{

	// blockLength_small and blockLength_rest for the main surface
	int iMax_mainVolume = size_x_shared*(size_y_shared - 2);
	const int myThreadProcRatio = 1;
	const int myBlockThreadRatio = nBlockPerThread;
	int numOfThread = omp_get_num_procs()*myThreadProcRatio;
	int numOfBlock = numOfThread * myBlockThreadRatio;
	int blockLength_small = (int)(iMax_mainVolume / numOfBlock);
	int blockLength_rest = (int)(iMax_mainVolume - numOfBlock*blockLength_small);
	omp_set_num_threads(numOfThread);

	//printf("numOfThread : %d. \n", numOfThread); 
	//printf("numOfBlock  : %d. \n", numOfBlock);
	//printf("blockLength_small : %d. \n", blockLength_small);
	//printf("blockLength_rest  : %d. \n", blockLength_rest);



#pragma omp parallel shared(size_x_shared, size_y_shared, in_ptr0_shared, out_ptr0_shared, numOfBlock, blockLength_small, blockLength_rest)
	{

		//printf("This is thread number %d  .\n", omp_get_thread_num());

		int currentBlockLength;
		int currentBlockStart;

		int i_thread;
		int iMax_thread;
		int N_max_thread = size_x_shared*size_y_shared;

		float* out_ptr_run;
		float* cent_ptr_run;
		float* xPos_ptr_run;
		float* xNeg_ptr_run;
		float* yPos_ptr_run;
		float* yNeg_ptr_run;

		// cross for the main volume
		float* out_ptr1 = out_ptr0_shared + myModulo((0 + 0) + size_x_shared*(1 + 0) , N_max_thread);
		float* cent_ptr1 = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(1 + 0) , N_max_thread);
		float* xPos_ptr1 = in_ptr0_shared + myModulo((0 + 1) + size_x_shared*(1 + 0) , N_max_thread);
		float* xNeg_ptr1 = in_ptr0_shared + myModulo((0 - 1) + size_x_shared*(1 + 0) , N_max_thread);
		float* yPos_ptr1 = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(1 + 1) , N_max_thread);
		float* yNeg_ptr1 = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(1 - 1) , N_max_thread);


#pragma omp for nowait
		for (int currentBlockInd = 0; currentBlockInd < numOfBlock; currentBlockInd++)
		{
			if (currentBlockInd < blockLength_rest)
			{
				currentBlockLength = blockLength_small + 1;
				currentBlockStart = currentBlockInd*currentBlockLength;
			}
			else
			{
				currentBlockLength = blockLength_small;
				currentBlockStart = (blockLength_small + 1)*blockLength_rest + (currentBlockInd - blockLength_rest)*blockLength_small;
			}


			// main_volume ---------------------------------------------------------------------------------

			out_ptr_run = out_ptr1 + currentBlockStart;
			cent_ptr_run = cent_ptr1 + currentBlockStart;
			xPos_ptr_run = xPos_ptr1 + currentBlockStart;
			xNeg_ptr_run = xNeg_ptr1 + currentBlockStart;
			yPos_ptr_run = yPos_ptr1 + currentBlockStart;
			yNeg_ptr_run = yNeg_ptr1 + currentBlockStart;

			for (i_thread = 0; i_thread < currentBlockLength; i_thread++)
			{
				*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++) / 5;
			}
			// main_volume ---------------------------------------------------------------------------------
		} // end para for




#pragma omp sections
		{

#pragma omp section
			{
				//printf("Thread number %d do section 1. \n", omp_get_thread_num()); 

				// start edge ---------------------------------------------------------------------------------
				out_ptr_run = out_ptr0_shared + myModulo((1 + 0) + size_x_shared*(0 + 0) , N_max_thread);
				cent_ptr_run = in_ptr0_shared + myModulo((1 + 0) + size_x_shared*(0 + 0) , N_max_thread);
				xPos_ptr_run = in_ptr0_shared + myModulo((1 + 1) + size_x_shared*(0 + 0) , N_max_thread);
				xNeg_ptr_run = in_ptr0_shared + myModulo((1 - 1) + size_x_shared*(0 + 0) , N_max_thread);
				yPos_ptr_run = in_ptr0_shared + myModulo((1 + 0) + size_x_shared*(0 + 1) , N_max_thread);
				yNeg_ptr_run = in_ptr0_shared + myModulo((1 + 0) + size_x_shared*(0 - 1) , N_max_thread);


				iMax_thread = size_x_shared - 1;
				for (i_thread = 0; i_thread < iMax_thread; i_thread++)
				{
					*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++) / 5;
				}
				// start edge ---------------------------------------------------------------------------------
			}// end section


#pragma omp section
			{
				//printf("Thread number %d do section 2. \n", omp_get_thread_num());

				// end edge ----------------------------------------------------------------------------------
				out_ptr_run = out_ptr0_shared + myModulo((0 + 0) + size_x_shared*(size_y_shared - 1 + 0) , N_max_thread);
				cent_ptr_run = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(size_y_shared - 1 + 0) , N_max_thread);
				xPos_ptr_run = in_ptr0_shared + myModulo((0 + 1) + size_x_shared*(size_y_shared - 1 + 0) , N_max_thread);
				xNeg_ptr_run = in_ptr0_shared + myModulo((0 - 1) + size_x_shared*(size_y_shared - 1 + 0) , N_max_thread);
				yPos_ptr_run = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(size_y_shared - 1 + 1) , N_max_thread);
				yNeg_ptr_run = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(size_y_shared - 1 - 1) , N_max_thread);


				iMax_thread = size_x_shared - 1;
				for (i_thread = 0; i_thread < iMax_thread; i_thread++)
				{
					*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++) / 5;
				}
				// end edge ----------------------------------------------------------------------------------
			}// end section





#pragma omp section
			{
				//printf("Thread number %d do section 3. \n", omp_get_thread_num());

				// start corner --------------------------------------------------------------------------
				out_ptr_run = out_ptr0_shared + myModulo((0 + 0) + size_x_shared*(0 + 0) , N_max_thread);
				cent_ptr_run = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(0 + 0) , N_max_thread);
				xPos_ptr_run = in_ptr0_shared + myModulo((0 + 1) + size_x_shared*(0 + 0) , N_max_thread);
				xNeg_ptr_run = in_ptr0_shared + myModulo((0 - 1) + size_x_shared*(0 + 0) , N_max_thread);
				yPos_ptr_run = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(0 + 1) , N_max_thread);
				yNeg_ptr_run = in_ptr0_shared + myModulo((0 + 0) + size_x_shared*(0 - 1) , N_max_thread);

				*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++) / 5;
				// start corner --------------------------------------------------------------------------
			}// end section




#pragma omp section
			{
				//printf("Thread number %d do section 4. \n", omp_get_thread_num());

				// end corner -----------------------------------------------------------------------------
				out_ptr_run = out_ptr0_shared + myModulo((size_x_shared - 1 + 0) + size_x_shared*(size_y_shared - 1 + 0) , N_max_thread);
				cent_ptr_run = in_ptr0_shared + myModulo((size_x_shared - 1 + 0) + size_x_shared*(size_y_shared - 1 + 0) , N_max_thread);
				xPos_ptr_run = in_ptr0_shared + myModulo((size_x_shared - 1 + 1) + size_x_shared*(size_y_shared - 1 + 0) , N_max_thread);
				xNeg_ptr_run = in_ptr0_shared + myModulo((size_x_shared - 1 - 1) + size_x_shared*(size_y_shared - 1 + 0) , N_max_thread);
				yPos_ptr_run = in_ptr0_shared + myModulo((size_x_shared - 1 + 0) + size_x_shared*(size_y_shared - 1 + 1) , N_max_thread);
				yNeg_ptr_run = in_ptr0_shared + myModulo((size_x_shared - 1 + 0) + size_x_shared*(size_y_shared - 1 - 1) , N_max_thread);

				*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++) / 5;
				// end corner ------------------------------------------------------------------------------
			}// end section



		}// end sections
	} // end OMP
} // end function



int myModulo(int a, int b)
{
	int c = a % b;
	if (c < 0)
	{
		c = (c + b) % b;
	}
	return c;
}


