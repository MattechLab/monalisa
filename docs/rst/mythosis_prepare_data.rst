Mitosis: Prepare Your Data for Reconstruction
=============================================

This section covers how to prepare your data for the mythosis step and run it. This is a fundamental step in the reconstruction. 
You already need to run the coil sensitivity estimation or have an estimate of coil sensitivity and masked coil sensitivity. You need to have access to the raw data of the acquisition (of course :) ). Your trajectory has to be supported by the toolbox, or you need to implement it yourself.

How to Correctly Run the Mitosis Step
-------------------------------------

The Mitosis step follows several steps. First of all, you need to define the path to your raw data file.

.. code-block:: matlab

    % path to the raw data file (in this case Siemens raw data)
    f = '/your/path/to/raw_data/rawdata.dat'; 
    % Display infos
    bmTwix_info(f); 
    % read raw data
    myTwix = bmTwix(f);

Then you need to set some parameter values.

.. code-block:: matlab

    p = bmMriAcquisitionParam([]); 
    p.name            = [];
    p.mainFile_name   = 'rawdata.dat';

    p.imDim           = 3;
    p.N               = 480;  
    p.nSeg            = 22;  
    p.nShot           = 2055;  
    p.nLine           = 45210;  
    p.nPar            = 1;  

    p.nLine           = double([]);
    p.nPt             = double([]);
    p.raw_N_u         = [480, 480, 480];
    p.raw_dK_u        = [1, 1, 1]./480;

    p.nCh             = 42;  
    p.nEcho           = 1; 

    p.selfNav_flag    = true;
    % This was estimated in the coil sensitivity computation
    p.nShot_off       = 10; 
    p.roosk_flag      = false;
    % This is the full FOV not the half FOV
    p.FoV             = [480, 480, 480];
    % This sets the trajectory used
    p.traj_type       = 'full_radial3_phylotaxis';

    % Fill in missing parameters that can be deduced from existing ones.
    p.refresh; 

A normalization step follows, where a simple reconstruction is run to produce an image, and the raw data is divided by the mean value of the image over a region of interest where the signal is present. Note that you can normalize the raw data and the image will be normalized. This is because the Fourier transform is linear and therefore:

.. math::

    F(f(.)/a) =  F(f(.))/a

.. code-block:: matlab

    % Simple reconstruction
    x_tot = bmMathilda(y_tot, t_tot, ve_tot, C, N_u, n_u, dK_u); 
    bmImage(x_tot)
    temp_im = getimage(gca); 
    bmImage(temp_im); 
    % compute mean over a region of interest
    temp_roi = roipoly; 
    normalize_val = mean(temp_im(temp_roi(:))); 

    %% to run only once: normalize the image
    y_tot = y_tot / normalize_val; 

We can now run the mitosis step and save the results on the disk.

.. code-block:: matlab

    % Load the masked coil sensitivity 
    load('/your/path/to/cMask.mat'); 

    cMask = reshape(cMask, [20, 22, 2055]); 
    cMask(:, 1, :) = []; 
    cMask(:, :, 1:p.nShot_off) = []; 
    cMask = bmPointReshape(cMask); 

    % Run the mitosis function and compute volume elements
    [y, t] = bmMitosis(y_tot, t_tot, cMask); 
    y = bmPermuteToCol(y); 

    ve  = bmVolumeElement(t, 'voronoi_full_radial3' ); 

    % Save all the resulting data structures on the disk. You are now ready
    % to run your reconstruction
    m = '/your/path/to/mitosius'; 
    bmMitosius_create(m, y, t, ve); 

Using a Custom Acquisition Trajectory
-------------------------------------

Still to do: Discuss how to use a custom trajectory & test it.
