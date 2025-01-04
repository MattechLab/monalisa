============
Introduction
============


The Design of Monalisa
======================



A few Definitions
=================

A static image will be called a **frame**. The spatial dimension of the reconstruced image will be called 
the **frame dimension** and will written ``frDim``. It is equal to 2 or 3. 

The spatial size of the image will be called the **frame size** and 
will be written ``frSize``. It is of the form ``[frNx, frNy]``
for 2D frames and of the form ``[frNx, frNy, frNz]`` for 3D frames. 

A dynamic image is an array of many frames. We will always store it as a cell-array. Each cell of the cell-array
contains then one frame of the image. For 1 non-spatial dimension, the cell-array is of size ``[nFr, 1]`` where ``nFr``
stands for **number of frames**. We will call such a cell-array a **chain (of frames)**. 
For 2 non-spatial dimensions, the cell-array is of size ``[nFr_1, nFr_2]``. We will call such a cell-array a **sheet (of frames)**. 

A sampling trajectory will be called a **Cartesian** trajectory if it is uniform and fully sampled. It will be called
**Partial-Cartesian** if it is a cartesian trajectory with missing points. In any other case it will be called **Non-Cartesian**. 

Reconstructions for non-cartesian and partial-cartesian trajectories are implemented by different functions.
The terminasion "**_partial_cartesian**" in the name of a function indicates a use for a partial cartesian trajectories. 
If that terminaison is absent from the name, it means that the reconstruction is for non-cartesian trajectories.
The present documentation do not describe reconstructions for Cartesian trajectories. 

All our iteartive reconstructions are least-square regularized reconstructions. We will write **LSR** for "**least-square regularized**". 
For each of our LSR reconstruction, we minimize the objective function either with the conjugate gradient descent method (**CGD**), or
the alternating direction method of multipliers (**ADMM**). 

Many kind of discrete Fourier transforms are involved in our theory of MRI reconstructions. 
We will write "**DFT**"" for "discrete Fourier transform". We will write :math:`F` with some super script to designate the matrix of a forward DFT as follows:  

    - We will write :math:`F^{Cart}` the forward DFT matrix for cartesian trajectories, 
    - We will write :math:`F^{PCart}` the forward DFT matrix for partial-cartesian trajectories,
    - We will write :math:`F^{NCart}` the forward DFT matrix for non-cartesian trajectories. 

The **inverse DFT** only exist for cartesian trajectories. 

For partial cartesian and non-cartesian trajectories we 
will call an **approx-inverse** any linear map that leads approximatively 
to the identity when it is composed with the forward DFT. 

The **adjoint DFT** always exist.


The the complex conjugate transpose of the DFT matrix is the matrix of a map that 
we will call the **star DFT**. The start and adjoint DFT are related but different in 
general. 

We use the following supper script for DFTs:

    - The matrix of the adjoint DFT will be written with supper scrpit :math:`\dagger`. 
    - The matrix of the star DFT will be written with supper scrpit :math:`*`.
    - The matrix of the inverse DFT, if it exists, will be written with supper scrpit :math:`-1`.  
    - The matrix of any approx-inverse DFT will be written with supper scrpit :math:`\sim  1`.  

.. note:: 
    The fast Fourier transform (**FFT**) algorithm is an algorithm that perform the DFT and inverse DFT for cartesian 
    trajectories in a rapid way. But the FFT algorithm do not realizes all kind of DFTs. 

The following tables summarizes the mathematical symboles that designate each of the 12 kind of DFTs involved in our MRI reconstructions. 

.. list-table:: 
    :header-rows: 1
    :align: center

    * - **DFT's**
      - Forward
      - Ajoint
      - Star
      - (Approx-) Inverse
    * - **Cartesian**
      - :math:`F^{Cart}`
      - :math:`(F^{Cart})^{\dagger}`
      - :math:`(F^{Cart})^{*}`
      - :math:`(F^{Cart})^{-1}`
    * - **Partial Cartesian**
      - :math:`F^{PCart}`
      - :math:`(F^{PCart})^{\dagger}`
      - :math:`(F^{PCart})^{*}`
      - :math:`(F^{Cart})^{\sim 1}`
    * - **Non-Cartesian**
      - :math:`F^{NCart}`
      - :math:`(F^{NCart})^{\dagger}`
      - :math:`(F^{NCart})^{*}`
      - :math:`(F^{NCart})^{\sim  1}`

Note that the notion of full sampling (and by extension of partial sampling) is defined by the sampling theorem, which is formulated only
for cartesian trajectories. There is no formally defined notion of under sampling for non-cartesian trajectories. 

Also note that among the 12 type of DFT s, some of them co-inside (up to a factor). For example, for cartesian trajectories 
are the  Adjoint, the Star and the Inverse DFT equal (they co-inside) up to a factor that depend on definitions. 
For partial-cartesian or non-cartesian trajectories, the notion of adjoint and star 
DFT do not longer co-inside while the inverse DFT do not longer exist in the strict sense. 




A Quick View at the List of our Reconstructions
===============================================

Here is the current list of our reconstructions: 

    *Non-Cartesian Static Reconstrucitons*: 

        - :ref:`Mathilda`: Gridded, zero-padded, approx-inverse DFT reconstruction.  
            .. math::
                x^\# = \underset{x \in X}{argmin} \lVert {C x - (F^{NCart})^{\sim  1} y} \rVert ^2_{X^{nCh}, 2}

        - :ref:`Sensa`: Iterative-SENSE reconstruction. 
            .. math::
                x^\# \in \underset{x \in X}{argmin} \lVert {F^{NCart}C x - y} \rVert ^2_{Y, 2}

        - :ref:`Steva`: LSR with spatial, anisotropic, total-variation regularization.
            .. math::
                x^\# \in \underset{x \in X}{argmin} \lVert {F^{NCart}C x - y} \rVert ^2_{Y, 2} + \frac{\delta}{2} \lVert {\nabla_r {} x} \rVert_{X, 1}

        - :ref:`Sleva`: LSR with regularized by the l2-norm of the image. 
            .. math::
                x^\# \in \underset{x \in X}{argmin} \lVert {F^{NCart}C x - y} \rVert ^2_{Y, 2} + \frac{\delta}{2} \lVert {x} \rVert_{X, 2}^2

    *Non-Cartesian Chain Reconstrucitons*:

        - :ref:`TevaMorphosia_chain`: LSR with regularization along one non-spatial dimension by l1-norm of the (motion-compensated) backward finite difference derivative. 
        - :ref:`TevaDuoMorphosia_chain`: LSR with regularization along one non-spatial dimension by l1-norm of the (motion-compensated) backward and forward finite difference derivative.
        - :ref:`SensitivaMorphosia_chain`: LSR with regularization along one non-spatial dimension by the squared l2-norm of the (motion-compensated) backward finite difference derivative.
        - :ref:`SensitivaDuoMorphosia_chain`: LSR with regularization along one non-spatial dimension by the squared l2-norm of the (motion-compensated) backward and forward finite difference derivative.

    *Non-Cartesian Sheet Reconstrucitons*:

        - :ref:`TevaMorphosia_sheet`: LSR with regularization along two non-spatial dimensions by l1-norm of the (motion-compensated) backward finite difference derivative. 
        - :ref:`SensitivaMorphosia_sheet`: LSR with regularization along two non-spatial dimensions by the squared l2-norm of the (motion-compensated) backward and forward finite difference derivative.

    *Cartesian Static Reconstrucitons*: 

        - `Nasha_cartesian`: Zero padded approx-inverse DFT reconstruction.
        - `Sensa_cartesian`: Iterative-SENSE reconstruction.

    *Cartesian Chain Reconstrucitons*:

        - `TevaMorphosia_chain_cartesian`: LSR with regularization along one non-spatial dimension by l1-norm of the (motion-compensated) backward and forward finite difference derivative.


Iterative reconstructions for Cartesian trajectories are not implemented yet in Monalisa. But all DFTs for that purpose 
are already present in the toolbox. Also, many partial-cartesian reconstructions are not implemented as compared to non-cartesian reconstructions. 

Feel free to try implementating some reconstructions missing in our list. We would be happy to test it and include it in Monalisa
if it works. In that case you would be the author of the reconstruction function that you wrote.  