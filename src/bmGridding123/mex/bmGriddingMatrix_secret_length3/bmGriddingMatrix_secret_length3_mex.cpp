// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include <iostream>
#include <cmath>
#include <cstdio>
#include "mex.h"

void bmGriddingMatrix_secret_length3_mex(float* tx_ptr0,
										 float* ty_ptr0, 
										 float* tz_ptr0, 
										 int nCh, 
										 int nPt, 
										 int Nx,
										 int Ny,
										 int Nz,
										 int nWin, 
										 long long* secrete_length_ptr);


/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

	float* tx_ptr0; 
	float* ty_ptr0;
	float* tz_ptr0;

	int nCh; 
	int nPt; 
	int Nx, Ny, Nz; 

	int nWin; 

	long long* secrete_length_ptr; 

	tx_ptr0			= (float*)mxGetPr(prhs[0]);
	ty_ptr0			= (float*)mxGetPr(prhs[1]);
	tz_ptr0			= (float*)mxGetPr(prhs[2]);

	nCh				= (int)mxGetScalar(prhs[3]); 
	nPt				= (int)mxGetScalar(prhs[4]); 
	Nx				= (int)mxGetScalar(prhs[5]);
	Ny				= (int)mxGetScalar(prhs[6]);
	Nz				= (int)mxGetScalar(prhs[7]);
	nWin			= (int)mxGetScalar(prhs[8]);

	// output arguments definition
	mwSize* out_size	= new mwSize[2];
	out_size[0]			= (mwSize)1;
	out_size[1]			= (mwSize)1;
	mwSize out_ndims	= (mwSize)2;
	plhs[0]				= mxCreateNumericArray(out_ndims, out_size, mxINT64_CLASS, mxREAL);
	secrete_length_ptr	= (long long*)mxGetPr(plhs[0]);


	bmGriddingMatrix_secret_length3_mex(	tx_ptr0,
											ty_ptr0, 
											tz_ptr0, 
											nCh, 
											nPt, 
											Nx,
											Ny,
											Nz,
											nWin,
											secrete_length_ptr);

	// delete[]
	delete[] out_size;
}



void bmGriddingMatrix_secret_length3_mex(	float* tx_ptr0,
											float* ty_ptr0, 
											float* tz_ptr0, 
											int nCh, 
											int nPt, 
											int Nx,
											int Ny,
											int Nz,
											int nWin,
											long long* secret_length_ptr)
{

	long long secret_length = 0; 
	
	float* tx_run			= tx_ptr0; 
	float* ty_run			= ty_ptr0;
	float* tz_run			= tz_ptr0;

	int						i, j, k; 
	int						ind_x, ind_y, ind_z;
	float					tx, ty, tz; 
	float					rx, ry, rz; 
	float					ux, uy, uz;
	float					dx, dy, dz;
	float					cx_float, cy_float, cz_float;
	int						cx, cy, cz;
	int						nx, ny, nz;
	

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
		ty = *ty_run++;
		tz = *tz_run++;

		modff(tx + fix_shift, &cx_float);
		modff(ty + fix_shift, &cy_float);
		modff(tz + fix_shift, &cz_float);

		rx = tx - cx_float;
		ry = ty - cy_float;
		rz = tz - cz_float;

		// -1 because indices start at 0 in c++. 
		cx = ((int)cx_float) - 1;
		cy = ((int)cy_float) - 1;
		cz = ((int)cz_float) - 1;

		// mexPrintf("cx is %d \n", cx);
		// mexPrintf("cx_float is %f \n", cx_float);


		nz = cz - nWin_half;
		uz = -nWin_half_float;
		for (ind_z = 0; ind_z < nWin; ind_z++)
		{
			if ((nz < 0) || (nz > Nz - 1))
			{
				nz++;
				uz += 1.0;
				continue;
			}

			ny = cy - nWin_half;
			uy = -nWin_half_float;
			for (ind_y = 0; ind_y < nWin; ind_y++)
			{
				if ((ny < 0) || (ny > Ny - 1))
				{
					ny++;
					uy += 1.0;
					continue;
				}

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
					dy = ry - uy;
					dz = rz - uz;
					d_square = dx*dx + dy*dy + dz*dz;
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
				ny++;
				uy += 1.0;
			} // END loop_y
			nz++;
			uz += 1.0;
		} // END loop_z

	} // END_counting_loop_over_points

	*secret_length_ptr = secret_length; 

} // end function


