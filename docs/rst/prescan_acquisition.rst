Acquisition Guidelines for Coil Sensitivity Estimation using Prescans
=======================================================================

We recommend using raw-data prescans for accurate coil sensitivity estimation. This requires two small extra acquisitions that are quick to perform. A second more simple possibility is to use two prescan images.

Consider the following when acquiring prescans:

1. One prescan have to be performed with the body coil, while the second have to be performed with the same coils used for the main acquisition.
2. The Field of View (FOV) of the prescans have to match that of the main acquisition.
3. Use a small repetition time (TR), as image contrast is not suitable. We should try to have signal everywhere in the limit of what is possbile.
4. The flip angle should be adapted to have enough signal.

Practical hints for a Siemens scanner:
1. Make sure to select the ``Adjust with Body Coil`` checkbox.
2. Append the protocol of the second scan to the first one.
3. Disable the automatic coil selection feature.
4. Listen between scans to ensure there is no re-shimming or other adjustments occurring.

