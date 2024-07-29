Writing Your Reconstruction Script
==================================

4D
--

The standard way of reconstructing images is using a single binning masks dimension. In this case, the reconstruction becomes 4D, where three dimensions are the X, Y, Z spatial dimensions, and one dimension corresponds to the bins. In practice, you are reconstructing a 3D volume for each bin mask.

This section covers writing custom scripts for MRI reconstruction. At the beginning of the script, you also need to define several parameters:

.. code-block:: matlab

    N_u     = [80, 80, 80]; % Size of the Virtual cartesian grid in the Fourier space (regridding)
    n_u     = [80, 80, 80]; % Image size (output)
    dK_u    = [1, 1, 1]./480; % Spacing of the virtual cartesian grid
    nFr     = 20; % The amount of frames in your reconstruction

The choice of dK_u and N_u sets the virtual cartesian grid used for regridding and inherently sets a maximum achievable spatial resolution = dK_u*N_u since you don't estimate the Fourier parameters above the frequency dK_u*N_u/2.

Before running the reconstruction script, it's necessary that the mythosis step is completed. This means that you have access to:

- ``y``, the raw data evaluated in the bins: a (Nfr x 1) cells
- ``t``, trajectory evaluated in the bins: a (Nfr x 1) cells
- ``ve``, the volume elements evaluated in the bins: a (Nfr x 1) cells
- ``C``, the estimated coil sensitivity: a 4D complex double array of size [Nx Ny Nz nChannels]

If you run the mythosius correctly, you can simply load the data as:

.. code-block:: matlab

    y   = bmMitosius_load(m, 'y'); 
    t   = bmMitosius_load(m, 't'); 
    ve  = bmMitosius_load(m, 've'); 

If you saved a low-resolution coil sensitivity matrix, you can run:

.. code-block:: matlab

    C = bmImResize(C, [48, 48, 48], N_u);

Once these parameters are set, you should estimate the gridding matrices:

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

    bmImage(x0);

Now you can set some reconstruction parameters and choose the best function for your needs.

.. code-block:: matlab

    nIter = 30;
    witness_ind = [];
    delta     = 0.1;
    rho       = 10*delta;
    nCGD      = 4;
    ve_max    = 10*prod(dK_u(:));

And run the reconstruction. Be aware there could be a crash if the memory needed is too big, and it can take a lot of time. Maybe it's better if you first test with small N_u and n_u values.

.. code-block:: matlab

    x = bmTevaMorphosia_chain(  x0, ...
                                [], [], ...
                                y, ve, C, ...
                                Gu, Gut, n_u, ...
                                [], [], ...
                                delta, rho, 'normal', ...
                                nCGD, ve_max, ...
                                nIter, ...
                                bmWitnessInfo('tevaMorphosia_d0p1_r1_nCGD4', witness_ind));

Take a look at your resulting image. Are you happy with your result?

.. code-block:: matlab

    bmImage(x)

5D Recons
---------

Still to document & to test

If you need a 5D reconstruction, the input dimensions are different. The needed inputs are:

- ``y``, the raw data evaluated in the bins: a (Nfr x Nfr2 x 1) cells
- ``t``, trajectory evaluated in the bins: a (Nfr x Nfr2 x 1) cells
- ``ve``, the volume elements evaluated in the bins: a (Nfr x Nfr2 x 1) cells
- ``C``, the estimated coil sensitivity: a 4D complex double array of size [Nx Ny Nz nChannels]
