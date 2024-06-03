// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <cmath>
#include <cstdio>


void bmImLaplaceEquationSolver1(int size_x, float* imStart_ptr0, bool* m_ptr0, float* out_ptr0, int nIter);
void bmImCrossMean1(int size_x, float* in_ptr0, float* out_ptr0);
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

	// output arguments initial
	float* out_ptr0;


	// input arguments definition
	size_x = (int)mxGetScalar(prhs[0]);
	imStart_ptr0 = (float*)mxGetPr(prhs[1]);
	m_ptr0 = (bool*)mxGetPr(prhs[2]);
	nIter = (int)mxGetScalar(prhs[3]);

	// output arguments definition
	mwSize* out_size = new mwSize[2];
	out_size[0] = (mwSize)size_x;
	out_size[1] = (mwSize)1;
	mwSize out_ndims = (mwSize)2;


	plhs[0] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_ptr0 = (float*)mxGetPr(plhs[0]);



	// function call
	bmImLaplaceEquationSolver1(size_x, imStart_ptr0, m_ptr0, out_ptr0, nIter);

	// delete[]
	delete[] out_size;
}


void bmImLaplaceEquationSolver1(int size_x, float* imStart_ptr0, bool* m_ptr0, float* out_ptr0, int nIter)
{

	int N = size_x;
	int i;

	float* imStart_run = imStart_ptr0;
	bool*  m_run = m_ptr0;
	float* out_run = out_ptr0;

	float* out2_ptr0 = new float[N];
	float* out2_run = out2_ptr0;



	// we devide nIer by 2 because we do double iterations
	nIter = (int)ceil((double)nIter / 2.0);



	// initial out and out2
	for (i = 0; i < N; i++)
	{
		*out_run++  = *imStart_run;
		*out2_run++ = *imStart_run++;
	}
	out_run  = out_ptr0;
	out2_run = out2_ptr0;
	imStart_run = imStart_ptr0;



	for (i = 0; i < nIter; i++)
	{
		bmImCrossMean1(size_x, out_ptr0, out2_ptr0);

		bmClampVal(N, out2_ptr0, m_ptr0, imStart_ptr0);

		bmImCrossMean1(size_x, out2_ptr0, out_ptr0);

		bmClampVal(N, out_ptr0, m_ptr0, imStart_ptr0);

	}


	delete[] out2_ptr0;
}



void bmImCrossMean1(int size_x, float* in_ptr0, float* out_ptr0)
{

	int i;
	int iMax;

	int N_max = size_x;

	float* out_ptr_run;
	float* cent_ptr_run;
	float* xPos_ptr_run;
	float* xNeg_ptr_run;

	// main_volume ---------------------------------------------------------------------------------



	// cross for the main volume
	out_ptr_run = out_ptr0 + myModulo((1 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((1 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((1 + 1), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((1 - 1), N_max);

	iMax = size_x - 2;
	for (i = 0; i < iMax; i++)
	{
		*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++) / 3;
	}

	// END main_volume -------------------------------------------------------------------------------





	// start first corner --------------------------------------------------------------------------
	out_ptr_run = out_ptr0 + myModulo((0 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((0 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((0 + 1), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((0 - 1), N_max);


	*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++) / 3;
	// end first corner --------------------------------------------------------------------------





	// start last corner -----------------------------------------------------------------------------
	out_ptr_run = out_ptr0 + myModulo((size_x - 1 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((size_x - 1 + 1), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((size_x - 1 - 1), N_max);	

	*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++) / 3;
	// end last corner ------------------------------------------------------------------------------


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
