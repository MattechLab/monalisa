=====================================================================
Acquisition Guidelines for Coil Sensitivity Estimation using Prescans
=====================================================================

We recommend using raw-data prescans for accurate coil sensitivity estimation. This requires two small extra acquisitions 
(one with body-coil and the same repeated with the surface coils) that are quick to perform. 
From the two resulting raw-data sets, the coil-sensitivity can be estimated by an iterative procedure that interact with the raw-data. 

Alternatively, prescan-images can be reconstructed from each prescan raw-data as a preparation setp. The coil-sensitivity estimation can then 
be performed in a simpler way from those prescan images. But if quality is a priority, we recomment the iterative procedure. 


Consider the following when acquiring prescans:

1. One prescan have to be performed with the body coil, while the second have to be performed with the same coils used for the main acquisition. Or inversely.
2. The Field of View (FOV) of the prescans have to match that of the main acquisition: in position, orientation, and size.
    But the matrix size can be smaller for the prescans.
3. For prescans, choose preferably acquisition parameters that result a low image contrast (as low as possible) and a high signal (as high as possible) everywhere tissue are present. 
    We need to get ride of contraste anyway by an image division for coil-sensitivity estimation.
    Maybe a small repetition time (TR) can help.
    In any case, the remaining presence of a strong contrast should still leads to an acceptable result.
4. The flip angle should be adapted to have enough signal.
    Good contrast is not required.

Practical hints for a Siemens scanner:
1. Try to avoid re-shimming between the two prescans.  
2. Make sure to select the ``Adjust with Body Coil`` checkbox in the protocol for prescans. It can help to avoid re-shimming between the two prescans. 
3. Set a protocol for the first prescan and then append the protocol of the second scan from first one.
4. Disable the automatic coil selection feature.
5. Listen between scans if you want to ensure there is no re-shimming or other adjustments occurring.

