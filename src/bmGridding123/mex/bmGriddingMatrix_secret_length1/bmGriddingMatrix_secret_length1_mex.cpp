// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include <iostream>
#include <cmath>
#include <cstdio>
#include "mex.h"

void bmGriddingMatrix_secret_length1_mex(float* tx_ptr0, 
										 int nCh, 
										 int nPt, 
										 int Nx,
										 int nWin, 
										 long long* secrete_length_ptr);


/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

	float* tx_ptr0; 

	int nCh; 
	int nPt; 
	int Nx; 

	int nWin; 

	long long* secrete_length_ptr; 

	tx_ptr0			= (float*)mxGetPr(prhs[0]);

	nCh				= (int)mxGetScalar(prhs[1]); 
	nPt				= (int)mxGetScalar(prhs[2]); 
	Nx				= (int)mxGetScalar(prhs[3]);
	nWin			= (int)mxGetScalar(prhs[4]);

	// output arguments definition
	mwSize* out_size	= new mwSize[2];
	out_size[0]			= (mwSize)1;
	out_size[1]			= (mwSize)1;
	mwSize out_ndims	= (mwSize)2;
	plhs[0]				= mxCreateNumericArray(out_ndims, out_size, mxINT64_CLASS, mxREAL);
	secrete_length_ptr	= (long long*)mxGetPr(plhs[0]);


	bmGriddingMatrix_secret_length1_mex(	tx_ptr0,
											nCh, 
											nPt, 
											Nx,
											nWin,
											secrete_length_ptr);

	// delete[]
	delete[] out_size;
}



void bmGriddingMatrix_secret_length1_mex(	float* tx_ptr0, 
											int nCh, 
											int nPt, 
											int Nx,
											int nWin,
											long long* secret_length_ptr)
{

	long long secret_length = 0; 
	
	float* tx_run			= tx_ptr0; 

	int						i, j, k; 
	int						ind_x;
	float					tx; 
	float					rx; 
	float					ux;
	float					dx;
	float					cx_float;
	int						cx;
	int						nx;
	

	float		d_square; 
	float		d_square_max = (  ((float)nWin) / 2.0f)*(  ((float)nWin) / 2.0f);
 

	float		fix_shift; 
	int			nWin_half; 
	float		nWin_half_float;


	if ((nWin % 2) > 0)
	{
		fix_shift = 0.5;
		nWin_half = (nWin - 1) / 2;
	}
	else
	{
		fix_shift = 0.0; 
		nWin_half = (nWin / 2) - 1; 
	}
	nWin_half_float = (float)nWin_half; 


	// counting_loop_over_points
	for (i = 0; i < nPt; i++)
	{

		tx = *tx_run++;

		modff(tx + fix_shift, &cx_float);

		rx = tx - cx_float;

		// -1 because indices start at 0 in c++. 
		cx = ((int)cx_float) - 1;

		// mexPrintf("cx is %d \n", cx);
		// mexPrintf("cx_float is %f \n", cx_float);
			


				nx = cx - nWin_half;
				ux = -nWin_half_float;
				for (ind_x = 0; ind_x < nWin; ind_x++)
				{

					if ((nx < 0) || (nx > Nx - 1))
					{
						nx++;
						ux += 1.0;
						continue;
					}

					// computing_squared_distance
					dx = rx - ux;
					d_square = dx*dx;
					// END_computing_squared_distance

					// symmetric_gridding_condition
					if (d_square >= d_square_max)
					{
						nx++;
						ux += 1.0;
						continue; 
					}
					// END_symmetric_gridding_condition




					// if all condition are OK, increment the secrete_length
					secret_length++; 



					nx++;
					ux += 1.0;
				} // END loop_x
	} // END_counting_loop_over_points

	*secret_length_ptr = secret_length; 

} // end function


