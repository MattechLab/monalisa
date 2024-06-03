// Bastien Milani
// CHUV and UNIL
// Lausanne - Switzerland
// May 2023

#include "mex.h"
#include <omp.h>
#include <cstdio>

void myFunction();


/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
	// function call
	myFunction();
}


void myFunction()
{
	int i = 0; 
		omp_set_num_threads(omp_get_num_procs());

#pragma omp parallel shared(i)
		{
			printf("This is thread number %d .\n", omp_get_thread_num()); 
		} // end thread

} // end function


