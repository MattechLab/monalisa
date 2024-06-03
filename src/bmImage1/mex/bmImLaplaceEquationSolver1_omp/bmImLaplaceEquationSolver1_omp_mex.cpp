// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <omp.h>
#include <cmath>
#include <cstdio>


void bmImLaplaceEquationSolver1_omp(int size_x, float* imStart_ptr0, bool* m_ptr0, float* out_ptr0, int nIter, int nBlockPerThread); 
void bmImCrossMean1_omp(int size_x, float* in_ptr0, float* out_ptr0, int nBlockPerThread);
void bmClampVal(int N, float* x, bool* m, float* c); 
int myModulo(int a, int b); 

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{


	// input arguments initial    
	int  size_x;
	float* imStart_ptr0;
	bool* m_ptr0;
	int nIter; 
	int nBlockPerThread; 

	// output arguments initial
	float* out_ptr0;




	// input arguments definition
	size_x  = (int)mxGetScalar(prhs[0]);
	imStart_ptr0 = (float*)mxGetPr(prhs[1]);
	m_ptr0  = (bool*)mxGetPr(prhs[2]);
	nIter = (int)mxGetScalar(prhs[3]);
	nBlockPerThread = (int)mxGetScalar(prhs[4]);

	// output arguments definition
	mwSize* out_size = new mwSize[2];
	out_size[0]      = (mwSize)size_x;
	out_size[1]      = (mwSize)1;
	mwSize out_ndims = (mwSize)2;


	plhs[0] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_ptr0 = (float*)mxGetPr(plhs[0]);



	// function call
	bmImLaplaceEquationSolver1_omp(size_x, imStart_ptr0, m_ptr0, out_ptr0, nIter, nBlockPerThread); 

	// delete[]
	delete[] out_size;
}


void bmImLaplaceEquationSolver1_omp(int size_x, float* imStart_ptr0, bool* m_ptr0, float* out_ptr0, int nIter, int nBlockPerThread)
{

	int N = size_x;
	
	float* imStart_run = imStart_ptr0;
	bool*  m_run = m_ptr0; 
	float* out_run = out_ptr0;

	float* out2_ptr0 = new float[N];
	float* out2_run  = out2_ptr0; 

	int i; 
	
	// we devide nIer by 2 because we do double iterations
	nIter = (int)ceil((double)nIter / 2.0); 



	// initial out and out2
	for (i = 0; i < N; i++)
	{
		*out_run++	= *imStart_run;
		*out2_run++ = *imStart_run++;
	}
	out_run   = out_ptr0;
	out2_run  = out2_ptr0;
	imStart_run = imStart_ptr0;
	


	for (i = 0; i < nIter; i++)
	{
		bmImCrossMean1_omp(size_x, out_ptr0, out2_ptr0, nBlockPerThread);

		bmClampVal(N, out2_ptr0, m_ptr0, imStart_ptr0);
		
		bmImCrossMean1_omp(size_x, out2_ptr0, out_ptr0, nBlockPerThread);

		bmClampVal(N, out_ptr0, m_ptr0, imStart_ptr0);
 
	}


	delete[] out2_ptr0; 
}





void bmImCrossMean1_omp(int size_x_shared, float* in_ptr0_shared, float* out_ptr0_shared, int nBlockPerThread)
{

	// blockLength_small and blockLength_rest for the main surface
	int iMax_mainVolume = size_x_shared-2;
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



#pragma omp parallel shared(size_x_shared, in_ptr0_shared, out_ptr0_shared, numOfBlock, blockLength_small, blockLength_rest)
	{

		//printf("This is thread number %d  .\n", omp_get_thread_num());


		int currentBlockLength;
		int currentBlockStart;

		int i_thread;
		int iMax_thread;

		int N_max_thread = size_x_shared;

		float* out_ptr_run;
		float* cent_ptr_run;
		float* xPos_ptr_run;
		float* xNeg_ptr_run;


		// main_volume ---------------------------------------------------------------------------------


		// cross for the main volume
		float* out_ptr1 = out_ptr0_shared + myModulo((1 + 0), N_max_thread);
		float* cent_ptr1 = in_ptr0_shared + myModulo((1 + 0), N_max_thread);
		float* xPos_ptr1 = in_ptr0_shared + myModulo((1 + 1), N_max_thread);
		float* xNeg_ptr1 = in_ptr0_shared + myModulo((1 - 1), N_max_thread);



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


			
			out_ptr_run = out_ptr1 + currentBlockStart;
			cent_ptr_run = cent_ptr1 + currentBlockStart;
			xPos_ptr_run = xPos_ptr1 + currentBlockStart;
			xNeg_ptr_run = xNeg_ptr1 + currentBlockStart;


			for (i_thread = 0; i_thread < currentBlockLength; i_thread++)
			{
				*out_ptr_run++ = (*cent_ptr_run++  + *xPos_ptr_run++ + *xNeg_ptr_run++ ) / 3;
			}
		} // end para for


		// END main_volume -------------------------------------------------------------------------------



#pragma omp sections
		{


#pragma omp section
			{
				//printf("Thread number %d do section 3. \n", omp_get_thread_num());

				// start first corner --------------------------------------------------------------------------
				out_ptr_run = out_ptr0_shared + myModulo((0 + 0), N_max_thread);
				cent_ptr_run = in_ptr0_shared + myModulo((0 + 0), N_max_thread);
				xPos_ptr_run = in_ptr0_shared + myModulo((0 + 1), N_max_thread);
				xNeg_ptr_run = in_ptr0_shared + myModulo((0 - 1), N_max_thread);		

				*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++) / 3;
				// end first corner --------------------------------------------------------------------------
			}// end section




#pragma omp section
			{
				//printf("Thread number %d do section 4. \n", omp_get_thread_num());

				// start last corner -----------------------------------------------------------------------------
				out_ptr_run = out_ptr0_shared + myModulo((size_x_shared - 1 + 0), N_max_thread);
				cent_ptr_run = in_ptr0_shared + myModulo((size_x_shared - 1 + 0), N_max_thread);
				xPos_ptr_run = in_ptr0_shared + myModulo((size_x_shared - 1 + 1), N_max_thread);
				xNeg_ptr_run = in_ptr0_shared + myModulo((size_x_shared - 1 - 1), N_max_thread);

				*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++) / 3;
				// end last corner ------------------------------------------------------------------------------
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



void bmClampVal(int N, float* x, bool* m, float* c)
{
	for (int i = 0; i < N; i++)
	{
		if (*m)
		{
			*x = *c;
		}
		x++; 
		m++; 
		c++; 
	}
}
