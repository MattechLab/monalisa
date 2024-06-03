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

	float* v_ptr0; 
	float* v_imag_ptr0;
	int n_vec_32; 

	// output arguments initial
	float* w_ptr0;
	float* w_imag_ptr0;




	// input arguments definition
	r_size       = (int)mxGetScalar(prhs[0]);
	r_jump_ptr0  = (int*)mxGetPr(prhs[1]);
	r_nJump_ptr0 = (int*)mxGetPr(prhs[2]);

	m_val_ptr0   = (float*)mxGetPr(prhs[3]);

	l_size       = (int)mxGetScalar(prhs[4]);
	l_jump_ptr0  = (int*)mxGetPr(prhs[5]);
	l_nJump      = (int)mxGetScalar(prhs[6]);

	l_jump_flag  = ((int)mxGetScalar(prhs[7]) != 0); 

	v_ptr0       = (float*)mxGetData(prhs[8]);
	v_imag_ptr0  = (float*)mxGetImagData(prhs[8]);
	n_vec_32     = (int)mxGetScalar(prhs[9]);



	// output arguments definition
	mwSize* w_size = new mwSize[2];
	w_size[0] = (mwSize)n_vec_32;
	w_size[1] = (mwSize)l_size;
	mwSize w_ndims = (mwSize)2; 
	plhs[0] = mxCreateNumericArray(w_ndims, w_size, mxSINGLE_CLASS, mxCOMPLEX);
	w_ptr0		= (float*)mxGetData(plhs[0]);
	w_imag_ptr0 = (float*)mxGetImagData(plhs[0]);
	

	
	// function call
	myFunction(r_size, r_jump_ptr0, r_nJump_ptr0, m_val_ptr0, l_size, l_jump_ptr0, l_nJump, v_ptr0, v_imag_ptr0, n_vec_32, w_ptr0, w_imag_ptr0);



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
	int* l_jump_run = l_jump_ptr0;

	int* r_nJump_run = r_nJump_ptr0;
	int  r_nJump_current = 0;

	float* temp_sum_real_ptr0 = new float[n_vec_32];
	float* temp_sum_real_run = temp_sum_real_ptr0;
	float* temp_sum_imag_ptr0 = new float[n_vec_32];
	float* temp_sum_imag_run = temp_sum_imag_ptr0;

	float* m_val_run = m_val_ptr0;
	float  m_val_current = 0;

	float* v_real_ptr1 = v_real_ptr0;
	float* v_real_run = v_real_ptr1;
	float* v_imag_ptr1 = v_imag_ptr0;
	float* v_imag_run = v_imag_ptr1;

	float* w_real_ptr1 = w_real_ptr0;
	float* w_real_run = w_real_ptr1;
	float* w_imag_ptr1 = w_imag_ptr0;
	float* w_imag_run = w_imag_ptr1;



	if (l_jump_ptr0 == 0)
	{
		for (i = 0; i < l_nJump; i++)
		{
			// initial temp_sum to 0
			for (k = 0; k < n_vec_32; k++)
			{
				*temp_sum_real_run++ = 0;
				*temp_sum_imag_run++ = 0;
			}
			temp_sum_real_run = temp_sum_real_ptr0;
			temp_sum_imag_run = temp_sum_imag_ptr0;

			r_nJump_current = *r_nJump_run++;
			for (j = 0; j < r_nJump_current; j++)
			{


				m_val_current = *m_val_run++;
				v_real_ptr1 += ((long long)(*r_jump_run))*n_vec_64;
				v_imag_ptr1 += ((long long)(*r_jump_run++))*n_vec_64;
				v_real_run = v_real_ptr1;
				v_imag_run = v_imag_ptr1;
				for (k = 0; k < n_vec_32; k++)
				{
					*temp_sum_real_run++ += *v_real_run++ * m_val_current;
					*temp_sum_imag_run++ += *v_imag_run++ * m_val_current;
				}
				temp_sum_real_run = temp_sum_real_ptr0;
				temp_sum_imag_run = temp_sum_imag_ptr0;


			}

			// copy temp_sum to w
			for (k = 0; k < n_vec_32; k++)
			{
				*w_real_run++ = *temp_sum_real_run++;
				*w_imag_run++ = *temp_sum_imag_run++;
			}
			temp_sum_real_run = temp_sum_real_ptr0;
			temp_sum_imag_run = temp_sum_imag_ptr0;

		} // end for i
	} // end block if
	else
	{
		long long w_length = ((long long)l_size)*n_vec_64;
		for (long long k_64 = 0; k_64 < w_length; k_64++)
		{
			*w_real_run++ = 0;
			*w_imag_run++ = 0;
		}
		w_real_run = w_real_ptr1;
		w_imag_run = w_imag_ptr1;

		for (i = 0; i < l_nJump; i++)
		{
			// initial temp_sum to 0
			for (k = 0; k < n_vec_32; k++)
			{
				*temp_sum_real_run++ = 0;
				*temp_sum_imag_run++ = 0;
			}
			temp_sum_real_run = temp_sum_real_ptr0;
			temp_sum_imag_run = temp_sum_imag_ptr0;

			r_nJump_current = *r_nJump_run++;
			for (j = 0; j < r_nJump_current; j++)
			{


				m_val_current = *m_val_run++;
				v_real_ptr1 += ((long long)(*r_jump_run))*n_vec_64;
				v_imag_ptr1 += ((long long)(*r_jump_run++))*n_vec_64;
				v_real_run = v_real_ptr1;
				v_imag_run = v_imag_ptr1;
				for (k = 0; k < n_vec_32; k++)
				{
					*temp_sum_real_run++ += *v_real_run++ * m_val_current;
					*temp_sum_imag_run++ += *v_imag_run++ * m_val_current;
				}
				temp_sum_real_run = temp_sum_real_ptr0;
				temp_sum_imag_run = temp_sum_imag_ptr0;


			}

			// copy temp_sum to w
			w_real_ptr1 += ((long long)(*l_jump_run))*n_vec_64;
			w_imag_ptr1 += ((long long)(*l_jump_run++))*n_vec_64;
			w_real_run = w_real_ptr1;
			w_imag_run = w_imag_ptr1;
			for (k = 0; k < n_vec_32; k++)
			{
				*w_real_run++ = *temp_sum_real_run++;
				*w_imag_run++ = *temp_sum_imag_run++;
			}
			temp_sum_real_run = temp_sum_real_ptr0;
			temp_sum_imag_run = temp_sum_imag_ptr0;

		} // end for i 
	} // end block if


	delete[] temp_sum_real_ptr0;
	delete[] temp_sum_imag_ptr0;
} // end function
