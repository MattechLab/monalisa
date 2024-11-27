Reconstruction Script(s)
==================================

This section covers how to reconstruct your data.

Before running the reconstruction script, make sure you have the necessary following input parameters:

- ``y``, the raw data evaluated in the bins: a (Nfr x 1) cells
- ``t``, trajectory evaluated in the bins: a (Nfr x 1) cells
- ``ve``, the volume elements evaluated in the bins: a (Nfr x 1) cells
- ``C``, the estimated coil sensitivity: a 4D complex double array of size [Nx Ny Nz nCh]

At the beginning of the script, you also need to define the following parameters:

.. code-block:: matlab

    N_u     = [80, 80, 80]; % Size of the Virtual cartesian grid in the Fourier space (regridding)
    n_u     = [80, 80, 80]; % Image size (output)
    dK_u    = [1, 1, 1]./480; % Spacing of the virtual cartesian grid
    nFr     = 20; % The amount of frames in your reconstruction
    nCh     = 24; % The number of channels in your coil sensitivity matrix

The choice of ``dK_u`` and ``N_u`` sets the virtual cartesian grid used for regridding and inherently
sets a maximum achievable spatial resolution of :math:`1/(dK\_u*N\_u)` since you don't estimate the Fourier parameters above the frequency :math:`dK\_u*N\_u/2`.

If you run the mitosius correctly, you can simply load the data as:

.. code-block:: matlab

    y   = bmMitosius_load(m, 'y'); 
    t   = bmMitosius_load(m, 't'); 
    ve  = bmMitosius_load(m, 've'); 

If you already saved a low-resolution coil sensitivity matrix, you can run:

.. code-block:: matlab

    C = bmImResize(C, C_size, N_u);

Once these parameters are set, you must estimate the gridding matrices:

.. code-block:: matlab

    [Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

Then you can estimate the initial guess (x0) for your reconstruction:

.. code-block:: matlab

    x0 = cell(nFr, 1);
    for i = 1:nFr
        x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, n_u, dK_u, [], [], [], []);
    end

Take a look at the image!!

.. code-block:: matlab

    >> bmImage(x0);

Now you can set some reconstruction parameters and choose the best function for your needs.

.. code-block:: matlab

    nIter = 30;
    witness_ind = 1:nIter;
    delta     = 0.1;
    rho       = 10*delta;
    nCGD      = 4;
    ve_max    = 10*prod(dK_u(:));

And run the reconstruction.
Be aware there could be a crash if the memory needed is too big, and it can take a lot of time.
Maybe it's better if you first test with small N_u and n_u values.

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
        bmWitnessInfo('tevaMorphosia_d0p1_r1_nCGD4', witness_ind)
    );

.. important::
    ``x`` and ``witness info`` are saved in the current directory.

Take a look at your resulting image. Are you happy with your result?

.. code-block:: matlab

    >> bmImage(x)

Iterative-SENSE reconstruction method
--------------------------------------
Iterative-SENSE [1]_ is an iterative reconstruction method for cartesian and non-cartesian data, performed frame by frame without sharing information between frames. 
Consequently, it performs poorly with heavily undersampled data.
However, despite its limitations, this method is important in the theoretical framework of reconstruction and finds applications in specific cases.  
We include a demonstration of the reconstruction here for completeness.
Our implementation of Iterative-SENSE is `bmSensa`, that uses the iterative conjugate gradient descent (CGD) algorithm. 

.. code-block:: matlab

    x = cell(nFr, 1); 
    for i = 1:nFr

        nIter       = 30;
        witness_ind = []; % 1:nIter;
        label       = 'sensa_frame_'; % label to save the files
        witnessInfo = bmWitnessInfo([label, num2str(i)], witness_ind);
        convCond    = bmConvergeCondition(nIter);

        nCGD    = 4;
        ve_max  = 10*prod(dK_u(:));

        x{i} = bmSensa( x0{i}, y{i}, ve{i}, C, Gu{i}, Gut{i}, n_u,
                        nCGD, ve_max, 
                        convCond, witnessInfo);
    end

Check out the reconstructed image here:

.. code-block:: matlab

    >> bmImage(x)

.. [1] Pruessmann, K. P., Weiger, M., Börnert, P., & Boesiger, P. (2001). Advances in sensitivity encoding with arbitrary k-space trajectories. Magnetic Resonance in Medicine, 46(4), 638–651. https://doi.org/10.1002/mrm.1241