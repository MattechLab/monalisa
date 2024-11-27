Installation
============

To get started with the MRI reconstruction code, follow these steps:

Clone the Repository
--------------------

Install git lfs (large file storage) to properly clone the repository:

- **Linux**: ``sudo apt-get install git-lfs``
- **macOS**: ``brew install git-lfs``
- **Windows**: ``choco install git-lfs`` or from the `official website <https://git-lfs.github.com/>`_
- **Conda**: ``conda install -c conda-forge git-lfs``

Initialize git lfs with ``git lfs install`` to make sure it has been installed. You should see a message like "Git LFS initialized.".

Clone the repository and navigate into the directory:

.. code-block:: bash

   git clone https://github.com/MattechLab/monalisa.git
   cd monalisa

In case you cloned it without lfs installed, install it, initialize it and run the following command 
(in monalisa directory) to download the large files: ``git lfs pull``.

Set Up a Compiler
-----------------

Ensure you have a compiler that is recognized by MATLAB. Run the following command in MATLAB to check:

.. code-block:: matlab

   mex -setup C++

If you see a message like "No supported compiler or SDK was found," you will need to install a compiler. Refer to the following sections based on your operating system.

Linux
-----

1. **Install g++**:

   .. code-block:: bash

      sudo apt-get update
      sudo apt-get install g++

2. **Compile the C++ code**:

   Navigate to the directory containing the `compileScript.m` file and run it in MATLAB:

   .. code-block:: matlab

      cd src/bmMex/m
      compileScript

macOS
-----

1. **Install Xcode Command Line Tools**:

   .. code-block:: bash

      xcode-select --install

2. **Install libomp via Homebrew**:

   .. code-block:: bash

      brew install libomp

3. **Update the `compileScript.m`**:

   Open `compileScript.m` and update the `libomp_dirs` directory:

   .. code-block:: matlab

      libomp_dirs = dir('/opt/homebrew/opt/libomp');  % Example path where Homebrew installs packages

   You can find the path by running:

   .. code-block:: bash

      brew --prefix libomp

4. **Compile the C++ code**:

   Navigate to the directory containing the `compileScript.m` file and run it in MATLAB:

   .. code-block:: matlab

      cd src/bmMex/m
      compileScript

Windows
-------

1. **Install Visual Studio with C++ components**:

   Download and install Visual Studio from the official website. Make sure to include the Desktop development with C++ workload.

2. **Compile the C++ code**:

   Navigate to the directory containing the `compileScript.m` file and run it in MATLAB:

   .. code-block:: matlab

      cd src/bmMex/m
      compileScript

Verify Installation
-------------------

Test your compilation step worked successfully using the example script:

.. code-block:: bash

   https://github.com/MattechLab/monalisa/blob/main/example/imDim_plus_card/script.m

Notes
-----

- **Linux**: Ensure that the g++ version is compatible with MATLAB.
- **macOS**: You need libomp as explained in this StackOverflow post: `How to include omp.h in OS X <https://stackoverflow.com/questions/25990296/how-to-include-omp-h-in-os-x>`_.
- **Windows**: Ensure that the Visual Studio C++ compiler is set up correctly and recognized by MATLAB.

Follow these steps to set up your environment and compile the necessary code for MRI reconstruction. If you encounter any issues, consider opening an issue on our GitHub repository.
