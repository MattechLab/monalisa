// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023


#include <omp.h>
#include <cstdio>
#include "mex.h"
#include "bmSparseMat_cC_oBlock_omp.h"


/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{


	// input arguments initial    
	int  r_size; 
	int* r_jump_ptr0; 
    int* r_nJump_ptr0; 
    
	float* m_val_ptr0;

	int  l_size; 
	int* l_jump_ptr0; 
	int  l_nJump; 

	bool l_jump_flag = false; 

	float* v_real_ptr0; 
	float* v_imag_ptr0; 
	int n_vec_32; 

	// output arguments initial
	float* w_real_ptr0;
	float* w_imag_ptr0;




	// input arguments definition
	r_size       = (int)mxGetScalar(prhs[0]);
	r_jump_ptr0  = (int*)mxGetData(prhs[1]);
	r_nJump_ptr0 = (int*)mxGetData(prhs[2]);

	m_val_ptr0   = (float*)mxGetData(prhs[3]);

	l_size       = (int)mxGetScalar(prhs[4]);
	l_jump_ptr0  = (int*)mxGetData(prhs[5]);
	l_nJump      = (int)mxGetScalar(prhs[6]);

	l_jump_flag  = ((int)mxGetScalar(prhs[7]) != 0); 

	v_real_ptr0	 = (float*)mxGetData(prhs[8]);
	v_imag_ptr0  = (float*)mxGetData(prhs[9]);
	n_vec_32     = (int)mxGetScalar(prhs[10]);


	// output arguments definition
	mwSize* w_size = new mwSize[2];
	w_size[0] = (mwSize)l_size;
	w_size[1] = (mwSize)n_vec_32;
	mwSize w_ndims = (mwSize)2; 
	plhs[0] = mxCreateNumericArray(w_ndims, w_size, mxSINGLE_CLASS, mxREAL);
	plhs[1] = mxCreateNumericArray(w_ndims, w_size, mxSINGLE_CLASS, mxREAL);
	w_real_ptr0  = (float*)mxGetData(plhs[0]);
	w_imag_ptr0  = (float*)mxGetData(plhs[1]);
	

	
	// function call
	bmSparseMat_cC_oBlock_omp(	r_size,
								r_jump_ptr0,
								r_nJump_ptr0,
								m_val_ptr0,
								l_size,
								l_jump_ptr0,
								l_nJump,
								v_real_ptr0,
								v_imag_ptr0,
								n_vec_32,
								w_real_ptr0,
								w_imag_ptr0);



	// delete[]
	delete[] w_size; 
}

