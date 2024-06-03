// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include <omp.h>
#include <cstdio>
#include "bmSparseMat_cC_oBlock_omp.h"

void bmSparseMat_cC_oBlock_omp(	int r_size_shared, 
								int* r_jump_ptr0_shared, 
								int* r_nJump_ptr0_shared, 
								float* m_val_ptr0_shared, 
								int l_size_shared, 
								int* l_jump_ptr0_shared, 
								int l_nJump_shared, 
								float* v_real_ptr0_shared, float* v_imag_ptr0_shared, 
								int n_vec_32_shared, 
								float* w_real_ptr0_shared, float* w_imag_ptr0_shared)
{

	if ((2 * n_vec_32_shared) < omp_get_max_threads())
	{
		omp_set_num_threads(2 * n_vec_32_shared);
	}
	else
	{
		omp_set_num_threads( omp_get_max_threads() );
	}
		

#pragma omp parallel shared(	r_size_shared, r_jump_ptr0_shared, r_nJump_ptr0_shared, m_val_ptr0_shared, l_size_shared, l_jump_ptr0_shared, l_nJump_shared, v_real_ptr0_shared, v_imag_ptr0_shared, n_vec_32_shared, w_real_ptr0_shared, w_imag_ptr0_shared)
		{
			// printf("This is thread number %d .\n", omp_get_thread_num()); 


			int i		= 0;
			int j		= 0;
			int k_half	= 0;
			int l		= 0;  

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


#pragma omp for
			for (int k = 0; k < (n_vec_32_shared * 2); k++)
			{


				if ((k % 2) == 0) // if real
				{
					k_half = (int)(k / 2);

					float* v_real_ptr0 = v_real_ptr0_shared + ((long long)r_size_shared)*((long long)k_half);
					float* v_real_run = v_real_ptr0;
					float* w_real_ptr0 = w_real_ptr0_shared + ((long long)l_size_shared)*((long long)k_half);
					float* w_real_run = w_real_ptr0;

					r_jump_run = r_jump_ptr0;
					r_nJump_run = r_nJump_ptr0;
					m_val_run = m_val_ptr0;
					l_jump_run = l_jump_ptr0;

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
					k_half = (int)((k - 1) / 2);

					float* v_imag_ptr0 = v_imag_ptr0_shared + ((long long)r_size_shared)*((long long)k_half);
					float* v_imag_run = v_imag_ptr0;
					float* w_imag_ptr0 = w_imag_ptr0_shared + ((long long)l_size_shared)*((long long)k_half);
					float* w_imag_run = w_imag_ptr0;

					r_jump_run = r_jump_ptr0;
					r_nJump_run = r_nJump_ptr0;
					m_val_run = m_val_ptr0;
					l_jump_run = l_jump_ptr0;

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
								v_imag_run += *r_jump_run++;
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


			} // end parfor
		} // end thread
} // end function


