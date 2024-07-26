Coil Sensitivity Map Estimation
===============================

This section covers the estimation of coil sensitivity maps.

## Overview

Coil sensitivity maps are crucial for various MRI applications, including image reconstruction and spatial localization. Estimating these maps accurately allows for improved image quality and quantitative analysis. This section details how coil sensitivity maps are computed using pre-scan images and how to perform this estimation using the `bmCoilSense_prescan_coilSense` function.

## General Method for Computing Coil Sensitivity Maps

In general coil estimation requires several steps:

1. **Acquire Prescan Images**:
   - Obtain low-resolution prescan images from each coil. These images capture the coil's response to a known signal and are used to estimate sensitivity maps.

2. **Create Composite Image**:
   - Compute a composite image using the sum-of-squares method. This method combines the images from all coils to create a single reference image that represents the combined signal.

   .. math::
      I_{\text{composite}}(x) = \sqrt{\sum_{i=1}^N |I_i(x)|^2}

   where :math:`I_i(x)` is the image from the :math:`i`-th coil and :math:`N` is the total number of coils.

3. **Normalize Coil Images**:
   - Normalize each coil's image with respect to the composite image to estimate the coil sensitivity map for each coil.

   .. math::
      S_i(x) = \frac{I_i(x)}{I_{\text{composite}}(x)}

   where :math:`S_i(x)` is the sensitivity map for the :math:`i`-th coil.

4. **Smoothing and Regularization (Optional)**:
   - Apply smoothing to the sensitivity maps to reduce noise and artifacts. This can be done using techniques such as Gaussian filtering.

   .. math::
      S_{i,\text{smoothed}}(x) = \text{GaussianFilter}(S_i(x))

## Computing Coil Sensitivity Maps Using `bmCoilSense_prescan_coilSense`

The `bmCoilSense_prescan_coilSense` function provides a robust method for estimating coil sensitivity maps from pre-scan images. Below is an explanation of how to use this function:

### Function Signature

.. code-block:: matlab

    function C = bmCoilSense_prescan_coilSense(x_body, x_surface, m, n_u)

see the implementation `here <https://github.com/MattechLab/monalisa/blob/main/src/bmCoilSense/from_prescan/bmCoilSense_prescan_coilSense.m>`_.

### Inputs

- **`x_body`**: 
  - Type: Numeric array
  - Description: Body coil prescan image. Can be 1D, 2D, or 3D. This image is used to estimate the body coil sensitivity.

- **`x_surface`**: 
  - Type: Numeric array
  - Description: Surface (array) coil prescan image. Can be 1D, 2D, or 3D. This image is used to estimate the sensitivity maps of the surface coils.

- **`m`**: 
  - Type: Logical array
  - Description: Mask segmenting the non-zero signal volume. The dimensions of this mask should match those of the images provided.

- **`n_u`**: 
  - Type: Numeric vector
  - Description: Image size excluding channels. For example, `[96, 96]` for a 2D image or `[64, 56, 32]` for a 3D image.

### Outputs

- **`C`**: 
  - Type: Numeric array (complex single)
  - Description: Estimated coil sensitivity maps for the surface coils. The output array will have the same dimensions as the input images, with an additional dimension for the coils.

### Description

1. **Initialization**:
   - The function initializes parameters for the Laplace solver and smoothing process.

2. **Normalization**:
   - It normalizes the body coil image and computes the root mean square (RMS) of the body coil image. This normalization is essential for accurate sensitivity map estimation.

3. **Estimate Body Coil Sensitivity**:
   - The function estimates the body coil sensitivity using pseudo-diffusion and refines it with a Laplace solver. This step provides a reference sensitivity map for the anatomical region.

4. **Estimate Surface Coil Sensitivity**:
   - For each surface coil, the function computes and refines the sensitivity maps using the anatomical reference and pseudo-diffusion method.

5. **Reshape Output**:
   - Finally, the function reshapes the estimated sensitivity maps to match the original dimensions of the input images.

### Example

Once you have your low resolution images you simply need to run:

.. code-block:: matlab

   % Define example inputs
   x_body = ...; % Body coil prescan image
   x_surface = ...; % Surface coil prescan image
   m = ...; % Mask of the signal volume
   n_u = [96, 96]; % Image size

   % Call the function
   C = bmCoilSense_prescan_coilSense(x_body, x_surface, m, n_u);
