=======================================
Binning: Flexible Readout Rearrangement
=======================================

In this section, we discuss how to flexibly partition readouts into several groups (or bins) to select which ones will contribute to each reconstructed image frame. 
This operation is often called "binning". In addition to the partitioning, we often exlcude some data-lines, if needed, as part of the binning operation. 

There are many possible ways to rearrange the measurements, depending on the goal of the study. Here, we present some examples to showcase the flexibility of this framework.

.. important::
   Monalisa requires the binning to be a logical array of size `[nBins,nLines]`, where the element `Mask(i, j)` is true if we want to include the `j-th` line in the `i-th` reconstructed image. `nLines` is the total number of sampled radial lines.

.. toctree::
   :maxdepth: 1
   :glob:
   :includehidden:

   2-3-1_binning_eye_1
   2-3-2_binning_eye_2
   2-3-3_binning_respiratory
   2-3-4_binning_cardiac