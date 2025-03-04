====================
Reconstruction Calls
====================

This section describes the functions calls of our reconstructions. 
All our reconstructions are implemented for 2 and 3 spatial dimensions. Some of them are static 
reconstruction (one single frame) and other are dynamic (multiple-frames) with 1 or 2 non-spatial dimensions.


Input Arguments for Reconstruction Functions
============================================

The input arguments that involve no or little preparation, and which are "easy" to define, and which are occupies little memory will be qualified as **leight**.

The input arguments that either need some careful preparation, or need some technical user defined choices, or occupies a lot of memory will be qualified as **heavy**.

For static (single frame) reconstructions, ``y``, ``t`` and ``ve`` are arrays, while for dynamic reconstructions 
they are cell-arrays with one cell per data-bin and per frame. 

For static reconstructions are: 

    - ``y``: the raw data. **Complex-valued, sinlge-precision, heavy.** Its size is ``[nPt, nCh]`` where ``nPt`` is the number of trajectory-points and ``nCh`` is the number of channels. 
    - ``t``: the trajectory. **Double-precision, heavy**. Its size is ``[frDim, nPt]`` where the frame-dimension ``frDim`` is the spatial dimension of the frames (2 or 3) and ``nPt`` is the number of trajectory-points. 
    - ``ve``: the volume elements (inverse density compensation). **Single precision, heavy**.  Its size is ``[1, nPt]`` where ``nPt`` is the number of trajectory-points. 

For multiple-frame (dynamic) reconstructions are 

    - ``y``: the cell-array of raw-data bins. **Each cell is complex-valued, sinlge-precision, heavy.**
    - ``t``: the cell-array of trajectory bins. **Each cell is double precision, heavy.**  
    - ``ve``: the cell-array of volume-elements bins. **Each cell is single precision, heavy.**  


The three variables ``y``, ``t`` and ``ve`` (may it be arrays or cell-arrays) forms the **Mitosius**. 
Refer to :doc:`2-3_mitosius_prepare` section to learn how to build ``y`` from the raw-data, how to build the trejectory ``t`` and how to estimate ``ve`` from ``t``. 
You can also build the trajectory ``t`` in your own way as long as you follow our convention described at the end of the `Mitosius` section. 
You can evaluate  ``ve`` by our functions if your trajectory is supported by Monalisa. Else you can obtain ``ve`` by your own means.  

If your mitosius is already stored on the disk at the math ``m``, you can load it as follows: 

.. code-block:: matlab

    y   = bmMitosius_load(m, 'y'); 
    t   = bmMitosius_load(m, 't'); 
    ve  = bmMitosius_load(m, 've');

For any reconstruction is

    - ``C``: the estimated coil sensitivity map. **Complex valued, single precision, heavy.** It is a 4D array of size ``[frSize, nCh]``, where the frame-size ``frSize`` is the spatial size of the image and ``nCh`` is the number of coils. 

You can estimate ``C`` either by your own means or by our procedure described in a later section. 
If you already saved a low-resolution coil sensitivity matrix ``C``, you can load it and resized it to the image-size as follows:

.. code-block:: matlab

    C_size = size(C); 
    C_size = C_size(1:frDim); 
    C = bmImResize(C, C_size, frSize);


For any reconstructions are

    - ``N_u`` : the size of the Cartesian gridd used for regridding in k-space. **Double precision, leight.** It is equal to ``[Nx, Ny]`` for 2 spatial dimensionts and it is equal to ``[Nx, Ny, Nz]`` for 3 spatial dimensions. 
    - ``dK_u`` : the step-size of the gridd used for regridding in k-space.  **Single precision, leight**. It is equal to  ``[dK_x, dK_y]`` for 2 spatial dimensions and it is equal to ``[dK_x, dK_y, dK_z]`` for 3 spatial dimensions. 
    - ``frSize`` : the size of the reconstructed frames. **Double precision, leight**. It is equal to  ``[frN_x, frN_y]`` for 2 spatial dimensions and it is equal to ``[frN_x, frN_y, frN_z]`` for 3 spatial dimensions.
    
We advise to set ``frSize`` equal to ``N_u`` for optimal image quality. 
If ``frSize`` is componentwise smaller than ``N_u`` some croping and zero-filling 
are used internally in the iterative reconstruction in order to regrid on the grid of size ``N_u``. 


These three arguments are the **Companions**. They are present in much of the functions involved in reconstructions.  
The choice of ``dK_u`` and ``N_u`` sets the virtual cartesian grid used for regridding
and inherently sets the voxel size :math:`[\Delta r_x, \Delta r_y, \Delta r_z]`: 

.. math::
    
   \Delta r_x = (1/dK_x)/N_x

   \Delta r_y = (1/dK_y)/N_y
   
   \Delta r_z = (1/dK_z)/N_z


Note that ``dK_u = 1./FoV`` where ``FoV`` is the true (non-croped) reconstruction FoV.  
The reconstruction FoV is set by the choice of ``dK_u``, or reversely, ``dK_u`` is set by the reconstruction FoV.  


.. note::

    The reconstruction FoV can be different from the acquisition FoV, that we will usually write *aFoV*.  


In order to avoid numerical problems due to large differences between volume elements, we have to limit them by a user defined upper bound that we called

    - ``ve_max``: the maximum volume element value that serves to limit ``ve`` in order to to avoid some convergence problems. *Single, scalar, leight*. 


For iterative reconstruction, the reconstruction function need a start ismage as input that we use to write

    - ``x0`` : The initial image for iterative reconstruction. **Complex valued, single precision, heavy**.  

The initial guess ``x0`` must have the same size as the reconstructed image. It must be a frame for static reconstructions and a cell-array for dynamic reconstructions. 

The number of iterations in reconstruction functions are given by

    - ``nIter``: the number of iterations of the outer-loop of iterative reconstruction. **Double precision, scalar, leight.**   
    - ``nCGD``: the number of iterations of the inner loop for the conjugate-gradient-descent. **Double precision, scalar, leight.**

For iterative reconstructions,  ``nIter`` is the number of iterations of the ADMM algorithm (outer loop) and ``nCGD`` is the number of CGD (inner loop) iterations.   
For least square reconstructions, ``nIter`` is the number of iterations of the CGD algorithm.


All least-square regularized reconstructions need a regularization weight. We provide an **adaptive** (automatic) and **normal** 
(manual) way to provide that weight. The choice is done by setting the parameter

    - ``regul_mode`` : Regularization mode. **String, length**. You can set it to **normal** or **adaptive**. 

If ``regul_mode`` is set to *adaptive*, the reconstruction function makes an automatic choice for the 
regularization weight in order to reach an equilibrium between the the data-fidelity term and the regularization term 
in the objective function.  

If ``regul_mode`` is set to **normal**, then is the regularization weight given by the input argument

    - ``delta`` : Regularisation parameter. **Single precision, leight.** The parameter ``delta`` can be either a scalar, or a list of 2 scalars ``[delta_min, delta_max]`` with `delta_min < delta_max` , or a vector of length `nIter`.  

If ``delta`` is a scalar, that number is used as regularization weight for each iteration. 
If ``delta`` is a vector of length `nIter`, iteration number `c` is performed with the regularization weight equal to the value 
at position `c` in the vector ``delta``. 
If ``delta`` is a list of 2 values ``[delta_min, delta_max]`` with `delta_min < delta_max`, then is  ``delta`` replaced 
by a list of length `nIter` by interpolating linearly `nIter` values between `delta_min` and `delta_max`.   

The ADMM algorithm (for l1 regularization) needs an additional **convergence parameter** that we will write

    - ``rho`` : Convergence parameter for the ADMM algorithm. **Single precision, scalar, leight.** A rule of thumb is to set ``rho`` equal to a multiple (from 1 to 20) of ``lambda`` (We don't say it is the best choice, we don't take any responsibility for this).    


For any non-cartesian reconstrucitons are

    - ``Gu`` : The gridding (sparse) matrix used for forward gridding in our iterative non-cartesian reconstructions. **Of class `bmSparseMat`, heavy.** 
    - ``Gut``: The transposed matrix of ``Gu`` used for backward (not inverse) gridding in our iterative non-cartesian reconstructions. **Of class `bmSparseMat`, heavy.** 

For the the sake of completeness and understanding of gridding, the construction of following sparase matrix is also implemented:

    - ``Gn``: The gridding (sparse) matrix that attempts to realize an "inverse" operation performed by ``Gu``. **Of class `bmSparseMat`, heavy.**  The inverse of ``Gu`` does not exist but ``Gn`` is constructed so that the composition ``Gn Gu`` is as close as possible to the identity.   

Before running any iterative non-cartesian reconstructions, you must estimate the gridding (sparse) matrices:

.. code-block:: matlab

    [Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

These two sparse matrices depend on the trajectory, the reconstruction FoV (given by ``dK_u``) and the k-space gridd size ``N_u``.

For image (not k-space) motion compensation are

    - ``Tu``        : the deformation (sparse) matrix used for forward deformation in our motion compensated reconstructions. **Of class `bmSparseMat`, heavy.** 
    - ``Tut``       : the transposed matrix of ``Tut`` for backward deformation. **Of class `bmSparseMat`, heavy.** 

Note that matrix ``Tut`` do not perform an inverse deformation. It realizes the transposed operation of the forward deformation. 

For the the sake of completeness and understanding of gridding, the construction of following sparase matrix is also implemented:

    - ``Tn``: The gridding (sparse) matrix that attempts to realize an "inverse" operation performed by ``Tu``. **Of class `bmSparseMat`, heavy.** The inverse of ``Tu`` may or may  not exist. In any case, ``Tn`` is constructed so that the composition ``Tn Tu`` is as close as possible to the identity.   

In order to monitor what is happening during a reconstruction (typically if this is taking lany hours) or just to have a track recoord of process after the reconstruction is finished, the following class has been implemented: 
    
    - ``witnessInfo``: Monitoring object to give as input argument to any iterative reconstruction function. **Of the class `bmWitnessInfo`, Leight.** It serves to store some monitoring information about the execution of the reconstruction process, in partocular some information about convergence and some 2D images at each iteration. 


.. note::
    The reconstructed image ``x`` and the monitoring object ``witnessInfo`` are saved in the current directory during the reconstruction.  
     
    


We have described all input arguments that you need to know to use our reconstruction functions. There are other but it is not critical to know them. 

Here is an example that summarizes the definitions of the leight input arguments: 

.. code-block:: matlab

    nIter               = 30; % number of iteration of the outer-loop of the algorithm.
    nCGD                = 4; % number of CGD iterations
    ve_max              = 6*prod(dK_u(:)); % maximum value of the volume elements. This is imprtant to avoid some numerical problems. 
    regul_mode          = 'normal'; % must be 'normal' or 'adaptive'. 

    delta               = 0.3;          % regularization parameter present in the objective function of iterative reconstructions.  
    rho                 = 10*delta;     % convergence parameter for ADMM

    witness_label       = 'myReconLabel';   % This label serves to name the files stored in the current directory during the reconstruction; 
    witness_ind         = 1:4:nIter;        % or []. If not empty, the current reconstructed image will be saved in the current directory if the current iteration number (outer loop) is in ``wintess_ind``.  
    save_witnessIm_flag = true;             % If true, the witness images (some 2D images) will be saved at every iteration of the outer loop. Set to false if rapidity is a priority. 

    myWitnessInfo       = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag); % Create an instance of bmWitnessInfo. 


Non-Cartesian Static Reconstructions
====================================

All reconstrucion calls presented in this section can be tested using the script
`static_recon_calls_script <https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/static_recon_calls_script.m>`_. 
that you can also find in the `script_demo` directory of Monalisa. 

.. _Mathilda:

Mathilda, the Initial Image-Reconstruction
------------------------------------------

Mathilda is our gridded, zero-padded, inverse DFT reconstruction for non-cartesian trajectories.
If the data are well sampled, then leads Mathilda already to a descent image. 
For iterative reconstruction of under sampled data, we mostly use Mathilda to perform the initial guess ``x0``  

Here is the function call: 

.. code-block:: matlab

    x0 = bmMathilda(y, t, ve, C, N_u, frSize, dK_u, [], [], [], []);

Note that you can also give the empty matrix `[]` instead of the coil-sensitivity C. In that case will Mathilda return the list of coil-images. 
You may then combine those images by any combination of your choice. If you don't have the coil-sensitivities, you can for example combine the 
coil-images by a root-mean-square, but the phase of the image is lost in that case.  

You can take a look at the image by running  

.. code-block:: matlab

    >> bmImage(x0);

Be aware that there could be a crash if the memory needed is too big,
and it can take a lot of time. Maybe it's better if you first test with small N_u and frSize values.




.. _Sensa:

Sensa
-----

This is our implementation of the iterative-SENSE reconstruction [1]_ for non-cartesian data.
It is a single-frame least-square reconstruction without regularisation. The objective function is minimized 
iteratively with the conjugate gradient descent (CGD) algorithm. 

Since it is a single frame reconstruction, it can be applied independently for all frames of a multiple-frame
image, but it does not share information between frames. Consequently, it performs poorly with heavily undersampled data.
However, despite its limitations, this method is important in the theoretical framework of reconstruction
and finds applications in specific cases.

.. code-block:: matlab

    witness_label = 'sens_demo'; 
    witnessInfo = bmWitnessInfo(witness_label, witness_ind);
    
    x = bmSensa(    x0{1}, y{1}, ve{1}, C, ...
                    Gu{1}, Gut{1}, frSize, ve_max, ... 
                    witnessInfo );

.. _Steva:

Steva
-----

Single-frame Least-square Regularized Reconstruction, 
where reularizaiton is the l1-norm of spatial gradient of the image. 

witness_label = 'steva_demo';

.. code-block:: matlab

    x = bmSteva(    x0{1}, ...
                    [], [], ...
                    y{1}, ve{1}, C, ...
                    Gu{1}, Gut{1}, frSize, ...
                    [], [], ...
                    delta, rho, 'normal', ...
                    nCGD, ve_max, ...
                    nIter, ...
                    witnessInfo);


.. _Sleva:

Sleva
-----

Single-frame Least-square Regularized Reconstruction, where reularizaiton is the l2-norm of the image. 

.. code-block:: matlab


    x = bmSleva(    x0, ...
                    [], [], ...
                    y, ve, C, ...
                    Gu, Gut, frSize, ...
                    [], [], ...
                    delta, rho, 'normal', ...
                    nCGD, ve_max, ...
                    nIter, ...
                    witnessInfo);




Deformation-Fields
==================

The deformation matrices (and their corresponding transposed matrices) serves to perform temporal regularization with movement compensation. 
The multiplication of an image vector by a deformation matrix defroms the image according to the deformation-field 
encoded in the deformation-matrix. A deformation-field must therefore be estimated prior to the definition of any deformation matrix. 

Here is a possible way to estimate deformation-fields. In that example, the deformation-field
between each frame and its (past and future) temporal neighboring frame is estimated with the `imregdemons` function of Matlab.  


.. code-block:: matlab

    %% deformation field evaluation with imReg Demon 
    reg_file                    = 'C:\path\to\your\reg_file';
    [DF_to_prev, imReg_to_prev] = bmImDeformFieldChain_imRegDemons23(h, frSize, 'curr_to_prev', 500, 1, reg_file, reg_mask); % past temporal neighbor
    [DF_to_next, imReg_to_next] = bmImDeformFieldChain_imRegDemons23(h, frSize, 'curr_to_next', 500, 1, reg_file, reg_mask); % futur temporal neighbor


Once the deformation-fields are estimated, the deformation-matrices can simply be defined as follows.:  


.. code-block:: matlab

    %% deformation fields to sparse matrices
    [Tu1, Tu1t] = bmImDeformField2SparseMat(DF_to_prev, N_u, [], true);
    [Tu2, Tu2t] = bmImDeformField2SparseMat(DF_to_next, N_u, [], true);


Note that the deformation-fields can be estimated by any tool as chosen by the user. Here is the use of `imregdemons` just an example. 

The computed deformation-matrices can be stored and reused many times with different functions described below.   



Non-Cartesian Chain Reconstructions
===================================


The next functions can be called with or without deformation-matrices given as argument. We will see both cases. 


.. _TevaMorphosia_chain:

TevaMorphosia_chain
-------------------


.. code-block:: matlab

    x = bmTevaMorphosia_chain(  
        x0, ...
        [], [], ...
        y, ve, C, ...
        Gu, Gut, frSize, ...
        Tu, Tut, ...
        delta, rho, 'normal', ...
        nCGD, ve_max, ...
        nIter, ...
        bmWitnessInfo(witness_label, witness_ind));


.. _TevaDuoMorphosia_chain:

TevaDuoMorphosia_chain
----------------------

Same as TevaMorphosia but with forward and backward temporal regularization, with or without deformation fields.

.. code-block:: matlab

    x = bmTevaDuoMorphosia_chain(   
        x0, ...
        [], [], [], [], ...
        y, ve, C, ...
        Gu, Gut, frSize, ...
        Tu1, Tu1t, Tu2, Tu2t, ...
        delta, rho, 'normal', ...
        nCGD, ve_max, ...
        nIter, ...
        witnessInfo);




.. _SensitivaMorphosia_chain:

SensitivaMorphosia_chain
------------------------

Least Square Regularized (LSR) reconstruction, where regularization is the squared 2 norm of 
finite difference time derivative. 

.. code-block:: matlab

    witnessInfo = bmWitnessInfo([witness_label, num2str(i)], witness_ind);

    x = bmSensitivaMorphosia_chain(
            x, ...
            y, ve, C, ...
            Gu, Gut, frSize, ...
            Tu, Tut, ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            nIter, ...
            witnessInfo)


.. _SensitivaDuoMorphosia_chain:

SensitivaDuoMorphosia_chain
---------------------------

Least Square Regularized (LSR) recon, where regularization is the squared 2 norm of 
finite difference time derivative. 

.. code-block:: matlab

    witnessInfo = bmWitnessInfo(witness_label, witness_ind);

    x = bmSensitivaDuoMorphosia_chain(
            x, ...
            y, ve, C, ...
            Gu, Gut, frSize, ...
            Tu1, Tu1t, Tu2, Tu2t, ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            nIter, ...
            witnessInfo)


Non-Cartesian Sheet Reconstructions
===================================



.. _TevaMorphosia_sheet:

TevaMorphosia_sheet
-------------------

Least Square Regularized (LSR) recon, where regularization is the squared 2 norm of 
finite difference time derivative. 

.. code-block:: matlab

    witnessInfo = bmWitnessInfo(witness_label, witness_ind);

    x = bmTevaMorphosia_sheet(
            x, ...
            y, ve, C, ...
            Gu, Gut, frSize, ...
            Tu1, Tu1t, Tu2, Tu2t, ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            nIter, ...
            witnessInfo)

.. _SensitivaMorphosia_sheet:

SensitivaMorphosia_sheet
------------------------

Least Square Regularized (LSR) recon, where regularization is the squared 2 norm of 
finite difference time derivative. 

.. code-block:: matlab

    witnessInfo = bmWitnessInfo(witness_label, witness_ind);

    x = bmSensitivaMorphosia_sheet(
            x, ...
            y, ve, C, ...
            Gu, Gut, frSize, ...
            Tu1, Tu1t, Tu2, Tu2t, ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            nIter, 
            witnessInfo)



Partial-Cartesian Static Reconstructions
========================================



Partial-Cartesian Chain Reconstructions
=======================================







.. [1] Pruessmann, K. P., Weiger, M., Börnert, P., & Boesiger, P. (2001).
    Advances in sensitivity encoding with arbitrary k-space trajectories. Magnetic Resonance in Medicine, 46(4), 638–651.
    https://doi.org/10.1002/mrm.1241.
