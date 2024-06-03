// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <cmath>
#include <cstdio>


void bmImLaplacian2(int size_x, int size_y, float* in_ptr0, float* out_ptr0);
int myModulo(int a, int b);

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

	// input arguments initial    
	int  size_x;
	int  size_y;
	float* in_ptr0;

	// output arguments initial
	float* out_ptr0;


	// input arguments definition
	size_x = (int)mxGetScalar(prhs[0]);
	size_y = (int)mxGetScalar(prhs[1]);
	in_ptr0 = (float*)mxGetPr(prhs[2]);
	
	// output arguments definition
	mwSize* out_size = new mwSize[2];
	out_size[0] = (mwSize)size_x;
	out_size[1] = (mwSize)size_y;
	mwSize out_ndims = (mwSize)2;


	plhs[0] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_ptr0 = (float*)mxGetPr(plhs[0]);

	// function call
	bmImLaplacian2(size_x, size_y, in_ptr0, out_ptr0);

	// delete[]
	delete[] out_size;
}




void bmImLaplacian2(int size_x, int size_y, float* in_ptr0, float* out_ptr0)
{

	int i;
	int iMax;

	int N_max = size_x*size_y;

	float* out_ptr_run;
	float* cent_ptr_run;
	float* xPos_ptr_run;
	float* xNeg_ptr_run;
	float* yPos_ptr_run;
	float* yNeg_ptr_run;


	// main_volume ---------------------------------------------------------------------------------



	// cross for the main volume
	out_ptr_run = out_ptr0 + myModulo((0 + 0) + size_x*(1 + 0), N_max);
	cent_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(1 + 0), N_max);
	xPos_ptr_run = in_ptr0 + myModulo((0 + 1) + size_x*(1 + 0), N_max);
	xNeg_ptr_run = in_ptr0 + myModulo((0 - 1) + size_x*(1 + 0), N_max);
	yPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(1 + 1), N_max);
	yNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(1 - 1), N_max);

	iMax = size_x*(size_y - 2); 
	for (i = 0; i < iMax; i++)
	{
		*out_ptr_run++ = (*xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ - 4*(*cent_ptr_run++));
	}



	// END main_volume -------------------------------------------------------------------------------



		// start first edge ---------------------------------------------------------------------------------
		out_ptr_run = out_ptr0 + myModulo((1 + 0) + size_x*(0 + 0), N_max);
		cent_ptr_run = in_ptr0 + myModulo((1 + 0) + size_x*(0 + 0), N_max);
		xPos_ptr_run = in_ptr0 + myModulo((1 + 1) + size_x*(0 + 0), N_max);
		xNeg_ptr_run = in_ptr0 + myModulo((1 - 1) + size_x*(0 + 0), N_max);
		yPos_ptr_run = in_ptr0 + myModulo((1 + 0) + size_x*(0 + 1), N_max);
		yNeg_ptr_run = in_ptr0 + myModulo((1 + 0) + size_x*(0 - 1), N_max);


		iMax = size_x - 1;
		for (i = 0; i < iMax; i++)
		{
			*out_ptr_run++ = (*xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ - 4 * (*cent_ptr_run++));
		}
		// end first edge ---------------------------------------------------------------------------------


		// start last edge ----------------------------------------------------------------------------------
		out_ptr_run = out_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 + 0), N_max);
		cent_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 + 0), N_max);
		xPos_ptr_run = in_ptr0 + myModulo((0 + 1) + size_x*(size_y - 1 + 0), N_max);
		xNeg_ptr_run = in_ptr0 + myModulo((0 - 1) + size_x*(size_y - 1 + 0), N_max);
		yPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 + 1), N_max);
		yNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(size_y - 1 - 1), N_max);


		iMax = size_x - 1;
		for (i = 0; i < iMax; i++)
		{
			*out_ptr_run++ = (*xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ - 4 * (*cent_ptr_run++));
		}
		// end last edge ----------------------------------------------------------------------------------



		// start first corner --------------------------------------------------------------------------
		out_ptr_run = out_ptr0 + myModulo((0 + 0) + size_x*(0 + 0), N_max);
		cent_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 0), N_max);
		xPos_ptr_run = in_ptr0 + myModulo((0 + 1) + size_x*(0 + 0), N_max);
		xNeg_ptr_run = in_ptr0 + myModulo((0 - 1) + size_x*(0 + 0), N_max);
		yPos_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 + 1), N_max);
		yNeg_ptr_run = in_ptr0 + myModulo((0 + 0) + size_x*(0 - 1), N_max);


		*out_ptr_run++ = (*xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ - 4 * (*cent_ptr_run++));
		// end first corner --------------------------------------------------------------------------





		// start last corner -----------------------------------------------------------------------------
		out_ptr_run = out_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 + 0), N_max);
		cent_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 + 0), N_max);
		xPos_ptr_run = in_ptr0 + myModulo((size_x - 1 + 1) + size_x*(size_y - 1 + 0), N_max);
		xNeg_ptr_run = in_ptr0 + myModulo((size_x - 1 - 1) + size_x*(size_y - 1 + 0), N_max);
		yPos_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 + 1), N_max);
		yNeg_ptr_run = in_ptr0 + myModulo((size_x - 1 + 0) + size_x*(size_y - 1 - 1), N_max);


		*out_ptr_run++ = (*xPos_ptr_run++ + *xNeg_ptr_run++ + *yPos_ptr_run++ + *yNeg_ptr_run++ - 4 * (*cent_ptr_run++));
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

