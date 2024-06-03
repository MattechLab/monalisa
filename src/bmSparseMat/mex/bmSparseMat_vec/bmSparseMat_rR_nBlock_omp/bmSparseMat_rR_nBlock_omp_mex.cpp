// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023


#include "mex.h"
#include <omp.h>
#include <cmath>
#include <cstdio>

void myFunction(int r_size, int* r_jump_ptr0_shared, int* r_nJump_ptr0_shared,
	float* m_val_ptr0_shared,
	int l_size, int* l_jump_ptr0_shared, int l_nJump,
	int nBlock, int* block_length_ptr0_shared, int* l_block_start_ptr0_shared, long long* m_block_start_ptr0_shared,
	float* v_ptr0_shared, int n_vec_32, float* w_ptr0_shared); 


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

	int nBlock; 
	int* block_length_ptr0;  
	int* l_block_start_ptr0; 
	long long* m_block_start_ptr0; 

	float* v_ptr0;
	int n_vec_32; 

	// output arguments initial
	float* w_ptr0;




	// input arguments definition
	r_size = (int)mxGetScalar(prhs[0]);
	r_jump_ptr0 = (int*)mxGetPr(prhs[1]);
	r_nJump_ptr0 = (int*)mxGetPr(prhs[2]);

	m_val_ptr0 = (float*)mxGetPr(prhs[3]);

	l_size = (int)mxGetScalar(prhs[4]);
	l_jump_ptr0 = (int*)mxGetPr(prhs[5]);
	l_nJump = (int)mxGetScalar(prhs[6]);

	l_jump_flag = ((int)mxGetScalar(prhs[7]) != 0);

	nBlock = (int)mxGetScalar(prhs[8]);
	block_length_ptr0 = (int*)mxGetPr(prhs[9]);
	l_block_start_ptr0 = (int*)mxGetPr(prhs[10]);
	m_block_start_ptr0 = (long long*)mxGetPr(prhs[11]);


	v_ptr0 = (float*)mxGetPr(prhs[12]);
	n_vec_32 = (int)mxGetScalar(prhs[13]);


	// output arguments definition
	mwSize* w_size = new mwSize[2];
	w_size[0] = (mwSize)n_vec_32;
	w_size[1] = (mwSize)l_size;
	mwSize w_ndims = (mwSize)2;


	plhs[0] = mxCreateNumericArray(w_ndims, w_size, mxSINGLE_CLASS, mxREAL);
	w_ptr0 = (float*)mxGetPr(plhs[0]);



	// function call
	myFunction(r_size, r_jump_ptr0, r_nJump_ptr0, m_val_ptr0, l_size, l_jump_ptr0, l_nJump, nBlock, block_length_ptr0, l_block_start_ptr0, m_block_start_ptr0, v_ptr0, n_vec_32, w_ptr0); 


	// delete[]
	delete[] w_size;
}




void myFunction(int r_size, int* r_jump_ptr0_shared, int* r_nJump_ptr0_shared,
	float* m_val_ptr0_shared,
	int l_size, int* l_jump_ptr0_shared, int l_nJump,
	int nBlock, int* block_length_ptr0_shared, int* l_block_start_ptr0_shared, long long* m_block_start_ptr0_shared,
	float* v_ptr0_shared, int n_vec_32, float* w_ptr0_shared)
{


	if (l_jump_ptr0_shared == 0)
	{
		int numOfThread = omp_get_num_procs();
		omp_set_num_threads(numOfThread);
#pragma omp parallel shared(r_size, r_jump_ptr0_shared, r_nJump_ptr0_shared, m_val_ptr0_shared, l_size, l_jump_ptr0_shared, l_nJump, nBlock, block_length_ptr0_shared, l_block_start_ptr0_shared, m_block_start_ptr0_shared, v_ptr0_shared, n_vec_32, w_ptr0_shared)
		{

			// printf("This is thread number %d .\n", omp_get_thread_num()); 

			long long n_vec_64 = (long long)n_vec_32; 

			int i = 0;
			int j = 0;
			int k = 0;
			int l = 0; 

			float* temp_sum_ptr0 = new float[n_vec_32];
			float* temp_sum_run = temp_sum_ptr0;


			// thread personal copy of l_block_start and m_block_start and block_length
			int* l_block_start_ptr0 = new int[nBlock]; 
			long long* m_block_start_ptr0 = new long long[nBlock];
			int* block_length_ptr0  = new int[nBlock];
			
			int* copy_ptr_run_1 = l_block_start_ptr0;
			int* copy_ptr_run_2 = l_block_start_ptr0_shared;
			for (l = 0; l < nBlock; l++)
			{
				*copy_ptr_run_1++ = *copy_ptr_run_2++;
			}
			
			long long* copy_ptr_64_run_1 = m_block_start_ptr0;
			long long* copy_ptr_64_run_2 = m_block_start_ptr0_shared;
			for (l = 0; l < nBlock; l++)
			{
				*copy_ptr_64_run_1++ = *copy_ptr_64_run_2++;
			}

			copy_ptr_run_1 = block_length_ptr0;
			copy_ptr_run_2 = block_length_ptr0_shared;
			for (l = 0; l < nBlock; l++)
			{
				*copy_ptr_run_1++ = *copy_ptr_run_2++;
			}
			// END thread personal copy of l_block_start and m_block_start and block_length



			int* r_jump_run;

			int* r_nJump_run;
			int  r_nJump_current;

			float* m_val_run;
			float  m_val_current;

			float* v_ptr1;
			float* v_run;

			float* w_run;

			int currentBlockLength; 



#pragma omp for
			for (int blockInd = 0; blockInd < nBlock; blockInd++)
			{
				//r_jump_run = r_jump_ptr0_shared + m_block_start_ptr0_shared[blockInd];
				r_jump_run = r_jump_ptr0_shared + m_block_start_ptr0[blockInd];

				//m_val_run  = m_val_ptr0_shared  + m_block_start_ptr0_shared[blockInd];
				m_val_run = m_val_ptr0_shared + m_block_start_ptr0[blockInd];
				m_val_current = 0;

				//r_nJump_run = r_nJump_ptr0_shared + l_block_start_ptr0_shared[blockInd];
				r_nJump_run = r_nJump_ptr0_shared + l_block_start_ptr0[blockInd];
				r_nJump_current = 0;

				v_ptr1 = v_ptr0_shared;
				v_run = v_ptr1;

				//w_run = w_ptr0_shared + l_block_start_ptr0_shared[blockInd]*n_vec;
				w_run = w_ptr0_shared + l_block_start_ptr0[blockInd] * n_vec_64;


				//currentBlockLength = block_length_ptr0_shared[blockInd]; 
				currentBlockLength = block_length_ptr0[blockInd];
				
				
				
				
				for (i = 0; i < currentBlockLength; i++)
				{
					// initial temp_sum to 0
					for (k = 0; k < n_vec_32; k++)
					{
						*temp_sum_run++ = 0;
					}
					temp_sum_run = temp_sum_ptr0;

					r_nJump_current = *r_nJump_run++; 
					for (j = 0; j < r_nJump_current; j++)
					{

						m_val_current = *m_val_run++;
						v_ptr1 += ((long long)(*r_jump_run++))*n_vec_64;
						v_run = v_ptr1;
						for (k = 0; k < n_vec_32; k++)
						{
							*temp_sum_run++ += *v_run++ * m_val_current;
						}
						temp_sum_run = temp_sum_ptr0;

					}

					// copy temp_sum to w
					for (k = 0; k < n_vec_32; k++)
					{
						*w_run++ = *temp_sum_run++;
					}
					temp_sum_run = temp_sum_ptr0;

				} // end for i
			}// end for blockInd

			delete[] temp_sum_ptr0;
			delete[] l_block_start_ptr0; 
			delete[] m_block_start_ptr0;
			delete[] block_length_ptr0;
		} // end pragma omp
	} // end block if
	else // l_sparsity case
	{

		int numOfThread = omp_get_num_procs();
		omp_set_num_threads(numOfThread);

		/*
#pragma omp parallel shared(l_size, nBlock, n_vec, w_ptr0_shared) // zero initialization of w
		{

			int blockLength_small = (int)floor(((double)l_size) / ((double)nBlock)); 
			int blockLength_rest   = l_size - blockLength_small*nBlock;
			int currentBlockLength;
			int currentBlockLength_2;
			int currentBlockStart;

			int k; 
			
			float* w_run; 
			
#pragma omp for
			for (int blockInd = 0; blockInd < nBlock; blockInd++)
			{
				if (blockInd < blockLength_rest)
				{
					currentBlockLength = blockLength_small + 1;
					currentBlockStart  = blockInd*currentBlockLength;
				}
				else
				{
					currentBlockLength = blockLength_small;
					currentBlockStart = (blockLength_small + 1)*blockLength_rest + (blockInd - blockLength_rest)*blockLength_small;
				}

				w_run = w_ptr0_shared + currentBlockStart*n_vec;
				currentBlockLength_2 = currentBlockLength * n_vec; 
				for (k = 0; k < currentBlockLength_2; k++)
				{
					*w_run++ = 0;
				}
			}// END omp for
		} // END pragma omp zero initialization of w. 
		

		*/



		long long w_length = ((long long)l_size)*((long long)n_vec_32);
		float* w_run = w_ptr0_shared; 
		for (long long k_64 = 0; k_64 < w_length; k_64++)
		{
			*w_run++ = 0; 
		}


#pragma omp parallel shared(r_size, r_jump_ptr0_shared, r_nJump_ptr0_shared, m_val_ptr0_shared, l_size, l_jump_ptr0_shared, l_nJump, nBlock, block_length_ptr0_shared, l_block_start_ptr0_shared, m_block_start_ptr0_shared, v_ptr0_shared, n_vec_32, w_ptr0_shared)
		{
			// printf("This is thread number %d .\n", omp_get_thread_num());

			long long n_vec_64 = (long long)n_vec_32; 

			int i = 0;
			int j = 0;
			int k = 0;
			int l = 0;

			float* temp_sum_ptr0 = new float[n_vec_32];
			float* temp_sum_run = temp_sum_ptr0;


			// thread personal copy of l_block_start and m_block_start and block_length
			int* l_block_start_ptr0 = new int[nBlock];
			long long* m_block_start_ptr0 = new long long[nBlock];
			int* block_length_ptr0  = new int[nBlock];

			int* copy_ptr_run_1 = l_block_start_ptr0;
			int* copy_ptr_run_2 = l_block_start_ptr0_shared;
			for (l = 0; l < nBlock; l++)
			{
				*copy_ptr_run_1++ = *copy_ptr_run_2++;
			}

			long long* copy_ptr_64_run_1 = m_block_start_ptr0;
			long long* copy_ptr_64_run_2 = m_block_start_ptr0_shared;
			for (l = 0; l < nBlock; l++)
			{
				*copy_ptr_64_run_1++ = *copy_ptr_64_run_2++;
			}

			copy_ptr_run_1 = block_length_ptr0;
			copy_ptr_run_2 = block_length_ptr0_shared;
			for (l = 0; l < nBlock; l++)
			{
				*copy_ptr_run_1++ = *copy_ptr_run_2++;
			}
			// END thread personal copy of l_block_start and m_block_start and block_length


			int* r_jump_run;
			int* l_jump_run;

			int* r_nJump_run;
			int  r_nJump_current;

			float* m_val_run;
			float  m_val_current;

			float* v_ptr1;
			float* v_run;

			float* w_ptr1;
			float* w_run;

			int currentBlockLength;


#pragma omp for
			for (int blockInd = 0; blockInd < nBlock; blockInd++)
			{



				//r_jump_run = r_jump_ptr0_shared + m_block_start_ptr0_shared[blockInd];
				r_jump_run = r_jump_ptr0_shared + m_block_start_ptr0[blockInd];

				//m_val_run  = m_val_ptr0_shared  + m_block_start_ptr0_shared[blockInd];
				m_val_run = m_val_ptr0_shared + m_block_start_ptr0[blockInd];
				m_val_current = 0;

				//r_nJump_run = r_nJump_ptr0_shared + l_block_start_ptr0_shared[blockInd];
				r_nJump_run = r_nJump_ptr0_shared + l_block_start_ptr0[blockInd];
				r_nJump_current = 0;

				//l_jump_run = l_jump_ptr0_shared + l_block_start_ptr0_shared[blockInd];
				l_jump_run = l_jump_ptr0_shared + l_block_start_ptr0[blockInd];

				//currentBlockLength = block_length_ptr0_shared[blockInd]; 
				currentBlockLength = block_length_ptr0[blockInd];


				v_ptr1 = v_ptr0_shared;
				v_run = v_ptr1;

				
				w_ptr1 = w_ptr0_shared;
				w_run = w_ptr1;



				for (i = 0; i < currentBlockLength; i++)
				{
					// initial temp_sum to 0
					for (k = 0; k < n_vec_32; k++)
					{
						*temp_sum_run++ = 0;
					}
					temp_sum_run = temp_sum_ptr0;

					
					r_nJump_current = *r_nJump_run++;
					for (j = 0; j < r_nJump_current; j++)
					{



						m_val_current = *m_val_run++;
						v_ptr1 +=  ((long long)(*r_jump_run++))*n_vec_64;
						v_run = v_ptr1;
						for (k = 0; k < n_vec_32; k++)
						{
							*temp_sum_run++ += *v_run++ * m_val_current;
						}
						temp_sum_run = temp_sum_ptr0;


					}


					// copy temp_sum to w
					w_ptr1 += ((long long)(*l_jump_run++))*n_vec_64;
					w_run = w_ptr1;
					for (k = 0; k < n_vec_32; k++)
					{
						*w_run++ = *temp_sum_run++;
					}
					temp_sum_run = temp_sum_ptr0;


				} // end for i
			}// end blockInd
			delete[] temp_sum_ptr0;
			delete[] l_block_start_ptr0;
			delete[] m_block_start_ptr0;
			delete[] block_length_ptr0;
			//printf("This is l_sparsity from thread numbre %d  \n", omp_get_thread_num()  ); 
		} // end pragma omp

	} // end block if
} // end function