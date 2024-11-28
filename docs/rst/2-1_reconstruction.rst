========================
Reconstruction Script(s)
========================

This section covers how to reconstruct your data from k-space to image space,
for 2D and 3D cartesian and non-cartesian configurations.
The standard way of reconstructing images is using a single binning masks dimension.
In this case, the reconstruction becomes 4D, where three dimensions are the X, Y, Z spatial dimensions,
and the fourth dimension corresponds to the bins (spatial or temporal).
In practice, you are reconstructing a 3D volume for each bin mask.

Prerequisites
=============

For cartesian data, the uniform Fast Fourier Transform (FFT) can directly be applied.
you need the following input parameters:

- ``y``: the raw data evaluated in the bins. A (Nfr x 1) cells.
- ``t``: the trajectory evaluated in the bins. A (Nfr x 1) cells.
- ``C``: the estimated coil sensitivity map. A 4D complex double array of size [Nx Ny Nz nCh].

Density Compensation - Volume elements
--------------------------------------

For non-cartesian (e.g. radial) data, the FFT cannot directly be applied.
You need to first obtain the density compensation (i.e. volume elements),
to then be able to apply the Non-Uniform FFT.
So you need the previous input parameters plus the volume elements:

- ``ve``: the volume elements evaluated in the bins (density compensation). A (Nfr x 1) cells.

The volume elements can be extracted from ``t`` knowing the trajectory.
This parameter depends only on the trajectory.
We have specified functions to extract ``ve`` for predefined trajectories,
but the user can implement their own for other trajectories. Check the section :doc:`2-2_mitosis_prepare_data` for more information.

``y``, ``t``, and ``ve`` are included in what we call the *mitosius*,
with further explanation on how to create it in the section :doc:`2-2_mitosis_prepare_data`.
They can be loaded as:

.. code-block:: matlab

    y   = bmMitosius_load(m, 'y'); 
    t   = bmMitosius_load(m, 't'); 
    ve  = bmMitosius_load(m, 've'); 

If you already saved a low-resolution coil sensitivity matrix, ``C`` needs to be resized as:

.. code-block:: matlab

    C = bmImResize(C, C_size, N_u);

Other Input Parameters
======================

You also need to define the following parameters:

.. code-block:: matlab

    Matrix_size = 80;
    ReconFov    = [240, 240, 240]; % mm
    N_u         = [Matrix_size, Matrix_size, Matrix_size]; % Size of the virtual cartesian grid in the Fourier space (regridding)
    n_u         = [Matrix_size, Matrix_size, Matrix_size]; % Image size (output)
    dK_u        = [1, 1, 1]./ReconFov; % Spacing of the virtual cartesian grid
    nFr         = 20; % The amount of frames in your reconstruction

The choice of ``dK_u`` and ``N_u`` sets the virtual cartesian grid used for regridding
and inherently sets a maximum achievable spatial resolution of :math:`1/(dK\_u*N\_u)`
since you don't estimate the Fourier parameters above the frequency :math:`dK\_u*N\_u/2`.

Mathilda, the initial reconstructed image
=========================================

Mathilda is the first step in the reconstruction process.
It performs the initial guess (``x0``), the gridded reconstruction for any or non-cartesian data.
With all the above parameters set, you can estimate ``x0``:

.. code-block:: matlab

    x0 = cell(nFr, 1);
    for i = 1:nFr
        x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, n_u, dK_u, [], [], [], []);
    end

Take a look at the image!!

.. code-block:: matlab

    >> bmImage(x0);

Different Reconstruction Configurations
=======================================

After having the initial guess ``x0``, we propose the following reconstruction scripts:

- :ref:`sensa`: iterative-SENSE recon
- :ref:`steva`: CS recon with spatial regularization
- :ref:`sensitivaMorphosia`: LSR recon 
- :ref:`tevaMorphosia`: CS recon with temporal regularization
- :ref:`tevaDuoMorphosia`: TevaMorphosia in both directions (forward and backward)

Before running any of the scripts, you must estimate the gridding (sparse) matrices:

.. code-block:: matlab

    [Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

These depend on the trajectory, the FoV (Field of View) and the matrix size (N_u).
For more information, check the section :ref:`Coil Sensitivity Map Estimation - Gridding Matrices <gridding_matrices>`.

Now you can set some useful reconstruction parameters and choose the best function for your needs:

.. code-block:: matlab

    nIter         = 30; % iterations before stopping
    witness_ind   = 1:nIter; % indices to save the witness
    witness_label = 'label'; % label to save the file
    delta         = 0.1; % regularization parameter
    rho           = 10*delta; % regularization parameter
    nCGD          = 4; % number of CGD iterations
    ve_max        = 10*prod(dK_u(:)); % maximum value of the volume elements

And run the reconstruction...

Be aware that there could be a crash if the memory needed is too big,
and it can take a lot of time. Maybe it's better if you first test with small N_u and n_u values.

For all the cases...

.. note::
    ``x`` and ``witnessInfo`` are saved in the current directory.

... and you can check out the reconstructed image using:

.. code-block:: matlab

    >> bmImage(x)

.. _sensa:

Sensa
-----

This is our implementation of the iterative-SENSE recon for non-cartesian data.
Iterative-SENSE [1]_ is an iterative reconstruction method, that uses the iterative conjugate gradient descent (CGD) algorithm,
for cartesian and non-cartesian data, performed frame by frame without sharing information between frames.
Consequently, it performs poorly with heavily undersampled data.
However, despite its limitations, this method is important in the theoretical framework of reconstruction
and finds applications in specific cases.

.. code-block:: matlab

    x = cell(nFr, 1); 

    for i = 1:nFr
        witnessInfo = bmWitnessInfo([witness_label, num2str(i)], witness_ind);
        convCond    = bmConvergeCondition(nIter); % convergence condition

        x{i} = bmSensa(
                x0{i}, y{i}, ve{i}, C, Gu{i}, Gut{i}, n_u,
                nCGD, ve_max, 
                convCond, witnessInfo);
    end

.. _steva:

Steva
-----

Compressed Sensing (CS) recon regularized with spatial total variation.

.. code-block:: matlab

    % For nFr<= 1
    x = bmSteva(  
        x0{1}, ...
        [], [], ...
        y{1}, ve{1}, C, ...
        Gu{1}, Gut{1}, n_u, ...
        [], [], ...
        delta, rho, 'normal', ...
        nCGD, ve_max, ...
        nIter, ...
        bmWitnessInfo(witness_label, witness_ind));

.. _sensitivamorphosia:

SensitivaMorphosia
------------------

Least Square Regularized (LSR) recon, where regularization is the squared 2 norm of 
temporal finite difference time derivative, or the squared 2 norm of motion compensated 
residuals if motion fields are used.

.. code-block:: matlab

    witnessInfo = bmWitnessInfo([witness_label, num2str(i)], witness_ind);
    convCond    = bmConvergeCondition(nIter); % convergence condition

    x = bmSensitivaMorphosia_chain(
            x, ...
            y, ve, C, ...
            Gu, Gut, n_u, ...
            Tu, Tut, ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            convCond, witnessInfo)

.. _tevamorphosia:

TevaMorphosia
-------------

CS recon with temporal regularization, with or without deformation fields.

.. code-block:: matlab

    x = bmTevaMorphosia_chain(  
        x0, ...
        [], [], ...
        y, ve, C, ...
        Gu, Gut, n_u, ...
        [], [], ...
        delta, rho, 'normal', ...
        nCGD, ve_max, ...
        nIter, ...
        bmWitnessInfo(witness_label, witness_ind));

.. _tevaduomorphosia:

TevaDuoMorphosia
----------------

Same as TevaMorphosia but with forward and backward temporal regularization, with or without deformation fields.

.. code-block:: matlab

    x = bmTevaDuoMorphosia_chain(   
        x0, ...
        [], [], [], [], ...
        y, ve, C, ...
        Gu, Gut, n_u, ...
        [], [], [], [], ...
        delta, rho, 'normal', ...
        nCGD, ve_max, ...
        bmConvergeCondition(nIter), ...
        bmWitnessInfo(witness_label, witness_ind));

Deformation Fields
==================

Here's how you add deformation fields to the reconstruction process.

.. code-block:: matlab

    %% deformation field evaluation with imReg Demon 
    reg_file                    = 'C:\path\to\your\reg_file';
    [DF_to_prev, imReg_to_prev] = bmImDeformFieldChain_imRegDemons23(h, n_u, 'curr_to_prev', 500, 1, reg_file, reg_mask); 
    [DF_to_next, imReg_to_next] = bmImDeformFieldChain_imRegDemons23(h, n_u, 'curr_to_next', 500, 1, reg_file, reg_mask); 

    %% deformation fields to sparse matrices
    [Tu1, Tu1t] = bmImDeformField2SparseMat(DF_to_prev, N_u, [], true);
    [Tu2, Tu2t] = bmImDeformField2SparseMat(DF_to_next, N_u, [], true);

TevaMorphosia with Deformation Fields
--------------------------------------

.. code-block:: matlab

    x = bmTevaMorphosia_chain(
        x0, ...
        [], [], ...
        y, ve, C, ...
        Gu, Gut, n_u, ...
        Tu1, Tu1t, ...
        delta, rho, 'normal', ...
        nCGD, ve_max, ...
        bmConvergeCondition(nIter), ...
        bmWitnessInfo(witness_label, witness_ind));

TevaDuoMorphosia with Deformation Fields
-----------------------------------------

.. code-block:: matlab

    x = bmTevaDuoMorphosia_chain(
        x0, ...
        [], [], [], [], ...
        y, ve, C, ...
        Gu, Gut, n_u, ...
        Tu1, Tu1t, Tu2, Tu2t, ...
        delta, rho, 'normal', ...
        nCGD, ve_max, ...
        bmConvergeCondition(nIter), ...
        bmWitnessInfo(witness_label, witness_ind));

.. [1] Pruessmann, K. P., Weiger, M., Börnert, P., & Boesiger, P. (2001).
    Advances in sensitivity encoding with arbitrary k-space trajectories. Magnetic Resonance in Medicine, 46(4), 638–651.
    https://doi.org/10.1002/mrm.1241.
