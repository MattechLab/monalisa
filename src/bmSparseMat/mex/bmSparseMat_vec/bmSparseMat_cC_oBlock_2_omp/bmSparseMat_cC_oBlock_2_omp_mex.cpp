// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023


#include "mex.h"
#include <omp.h>
#include <cstdio>

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
	v_imag_ptr0  = (float*)mxGetImagData(prhs[8]);
	n_vec_32     = (int)mxGetScalar(prhs[9]);


	// output arguments definition
	mwSize* w_size = new mwSize[2];
	w_size[0] = (mwSize)l_size;
	w_size[1] = (mwSize)n_vec_32;
	mwSize w_ndims = (mwSize)2; 
	plhs[0] = mxCreateNumericArray(w_ndims, w_size, mxSINGLE_CLASS, mxCOMPLEX);
	w_real_ptr0  = (float*)mxGetData(plhs[0]);
	w_imag_ptr0  = (float*)mxGetImagData(plhs[0]);
	

	
	// function call
	myFunction(r_size, r_jump_ptr0, r_nJump_ptr0, m_val_ptr0, l_size, l_jump_ptr0, l_nJump, v_real_ptr0, v_imag_ptr0, n_vec_32, w_real_ptr0, w_imag_ptr0);




	// delete[]
	delete[] w_size; 
}


void myFunction(int r_size_shared, int* r_jump_ptr0_shared, int* r_nJump_ptr0_shared, float* m_val_ptr0_shared, int l_size_shared, int* l_jump_ptr0_shared, int l_nJump_shared, float* v_real_ptr0_shared, float* v_imag_ptr0_shared, int n_vec_32_shared, float* w_real_ptr0_shared, float* w_imag_ptr0_shared)
{
		omp_set_num_threads(2*n_vec_32_shared);
#pragma omp parallel shared(r_size_shared, r_jump_ptr0_shared, r_nJump_ptr0_shared, m_val_ptr0_shared, l_size_shared, l_jump_ptr0_shared, l_nJump_shared, v_real_ptr0_shared, v_imag_ptr0_shared, n_vec_32_shared, w_real_ptr0_shared, w_imag_ptr0_shared)
		{
			// printf("This is thread number %d .\n", omp_get_thread_num()); 

			long long n_vec_64 = (long long)n_vec_32_shared;

			int i = 0;
			int j = 0;
			int k = (int)omp_get_thread_num();
			int l = 0; 

			int l_size = l_size_shared;
			int l_nJump = l_nJump_shared; 

			int* r_jump_ptr0 = r_jump_ptr0_shared; 
			int* r_jump_run = r_jump_ptr0;

			int* r_nJump_ptr0 = r_nJump_ptr0_shared; 
			int* r_nJump_run = r_nJump_ptr0;
			int r_nJump_current = 0;

			float* m_val_ptr0 = m_val_ptr0_shared;
			float* m_val_run = m_val_ptr0;

			int* l_jump_ptr0 = l_jump_ptr0_shared;
			int* l_jump_run = l_jump_ptr0;


			if ((k % 2) == 0) // if real
			{
				k = (int)(k / 2); 

				float* v_real_ptr0 = v_real_ptr0_shared + ((long long)r_size_shared)*((long long)k);
				float* v_real_run = v_real_ptr0;
				float* w_real_ptr0 = w_real_ptr0_shared + ((long long)l_size_shared)*((long long)k);
				float* w_real_run = w_real_ptr0;

				for (l = 0; l < l_size; l++)
				{
					*w_real_run++ = 0;
				}
				w_real_run = w_real_ptr0;

				if (l_jump_ptr0_shared == 0) // if not_l_sparsity
				{
					for (i = 0; i < l_nJump; i++)
					{
						r_nJump_current = *r_nJump_run++;
						for (j = 0; j < r_nJump_current; j++)
						{
							v_real_run += *r_jump_run++;
							*w_real_run += (*m_val_run++)*(*v_real_run);
						}// end for j
						w_real_run++;
					} // end for i
				} // end if not_l_sparsity
				else // l_sparsity
				{
					for (i = 0; i < l_nJump; i++)
					{
						r_nJump_current = *r_nJump_run++;
						w_real_run += *l_jump_run++;
						for (j = 0; j < r_nJump_current; j++)
						{
							v_real_run += *r_jump_run++;
							*w_real_run += (*m_val_run++)*(*v_real_run);
						}// end for j
					} // end for i
				} // end if not_l_sparsity
			} // end if real
			else // if complex
			{
				k = (int)((k-1) / 2);

				float* v_imag_ptr0 = v_imag_ptr0_shared + ((long long)r_size_shared)*((long long)k);
				float* v_imag_run = v_imag_ptr0;
				float* w_imag_ptr0 = w_imag_ptr0_shared + ((long long)l_size_shared)*((long long)k);
				float* w_imag_run = w_imag_ptr0;

				for (l = 0; l < l_size; l++)
				{
					*w_imag_run++ = 0;
				}
				w_imag_run = w_imag_ptr0;

				if (l_jump_ptr0_shared == 0) // if not_l_sparsity
				{
					for (i = 0; i < l_nJump; i++)
					{
						r_nJump_current = *r_nJump_run++;
						for (j = 0; j < r_nJump_current; j++)
						{
							v_imag_run  += *r_jump_run++;
							*w_imag_run += (*m_val_run++)*(*v_imag_run);
						}// end for j
						w_imag_run++;
					} // end for i
				} // end if not l_sparsity
				else // l_sparsity
				{
					for (i = 0; i < l_nJump; i++)
					{
						r_nJump_current = *r_nJump_run++;
						w_imag_run += *l_jump_run++;
						for (j = 0; j < r_nJump_current; j++)
						{
							v_imag_run += *r_jump_run++;
							*w_imag_run += (*m_val_run++)*(*v_imag_run);
						}// end for j
					} // end for i
				} // end if l_sparsity
			} // end if complex
		} // end thread
} // end function


