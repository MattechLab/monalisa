// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <cstdio>

void bmSparseMat_r_nJump2index_mex(int l_size, int* r_nJump_ptr0, int* ind_ptr0);

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

	// input arguments initial
	int  l_size;
	int* r_nJump_ptr0;
	long long ind_length; 

	// output arguments initial
	int* ind_ptr0;
	long long* myInt64_ptr0; 

	// input arguments definition
	l_size = (int)mxGetScalar(prhs[0]);
	r_nJump_ptr0 = (int*)mxGetPr(prhs[1]);
	ind_length = (long long)mxGetScalar(prhs[2]);




	// output arguments definition
	mwSize* ind_size = new mwSize[2];
	ind_size[0] = (mwSize)1;
	ind_size[1] = (mwSize)ind_length;
	mwSize ind_ndims = (mwSize)2;


	plhs[0] = mxCreateNumericArray(ind_ndims, ind_size, mxINT32_CLASS, mxREAL);
	ind_ptr0 = (int*)mxGetPr(plhs[0]);



	mwSize* myInt64_size = new mwSize[2];
	myInt64_size[0] = (mwSize)1;
	myInt64_size[1] = (mwSize)1;
	mwSize myInt64_ndims = (mwSize)2;
	
	
	plhs[1] = mxCreateNumericArray(myInt64_ndims, myInt64_size, mxINT64_CLASS, mxREAL);
	myInt64_ptr0 = (long long*)mxGetPr(plhs[1]);
	*myInt64_ptr0 = (long long)ind_size[1]; 


	// function call
	bmSparseMat_r_nJump2index_mex(l_size, r_nJump_ptr0, ind_ptr0);

	// printf("ind_length  is %u \n", ind_length);
	// printf("First size  is %d \n", ind_size[0]);
	// printf("Second size is %u \n", ind_size[1]);

	// delete[]
	delete[] ind_size;
	delete[] myInt64_size;
}




void bmSparseMat_r_nJump2index_mex(int l_size, int* r_nJump_ptr0, int* ind_ptr0)
{
	int* r_nJump_run = r_nJump_ptr0; 
	int* ind_run = ind_ptr0; 

	int i; 
	int j; 
	int jMax; 


	for (i = 0; i < l_size; i++)
	{
		jMax = *r_nJump_run++;
		for (j = 0; j < jMax; j++)
		{
			*ind_run++ = i; 
		}
	}

} // end function



