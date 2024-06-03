// Bastien Milani
// CHUV and UNIL
// Lausanne - Swizerland
// May 2023

#ifndef __bmSparseMat_cC_oBlock_omp_H__
#define __bmSparseMat_cC_oBlock_omp_H__
 
extern void bmSparseMat_cC_oBlock_omp(int r_size, int* r_jump_ptr0, int* r_nJump_ptr0,
	float* m_val_ptr0,
	int l_size, int* l_jump_ptr0, int l_nJump,
	float* v_real_ptr0, float* v_imag_ptr0,
	int n_vec_32,
	float* w_real_ptr0, float* w_imag_ptr0); 

#endif // __bmSparseMat_cC_oBlock_omp_H__