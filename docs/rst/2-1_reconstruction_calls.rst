====================
Reconstruction Calls
====================

*Author : Jaime Barranco*

This section describes the functions calls of our reconstructions. 
All our reconstructions are implemented for 2 and 3 spatial dimensions. Some of them are static 
reconstruction (one signle frame) and other are dynamic (multiple-frames) with 1 or 2 non-spatial dimensions.

A static image will be called a `frame`. The spatial dimension of the reconstruced image will be called 
the `frame dimension` and will written ``frDim``. It is equal to 2 or 3. The spatial size of the image 
will be called the `frame size` and will be written ``frSize``. It is of the form ``[frNx, frNy]``
for 2D frames and of the form ``[frNx, frNy, frNz]`` for 3D frames. 

A dynamic image is an array of many frames. We will always store it as a cell-array. Each cell of the cell-array
contains then one frame of the image. For 1 non-spatial dimension, the cell-array is of size ``[nFr, 1]`` where ``nFr``
stands for `number of frames`. We will call such a cell-array a `chain (of frames)`. 
For 2 non-spatial dimensions, the cell-array is of size ``[nFr_1, nFr_2]``. We will call such a cell-array a `sheet (of frames)`. 

Reconstructions for non-cartesian and cartesian trajectories are implemented by different functions.
The terminasion "_partial_cartesian" in the name of a function indicates a use for a  
fully or parially sampled cartesian trajectory. If that terminasion is absent from the name, 
it means that the reconstruction is for non-cartesian trajectory.    

Here is the current list of our reconstructions: 

    *Non-Cartesian Static Reconstrucitons*: 

        - :ref:`Mathilda`: Gridded, zero-padded reconstruction for non-cartesian data (single-frame).  
        - :ref:`Sensa`: Iterative-SENSE reconstruction (single frame). 
        - :ref:`Steva`: CS recon with spatial (anisotropic) total-variation regularization (single frame). 
        - :ref:`Sleva`: Iterative-Sense reconstruction with regulerization by l2-norm of the image (single frame). 

    *Non-Cartesian Chain Reconstrucitons*:

        - :ref:`TevaMorphosia_chain`: CS recon with temporal regularization by l1-norm of temporal derivative (chain of frames). 
        - :ref:`TevaDuoMorphosia_chain`: CS recon with temporal regularization by l1-norm of (forward and backward) temporal derivative (chain of frames). 
        - :ref:`SensitivaMorphosia_chain`: Iterative-Sense with regularization by l2-norm of the temporal derivative (chain of frames).
        - :ref:`SensitivaDuoMorphosia_chain`: Iterative-Sense with regularization by l2-norm of the (forward and backward) temporal derivative (chain of frames).

    *Non-Cartesian Sheet Reconstrucitons*:


        - :ref:`TevaMorphosia_sheet`: CS recon with temporal regularization by l1-norm of temporal derivative (sheet of frames). 
        - :ref:`SensitivaMorphosia_sheet`: Iterative-Sense with regularization by l2-norm of the temporal derivative (sheet of frames). 

    *Cartesian Static Reconstrucitons*: 

        - `Sensa_partial_cartesian`: Iterative-SENSE reconstruction (single frame).

    *Cartesian Chain Reconstrucitons*:

        - `TevaMorphosia_chain_partial_cartesian`: CS recon with temporal regularization by l1-norm of temporal derivative (chain of frames).


Generic Arguments
=================

Some argument are (almost) always present in the argument list of all our reconstructions. 
We will call them the `generic arguments`. 


For static (single frame) reconstructions, ``y``, ``t`` and ``ve`` are arrays, while for dynamic reconstructions 
they are cell-arrays with one cell per data-bin and per frame. 

For static recontructions are: 

    - ``y``: the raw data. Complex-valued sinlge-precision. Of size ``[nPt, nCh]`` where ``nPt`` is the number of trajectory-points and ``nCh`` is the number of channels. 
    - ``t``: the trajectory. Double-precision. Of size ``[frDim, nPt]`` where the frame-dimension ``frDim`` is the spatial dimension of the frames (2 or 3) and ``nPt`` is the number of trajectory-points. 
    - ``ve``: the volume elements (inverse density compensation). Single precision.  Of size ``[1, nPt]`` where ``nPt`` is the number of trajectory-points. 


Refer to :doc:`2-2_mitosius_prepare` section to learn how to build ``y`` from the raw-data, how to build the trejectory ``t`` and how to estimate ``ve`` from ``t``. 

You can also build the trajectory ``t`` in your own way as long as you follow our convention described at the end of the `Mitosius` section. 
You can evaluate  ``ve`` by our functions if your trajectory is supported by Monalisa. Else you can obtain ``ve`` by your own means.  

For any reconstruciton is

    - ``C``: the estimated coil sensitivity map. It is a 4D complex single-precision array of size ``[frSize, nCh]``, where the frame-size ``frSize`` is the spatial size of the image and ``nCh`` is the number of coils. 

You can estimate ``C`` either by your own means or by our procedure described in a later section. 

For any reconstrucitons are

    - ``N_u`` : This is the size of the Cartesian gridd used for regridding in k-space. It is of size ``[Nx, Ny]`` for 2 spatial dimensionts and of size ``[Nx, Ny, Nz]`` for 3 spatial dimensions. 
    - ``dK_u`` : Is the step-size of the gridd used for regridding in k-space. It is of size ``[dK_x, dK_y]`` for 2 spatial dimensionts and of size ``[dK_x, dK_y, dK_z]`` for 3 spatial dimensions. 
    - ``frSize`` : Is the size of the reconstructed frames which we advise to set equal to ``N_u`` for optimal image quality. If ``frSize`` is componentwise smaller than ``N_u`` some croping and zero-filling are used internally in the iterative reconstruction in order to regrid on the grid of size ``N_u``. 


The choice of ``dK_u`` and ``N_u`` sets the virtual cartesian grid used for regridding
and inherently sets a maximum achievable spatial resolution of :math:`1/(dK\_u*N\_u)`. 
Note that ``dK_u = 1./FoV`` where ``FoV`` is the true (non-croped) reconstruction FoV, which is set by the choice of ``dK_u`` (or reversely) and can be different from the acquisition FoV. 


``y``, ``t``, and ``ve`` are included in what we call the *mitosius*,
with further explanation on how to create it in the section :doc:`2-2_mitosius_prepare`.

If your mitosius is already stored on the disk at the math ``m``, you can load it as follows: 

.. code-block:: matlab

    y   = bmMitosius_load(m, 'y'); 
    t   = bmMitosius_load(m, 't'); 
    ve  = bmMitosius_load(m, 've'); 

If you already saved a low-resolution coil sensitivity matrix ``C``, you can load it and resized it to the image-size as follows:

.. code-block:: matlab

    C_size = size(C); 
    C_size = C_size(1:frDim); 
    C = bmImResize(C, C_size, frSize);


For any non-cartesian reconstrucitons are

    - ``Gu`` and ``Gut``: The gridding (sparse) matrix and its transposed matrix used for forward and backward gridding in our iterative non-cartesian reconstructions. For a static reconstruction...

Other Arguments
===============

You will also encounter other argulents to pass as input to our reconstruction functions. Amongs them are:

    - ``delta`` : Regularisation parameter. Single precision scalar. 
    - ``rho`` : Convergence parameter for the ADMM algorithm. Single precision scalar. A rule of thumb is to set ``rho`` equal to a multiple (from 1 to 20) of ``lambda`` (We don't say it is the best choice, we don't take any responsability for this).    
    - ``nIter``: the number of iterations of the outer-loop of iterative reconstruction. Integer. 
    - ``nCGD``: the number of iterations of the inner loop for the conjugate-gradient-descent in iterative reconstructions. Integer. 
    - ``ve_max``: the maxium vomume element value that serves to limite ``ve`` in order to to avoid some convergence problems. Single precision scalar. 
    - ``witnessInfo``: An object of the class ``witnessInfo``. It serves to store some monitoring information about the execution of the reconstruction process, in partocular some information about convergence and some 2D images from each iteration. 



Non-Cartesian Static Reconstructions
====================================

The following section describes the script for static non-cartesian reconstruction that can be 
found `here <https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/static_recon_calls_script.m>`_.  
You will also find that script in the `script_demo` directory of Monalisa. 

The present section gives explanations about variables and functions of that script. 




.. _Mathilda:

Mathilda, the Initial Image-Reconstruction
------------------------------------------

Mathilda is our gridded zero-padded reconstruction for non-cartesian trajectories. 
It performs the initial guess that we often call ``x0``. 
Here is the funciton call for a single cell: 

.. code-block:: matlab

    x0 = bmMathilda(y, t, ve, C, N_u, frSize, dK_u, [], [], [], []);

To take a look at the image, run the following command: 

.. code-block:: matlab

    >> bmImage(x0);


Before running any iterative non-cartesian reconstructions, you must estimate the gridding (sparse) matrices:

.. code-block:: matlab

    [Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

These depend on the trajectory, the reconstruction FoV (given by ``dK_u``) and the k-space gridd size ``N_u``.

The following reconstruciton parameters are needed to test the static non-cartesian reconstructions. 

.. code-block:: matlab

    nIter               = 30; % number of iteration of the outer-loop of the algorithm. 
    witness_ind         = []; % Indices of the iterations at which the reconstructed image will be saved on the disk. 
    witness_label       = 'label'; % label to save the file on the disk.
    save_witnessIm_flag = false; % Set to true if you want some images of each iteration to be saved. Set to false if rapidity is a priority.  
    delta               = 0.1; % regularization parameter
    rho                 = 10*delta; % convergence parameter for ADMM
    nCGD                = 4; % number of CGD iterations
    ve_max              = 10*prod(dK_u(:)); % maximum value of the volume elements. This is imprtant to avoid some convergence problems. 



Be aware that there could be a crash if the memory needed is too big,
and it can take a lot of time. Maybe it's better if you first test with small N_u and frSize values.

For all the cases...

.. note::
    The reconstructed image ``x`` and the monitoring object ``witnessInfo`` are saved in the current directory.



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
where reularizaiton is the l&-norm of spatial gradient of the image. 

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
                    bmWitnessInfo(witness_label, witness_ind));


.. _Sleva:

Sleva
-----

Single-frame Least-square Regularized Reconstruction, where reularizaiton is the l2-norm of the image. 

.. code-block:: matlab

    witness_label = 'sleva_demo'; 

    x = bmSleva(    x0, ...
                    [], [], ...
                    y, ve, C, ...
                    Gu, Gut, frSize, ...
                    [], [], ...
                    delta, rho, 'normal', ...
                    nCGD, ve_max, ...
                    nIter, ...
                    bmWitnessInfo(witness_label, witness_ind));





Non-Cartesian Chain Reconstructions
===================================

For multiple-frame (dynamic) recontructions with one non-spatial dimension will be called *chain reconstructions*. 
In that case are

    - ``y``: the cell-array of raw-data bins. 
    - ``t``: the cell-array of trajectory bins. 
    - ``ve``: the cell-array of volume-elements bins. 

The cell of each cell-array is of size and type as given in the static case. 

 - ``Tu`` and ``Tut``: The deformation (sparse) matrix and its transposed matrix used for forward and backward defoemation in our motion compensated reconstructions.



Deformation Fields
------------------

The next functions can be called with or without deformation-matrices given as argument. We will see both cases. 

The deformation matrices (and their corresponding transposed matrices) serves to perform temporal regularization with mouvement compensation. 
The multiplication of an image vector by a deformation matrix defroms the image accroding to the deformation-field 
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

The computed deformation-matrices can be strored and re-used many times with different functions described below.   


.. _TevaMorphosia_chain:

TevaMorphosia_chain
-------------------

CS recon with temporal regularization, with or without deformation fields.

.. code-block:: matlab

    x = bmTevaMorphosia_chain(  
        x0, ...
        [], [], ...
        y, ve, C, ...
        Gu, Gut, frSize, ...
        [], [], ...
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
        [], [], [], [], ...
        delta, rho, 'normal', ...
        nCGD, ve_max, ...
        bmConvergeCondition(nIter), ...
        bmWitnessInfo(witness_label, witness_ind));




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
            [], [], ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            convCond, witnessInfo)


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
            [], [], [], [], ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            nIter, witnessInfo)


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
            [], [], [], [], ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            nIter, witnessInfo)

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
            [], [], [], [], ...
            delta, regul_mode, ...
            nCGD, ve_max, ...
            nIter, witnessInfo)






.. [1] Pruessmann, K. P., Weiger, M., Börnert, P., & Boesiger, P. (2001).
    Advances in sensitivity encoding with arbitrary k-space trajectories. Magnetic Resonance in Medicine, 46(4), 638–651.
    https://doi.org/10.1002/mrm.1241.
