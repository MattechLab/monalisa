# Monalisa : a reconstruction tool-box for non-cartesian and cartesian MRI data

This repository contains code for performing MRI reconstruction with non-cartesian or cartesian data.
Several iterative reconstruction are implemented. They all consist in minimizing a regularized or non-regularized least-square objective function.

## Getting started

Check the Monalisa documentation [here](https://mattechlab.github.io/monalisa/)!

## Usage and installation

To get started with the MRI reconstruction code, follow these steps:

1. Clone the repository

```sh
   git clone https://github.com/MattechLab/monalisa.git
   cd monalisa
```

2. Make sure you have a compiler that is recognized by MATLAB. To check that you can run

```sh
mex -setup C++
```

Depending on your configuration, you should install a C++ compiler. (If you see a message like "No supported compiler or SDK was found. For options, visit <https://www.mathworks.com/support/compilers>.")

If you have to install a compiler, we recommend:

- g++ for Linux,
- Xcode Clang++ for macOS,
- Visual Studio C++ or MinGW for Windows. Normally, the compiler from Visual Studio C++ will work. If it fails, you can also install MinGW alternatively following the instructions [here](https://ch.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-mingw-w64-c-c-fortran-compiler). After downloading MinGW, such as `mingw81`, run the command `% configuremingw('\path\to\mingw81')`, then you are ready to compile Monalisa!

3. Compile the C++ code using the script [compileScript.m](https://github.com/MattechLab/monalisa/blob/main/src/bmMex/m/compileScript.m). On macOS, you should change the libomp_dirs directory [here](https://github.com/MattechLab/monalisa/blob/5febe05d39f822f6c3b5c830fbc99311d195e237/src/bmMex/m/compileScript.m#L61). If you are using brew for the installations, you can find the path by running: `brew --prefix libomp`. You need libomp as explained [here](https://stackoverflow.com/questions/25990296/how-to-include-omp-h-in-os-x).

4. Test your compilation step worked successfully using the [example script](https://github.com/MattechLab/monalisa/blob/main/example/imDim_plus_card/script.m).
