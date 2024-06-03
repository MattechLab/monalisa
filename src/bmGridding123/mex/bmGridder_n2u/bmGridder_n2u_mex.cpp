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
#include <cstdio>
#include "mex.h"


void bmGridder_n2u_mex(float* aReal_ptr0, float* aImag_ptr0, float*bReal_ptr0, float*bImag_ptr0, float* w_ptr0, int* nJump_ptr0, int nNb, int nCh, int nPt, int Nu_tot);

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

    float* aReal_ptr0;
	float* aImag_ptr0;
	float* bReal_ptr0;
	float* bImag_ptr0;
	
	float* w_ptr0;
	int* nJump_ptr0; 

	int nCh; 
	int nNb;
	int nPt; 
	int Nu_tot; 



	aReal_ptr0	= (float*)mxGetPr(prhs[0]);
	aImag_ptr0  = (float*)mxGetPr(prhs[1]);

	w_ptr0		= (float*)mxGetPr(prhs[2]);
	nJump_ptr0	= (int*)mxGetPr(prhs[3]);

	nCh		= (int)mxGetScalar(prhs[4]);
	nNb     = (int)mxGetScalar(prhs[5]);
	nPt		= (int)mxGetScalar(prhs[6]);
	Nu_tot  = (int)mxGetScalar(prhs[7]);


	// output arguments definition
	mwSize* b_size = new mwSize[2];
	b_size[0] = (mwSize)nCh;
	b_size[1] = (mwSize)Nu_tot;
	mwSize b_ndims = (mwSize)2;
	plhs[0] = mxCreateNumericArray(b_ndims, b_size, mxSINGLE_CLASS, mxREAL);
	plhs[1] = mxCreateNumericArray(b_ndims, b_size, mxSINGLE_CLASS, mxREAL);
	bReal_ptr0 = (float*)mxGetPr(plhs[0]);
	bImag_ptr0 = (float*)mxGetPr(plhs[1]);


	bmGridder_n2u_mex(aReal_ptr0, aImag_ptr0, bReal_ptr0, bImag_ptr0, w_ptr0, nJump_ptr0, nNb, nCh, nPt, Nu_tot);

	// delete[]
	delete[] b_size;
}



void bmGridder_n2u_mex(float* aReal_ptr0, float* aImag_ptr0, float*bReal_ptr0, float*bImag_ptr0, float* w_ptr0, int* nJump_ptr0, int nNb, int nCh, int nPt, int Nu_tot)
{

	


	float* aReal_ptr1 = aReal_ptr0;
	float* aImag_ptr1 = aImag_ptr0;
	float* aReal_run  = aReal_ptr0;
	float* aImag_run  = aImag_ptr0;

	float* bReal_ptr1 = bReal_ptr0;
	float* bImag_ptr1 = bImag_ptr0;
	float* bReal_run  = bReal_ptr0;
	float* bImag_run  = bImag_ptr0;

	float* normalize_ptr0 = new float[Nu_tot];
	float* normalize_run  = normalize_ptr0; 
	
	float* w_run = w_ptr0; 
	int* nJump_run = nJump_ptr0; 

	long long nCh_64 = (long long)nCh;
	long long Nu_tot_64 = (long long)Nu_tot;

	long long b_length = nCh_64*Nu_tot_64;
	long long l = 0; 

	float aReal_val;
	float aImag_val;

	float myWeight; 
	float mynormalize_val;

	int myJump; 
	long long myJump_nCh; 

	int i; 
	int j; 
	int k; 


	for (l = 0; l < b_length; l++)
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

	
	
	
	for (i = 0; i < nPt; i++)
	{
		for (j = 0; j < nNb; j++)
		{
			myWeight = *w_run++; 
			myJump   = *nJump_run++;
			myJump_nCh = ((long long)myJump)*nCh_64;

			normalize_run  += myJump;
			bReal_ptr1 += myJump_nCh; 
			bImag_ptr1 += myJump_nCh;

			aReal_run = aReal_ptr1;
			aImag_run = aImag_ptr1;

			bReal_run = bReal_ptr1;
			bImag_run = bImag_ptr1;
			



			*normalize_run += myWeight; 
			for (k = 0; k < nCh; k++)
			{
				*bReal_run++ += myWeight*(*aReal_run++);
				*bImag_run++ += myWeight*(*aImag_run++);
			} // end channel

			

		}// end neighboors

		aReal_ptr1 += nCh; 
		aImag_ptr1 += nCh;

	}// end points




	bReal_run = bReal_ptr0;
	bImag_run = bImag_ptr0;
	normalize_run = normalize_ptr0; 

	
	

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

	


	delete[] normalize_ptr0; 

	


} // end function
