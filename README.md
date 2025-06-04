# Monalisa : a reconstruction tool-box for non-cartesian and cartesian MRI data

This repository contains code for performing MRI reconstruction with non-cartesian or cartesian data.
Several iterative reconstruction are implemented. They all consist in minimizing a regularized or non-regularized least-square objective function. 

Make sure to **visit our [documentation](https://mattechlab.github.io/monalisa/)**.

If you find this useful, **please leave us a star!**

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

Depending on your configuration, you should install a C++ compiler. (If you see a message like "No supported compiler or SDK was found. For options, visit <https://www.mathworks.com/support/compilers>".)

If you have to install a compiler, we recommend:

- g++ for Linux,
- Xcode Clang++ for macOS,
- Visual studio c++ or MinGW for windows. Normally, the compiler from Visual studio c++ will work. If it fails, you can also install MinGW alternatively following these [instructions](https://ch.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-mingw-w64-c-c-fortran-compiler). After downloading the MinGW, such as `mingw81`, run the command `% configuremingw('\path\to\mingw81')`,then you are ready to compile Monalisa!

3. Compile the cpp code using the [function](https://github.com/MattechLab/monalisa/blob/main/src/bmMex/m/compile_mex_for_monalisa.m) . On macOS you should change the libomp_dirs directory here: <https://github.com/MattechLab/monalisa/blob/0669b36852b1cf2a0284f8c0e69d8b873e46b89b/src/bmMex/m/compile_mex_for_monalisa.m#L62>. If you are using brew for the installations, you can find the libomp_dirs path by running: brew --prefix libomp. (you need libomp as explained [here](https://stackoverflow.com/questions/25990296/how-to-include-omp-h-in-os-x>))

4. Great, installation is done! You are now ready to run the first [tutorial](https://mattechlab.github.io/monalisa/3-1_example1.html)

## Getting started

For better installation guidelines and much more **check Monalisa's documentation** [here](https://mattechlab.github.io/monalisa/)!

## Navigating This Repository

This repository is organized into 5 main subfolders, each with a specific purpose:

- **`demo/`** – Example scripts and tutorials demonstrating how to use the toolbox.

- **`docs/`** – Documentation sources and build tools for generating the project’s documentation.

- **`src/`** – Core source code of the Monalisa toolbox. This is where the main functionality is implemented.

- **`third_part/`** – Third-party software dependencies (some with local modifications). These are distributed under licenses different from Monalisa’s.

- **`tests/`** – Unit tests and validation scripts to ensure code reliability.


## Help us improve

Monalisa is still very young. If you encounter an issue, please consider **opening a GitHub issue** in the repository. If you know how to fix the problem, feel free to submit a pull request!
