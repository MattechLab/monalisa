// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <cmath>
#include <cstdio>


void bmImGradient3(int size_x, int size_y, int size_z, float* in_ptr0, float* out_x_ptr0, float* out_y_ptr0, float* out_z_ptr0);

int myModulo(int a, int b);

void setPointers(float* in_ptr0, float* out_x_ptr0, float* out_y_ptr0, float* out_z_ptr0,

				float* &out_x_ptr_run, float* &out_y_ptr_run, float* &out_z_ptr_run,

				float* &xCen_yCen_zCen_ptr_run, float* &xPos_yCen_zCen_ptr_run, float* &xNeg_yCen_zCen_ptr_run,
				float* &xCen_yPos_zCen_ptr_run, float* &xPos_yPos_zCen_ptr_run, float* &xNeg_yPos_zCen_ptr_run,
				float* &xCen_yNeg_zCen_ptr_run, float* &xPos_yNeg_zCen_ptr_run, float* &xNeg_yNeg_zCen_ptr_run,

				float* &xCen_yCen_zPos_ptr_run, float* &xPos_yCen_zPos_ptr_run, float* &xNeg_yCen_zPos_ptr_run,
				float* &xCen_yPos_zPos_ptr_run, float* &xPos_yPos_zPos_ptr_run, float* &xNeg_yPos_zPos_ptr_run,
				float* &xCen_yNeg_zPos_ptr_run, float* &xPos_yNeg_zPos_ptr_run, float* &xNeg_yNeg_zPos_ptr_run,

				float* &xCen_yCen_zNeg_ptr_run, float* &xPos_yCen_zNeg_ptr_run, float* &xNeg_yCen_zNeg_ptr_run,
				float* &xCen_yPos_zNeg_ptr_run, float* &xPos_yPos_zNeg_ptr_run, float* &xNeg_yPos_zNeg_ptr_run,
				float* &xCen_yNeg_zNeg_ptr_run, float* &xPos_yNeg_zNeg_ptr_run, float* &xNeg_yNeg_zNeg_ptr_run,

				int nx, int ny, int nz, int size_x, int size_y, int size_z); 


/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{


	// input arguments initial    
	int  size_x;
	int  size_y;
	int  size_z;
	float* in_ptr0;

	// output arguments initial
	float* out_x_ptr0;
	float* out_y_ptr0;
	float* out_z_ptr0;




	// input arguments definition
	size_x	= (int)mxGetScalar(prhs[0]);
	size_y	= (int)mxGetScalar(prhs[1]);
	size_z	= (int)mxGetScalar(prhs[2]);
	in_ptr0 = (float*)mxGetPr(prhs[3]);


	// output arguments definition
	mwSize* out_size = new mwSize[3];
	out_size[0] = (mwSize)size_x;
	out_size[1] = (mwSize)size_y;
	out_size[2] = (mwSize)size_z;
	mwSize out_ndims = (mwSize)3;


	plhs[0] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_x_ptr0 = (float*)mxGetPr(plhs[0]);

	plhs[1] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_y_ptr0 = (float*)mxGetPr(plhs[1]);

	plhs[2] = mxCreateNumericArray(out_ndims, out_size, mxSINGLE_CLASS, mxREAL);
	out_z_ptr0 = (float*)mxGetPr(plhs[2]);


	// function call
	bmImGradient3(size_x, size_y, size_z, in_ptr0, out_x_ptr0, out_y_ptr0, out_z_ptr0);

	// delete[]
	delete[] out_size;
}



void bmImGradient3(int size_x, int size_y, int size_z, float* in_ptr0, float* out_x_ptr0, float* out_y_ptr0, float* out_z_ptr0)
{


	int i, j, k;
	int nx, ny, nz; 
	int iMax;
	int N_max = size_x*size_y*size_z;

	float *out_x_ptr_run, *out_y_ptr_run, *out_z_ptr_run; 

	float *xCen_yCen_zCen_ptr_run, *xPos_yCen_zCen_ptr_run, *xNeg_yCen_zCen_ptr_run; 
	float *xCen_yPos_zCen_ptr_run, *xPos_yPos_zCen_ptr_run, *xNeg_yPos_zCen_ptr_run;
	float *xCen_yNeg_zCen_ptr_run, *xPos_yNeg_zCen_ptr_run, *xNeg_yNeg_zCen_ptr_run;

	float *xCen_yCen_zPos_ptr_run, *xPos_yCen_zPos_ptr_run, *xNeg_yCen_zPos_ptr_run;
	float *xCen_yPos_zPos_ptr_run, *xPos_yPos_zPos_ptr_run, *xNeg_yPos_zPos_ptr_run;
	float *xCen_yNeg_zPos_ptr_run, *xPos_yNeg_zPos_ptr_run, *xNeg_yNeg_zPos_ptr_run;

	float *xCen_yCen_zNeg_ptr_run, *xPos_yCen_zNeg_ptr_run, *xNeg_yCen_zNeg_ptr_run;
	float *xCen_yPos_zNeg_ptr_run, *xPos_yPos_zNeg_ptr_run, *xNeg_yPos_zNeg_ptr_run;
	float *xCen_yNeg_zNeg_ptr_run, *xPos_yNeg_zNeg_ptr_run, *xNeg_yNeg_zNeg_ptr_run;


	// main_volume ---------------------------------------------------------------------------------

	nx = 1; 
	ny = 1; 
	nz = 1; 

	setPointers(in_ptr0, out_x_ptr0, out_y_ptr0, out_z_ptr0, 
		
				out_x_ptr_run, out_y_ptr_run, out_z_ptr_run, 
				
				xCen_yCen_zCen_ptr_run, xPos_yCen_zCen_ptr_run, xNeg_yCen_zCen_ptr_run, 
				xCen_yPos_zCen_ptr_run, xPos_yPos_zCen_ptr_run, xNeg_yPos_zCen_ptr_run, 
				xCen_yNeg_zCen_ptr_run, xPos_yNeg_zCen_ptr_run, xNeg_yNeg_zCen_ptr_run, 
				
				xCen_yCen_zPos_ptr_run, xPos_yCen_zPos_ptr_run, xNeg_yCen_zPos_ptr_run,
				xCen_yPos_zPos_ptr_run, xPos_yPos_zPos_ptr_run, xNeg_yPos_zPos_ptr_run,
				xCen_yNeg_zPos_ptr_run, xPos_yNeg_zPos_ptr_run, xNeg_yNeg_zPos_ptr_run, 
				
				xCen_yCen_zNeg_ptr_run, xPos_yCen_zNeg_ptr_run, xNeg_yCen_zNeg_ptr_run,
				xCen_yPos_zNeg_ptr_run, xPos_yPos_zNeg_ptr_run, xNeg_yPos_zNeg_ptr_run,
				xCen_yNeg_zNeg_ptr_run, xPos_yNeg_zNeg_ptr_run, xNeg_yNeg_zNeg_ptr_run, 
				
				nx, ny, nz, size_x, size_y, size_z);



	iMax = N_max - 2*(1 + size_x + size_x*size_y);
	for (i = 0; i < iMax; i++)
	{
		*out_x_ptr_run++ = (*xPos_yCen_zCen_ptr_run - *xNeg_yCen_zCen_ptr_run +
							*xPos_yPos_zCen_ptr_run - *xNeg_yPos_zCen_ptr_run +
							*xPos_yNeg_zCen_ptr_run - *xNeg_yNeg_zCen_ptr_run +
							*xPos_yCen_zPos_ptr_run - *xNeg_yCen_zPos_ptr_run +
							*xPos_yPos_zPos_ptr_run - *xNeg_yPos_zPos_ptr_run +
							*xPos_yNeg_zPos_ptr_run - *xNeg_yNeg_zPos_ptr_run +
							*xPos_yCen_zNeg_ptr_run - *xNeg_yCen_zNeg_ptr_run +
							*xPos_yPos_zNeg_ptr_run - *xNeg_yPos_zNeg_ptr_run +
							*xPos_yNeg_zNeg_ptr_run - *xNeg_yNeg_zNeg_ptr_run ) / 18;

		*out_y_ptr_run++ = (*xCen_yPos_zCen_ptr_run - *xCen_yNeg_zCen_ptr_run +
							*xPos_yPos_zCen_ptr_run - *xPos_yNeg_zCen_ptr_run +
							*xNeg_yPos_zCen_ptr_run - *xNeg_yNeg_zCen_ptr_run +
							*xCen_yPos_zPos_ptr_run - *xCen_yNeg_zPos_ptr_run +
							*xPos_yPos_zPos_ptr_run - *xPos_yNeg_zPos_ptr_run +
							*xNeg_yPos_zPos_ptr_run - *xNeg_yNeg_zPos_ptr_run +
							*xCen_yPos_zNeg_ptr_run - *xCen_yNeg_zNeg_ptr_run +
							*xPos_yPos_zNeg_ptr_run - *xPos_yNeg_zNeg_ptr_run +
							*xNeg_yPos_zNeg_ptr_run - *xNeg_yNeg_zNeg_ptr_run ) / 18;


		*out_z_ptr_run++ = (*xCen_yCen_zPos_ptr_run - *xCen_yCen_zNeg_ptr_run +
							*xPos_yCen_zPos_ptr_run - *xPos_yCen_zNeg_ptr_run +
							*xNeg_yCen_zPos_ptr_run - *xNeg_yCen_zNeg_ptr_run +
							*xCen_yPos_zPos_ptr_run - *xCen_yPos_zNeg_ptr_run +
							*xPos_yPos_zPos_ptr_run - *xPos_yPos_zNeg_ptr_run +
							*xNeg_yPos_zPos_ptr_run - *xNeg_yPos_zNeg_ptr_run +
							*xCen_yNeg_zPos_ptr_run - *xCen_yNeg_zNeg_ptr_run +
							*xPos_yNeg_zPos_ptr_run - *xPos_yNeg_zNeg_ptr_run +
							*xNeg_yNeg_zPos_ptr_run - *xNeg_yNeg_zNeg_ptr_run ) / 18;

		xCen_yCen_zCen_ptr_run++; xPos_yCen_zCen_ptr_run++; xNeg_yCen_zCen_ptr_run++;
		xCen_yPos_zCen_ptr_run++; xPos_yPos_zCen_ptr_run++; xNeg_yPos_zCen_ptr_run++;
		xCen_yNeg_zCen_ptr_run++; xPos_yNeg_zCen_ptr_run++; xNeg_yNeg_zCen_ptr_run++;
		xCen_yCen_zPos_ptr_run++; xPos_yCen_zPos_ptr_run++; xNeg_yCen_zPos_ptr_run++;
		xCen_yPos_zPos_ptr_run++; xPos_yPos_zPos_ptr_run++; xNeg_yPos_zPos_ptr_run++;
		xCen_yNeg_zPos_ptr_run++; xPos_yNeg_zPos_ptr_run++; xNeg_yNeg_zPos_ptr_run++;
		xCen_yCen_zNeg_ptr_run++; xPos_yCen_zNeg_ptr_run++; xNeg_yCen_zNeg_ptr_run++;
		xCen_yPos_zNeg_ptr_run++; xPos_yPos_zNeg_ptr_run++; xNeg_yPos_zNeg_ptr_run++;
		xCen_yNeg_zNeg_ptr_run++; xPos_yNeg_zNeg_ptr_run++; xNeg_yNeg_zNeg_ptr_run++; 


	}
	// main_volume ---------------------------------------------------------------------------------


	// start_volume ---------------------------------------------------------------------------------
	nx = 0;
	ny = 0;
	nz = 0;

	setPointers(in_ptr0, out_x_ptr0, out_y_ptr0, out_z_ptr0,

		out_x_ptr_run, out_y_ptr_run, out_z_ptr_run,

		xCen_yCen_zCen_ptr_run, xPos_yCen_zCen_ptr_run, xNeg_yCen_zCen_ptr_run,
		xCen_yPos_zCen_ptr_run, xPos_yPos_zCen_ptr_run, xNeg_yPos_zCen_ptr_run,
		xCen_yNeg_zCen_ptr_run, xPos_yNeg_zCen_ptr_run, xNeg_yNeg_zCen_ptr_run,

		xCen_yCen_zPos_ptr_run, xPos_yCen_zPos_ptr_run, xNeg_yCen_zPos_ptr_run,
		xCen_yPos_zPos_ptr_run, xPos_yPos_zPos_ptr_run, xNeg_yPos_zPos_ptr_run,
		xCen_yNeg_zPos_ptr_run, xPos_yNeg_zPos_ptr_run, xNeg_yNeg_zPos_ptr_run,

		xCen_yCen_zNeg_ptr_run, xPos_yCen_zNeg_ptr_run, xNeg_yCen_zNeg_ptr_run,
		xCen_yPos_zNeg_ptr_run, xPos_yPos_zNeg_ptr_run, xNeg_yPos_zNeg_ptr_run,
		xCen_yNeg_zNeg_ptr_run, xPos_yNeg_zNeg_ptr_run, xNeg_yNeg_zNeg_ptr_run,

		nx, ny, nz, size_x, size_y, size_z);



	iMax = size_x*size_y + size_x + 1;
	for (i = 0; i < iMax; i++)
	{
		*out_x_ptr_run++ = (*xPos_yCen_zCen_ptr_run - *xNeg_yCen_zCen_ptr_run +
			*xPos_yPos_zCen_ptr_run - *xNeg_yPos_zCen_ptr_run +
			*xPos_yNeg_zCen_ptr_run - *xNeg_yNeg_zCen_ptr_run +
			*xPos_yCen_zPos_ptr_run - *xNeg_yCen_zPos_ptr_run +
			*xPos_yPos_zPos_ptr_run - *xNeg_yPos_zPos_ptr_run +
			*xPos_yNeg_zPos_ptr_run - *xNeg_yNeg_zPos_ptr_run +
			*xPos_yCen_zNeg_ptr_run - *xNeg_yCen_zNeg_ptr_run +
			*xPos_yPos_zNeg_ptr_run - *xNeg_yPos_zNeg_ptr_run +
			*xPos_yNeg_zNeg_ptr_run - *xNeg_yNeg_zNeg_ptr_run) / 18;

		*out_y_ptr_run++ = (*xCen_yPos_zCen_ptr_run - *xCen_yNeg_zCen_ptr_run +
			*xPos_yPos_zCen_ptr_run - *xPos_yNeg_zCen_ptr_run +
			*xNeg_yPos_zCen_ptr_run - *xNeg_yNeg_zCen_ptr_run +
			*xCen_yPos_zPos_ptr_run - *xCen_yNeg_zPos_ptr_run +
			*xPos_yPos_zPos_ptr_run - *xPos_yNeg_zPos_ptr_run +
			*xNeg_yPos_zPos_ptr_run - *xNeg_yNeg_zPos_ptr_run +
			*xCen_yPos_zNeg_ptr_run - *xCen_yNeg_zNeg_ptr_run +
			*xPos_yPos_zNeg_ptr_run - *xPos_yNeg_zNeg_ptr_run +
			*xNeg_yPos_zNeg_ptr_run - *xNeg_yNeg_zNeg_ptr_run) / 18;


		*out_z_ptr_run++ = (*xCen_yCen_zPos_ptr_run - *xCen_yCen_zNeg_ptr_run +
			*xPos_yCen_zPos_ptr_run - *xPos_yCen_zNeg_ptr_run +
			*xNeg_yCen_zPos_ptr_run - *xNeg_yCen_zNeg_ptr_run +
			*xCen_yPos_zPos_ptr_run - *xCen_yPos_zNeg_ptr_run +
			*xPos_yPos_zPos_ptr_run - *xPos_yPos_zNeg_ptr_run +
			*xNeg_yPos_zPos_ptr_run - *xNeg_yPos_zNeg_ptr_run +
			*xCen_yNeg_zPos_ptr_run - *xCen_yNeg_zNeg_ptr_run +
			*xPos_yNeg_zPos_ptr_run - *xPos_yNeg_zNeg_ptr_run +
			*xNeg_yNeg_zPos_ptr_run - *xNeg_yNeg_zNeg_ptr_run) / 18;

		

		xCen_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);
		xPos_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);
		xNeg_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);

		xCen_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);
		xPos_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);
		xNeg_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);

		xCen_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);
		xPos_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);
		xNeg_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);


		xCen_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);
		xPos_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);
		xNeg_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);

		xCen_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);
		xPos_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);
		xNeg_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);

		xCen_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);
		xPos_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);
		xNeg_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);



		xCen_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);
		xPos_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);
		xNeg_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);

		xCen_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);
		xPos_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);
		xNeg_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);

		xCen_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);
		xPos_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);
		xNeg_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);


	}
	// start_volume ---------------------------------------------------------------------------------


	// end_volume ---------------------------------------------------------------------------------
	nx = size_x - 1;
	ny = size_y - 2;
	nz = size_z - 2;

	setPointers(in_ptr0, out_x_ptr0, out_y_ptr0, out_z_ptr0,

		out_x_ptr_run, out_y_ptr_run, out_z_ptr_run,

		xCen_yCen_zCen_ptr_run, xPos_yCen_zCen_ptr_run, xNeg_yCen_zCen_ptr_run,
		xCen_yPos_zCen_ptr_run, xPos_yPos_zCen_ptr_run, xNeg_yPos_zCen_ptr_run,
		xCen_yNeg_zCen_ptr_run, xPos_yNeg_zCen_ptr_run, xNeg_yNeg_zCen_ptr_run,

		xCen_yCen_zPos_ptr_run, xPos_yCen_zPos_ptr_run, xNeg_yCen_zPos_ptr_run,
		xCen_yPos_zPos_ptr_run, xPos_yPos_zPos_ptr_run, xNeg_yPos_zPos_ptr_run,
		xCen_yNeg_zPos_ptr_run, xPos_yNeg_zPos_ptr_run, xNeg_yNeg_zPos_ptr_run,

		xCen_yCen_zNeg_ptr_run, xPos_yCen_zNeg_ptr_run, xNeg_yCen_zNeg_ptr_run,
		xCen_yPos_zNeg_ptr_run, xPos_yPos_zNeg_ptr_run, xNeg_yPos_zNeg_ptr_run,
		xCen_yNeg_zNeg_ptr_run, xPos_yNeg_zNeg_ptr_run, xNeg_yNeg_zNeg_ptr_run,

		nx, ny, nz, size_x, size_y, size_z);



	iMax = size_x*size_y + size_x + 1;
	for (i = 0; i < iMax; i++)
	{
		*out_x_ptr_run++ = (*xPos_yCen_zCen_ptr_run - *xNeg_yCen_zCen_ptr_run +
			*xPos_yPos_zCen_ptr_run - *xNeg_yPos_zCen_ptr_run +
			*xPos_yNeg_zCen_ptr_run - *xNeg_yNeg_zCen_ptr_run +
			*xPos_yCen_zPos_ptr_run - *xNeg_yCen_zPos_ptr_run +
			*xPos_yPos_zPos_ptr_run - *xNeg_yPos_zPos_ptr_run +
			*xPos_yNeg_zPos_ptr_run - *xNeg_yNeg_zPos_ptr_run +
			*xPos_yCen_zNeg_ptr_run - *xNeg_yCen_zNeg_ptr_run +
			*xPos_yPos_zNeg_ptr_run - *xNeg_yPos_zNeg_ptr_run +
			*xPos_yNeg_zNeg_ptr_run - *xNeg_yNeg_zNeg_ptr_run) / 18;

		*out_y_ptr_run++ = (*xCen_yPos_zCen_ptr_run - *xCen_yNeg_zCen_ptr_run +
			*xPos_yPos_zCen_ptr_run - *xPos_yNeg_zCen_ptr_run +
			*xNeg_yPos_zCen_ptr_run - *xNeg_yNeg_zCen_ptr_run +
			*xCen_yPos_zPos_ptr_run - *xCen_yNeg_zPos_ptr_run +
			*xPos_yPos_zPos_ptr_run - *xPos_yNeg_zPos_ptr_run +
			*xNeg_yPos_zPos_ptr_run - *xNeg_yNeg_zPos_ptr_run +
			*xCen_yPos_zNeg_ptr_run - *xCen_yNeg_zNeg_ptr_run +
			*xPos_yPos_zNeg_ptr_run - *xPos_yNeg_zNeg_ptr_run +
			*xNeg_yPos_zNeg_ptr_run - *xNeg_yNeg_zNeg_ptr_run) / 18;


		*out_z_ptr_run++ = (*xCen_yCen_zPos_ptr_run - *xCen_yCen_zNeg_ptr_run +
			*xPos_yCen_zPos_ptr_run - *xPos_yCen_zNeg_ptr_run +
			*xNeg_yCen_zPos_ptr_run - *xNeg_yCen_zNeg_ptr_run +
			*xCen_yPos_zPos_ptr_run - *xCen_yPos_zNeg_ptr_run +
			*xPos_yPos_zPos_ptr_run - *xPos_yPos_zNeg_ptr_run +
			*xNeg_yPos_zPos_ptr_run - *xNeg_yPos_zNeg_ptr_run +
			*xCen_yNeg_zPos_ptr_run - *xCen_yNeg_zNeg_ptr_run +
			*xPos_yNeg_zPos_ptr_run - *xPos_yNeg_zNeg_ptr_run +
			*xNeg_yNeg_zPos_ptr_run - *xNeg_yNeg_zNeg_ptr_run) / 18;



		xCen_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);
		xPos_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);
		xNeg_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);

		xCen_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);
		xPos_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);
		xNeg_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);

		xCen_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);
		xPos_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);
		xNeg_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);


		xCen_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);
		xPos_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);
		xNeg_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);

		xCen_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);
		xPos_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);
		xNeg_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);

		xCen_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);
		xPos_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);
		xNeg_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);



		xCen_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);
		xPos_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);
		xNeg_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);

		xCen_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);
		xPos_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);
		xNeg_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);

		xCen_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);
		xPos_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);
		xNeg_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);


	}
	// end_volume ---------------------------------------------------------------------------------



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


void setPointers(float* in_ptr0, float* out_x_ptr0, float* out_y_ptr0, float* out_z_ptr0, 
	
	float* &out_x_ptr_run, float* &out_y_ptr_run, float* &out_z_ptr_run,

	float* &xCen_yCen_zCen_ptr_run, float* &xPos_yCen_zCen_ptr_run, float* &xNeg_yCen_zCen_ptr_run,
	float* &xCen_yPos_zCen_ptr_run, float* &xPos_yPos_zCen_ptr_run, float* &xNeg_yPos_zCen_ptr_run,
	float* &xCen_yNeg_zCen_ptr_run, float* &xPos_yNeg_zCen_ptr_run, float* &xNeg_yNeg_zCen_ptr_run,

	float* &xCen_yCen_zPos_ptr_run, float* &xPos_yCen_zPos_ptr_run, float* &xNeg_yCen_zPos_ptr_run,
	float* &xCen_yPos_zPos_ptr_run, float* &xPos_yPos_zPos_ptr_run, float* &xNeg_yPos_zPos_ptr_run,
	float* &xCen_yNeg_zPos_ptr_run, float* &xPos_yNeg_zPos_ptr_run, float* &xNeg_yNeg_zPos_ptr_run,

	float* &xCen_yCen_zNeg_ptr_run, float* &xPos_yCen_zNeg_ptr_run, float* &xNeg_yCen_zNeg_ptr_run,
	float* &xCen_yPos_zNeg_ptr_run, float* &xPos_yPos_zNeg_ptr_run, float* &xNeg_yPos_zNeg_ptr_run,
	float* &xCen_yNeg_zNeg_ptr_run, float* &xPos_yNeg_zNeg_ptr_run, float* &xNeg_yNeg_zNeg_ptr_run,

	int nx, int ny, int nz, int size_x, int size_y, int size_z)
{

	int N_max = size_x*size_y*size_z; 

	
	out_x_ptr_run = out_x_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);
	out_y_ptr_run = out_y_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);
	out_z_ptr_run = out_z_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);

	xCen_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);
	xPos_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);
	xNeg_yCen_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz + 0), N_max);

	xCen_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);
	xPos_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);
	xNeg_yPos_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz + 0), N_max);

	xCen_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);
	xPos_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);
	xNeg_yNeg_zCen_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz + 0), N_max);


	xCen_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);
	xPos_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);
	xNeg_yCen_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz + 1), N_max);

	xCen_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);
	xPos_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);
	xNeg_yPos_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz + 1), N_max);

	xCen_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);
	xPos_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);
	xNeg_yNeg_zPos_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz + 1), N_max);



	xCen_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);
	xPos_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);
	xNeg_yCen_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 0) + size_x*size_y*(nz - 1), N_max);

	xCen_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);
	xPos_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);
	xNeg_yPos_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny + 1) + size_x*size_y*(nz - 1), N_max);

	xCen_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx + 0) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);
	xPos_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx + 1) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);
	xNeg_yNeg_zNeg_ptr_run = in_ptr0 + myModulo((nx - 1) + size_x*(ny - 1) + size_x*size_y*(nz - 1), N_max);


}




