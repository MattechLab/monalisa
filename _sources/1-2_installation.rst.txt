============
Installation
============

To get started with the MRI reconstruction code, follow these steps:

Clone the Repository
====================

Clone the repository and navigate into the directory, using your terminal, navigate to the directory where you want to install the monalisa folder then run:

.. code-block:: bash

   git clone https://github.com/MattechLab/monalisa.git
   cd monalisa

Set Up a c++ Compiler
=====================

Ensure you have a compiler that is recognized by MATLAB. You can run the following command in MATLAB to check if you already have one:

.. code-block:: matlab

   mex -setup C++

If you see a message like "No supported compiler or SDK was found", you will need to install a compiler. Refer to the following sections based on your operating system.

Linux
-----

1. **Install g++**:

   .. code-block:: bash

      sudo apt-get update
      sudo apt-get install g++

macOS
-----

.. warning::  
   If you are using a Mac with Apple Silicon architecture, ensure that you have installed the MATLAB version specifically designed for Apple Silicon. Installing the version intended for Intel architecture may lead to compilation errors.

1. **Install Xcode Command Line Tools**:

   .. code-block:: bash

      xcode-select --install

2. **Install libomp via Homebrew**:

   .. code-block:: bash

      brew install libomp

3. **Update the `compileScript.m`**:

   Open `compile_mex_for_monalisa.m` at `monalisa/src/bmMex/m/` and update the `libomp_dirs` directory:

   .. code-block:: matlab

      % Insert your libomp path instead of this
      libomp_dirs = dir('/opt/homebrew/opt/libomp');  

   If you are using homebrew, you can find the path by running:

   .. code-block:: bash

      brew --prefix libomp

   To be even more clear, you might need to change `this <https://github.com/MattechLab/monalisa/blob/597a86009e288826efe0486a368b5debda99e962/src/bmMex/m/compile_mex_for_monalisa.m#L62>`_ line of code.

Windows
-------

1. **Install Visual Studio with C++ components**:

   Download and install Visual Studio from the official website. Make sure to include the Desktop development with C++ workload.


Add Monalisa source path to your MATLAB path
=============================================
   .. code-block:: matlab

      addpath(genpath('./src'))

Compile the C++ Source
=======================

   After checking that the compiler is successfully installed (mex -setup C++), run `compile_mex_for_monalisa.m` function in MATLAB:

   .. code-block:: matlab

      compile_mex_for_monalisa
   
   Congratulations, you are ready to use Monalisa.

Verify Installation
===================

Test your compilation step worked successfully using the example script:

.. code-block:: matlab
   
   cd /monalisa/demo/script_demo/script_recon_calls/
   # you can run your fist recon to test the installation: 
   # static_recon_calls_script.m

Notes
=====

- **Linux**: Ensure that the g++ version is compatible with MATLAB.
- **macOS**: You need libomp as explained in this StackOverflow post: `How to include omp.h in OS X <https://stackoverflow.com/questions/25990296/how-to-include-omp-h-in-os-x>`_.
- **Windows**: Ensure that the Visual Studio C++ compiler is set up correctly and recognized by MATLAB.

Follow these steps to set up your environment and compile the necessary code for MRI reconstruction. If you encounter any issues, consider opening an issue on our GitHub repository. We will do our best to help you.
