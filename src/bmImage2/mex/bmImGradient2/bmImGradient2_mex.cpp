// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <cmath>
#include <cstdio>

void bmImGradient2(int size_x, int size_y, float* in_ptr0, float* out_x_ptr0, float* out_y_ptr0);

int myModulo(int a, int b);

void setPointers(float* in_ptr0, float* out_x_ptr0, float* out_y_ptr0,

				float* &out_x_ptr_run, float* &out_y_ptr_run,

				float* &xCen_yCen_ptr_run, float* &xPos_yCen_ptr_run, float* &xNeg_yCen_ptr_run,
				float* &xCen_yPos_ptr_run, float* &xPos_yPos_ptr_run, float* &xNeg_yPos_ptr_run,
				float* &xCen_yNeg_ptr_run, float* &xPos_yNeg_ptr_run, float* &xNeg_yNeg_ptr_run,

				int nx, int ny, int size_x, int size_y); 

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

	// input arguments initial    
	int  size_x;
	int  size_y;
	float* in_ptr0;

	// output arguments initial
	float* out_x_ptr0;
	float* out_y_ptr0;


	// input arguments definition
	size_x	= (int)mxGetScalar(prhs[0]);
	size_y	= (int)mxGetScalar(prhs[1]);
	in_ptr0 = (float*)mxGetPr(prhs[2]);


	// output arguments definition
	mwSize* out_size = new mwSize[2];
	out_size[0] = (mwSize)size_x;
	out_size[1] = (mwSize)size_y;
	mwSize out_ndims = (mwSize)2;


	plhs[0] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_x_ptr0 = (float*)mxGetPr(plhs[0]);

	plhs[1] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_y_ptr0 = (float*)mxGetPr(plhs[1]);

	// function call
	bmImGradient2(size_x, size_y, in_ptr0, out_x_ptr0, out_y_ptr0);

	// delete[]
	delete[] out_size;
}



void bmImGradient2(int size_x, int size_y, float* in_ptr0, float* out_x_ptr0, float* out_y_ptr0)
{

	int i, j, nx, ny;
	int iMax;
	int N_max = size_x*size_y;

	float *out_x_ptr_run, *out_y_ptr_run; 

	float *xCen_yCen_ptr_run, *xPos_yCen_ptr_run, *xNeg_yCen_ptr_run; 
	float *xCen_yPos_ptr_run, *xPos_yPos_ptr_run, *xNeg_yPos_ptr_run;
	float *xCen_yNeg_ptr_run, *xPos_yNeg_ptr_run, *xNeg_yNeg_ptr_run;


	// main_volume ---------------------------------------------------------------------------------

	nx = 1; 
	ny = 1; 

	setPointers(in_ptr0, out_x_ptr0, out_y_ptr0, 
		
				out_x_ptr_run, out_y_ptr_run, 
				
				xCen_yCen_ptr_run, xPos_yCen_ptr_run, xNeg_yCen_ptr_run, 
				xCen_yPos_ptr_run, xPos_yPos_ptr_run, xNeg_yPos_ptr_run, 
				xCen_yNeg_ptr_run, xPos_yNeg_ptr_run, xNeg_yNeg_ptr_run, 
				
				nx, ny, size_x, size_y);


	iMax = N_max - 2*(1 + size_x);
	for (i = 0; i < iMax; i++)
	{
		*out_x_ptr_run++ = (*xPos_yCen_ptr_run - *xNeg_yCen_ptr_run +
							*xPos_yPos_ptr_run - *xNeg_yPos_ptr_run +
							*xPos_yNeg_ptr_run - *xNeg_yNeg_ptr_run ) / 6;

		*out_y_ptr_run++ = (*xCen_yPos_ptr_run - *xCen_yNeg_ptr_run +
							*xPos_yPos_ptr_run - *xPos_yNeg_ptr_run +
							*xNeg_yPos_ptr_run - *xNeg_yNeg_ptr_run ) / 6;


		xCen_yCen_ptr_run++; xPos_yCen_ptr_run++; xNeg_yCen_ptr_run++;
		xCen_yPos_ptr_run++; xPos_yPos_ptr_run++; xNeg_yPos_ptr_run++;
		xCen_yNeg_ptr_run++; xPos_yNeg_ptr_run++; xNeg_yNeg_ptr_run++;
	}
	// main_volume ---------------------------------------------------------------------------------

	// start_rest_volume --------------------------------------------------------------------------

	nx = 0;
	ny = 0;

	setPointers(in_ptr0, out_x_ptr0, out_y_ptr0,

		out_x_ptr_run, out_y_ptr_run,

		xCen_yCen_ptr_run, xPos_yCen_ptr_run, xNeg_yCen_ptr_run,
		xCen_yPos_ptr_run, xPos_yPos_ptr_run, xNeg_yPos_ptr_run,
		xCen_yNeg_ptr_run, xPos_yNeg_ptr_run, xNeg_yNeg_ptr_run,

		nx, ny, size_x, size_y);

	iMax = size_x + 1;
	for (i = 0; i < iMax; i++)
	{
		*out_x_ptr_run++ = (*xPos_yCen_ptr_run - *xNeg_yCen_ptr_run +
							*xPos_yPos_ptr_run - *xNeg_yPos_ptr_run +
							*xPos_yNeg_ptr_run - *xNeg_yNeg_ptr_run) / 6;

		*out_y_ptr_run++ = (*xCen_yPos_ptr_run - *xCen_yNeg_ptr_run +
							*xPos_yPos_ptr_run - *xPos_yNeg_ptr_run +
							*xNeg_yPos_ptr_run - *xNeg_yNeg_ptr_run) / 6;



		xCen_yCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0), N_max);
		xPos_yCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0), N_max);
		xNeg_yCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0), N_max);

		xCen_yPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1), N_max);
		xPos_yPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1), N_max);
		xNeg_yPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1), N_max);

		xCen_yNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1), N_max);
		xPos_yNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1), N_max);
		xNeg_yNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1), N_max);

	}

	// END_start_rest_volume ----------------------------------------------------------------------


	// end_rest_volume --------------------------------------------------------------------------

	nx = size_x-2;
	ny = size_y-2;

	setPointers(in_ptr0, out_x_ptr0, out_y_ptr0,

		out_x_ptr_run, out_y_ptr_run,

		xCen_yCen_ptr_run, xPos_yCen_ptr_run, xNeg_yCen_ptr_run,
		xCen_yPos_ptr_run, xPos_yPos_ptr_run, xNeg_yPos_ptr_run,
		xCen_yNeg_ptr_run, xPos_yNeg_ptr_run, xNeg_yNeg_ptr_run,

		nx, ny, size_x, size_y);

	iMax = size_x + 1;
	for (i = 0; i < iMax; i++)
	{
		*out_x_ptr_run++ = (*xPos_yCen_ptr_run - *xNeg_yCen_ptr_run +
			*xPos_yPos_ptr_run - *xNeg_yPos_ptr_run +
			*xPos_yNeg_ptr_run - *xNeg_yNeg_ptr_run) / 6;

		*out_y_ptr_run++ = (*xCen_yPos_ptr_run - *xCen_yNeg_ptr_run +
			*xPos_yPos_ptr_run - *xPos_yNeg_ptr_run +
			*xNeg_yPos_ptr_run - *xNeg_yNeg_ptr_run) / 6;



		xCen_yCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0), N_max);
		xPos_yCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0), N_max);
		xNeg_yCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0), N_max);

		xCen_yPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1), N_max);
		xPos_yPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1), N_max);
		xNeg_yPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1), N_max);

		xCen_yNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1), N_max);
		xPos_yNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1), N_max);
		xNeg_yNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1), N_max);

	}

	// END_end_rest_volume ----------------------------------------------------------------------


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


void setPointers(float* in_ptr0, float* out_x_ptr0, float* out_y_ptr0,

				float* &out_x_ptr_run, float* &out_y_ptr_run,

				float* &xCen_yCen_ptr_run, float* &xPos_yCen_ptr_run, float* &xNeg_yCen_ptr_run,
				float* &xCen_yPos_ptr_run, float* &xPos_yPos_ptr_run, float* &xNeg_yPos_ptr_run,
				float* &xCen_yNeg_ptr_run, float* &xPos_yNeg_ptr_run, float* &xNeg_yNeg_ptr_run,

				int nx, int ny, int size_x, int size_y)
{

	int N_max = size_x*size_y; 

	
	out_x_ptr_run		= out_x_ptr0 + myModulo((nx + 0) + size_x*(ny + 0), N_max);
	out_y_ptr_run		= out_y_ptr0 + myModulo((nx + 0) + size_x*(ny + 0), N_max);

	xCen_yCen_ptr_run	= in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0), N_max);
	xPos_yCen_ptr_run	= in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0), N_max);
	xNeg_yCen_ptr_run	= in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0), N_max);

	xCen_yPos_ptr_run	= in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1), N_max);
	xPos_yPos_ptr_run	= in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1), N_max);
	xNeg_yPos_ptr_run	= in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1), N_max);

	xCen_yNeg_ptr_run	= in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1), N_max);
	xPos_yNeg_ptr_run	= in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1), N_max);
	xNeg_yNeg_ptr_run	= in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1), N_max);

}




