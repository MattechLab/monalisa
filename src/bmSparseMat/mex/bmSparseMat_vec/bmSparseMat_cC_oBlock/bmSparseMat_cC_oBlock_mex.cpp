// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023


#include "mex.h"

void myFunction(int r_size, int* r_jump_ptr0, int* r_nJump_ptr0, float* m_val_ptr0, int l_size, int* l_jump_ptr0, int l_nJump, float* v_real_ptr0, float* v_imag_ptr0, int n_vec_32, float* w_real_ptr0, float* w_imag_ptr0);


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
	v_imag_ptr0	 = (float*)mxGetData(prhs[9]);
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
	myFunction(r_size, r_jump_ptr0, r_nJump_ptr0, m_val_ptr0, l_size, l_jump_ptr0, l_nJump, v_real_ptr0, v_imag_ptr0, n_vec_32, w_real_ptr0, w_imag_ptr0);




	// delete[]
	delete[] w_size; 
}


void myFunction(int r_size, int* r_jump_ptr0, int* r_nJump_ptr0, float* m_val_ptr0, int l_size, int* l_jump_ptr0, int l_nJump, float* v_real_ptr0, float* v_imag_ptr0, int n_vec_32, float* w_real_ptr0, float* w_imag_ptr0)
{

	long long n_vec_64 = (long long)n_vec_32; 

	int i = 0;
	int j = 0;
	int k = 0;

	int* r_jump_run = r_jump_ptr0;

	int* r_nJump_run = r_nJump_ptr0;
	int r_nJump_current = 0; 

	float* m_val_run = m_val_ptr0;

	int* l_jump_run = l_jump_ptr0;


	float* v_real_run = v_real_ptr0;
	float* v_imag_run = v_imag_ptr0;
	float* w_real_run = w_real_ptr0;
	float* w_imag_run = w_imag_ptr0;
	

	long long w_length = ((long long)l_size)*n_vec_64;
	for (long long k_64 = 0; k_64 < w_length; k_64++)
	{
		*w_real_run++ = 0;
		*w_imag_run++ = 0;
	}
	w_real_run = w_real_ptr0;
	w_imag_run = w_imag_ptr0;



	if (l_jump_ptr0 == 0)
	{



		for (k = 0; k < n_vec_32; k++)
		{
			
			v_real_run = v_real_ptr0 + ((long long)r_size)*((long long)k);
			v_imag_run = v_imag_ptr0 + ((long long)r_size)*((long long)k);
			w_real_run = w_real_ptr0 + ((long long)l_size)*((long long)k);
			w_imag_run = w_imag_ptr0 + ((long long)l_size)*((long long)k);
			
			r_jump_run = r_jump_ptr0;
			r_nJump_run = r_nJump_ptr0;
			l_jump_run = l_jump_ptr0;
			m_val_run = m_val_ptr0; 

			for (i = 0; i < l_nJump; i++)
			{
				r_nJump_current = *r_nJump_run++; 
				for (j = 0; j < r_nJump_current; j++)
				{
					v_real_run  += *r_jump_run;
					v_imag_run  += *r_jump_run++;
					*w_real_run += (*m_val_run)*(*v_real_run);
					*w_imag_run += (*m_val_run++)*(*v_imag_run);
				}// end for j
				w_real_run++; 
				w_imag_run++;
			} // end for i
		} // end for k




	} // end block if
	else // l_sparsity
	{

		

		for (k = 0; k < n_vec_32; k++)
		{
			v_real_run = v_real_ptr0 + ((long long)r_size)*((long long)k);
			v_imag_run = v_imag_ptr0 + ((long long)r_size)*((long long)k);
			w_real_run = w_real_ptr0 + ((long long)l_size)*((long long)k);
			w_imag_run = w_imag_ptr0 + ((long long)l_size)*((long long)k);

			r_jump_run  = r_jump_ptr0;
			r_nJump_run = r_nJump_ptr0; 
			l_jump_run  = l_jump_ptr0; 
			m_val_run = m_val_ptr0;

			for (i = 0; i < l_nJump; i++)
			{
				r_nJump_current = *r_nJump_run++;
				w_real_run += *l_jump_run;
				w_imag_run += *l_jump_run++;
				for (j = 0; j < r_nJump_current; j++)
				{
					v_real_run += *r_jump_run;
					v_imag_run += *r_jump_run++;
					*w_real_run += (*m_val_run)*(*v_real_run);
					*w_imag_run += (*m_val_run++)*(*v_imag_run);
				}// end for j
			} // end for i
		} // end for k




	} // end block if


} // end function


