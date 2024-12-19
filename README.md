# monalisa
This repository contains code for performing MRI reconstruction with non-cartesian or cartesian data. 
Several iterative reconstruction are implemented. They all consist in minimizing a regularized or non-regularized least-square objective function. 

## MRI Reconstruction with Non-Uniform Fast Fourier Transform (NUFFT)

## Overview
This repository contains code for performing MRI reconstruction with non-cartesian or cartesian data. 
Several iterative reconstruction are implemented. They all consist in minimizing a regularized or non-regularized least-square objective function. 

## Usage and installation
To get started with the MRI reconstruction code, follow these steps:
1. Clone the repository:

```sh
   git clone https://github.com/MattechLab/monalisa.git
   cd monalisa
```

3. Make sure you have a compiler that is recognized by matlab. To check that you can run:

```sh
mex -setup C++
```

Depending on your configuaration you should install a cpp compiler. (if you see a message like No supported compiler or SDK was found.
For options, visit https://www.mathworks.com/support/compilers.) 

If you have to install a compiler we reccomend:
- gpp for linux,
- Xcode Clang++ for macOS,
- Visual studio c++ or MinGW for windows. Normally, the compiler from Visual studio c++ will work. If it fails, you can also install MinGW alternatively following the instructions here https://ch.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-mingw-w64-c-c-fortran-compiler. After downloading the MinGW, such as `mingw81`, run the command `% configuremingw('\path\to\mingw81')`,then you are ready to compile Monalisa!

3. Compile the cpp code using the script https://github.com/MattechLab/monalisa/blob/main/src/bmMex/m/compileScript.m. On macOS you should change the libomp_dirs directory here: https://github.com/MattechLab/monalisa/blob/5febe05d39f822f6c3b5c830fbc99311d195e237/src/bmMex/m/compileScript.m#L61. If you are using brew for the installations, you can find the path by running: brew --prefix libomp. (you need libomp as explained here: https://stackoverflow.com/questions/25990296/how-to-include-omp-h-in-os-x)
   
4. Test your compilation step worked successfully using the example script: https://github.com/MattechLab/monalisa/blob/main/example/imDim_plus_card/script.m
   
# Getting started: 
Link to initial tutorials.

Link to Docs.
