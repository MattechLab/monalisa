// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

// I thank
//
// Gabriele Bonanno
//
// for the help he brought about gridders at the
// early stage of developpment of the
// reconstruction code.


#include <iostream>
#include <cmath>
#include <cstdio>
#include "mex.h"


void bmGridder_n2u_leight3_mex(	float* aReal_ptr0, 
								float* aImag_ptr0, 
								float* bReal_ptr0, 
								float* bImag_ptr0, 
								float* tx_ptr0, 
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

    float* aReal_ptr0;
	float* aImag_ptr0;
	float* bReal_ptr0;
	float* bImag_ptr0;

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

	aReal_ptr0		= (float*)mxGetPr(prhs[0]); 
	aImag_ptr0		= (float*)mxGetPr(prhs[1]); 

	tx_ptr0			= (float*)mxGetPr(prhs[2]);
	ty_ptr0			= (float*)mxGetPr(prhs[3]);
	tz_ptr0			= (float*)mxGetPr(prhs[4]);

	Dn_ptr0			= (float*)mxGetPr(prhs[5]); 

	nCh				= (int)mxGetScalar(prhs[6]); 
	nPt				= (int)mxGetScalar(prhs[7]); 
	Nx				= (int)mxGetScalar(prhs[8]);
	Ny				= (int)mxGetScalar(prhs[9]);
	Nz				= (int)mxGetScalar(prhs[10]);

	nWin			= (int)mxGetScalar(prhs[11]);
	kernelParam_1	= (float)mxGetScalar(prhs[12]);
	kernelParam_2	= (float)mxGetScalar(prhs[13]);

	int Nu_tot = Nx*Ny*Nz;

	// output arguments definition
	mwSize* b_size = new mwSize[2];
	b_size[0] = (mwSize)nCh;
	b_size[1] = (mwSize)Nu_tot;
	mwSize b_ndims = (mwSize)2;
	plhs[0] = mxCreateNumericArray(b_ndims, b_size, mxSINGLE_CLASS, mxREAL);
	plhs[1] = mxCreateNumericArray(b_ndims, b_size, mxSINGLE_CLASS, mxREAL);
	bReal_ptr0 = (float*)mxGetPr(plhs[0]);
	bImag_ptr0 = (float*)mxGetPr(plhs[1]);


	bmGridder_n2u_leight3_mex(	aReal_ptr0, 
								aImag_ptr0, 
								bReal_ptr0, 
								bImag_ptr0, 
								tx_ptr0, 
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



void bmGridder_n2u_leight3_mex(	float* aReal_ptr0, 
								float* aImag_ptr0, 
								float* bReal_ptr0, 
								float* bImag_ptr0, 
								float* tx_ptr0, 
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

	float* aReal_ptr1		= aReal_ptr0;
	float* aReal_run		= aReal_ptr0;

	float* aImag_ptr1		= aImag_ptr0;
	float* aImag_run		= aImag_ptr0;

	float* bReal_ptr1		= bReal_ptr0;
	float* bReal_run		= bReal_ptr0;

	float* bImag_ptr1		= bImag_ptr0;
	float* bImag_run		= bImag_ptr0;

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

	float		t_shift; 
	int			nWin_half; 
	float		nWin_half_float;


	if ((nWin % 2) > 0)
	{
		t_shift = 0.5;
		nWin_half = (nWin - 1) / 2;
	}
	else
	{
		t_shift = 0.0; 
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
	// END_initial -----------------------------------------------


	for (i = 0; i < nPt; i++)
	{

		
		tx = *tx_run++; 
		ty = *ty_run++;
		tz = *tz_run++;

		modff(tx + t_shift, &cx_float);
		modff(ty + t_shift, &cy_float);
		modff(tz + t_shift, &cz_float);

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
					w				= g1*expf(g2*d_square)*Dn; // Gauss gridding-kernel times volume-element. 

					// setting pointers on starting cartesian position. 
					nx_64			= (long long)nx; 
					ny_64			= (long long)ny;
					nz_64			= (long long)nz;
					normalize_run	= normalize_ptr0	+ (nx_64		+ ny_64*Nx_64		+ nz_64*Nx_Ny_64); 
					bReal_ptr1		= bReal_ptr0		+ (nx_64*nCh_64 + ny_64*Nx_nCh_64	+ nz_64*Nx_Ny_nCh_64);
					bReal_run		= bReal_ptr1; 
					bImag_ptr1		= bImag_ptr0		+ (nx_64*nCh_64 + ny_64*Nx_nCh_64	+ nz_64*Nx_Ny_nCh_64);
					bImag_run		= bImag_ptr1;

					aReal_run		= aReal_ptr1; 
					aImag_run		= aImag_ptr1;

					// incrementing normalization factor and output data over all channels. 
					*normalize_run += w;
					for (ind_ch = 0; ind_ch < nCh; ind_ch++)
					{
						*bReal_run++ += w*(*aReal_run++);
						*bImag_run++ += w*(*aImag_run++);
					}


					nx++; 
					ux += 1.0; 
				} // END loop_x
				ny++; 
				uy += 1.0; 
			} // END loop_y
			nz++; 
			uz += 1.0; 
		} // END loop_z

		aReal_ptr1 += nCh_64; 
		aImag_ptr1 += nCh_64;

	} // END loop_points
	



	// normalization ------------------------------------------
	bReal_run		= bReal_ptr0;
	bImag_run		= bImag_ptr0;
	normalize_run	= normalize_ptr0;

	for (i = 0; i < Nu_tot; i++)
	{
		mynormalize_val = *normalize_run++;
		if (mynormalize_val < 1e-5)
		{
			mynormalize_val = 1.0;
		}

		for (k = 0; k < nCh; k++)
		{
			*bReal_run++ /= mynormalize_val;
			*bImag_run++ /= mynormalize_val;
		}
	}
	// END_normalization --------------------------------------



	delete[] normalize_ptr0;

} // end function
