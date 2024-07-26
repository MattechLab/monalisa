Coil Sensitivity Map Estimation
================================

After acquiring the body coil precan and the selected coil prescan, we first read in the metadata from these prescan files.

Please note that the input initialization shown below is not automated, as the names and content of the variables depend on the specific programmed sequence. For now, we just read and print the TwixInfo and set the input variables as an example, and you need to adjust the parameters manually. In the future, we will write a function to automate the ISMR rawData format for standardization.


.. code-block:: matlab

    bmTwix_info(bodyCoilFile)
    bmTwix_info(arrayCoilFile)

According to the TwixInfo printed above, we can generate the trajectory variables as below:

.. code-block:: matlab

    N            = 128; 
    nSeg         = 22; 
    nShot        = 419; 
    FoV          = [480, 480, 480]; 
    nShotOff     = 10; # The shots to be eliminated for better image quality 
    N_u          = [48, 48, 48]; # Size 
    dK_u         = [1, 1, 1]./480; 

    nCh_array    = 42; # number of selected coils
    nCh_body     = 2;  # number of body coils 

Please note that the initialization of the variables is not automated, as the names and content of the variables depend on the specific programmed sequence. For now, we just read and print the TwixInfo and set the input variables as an example, and you need to adjust the parameters manually. In the future, we will write a function to automate the ISMR rawData format for standardization.

We called the function `bmCoilSense_nonCart_dataFromTwix` for generating the raw data, trajectory points, and the volume element for the body coil.

.. code-block:: matlab

    [y_body, t, ve] = bmCoilSense_nonCart_dataFromTwix( bodyCoilFile, ...
                                                        N_u, ...
                                                        N, ...
                                                        nSeg, ...
                                                        nShot, ...
                                                        nCh_body, ...
                                                        FoV, ...
                                                        nShotOff)

Within the function `bmCoilSense_nonCart_dataFromTwix`:

- Extract raw data: `bmTwix_data`
  
- Compute trajectory: `bmTraj_fullRadial3_phyllotaxis_lineAssym2`
  
  - Here we assume we only use trajectory of 3D phyllotaxis
    
- Calculate the volume element: `bmVolumeElement`
  
  - We designed different options of trajectories as input of the function.
    
    .. code-block:: matlab
    
        ve      = bmVolumeElement(t, 'voronoi_full_radial3')

    For example, in this case, we use the voronoi algorithm to calculate the volume given a 3D radial trajectory.
    
    Please check the codes and choose the one you are using.
    
    [can add more description of the options here]
    
    If no case is your traj, you should define your own ve calculation function.
    
- Only keep the raw data in a box (set by `N_u`) to keep the frequencies for lower resolution. (?)

And we calculate the raw data for the selected array coils with the same function.

.. 
