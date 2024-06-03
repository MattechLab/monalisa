// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <cmath>
#include <cstdio>


void bmImLaplaceEquationSolver3(int size_x, int size_y, int size_z, float* imStart_ptr0, bool* m_ptr0, float* out_ptr0, int nIter);
void bmImCrossMean3(int size_x, int size_y, int size_z, float* in_ptr0, float* out_ptr0);
void bmClampVal(int N, float* x, bool* m, float* c);
int myModulo(int a, int b);

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{


	// input arguments initial    
	int  size_x;
	int  size_y;
	int  size_z;
	float* imStart_ptr0;
	bool* m_ptr0;
	int nIter;

	// output arguments initial
	float* out_ptr0;




	// input arguments definition
	size_x = (int)mxGetScalar(prhs[0]);
	size_y = (int)mxGetScalar(prhs[1]);
	size_z = (int)mxGetScalar(prhs[2]);
	imStart_ptr0 = (float*)mxGetPr(prhs[3]);
	m_ptr0 = (bool*)mxGetPr(prhs[4]);
	nIter = (int)mxGetScalar(prhs[5]);

	// output arguments definition
	mwSize* out_size = new mwSize[3];
	out_size[0] = (mwSize)size_x;
	out_size[1] = (mwSize)size_y;
	out_size[2] = (mwSize)size_z;
	mwSize out_ndims = (mwSize)3;


	plhs[0] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_ptr0 = (float*)mxGetPr(plhs[0]);



	// function call
	bmImLaplaceEquationSolver3(size_x, size_y, size_z, imStart_ptr0, m_ptr0, out_ptr0, nIter);

	// delete[]
	delete[] out_size;
}


void bmImLaplaceEquationSolver3(int size_x, int size_y, int size_z, float* imStart_ptr0, bool* m_ptr0, float* out_ptr0, int nIter)
{

	int N = size_x*size_y*size_z;
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
		*out_run++ = *imStart_run;
		*out2_run++ = *imStart_run++;
	}
	out_run = out_ptr0;
	out2_run = out2_ptr0;
	imStart_run = imStart_ptr0;



	for (i = 0; i < nIter; i++)
	{
		bmImCrossMean3(size_x, size_y, size_z, out_ptr0, out2_ptr0);

		bmClampVal(N, out2_ptr0, m_ptr0, imStart_ptr0);

		bmImCrossMean3(size_x, size_y, size_z, out2_ptr0, out_ptr0);

		bmClampVal(N, out_ptr0, m_ptr0, imStart_ptr0);

	}


	delete[] out2_ptr0;
}





void bmImCrossMean3(int size_x, int size_y, int size_z, float* in_ptr0, float* out_ptr0)
{


	int i;
	int iMax;
	int N_max = size_x*size_y*size_z;

	float* out_ptr_run;
	float* cent_ptr_run;
	float* xPos_ptr_run;
	float* xNeg_ptr_run;
	float* yPos_ptr_run;
	float* yNeg_ptr_run;
	float* zPos_ptr_run;
	float* zNeg_ptr_run;



	// main_volume ---------------------------------------------------------------------------------

	out_ptr_run = out_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(1 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(1 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((0 + 1) + size_x*(0 + 0) + size_x*size_y*(1 + 0), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((0 - 1) + size_x*(0 + 0) + size_x*size_y*(1 + 0), N_max);
	yPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 1) + size_x*size_y*(1 + 0), N_max);
	yNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 - 1) + size_x*size_y*(1 + 0), N_max);
	zPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(1 + 1), N_max);
	zNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(1 - 1), N_max);



	iMax = size_x*size_y*(size_z - 2);
	for (i = 0; i < iMax; i++)
	{
		*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ + *zPos_ptr_run++ + *zNeg_ptr_run++) / 7;
	}
	// main_volume ---------------------------------------------------------------------------------





	// start face ---------------------------------------------------------------------------------
	out_ptr_run = out_ptr0 + myModulo((0 + 0) + size_x*(1 + 0) + size_x*size_y*(0 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(1 + 0) + size_x*size_y*(0 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((0 + 1) + size_x*(1 + 0) + size_x*size_y*(0 + 0), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((0 - 1) + size_x*(1 + 0) + size_x*size_y*(0 + 0), N_max);
	yPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(1 + 1) + size_x*size_y*(0 + 0), N_max);
	yNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(1 - 1) + size_x*size_y*(0 + 0), N_max);
	zPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(1 + 0) + size_x*size_y*(0 + 1), N_max);
	zNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(1 + 0) + size_x*size_y*(0 - 1), N_max);

	iMax = size_x*(size_y - 1);
	for (i = 0; i < iMax; i++)
	{
		*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ + *zPos_ptr_run++ + *zNeg_ptr_run++) / 7;
	}
	// start face ---------------------------------------------------------------------------------



	// end face ----------------------------------------------------------------------------------
	out_ptr_run = out_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((0 + 1) + size_x*(0 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((0 - 1) + size_x*(0 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	yPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 1) + size_x*size_y*(size_z - 1 + 0), N_max);
	yNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 - 1) + size_x*size_y*(size_z - 1 + 0), N_max);
	zPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(size_z - 1 + 1), N_max);
	zNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(size_z - 1 - 1), N_max);


	iMax = size_x*(size_y - 1);
	for (i = 0; i < iMax; i++)
	{
		*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ + *zPos_ptr_run++ + *zNeg_ptr_run++) / 7;
	}
	// end face ----------------------------------------------------------------------------------


	// start edge ---------------------------------------------------------------------------------
	out_ptr_run = out_ptr0 + myModulo((1 + 0) + size_x*(0 + 0) + size_x*size_y*(0 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((1 + 0) + size_x*(0 + 0) + size_x*size_y*(0 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((1 + 1) + size_x*(0 + 0) + size_x*size_y*(0 + 0), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((1 - 1) + size_x*(0 + 0) + size_x*size_y*(0 + 0), N_max);
	yPos_ptr_run = in_ptr0 + myModulo((1 + 0) + size_x*(0 + 1) + size_x*size_y*(0 + 0), N_max);
	yNeg_ptr_run = in_ptr0 + myModulo((1 + 0) + size_x*(0 - 1) + size_x*size_y*(0 + 0), N_max);
	zPos_ptr_run = in_ptr0 + myModulo((1 + 0) + size_x*(0 + 0) + size_x*size_y*(0 + 1), N_max);
	zNeg_ptr_run = in_ptr0 + myModulo((1 + 0) + size_x*(0 + 0) + size_x*size_y*(0 - 1), N_max);


	iMax = size_x - 1;
	for (i = 0; i < iMax; i++)
	{
		*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ + *zPos_ptr_run++ + *zNeg_ptr_run++) / 7;
	}
	// start edge ---------------------------------------------------------------------------------



	// end edge ----------------------------------------------------------------------------------
	out_ptr_run = out_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((0 + 1) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((0 - 1) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	yPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 + 1) + size_x*size_y*(size_z - 1 + 0), N_max);
	yNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 - 1) + size_x*size_y*(size_z - 1 + 0), N_max);
	zPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 1), N_max);
	zNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 - 1), N_max);


	iMax = size_x - 1;
	for (i = 0; i < iMax; i++)
	{
		*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ + *zPos_ptr_run++ + *zNeg_ptr_run++) / 7;
	}
	// end edge ----------------------------------------------------------------------------------






	// start corner --------------------------------------------------------------------------
	out_ptr_run = out_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(0 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(0 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((0 + 1) + size_x*(0 + 0) + size_x*size_y*(0 + 0), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((0 - 1) + size_x*(0 + 0) + size_x*size_y*(0 + 0), N_max);
	yPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 1) + size_x*size_y*(0 + 0), N_max);
	yNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 - 1) + size_x*size_y*(0 + 0), N_max);
	zPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(0 + 1), N_max);
	zNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0) + size_x*size_y*(0 - 1), N_max);

	*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ + *zPos_ptr_run++ + *zNeg_ptr_run++) / 7;
	// start corner --------------------------------------------------------------------------





	// end corner -----------------------------------------------------------------------------
	out_ptr_run = out_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((size_x - 1 + 1) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((size_x - 1 - 1) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 0), N_max);
	yPos_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 + 1) + size_x*size_y*(size_z - 1 + 0), N_max);
	yNeg_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 - 1) + size_x*size_y*(size_z - 1 + 0), N_max);
	zPos_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 + 1), N_max);
	zNeg_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 + 0) + size_x*size_y*(size_z - 1 - 1), N_max);

	*out_ptr_run++ = (*cent_ptr_run++ + *xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ + *zPos_ptr_run++ + *zNeg_ptr_run++) / 7;
	// end corner ------------------------------------------------------------------------------




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
