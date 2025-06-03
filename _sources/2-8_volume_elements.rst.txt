Volume Elements or Density Compensation
=======================================

What are Volume Elements? Basic Usage
--------------------------------------

Volume elements act as weights for each sampling point in k-space, enabling accurate image reconstruction. For **non-Cartesian distributions**, the sampling density is not constant in k-space. This means some regions are sampled more densely than others. Without proper compensation, this uneven distribution can cause severe artifacts in the reconstructed image.

A useful intuition: the **local point density** is inversely proportional to the volume element:

.. math::

    \text{Density at a point} \propto \frac{1}{\Delta k_p}.

This explains the term **density compensation** commonly used in MRI literature.

To compute the volume elements in **Monalisa**, use the following function:

.. code-block:: matlab

    ve = bmVolumeElement(trajectory, type_of_trajectory, optional_arguments)

Here the parameters are:
- `trajectory`: The k-space sampling positions (see the Trajectory section in the docs).
- `type_of_trajectory`: A string that determines which model is used to compute the volume elements. Carefully choose from the table below:

.. list-table:: Supported Trajectory Types
   :widths: 20 20 20
   :header-rows: 1

   * - **type_of_trajectory**
     - **Required Parameters**
     - **Use Case**

   * - ``voronoi_center_out_radial2``
     - None
     - 2D radial trajectory with center-out spokes (typical for 2D UTE)

   * - ``voronoi_center_out_radial3``
     - None
     - 3D radial trajectory with center-out spokes (typical for 3D UTE)

   * - ``voronoi_full_radial2``
     - None
     - 2D full radial trajectory with diametric spokes (center sampled twice)

   * - ``voronoi_full_radial3``
     - None
     - 3D full radial trajectory with diametric spokes (center sampled twice)

   * - ``voronoi_full_radial2_nonUnique``
     - ``nAvg``: number of averages
     - 2D full radial with duplicate samples, including multiple center acquisitions

   * - ``voronoi_full_radial3_nonUnique``
     - None
     - 3D full radial with duplicate samples, including multiple center acquisitions

   * - ``voronoi_box2``
     - None
     - Generic 2D layout without duplicates; fallback when no other type fits

   * - ``voronoi_box3``
     - None
     - Generic 3D layout without duplicates; **computationally expensive**, avoid for large data

   * - ``cartesian2``
     - None
     - 2D Cartesian grid (uniform sampling); assumes center point is at index N/2 + 1

   * - ``cartesian3``
     - None
     - 3D Cartesian grid (uniform sampling); assumes center point is at index N/2 + 1

   * - ``randomPartialCartesian2_x``
     - None
     - 2D Cartesian trajectory with randomly missing samples

   * - ``randomPartialCartesian3_x``
     - None
     - 3D Cartesian trajectory with randomly missing samples

   * - ``center_out_radial3``
     - None
     - Fast approximate estimation for 3D center-out radial (non-Voronoi)

   * - ``full_radial3``
     - None
     - Fast approximate estimation for 3D full radial (non-Voronoi)

   * - ``imDeformField2``
     - ``deformationField``: deformation vector field
     - 2D volume elements corrected for deformation fields (motion/distortion)

   * - ``imDeformField3``
     - ``deformationField``: deformation vector field
     - 3D volume elements corrected for deformation fields (motion/distortion)

You don't see your usecase, or you don't know which to pick? Consider opening an issue on Monalisa's GitHub page.

Volume elements are typically computed using **Voronoi parcellation**, which naturally estimates how much space each point "owns" in k-space. Each Voronoi cell contains all points closer to a given sample than to any other.

**Important notes:**

- Volume elements **depend on binning**. If you divide your acquisition into bins (e.g., for motion correction), recompute the volume elements **after** binning.
- It is **strongly recommended** to set a `ve_max` threshold to avoid numerical instability.
- Output `ve` is a `[1, nPt]` double-precision vector.
- The function does **not** normalize or rescale values.

.. code-block:: matlab

    % Set maximum volume element to avoid instability
    ve_max = 10 * dKu_x * dKu_y;  % For 2D
    ve_max = 10 * dKu_x * dKu_y * dKu_z;  % For 3D

Ok, but why are there Volume Elements?
--------------------------------------

Volume elements originate from the need to approximate integrals using discrete data. For example, consider the goal of computing:

.. math::

    \int_{\mathbb{R}^3} f(\mathbf{k})\,d^3\mathbf{k}.

With sampled k-space points :math:`\{\mathbf{k}_p\}_{p=1}^N`, we approximate:

.. math::

    \int_{\mathbb{R}^3} f(\mathbf{k})\,d^3\mathbf{k} \approx \sum_{p=1}^{N} \Delta k_p\, f(\mathbf{k}_p),

where :math:`\Delta k_p` is the **volume element** for point :math:`\mathbf{k}_p`.

In **Cartesian sampling**, all :math:`\Delta k_p` are constant, so we write:

.. math::

    \int_{\mathbb{R}^3} f(\mathbf{k})\,d^3\mathbf{k} \approx \Delta k \sum_{p=1}^{N} f(\mathbf{k}_p).

And therefore can be ignored since anyways raw data are usually normalized. However, in **non-Cartesian sampling**, the density of points varies across space, hence we need to estimate the :math:`\Delta k_p` for each point to correctly approximate the integral. For example **Radial** sampling oversamples the center. Historically, this concept is referred to as "density compensation" in MRI, originating from the transition from uniform trajectories, where the density is constant and can be neglected, to non-uniform trajectories. Although non-uniform density was once viewed as a problem to be “compensated”, it is in fact the general case, with uniform sampling being a special scenario.