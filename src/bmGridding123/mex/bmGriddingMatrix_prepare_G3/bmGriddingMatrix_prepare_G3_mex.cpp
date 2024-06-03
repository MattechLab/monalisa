// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include <iostream>
#include <cmath>
#include <cstdio>
#include "mex.h"


void bmGriddingMatrix_prepare_G3_mex(	float* tx_ptr0, 
										float* ty_ptr0, 
										float* tz_ptr0, 
										float* Dn_ptr0, 
										int nCh, 
										int nPt, 
										int Nx,
										int Ny,
										int Nz,
										int nWin, 
										float kernelParam_1, 
										float kernelParam_2);

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

	float* tx_ptr0; 
	float* ty_ptr0;
	float* tz_ptr0;

	float* Dn_ptr0; 

	int nCh; 
	int nPt; 
	int Nx, Ny, Nz; 

	int nWin; 
	float kernelParam_1; 
	float kernelParam_2;

	tx_ptr0			= (float*)mxGetPr(prhs[0]);
	ty_ptr0			= (float*)mxGetPr(prhs[1]);
	tz_ptr0			= (float*)mxGetPr(prhs[2]);

	Dn_ptr0			= (float*)mxGetPr(prhs[3]); 

	nCh				= (int)mxGetScalar(prhs[4]); 
	nPt				= (int)mxGetScalar(prhs[5]); 
	Nx				= (int)mxGetScalar(prhs[6]);
	Ny				= (int)mxGetScalar(prhs[7]);
	Nz				= (int)mxGetScalar(prhs[8]);
	secrete_length	= (int)mxGetScalar(prhs[9]);
	nWin			= (int)mxGetScalar(prhs[10]);

	int Nu_tot		= Nx*Ny*Nz;

	// output arguments definition
	mwSize* w_size	= new mwSize[2];
	w_size[0]		= (mwSize)nCh;
	w_size[1]		= (mwSize)1;
	mwSize w_ndims	= (mwSize)2;
	plhs[0]			= mxCreateNumericArray(w_ndims, w_size, mxSINGLE_CLASS, mxREAL);
	bReal_ptr0		= (float*)mxGetPr(plhs[0]);


	mwSize* pillar_jump_size	= new mwSize[2];
	pillar_jump_size[0]			= (mwSize)secrete_length;
	pillar_jump_size[1]			= (mwSize)1;
	mwSize pillar_jump_ndims	= (mwSize)2;
	plhs[1]						= mxCreateNumericArray(pillar_jump_ndims, pillar_jump_size, mxSINGLE_CLASS, mxREAL);
	pillar_jump_ptr0			= (float*)mxGetPr(plhs[1]);

	



	bmGriddingMatrix_prepare_G3_mex(tx_ptr0, 
									ty_ptr0, 
									tz_ptr0, 
									Dn_ptr0, 
									nCh, 
									nPt, 
									Nx,
									Ny,
									Nz,
									nWin,
									kernelParam_1,
									kernelParam_2);

	// delete[]
	delete[] b_size;
}



void bmGriddingMatrix_prepare_G3_mex(	float* tx_ptr0, 
										float* ty_ptr0, 
										float* tz_ptr0, 
										float* Dn_ptr0, 
										int nCh, 
										int nPt, 
										int Nx,
										int Ny,
										int Nz,
										int nWin, 
										float kernelParam_1, 
										float kernelParam_2)
{


	float* Dn_run = Dn_ptr0; 

	int Nu_tot				= Nx*Ny*Nz;

	float* normalize_ptr0	= new float[Nu_tot];
	float* normalize_run	= normalize_ptr0; 
	
	float* tx_run			= tx_ptr0; 
	float* ty_run			= ty_ptr0;
	float* tz_run			= tz_ptr0;

	int			ind_x, ind_y, ind_z;
	float		tx, ty, tz; 
	float		rx, ry, rz; 
	float		ux, uy, uz;
	float		dx, dy, dz;
	float		cx_float, cy_float, cz_float;
	int			cx, cy, cz;
	int			nx, ny, nz;
	long long	nx_64, ny_64, nz_64;
	int			secrete_length; 

	
	long long b_length_64	= ((long long)nCh)*((long long)Nu_tot);
	long long l_64			= ((long long)0);
	long long nCh_64		= ((long long)nCh); 
	long long Nx_64			= ((long long)Nx);
	long long Nx_Ny_64		= ((long long)Nx)*((long long)Ny);
	long long Nx_nCh_64		= ((long long)Nx)*((long long)nCh); 
	long long Nx_Ny_nCh_64	= ((long long)Nx)*((long long)Ny)*((long long)nCh);
	

	float		mynormalize_val;

	int			i, j, k; 
	int			ind_ch; 
	float		d_square; 
	float		d_square_max = (((float)nWin) / 2.0)*(((float)nWin) / 2.0);
 

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


	float mySigma			= kernelParam_1; 
	float mySigma_square	= mySigma*mySigma; 
	float g1				=  1 / ((float)sqrt(2 * 3.141592) * mySigma);
	float g2				= -1 / (2*mySigma_square); 
	float Dn				= 0; 
	float w					= 0; 

	// initial ---------------------------------------------------
	for (l_64 = 0; l_64 < b_length_64; l_64++)
	{
		*bReal_run++ = 0.0;
		*bImag_run++ = 0.0;
	}
	bReal_run = bReal_ptr0;
	bImag_run = bImag_ptr0;

	for (i = 0; i < Nu_tot; i++)
	{
		*normalize_run++ = 0.0;
	}
	normalize_run = normalize_ptr0;

	secrete_length = 0;
	// END_initial -----------------------------------------------


	// counting_loop
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

					// computing the weight (including volume-element). 
					dx = rx - ux;
					dy = ry - uy;
					dz = rz - uz;
					d_square = dx*dx + dy*dy + dz*dz;

					if (d_square >= d_square_max)
					{
						nx++;
						ux += 1.0;
						continue; 
					}

					secrete_length++; 



					nx++;
					ux += 1.0;
				} // END loop_x
				ny++;
				uy += 1.0;
			} // END loop_y
			nz++;
			uz += 1.0;
		} // END loop_z

	} // END_counting_loop



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
		cx = ((int)cx_float)-1; 
		cy = ((int)cy_float)-1;
		cz = ((int)cz_float)-1; 

		// mexPrintf("cx is %d \n", cx);
		// mexPrintf("cx_float is %f \n", cx_float);

		Dn			= *Dn_run++; 

		nz = cz-nWin_half; 
		uz = -nWin_half_float; 
		for (ind_z = 0; ind_z < nWin; ind_z++)
		{
			if ((nz < 0) || (nz > Nz-1))
			{
				nz++; 
				uz += 1.0; 
				continue; 
			}

			ny = cy-nWin_half;
			uy = -nWin_half_float; 
			for (ind_y = 0; ind_y < nWin; ind_y++)
			{
				if ((ny < 0) || (ny > Ny-1))
				{
					ny++;
					uy += 1.0; 
					continue;
				}

				nx = cx-nWin_half;
				ux = -nWin_half_float; 
				for (ind_x = 0; ind_x < nWin; ind_x++)
				{

					if ((nx < 0) || (nx > Nx-1))
					{
						nx++;
						ux += 1.0; 
						continue;
					}

					// computing the weight (including volume-element). 
					dx				= rx - ux; 
					dy				= ry - uy;
					dz				= rz - uz;
					d_square		= dx*dx + dy*dy + dz*dz; 

					if (d_square >= d_square_max)
					{
						nx++;
						ux += 1.0;
						continue;
					}

					
					*w++			= g1*expf(g2*d_square)*Dn; // Gauss gridding-kernel times volume-element. 

					// setting pointers on starting cartesian position. 
					nx_64			= (long long)nx; 
					ny_64			= (long long)ny;
					nz_64			= (long long)nz;

					*pillar_ind		= (nx_64 + ny_64*Nx_64 + nz_64*Nx_Ny_64); 

					normalize_run	= normalize_ptr0 + pillar_ind;
					bReal_ptr1		= bReal_ptr0 + pillar_ind*nCh_64;
					bReal_run		= bReal_ptr1; 
					bImag_ptr1		= bImag_ptr0 + pillar_ind*nCh_64;
					bImag_run		= bImag_ptr1;

					pillar_ind++; 

					// aReal_run		= aReal_ptr1; 
					// aImag_run		= aImag_ptr1;

					// incrementing normalization factor and output data over all channels. 
					// *normalize_run += w;
					// for (ind_ch = 0; ind_ch < nCh; ind_ch++)
					// {
					//	*bReal_run++ += w*(*aReal_run++);
					//	*bImag_run++ += w*(*aImag_run++);
					// }


					nx++; 
					ux += 1.0; 
				} // END loop_x
				ny++; 
				uy += 1.0; 
			} // END loop_y
			nz++; 
			uz += 1.0; 
		} // END loop_z

		// aReal_ptr1 += nCh_64; 
		// aImag_ptr1 += nCh_64;

	} // END loop_points
	



	// delete[] normalize_ptr0;

} // end function
