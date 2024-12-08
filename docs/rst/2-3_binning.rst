=======================================
Binning: Flexible Readout Rearrangement
=======================================

In this section, we discuss how to flexibly partition readouts into several groups (or bins) to select which ones will contribute to each reconstructed image frame. 
This operation is often called "binning". In addition to the partitioning, we often exlcude some data-lines, if needed, as part of the binning operation. 

There are many possible ways to rearrange the measurements, depending on the goal of the study. Here, we present some examples to showcase the flexibility of this framework.

.. important::
   Monalisa requires the binning to be a logical array of size `[nBins,nLines]`, where the element `Mask(i, j)` is true if we want to include the `j-th` line in the `i-th` reconstructed image. `nLines` is the total number of sampled radial lines.

First Example: Sequential Binning
=================================

Sequential binning is one of the simplest ways to partition lines, splitting data sequentially by acquisition time. This method is particularly useful for imaging modalities that depend on temporal dynamics, such as resting-state fMRI, where we want to monitor the timecourse of the BOLD signal across brain regions. In sequential binning, we aim to generate a sequence of frames as illustrated below:

.. image:: ../images/sequential_binning.png
   :width: 90%
   :align: center
   :alt: Sequential binning groups data based on time.

For this example, we assume the unit of time is milliseconds, and that we want to produce a temporal sequence of images, each one containing data acquired over a period of 2 seconds (window size).

Steps for Sequential Binning
----------------------------

1. **Initialize and Set Parameters**:
   Start by configuring the temporal window size and extracting metadata from the acquisition parameters. The `RawDataReader` object provides the necessary data for binning, such as the number of measures, the number of segments per shot (`nSeg`), and timestamps for each readout.

   .. code-block:: matlab

      % Set temporal window size
      temporalWindowSec = 2; %magic number
      
      % Extract parameters from acquisition
      acquisitionParams = reader.acquisitionParams;
      % Total amount of lines
      nLines = acquisitionParams.nLine;
      % This only makes sense for phyllotaxis spiral
      nSeg = acquisitionParams.nSeg;
      % Non steady state lines
      nSegNotSS = acquisitionParams.nShot_off*acquisitionParams.nSeg;

2. **Adjust and Scale Timestamps**:
   The timestamps from the acquisition are adjusted to remove non-steady-state measurements, which are not used for image reconstruction. These timestamps are converted into milliseconds for easier manipulation.

   .. code-block:: matlab

      % Adjust timestamps and scale to milliseconds
      costTime = 2.5;  % Siemens-specific constant
      timeStamp = acquisitionParams.timestamp;
      timeStamp = timeStamp - min(timeStamp);
      % Relative time w.r.t. beginning of acquisition in milliseconds
      timestampMs = timeStamp * costTime; 
      % Non steady state time: example of filtering
      notSSTime = timestampMs(nSegNotSS);

3. **Determine the Number of Temporal Bins**:
   Based on the total duration of valid data, calculate how many temporal bins (masks) are needed. Each bin corresponds to a fixed duration (e.g., 2 seconds).

   .. code-block:: matlab

      % Calculate total duration and number of temporal bins (masks)
      totalDuration = max(timestampMs) - notSSTime;
      temporalWindowMs = temporalWindowSec * 1000;
      nMasks = floor(totalDuration / temporalWindowMs);

4. **Create and Assign Bins**:
   For each temporal bin, identify the corresponding measurements based on their timestamps. The binning masks (`seqMask`) are initialized as logical arrays, where each bin corresponds to a set of measurements that occurred within the temporal window. SI projections (special measurements that should not contribute to image reconstruction) are excluded from each bin.

   .. code-block:: matlab

      % Initialize binning masks
      seqMask = false(nMasks, nLines);
      % Populate the masks for each time window
      for i = 1:nMasks
            windowStart = notSSTime + (i-1) * temporalWindowMs;
            windowEnd = windowStart + temporalWindowMs;
            % Create mask for the current time window
            mask = (timestampMs >= windowStart) ...
            & (timestampMs < windowEnd);
            % Assign the mask to the bin matrix
            seqMask(i, :) = mask;
      end

The reconstructed images result from the contribution of each line within the associated bin. In this case, the image represents the average BOLD signal over the 2-second interval corresponding to each bin.

.. tip::
   The binning process is usually composed of two main parts:

   1. A filtering of data not adeguate for image reconstruction (e.g., not steady state)
   2. A partition of the data, to produce several frames.

   Clearly the partitioning depends on the analysis that will be applied later.
   For example, to estimate rigid motion we are need to apply sequential binning.

Second Example: Task-Based (Hi-Fi) fMRI
========================================

This section discusses the binning process for task-based fMRI, which focuses on isolating the haemodynamic response to specific stimuli. By averaging multiple trials, this method effectively reduces the contributions of temporally uncorrelated brain activity, resulting in a clearer signal.

For instance, in a visual stimulation study, delayed activation in the brain's visual processing regions can be captured without assumptions about the shape of the haemodynamic response. This is done by combining readouts from several trials and reconstruct images that reflect the average response across trials, minimizing the effect of noise from activations that are uncorrelated with the stimulation.

.. image:: ../images/hifi_fMRI_binning.png
   :width: 90%
   :align: center
   :alt: Task-based fMRI binning

To implement this binning strategy, we generate a logical array, `hifiMask`, of size `[nBins, nLines]`, where `hifiMask(i, j)` is true if the j-th measurement corresponds to the i-th bin. The number of bins is determined by the total duration of the trial and the temporal resolution we aim to achieve for the haemodynamic response. Of course you need to have enogh lines in each bin if you want to successfully reconstruct images.

Steps for Hi-Fi Binning:
------------------------

1. **Initialize and Set Parameters**:
   
   We extract parameters from the `RawDataReader` object, which include the number of measurements, segments, and the number of shots to exclude. This information is vital for creating the mask and ensuring accurate binning.

   .. code-block:: matlab
      
      % Extract parameters from acquisition
      acquisitionParams = reader.acquisitionParams;
      % Total amount of lines
      nLines = acquisitionParams.nLine;
      % This only makes sense for phyllotaxis spiral
      nSeg = acquisitionParams.nSeg;
      % Non steady state lines
      nSegNotSS = acquisitionParams.nShot_off*acquisitionParams.nSeg;

2. **Calculate Timestamps:**

   Normalizing the timestamps allows us to accurately track the timing of each measurement in milliseconds. This is essential for defining the intervals for each bin.

   .. code-block:: matlab
   
      % Adjust timestamps and scale to milliseconds
      costTime = 2.5;  % Siemens-specific constant
      timeStamp = acquisitionParams.timestamp;
      timeStamp = timeStamp - min(timeStamp);
      % Relative time w.r.t. beginning of acquisition in milliseconds
      timestampMs = timeStamp * costTime; 
      % Non steady state time: example of filtering
      notSSTime = timestampMs(nSegNotSS);

3. **Determine Number of Bins:**

   Based on the total duration of the trial and the specified temporal resolution, we calculate the number of bins required for the analysis. This is essential for structuring the `hifiMask` array correctly.

   .. code-block:: matlab

      % We assume the stimulation and acquisition are synchronized
      nMasks = floor(trialDurationSec / temporalResolutionSec);
      windowDuration = trialDurationSec/nMasks;

4. **Initialize the Mask Matrix:**

   Create a logical mask matrix initialized to `false`, which will be populated with `true` values indicating the measurements belonging to each bin.

   .. code-block:: matlab

      hifiMask = false(nMasks, nLines);

5. **Populate the Bin Masks:**

   For each bin, we define the time window and create a mask that indicates which measurements fall within that window. We also exclude specific measurements corresponding to SI projections to enhance the quality of the data. In this case we have to handle non steady state a bit differently: we cannot shift all the bins temporally as in the previous example, this is because binning is linked to the visual stimulation temporally.

   .. code-block:: matlab

      start = 0;
      for i = 1:nMasks
         maskOffset = (i-1)*(temporalResolutionSec)*1000
         for j = 1:nTrials
            % Define the start and end of the current trial
            trialStartTime = (j-1)*trialDurationSec*1000

            windowStart = trialStartTime + maskOffset; % Convert to ms
            windowEnd = windowStart + (temporalResolutionSec)*1000;
            
            % Create the mask for the current trial
            % Remove non steady state data
            mask = (timestampMs >= notSSTime) ... 
            &  (timestampMs >= windowStart) ...
            & (timestampMs < windowEnd);

            % Assign the mask to the hifiMask matrix
            hifiMask(i, :) = hifiMask(i, :) | mask;
      end

The resulting `hifiMask` will allow for the reconstruction of images that reflect the average haemodynamic response across trials, facilitating more accurate analysis of brain activation during task-based fMRI studies.


Third Example: Respiratory Binning for Motion-Resolved Cardiac MRI using Superior-Inferior (SI) Projections
===========================================================================================================


The present respiratory binning procedure is implemented in the script `lineMask_resp_fromSI_script.m`. 
It returns a list of masks (one mask per bin) as a binary array of size `[nBin, nLines]` where `nLines` is 
the total number of acquired lines in the sequence.

Each mask corresponds to a respiratory phase extracted from the superior inferior (SI) projections 
acquired as the first line of each shot of a 3D-radial free running sequence (ref sequence???). 

In order to run the scripts, the SI’s must be prepared in an array named `SI` of size `[nCh, N, nShot]` 
where `nCh` is the number of channels in the raw data, `N` is the number of points per acquired line, 
and `nShot` is the total number of shots acquired during the sequence. We describe here 
each section of the script. 


Steps for Respiratory Binning using SI projections:
---------------------------------------------------


1. **Initialization**


   Here we set some parameters to help the program to recognize correct sizes 
   and to inform the rest of the procedure. Enter the requested parameters 
   as described more in detail below. You can then run the section. 

   .. code-block:: matlab
      
      %% Initialization
      
      filter_type                 = 'lowPass';    
                                    % 'lowPass'  for respiratory binning

      nMask                       = 4; 
      maskWidth                   = 1; % a with of 1 expresses no overlap. 
      nSignal_to_select           = 1; % 1 manually, untrended, 
                                       % selected signal for resp. 
                                       % binning 

      signal_exploration_level    = 'medium';     
                                    % 'leight' or 'medium' 
                                    % or 'heavy'

      nCh                         = 20; 
      N                           = 384; 
      nSeg                        = 22; 
      nShot                       = 3870;

      nLine                       = nSeg*nShot; 
      nPt                         = N*nLine; 



   -	`filter_type` must be set to `lowPass` for respiratory binning. 
   -	`nMask` is the number of masks (or bins) that we want in the output. 
   -	`maskWidth` expresses how much the bins can overlap between neighbors. A value of 1 expresses no overlap. A value of 1.2 expresses 20% overlap. 
   -	`signal_exploration_level` expresses the number of candidates signals the automatic search is going to generate. For a modern labtop you can chose `medium`. For a larger computer you can chose `heavy`. 
   -	`nCh` is the number of channels in the raw data. 
   -	`N` is the number of points per acquired lines. 
   -	`nSeg` is the number of segments per shot in the sequence. 
   -	`nShot` is the total number of acquired shots in the sequence. 



2. **Constructing root-mean-squared SI for display** 

   This section requires no input. 
   It is just evaluating the root-mean-squared SI's for a display purpose. 
   You can just run the section. 

   .. code-block:: matlab
      
      %% getting rmsSI from SI
      
      rmsSI = bmMriPhi_fromSI_rmsSI(SI, nCh, N, nShot); 



3. **Extracting one single Reference Signal for Respiratory Binning** 

   The goal of this section is to extract a single reference physiological 
   signal that will serve to perform the respiratory binning. 

   .. code-block:: matlab

      %% getting standart_reference_signal from SI

      [s_ref, ...
      t_ref, ...
      Fs_ref, ...
      nu_ref, ...
      imNav, ...
      ind_shot_min, ...
      ind_shot_max, ...
      ind_SI_min, ...
      ind_SI_max, ...
      s_reverse_flag   ] =... 
      bmMriPhi_fromSI_get_standart_reference_signal(rmsSI, ...
                                                    nCh, ...
                                                    N, ...
                                                    nSeg, ...
                                                    nShot); 
   
   Run the section and you will see a graphical interface appear. 
   You should be able to recognize the respiratory patern. 

   .. image:: ../images/respiratory_binning/ref_signal_1.png
      :width: 90%
      :align: center
      :alt: Graphical Interface to Select the Reference Signal


   You need now to define 3 pairs of lines by 6 clicks (and some possible re-adjustments) 
   and then close the window to terminate the section.


   The first pair of lines is to define a horizontal window. 

      - Do `s + Left Click` to set the left end of the window.
      - Do `s + Right Click` to set the right end of the window.

   The program is going to construct internally the even extension 
   of the reference signal extracted by the present section. Observe 
   next figure to select the left and right end of the horizontal 
   window so that no pathology occurs, if possible (it is not critical 
   but do your best). 
   
   .. image:: ../images/respiratory_binning/even_extension.png
      :width: 90%
      :align: center
      :alt: Even Extension and Associated Pathologies
   
   In order to avoid pathologies in the even extension of the reference signal, 
   we will select the left and right ends (yellow vertical bars) of the 
   horizontal window either in two maxima of the respiratory patern, or in two minima.
   You can zoom with the loop to click precisely.  
   
   Note that the left end of that horizontal window also serve to exclude the 
   non-steady-state acquired data.

   Here is an example of the selection for the left and right ends of the horizontal
   window. 

   .. image:: ../images/respiratory_binning/left_end.png
      :width: 90%
      :align: center
      :alt: Left end of horiozntal window


   .. image:: ../images/respiratory_binning/right_end.png
      :width: 90%
      :align: center
      :alt: Right end of horiozntal window


   You have now to define the lower and upper bound of the vertical window that
   contains the some caracteristic patterns of respiration. The best way to do it
   is to select some vertical window that seems to contain some respiratory pattern
   and then adjust it as described below. Make two clicks as follows: 

      - Do `x + Left Click` to set the lower bound of the window.
      - Do `x + Right Click` to set the upper end of the window.

   After the first click you shou see someting like this: 

   .. image:: ../images/respiratory_binning/lower_bound.png
      :width: 90%
      :align: center
      :alt: Lower bound vertical window


   And after the second click you shou see someting like that: 

   .. image:: ../images/respiratory_binning/upper_bound.png
      :width: 90%
      :align: center
      :alt: Upper bound vertical window
    
   The red line is the reference signal generated from the selected windows. 
   It is a weighted average of the grey values in the vertical window. 
   You have now to adjust it: 

      - press the up-arrow to shift the vertical window up, 
      - press the down-arrow to shift the vertical window down,
      - press the ctrl+right-arrow to increase the width of vertical window,
      - press the ctrl+left-arrow to decrease the width of vertical window,

   .. image:: ../images/respiratory_binning/ref_signal_2.png
      :width: 90%
      :align: center
      :alt: ref_signal_2
   
   You can also 

      - press ctrl+up-arrow to increase the displayed amplitude of the reference signal,
      - press ctrl+down-arrow to decrease the displayed amplitude of the reference signal.
      - press ctrl+R to flip up-down the reference signal. 

   After playing with those adjustments, you may be able to end up with something 
   similar like the next figure.  
      
   .. image:: ../images/respiratory_binning/ref_signal_3.png
      :width: 90%
      :align: center
      :alt: ref_signal_3


   Finally, chose a vertical window that will serve for display purpose 
   only in the rest of the precedure.

      - press n + left-click to select the lower bound of the display window, 
      - press n + right-click to select the upper bound of the display window. 


   After the first click you shou see someting like this: 

   .. image:: ../images/respiratory_binning/ref_signal_4.png
      :width: 90%
      :align: center
      :alt: ref_signal_4


   And after the second click you shou see someting like that: 

   .. image:: ../images/respiratory_binning/ref_signal_5.png
      :width: 90%
      :align: center
      :alt: ref_signal_5  


   You can now close the windows and the chosen reference signal will
   automatically be saved. 



4. **Graphical Frequency Selector**

   We will now lowpass filter the reference signal. Run the following section.  

   .. code-block:: matlab

      %% graphical frequency selector
      
      [ s_ref_lowPass, ...
      s_ref_bandPass, ...
      lowPass_filter, ...
      bandPass_filter ] = ...
      bmMriPhi_graphical_frequency_selector(s_ref, ...
                                            t_ref, ...
                                            Fs_ref, ...
                                            nu_ref, ...
                                            imNav); 
                                                               

   You should then see the graphical frequency selector appear. In the left pannel is the 
   frequency spectrum of the reference signal displayed, and the right pannel 
   is the reference signal displayed.  
   On the left pannel, in the upper line of buttons, press the more right button the stretch 
   the frequency axis to the right until you see a similar picture like the following.  

   .. image:: ../images/respiratory_binning/freq_select_1.png
      :width: 90%
      :align: center
      :alt: freq_select_1  

   Still on the left pannel, in the lower line of buttons, on the right, press the "<<<" button
   to decrese the value of the maximum frequency of the filter. You may have to press many times 
   until the effect appears on the displayed range of frequencies. You can also use the buttons 
   "<<" and "<" to be more precise. Try to identify the peak arround the base frequency of 
   the respiratory signal, and create a lowpass filter that include that peak, like on the 
   following figure. 

   .. image:: ../images/respiratory_binning/freq_select_2.png
      :width: 90%
      :align: center
      :alt: freq_select_2  


   For respiratory binning, keep the minimum frequency of the filter at 0. We do a lowpass 
   filter (bandpass will be for cardiac binning). 
   
   Then press the button "Filter Signal". 
   The filtered signal appears then in blue on the right pannel. 
   You can press "Hide Yelow" to discard the reference signal. 
   
   .. image:: ../images/respiratory_binning/freq_select_3.png
      :width: 90%
      :align: center
      :alt: freq_select_3  
   
   
   You can stretch the time axis in both directions using the "<<<" and ">>>" buttons  
   and navigate using the "--->" and  "<---" buttons to inspect the filtered 
   reference signal. Make sure that the signal looks like a sinusoid modulated in 
   amplitude and frequency, but that no harmonic of the base frequency are expressed. 
   There should ideally be no ringing in the filtered signal.   


     .. image:: ../images/respiratory_binning/freq_select_4.png
      :width: 90%
      :align: center
      :alt: freq_select_4  


   If needed, you can re-adjust the filter and press "Filter Signal" again, 
   until the filtered signal looks like a modulated sinusoid. You can then close
   window and the filter will be saved.

   Note that you can change the contrast of the background in the right 
   pannel with the imcontrast tool of Matlab by pressing the "imcontrast" button. 
   But once you have changed the contrast, press the "fix contrast" buton, else
   changes in contrast will be lost.  
 

5. **Reformating the Filtered Signal**

   Just execute the following automatic section. 

   .. code-block:: matlab
      
      %% reformated_signal_ref
      check_image = rmsSI(ind_SI_min:ind_SI_max, :); 
      reformated_signal_ref = ...
      bmMriPhi_fromSI_standartSignal_to_reformatedSignal(s_ref_lowPass, ...
                                                         nSeg, ...
                                                         nShot, ...
                                                         ind_shot_min, ...
                                                         ind_shot_max, ...
                                                         check_image);
                                                                              

   A figure appears then to show the filtered signal reformated with the correct size. 
   You can check on that figure that the filtered signal oscillate toghether with the 
   background. 

   .. image:: ../images/respiratory_binning/resp_confirm.png
      :width: 90%
      :align: center
      :alt: resp_confirm  

   You can close that figure and go to the next section. 


6. **Looking for Signal Candidates in Order to Create a Phase**

   This section is important for cardiac binning. It has no effect for the present 
   respiratory binning. Just run it and go to the next. 

   .. code-block:: matlab
      
      %% extracting reformated_signal_list from SI 
      if nSignal_to_select > 1 
         nSignal_to_select_minus_1 = nSignal_to_select - 1; 
         reformated_signal_list = ...
         bmMriPhi_fromSI_collect_signal_list(filter_type, ...
                                             t_ref, ...
                                             nu_ref, ...
                                             SI, ...
                                             lowPass_filter, ...
                                             bandPass_filter, ...
                                             nCh, ...
                                             N, ...
                                             nSeg, ...
                                             nShot, ...
                                             nSignal_to_select_minus_1, ...
                                             signal_exploration_level, ...
                                             ind_shot_min, ...
                                             ind_shot_max, ...
                                             ind_SI_min, ...
                                             ind_SI_max, ...
                                             s_reverse_flag);
      else
         reformated_signal_list = []; 
      end

      reformated_signal_list = cat(1, ...
                                 reformated_signal_ref, ...
                                 reformated_signal_list); 




7. **Selecting the Best Candidate Signals**

   This section is to include and exclude candidate signals for cardiac binning. 
   In the present case of respiratory binning, we have only one candidate. 
   You can run section.   

   .. code-block:: matlab
      
      %% exclude some of the signals manually
      final_signal_list = ...
      bmMriPhi_manually_exclude_signal_of_list( reformated_signal_list ); 


   A figure appears to display our single candidate signal. Just close the figure. 
   

   .. image:: ../images/respiratory_binning/accept_resp.png
      :width: 90%
      :align: center
      :alt: accept_resp 

   Then accept the signal, and go to the next section.

   .. image:: ../images/respiratory_binning/accept_refuse.png
      :width: 40%
      :align: center
      :alt: accept_refuse 
   


8. **Create the Masks**

   Here is the last section for respiratory binning. You can run it. 

   .. code-block:: matlab
      
      %% mask_construction
      rMask = bmMriPhi_magnitude_to_mask(final_signal_list, ...
                                         nMask, ...
                                         nSeg, ...
                                         nShot, ...
                                         ind_shot_min, ...
                                         ind_shot_max); 
                                          

   .. image:: ../images/respiratory_binning/resp_mask.png
      :width: 90%
      :align: center
      :alt: resp_mask 

   The binning mask are displayed and stored in the variable rMask. Note that
   some first linest are excuded by the masks, in accordance with the choice of the
   horizontal window, which was chosen to exclude non-steady state acquired lines
   at the begining of the precedure. 

   You can then save rMask on the disk for a future purpose.                                           
   


Fourth Example: Cardiac Binning for Motion-Resolved Cardiac MRI using Superior-Inferior (SI) Projections
========================================================================================================

The present cardiac binning procedure is implemented in the script `lineMask_card_fromSI_script.m`. 
It returns a list of masks (one mask per bin) as a binary array of size `[nBin, nLines]` where `nLines` is 
the total number of acquired lines in the sequence.

Each mask corresponds to a cardiac phase extracted from the superior inferior (SI) projections 
acquired as the first line of each shot of a 3D-radial free running sequence (ref sequence???). 

In order to run the scripts, the SI’s must be prepared in an array named `SI` of size `[nCh, N, nShot]` 
where `nCh` is the number of channels in the raw data, `N` is the number of points per acquired line, 
and `nShot` is the total number of shots acquired during the sequence. We describe here 
each section of the script. 

This script is  similar to the script for respiratory binning, but we run sometimes some different 
functions with different parameters.  


Steps for Cardiac Binning using SI projections:
---------------------------------------------------


1. **Initialization**


   Here we set some parameters to help the program to recognize correct sizes 
   and to inform the rest of the procedure. Enter the requested parameters 
   as described more in detail below. You can then run the section. 

   .. code-block:: matlab
      
      %%
      filter_type                 = 'bandPass'; 
                                    % 'bandPass' for card. binning 
                                                
      nMask                       = 18; % Should be adapted to heart_rate.  
      maskWidth                   = 1;  % A width of 1 expresses no overlap.
                                        % A width of 1.2 expresses 20% overlapp. 

      nSignal_to_select           = 20; % 15 to 25 for card. binning.
                                           

      signal_exploration_level    = 'medium';   
                                    % 'leight' or 'medium' or 'heavy'

      nCh                         = 20; 
      N                           = 384; 
      nSeg                        = 22; 
      nShot                       = 3870;

      nLine                       = nSeg*nShot; 
      nPt                         = N*nLine; 



   -	`filter_type` must be set to `bandPass` for cardiac binning. 
   -	`nMask` is the number of masks (or bins) that we want in the output. 
   -	`maskWidth` expresses how much the bins can overlap between neighbors. A value of 1 expresses no overlap. A value of 1.2 expresses 20% overlap. 
   -	`nSignal_to_select` is a number of candidate signals generated in the procedure. We will manually select among them some signals that will serve to create a phase for cardiac binning.  
   -	`signal_exploration_level` expresses the number of candidates signals the automatic search is going to generate. For a modern labtop you can chose `medium`. For a larger computer you can chose `heavy`. 
   -	`nCh` is the number of channels in the raw data. 
   -	`N` is the number of points per acquired lines. 
   -	`nSeg` is the number of segments per shot in the sequence. 
   -	`nShot` is the total number of acquired shots in the sequence. 



2. **Constructing root-mean-squared SI for display** 

   This section requires no input. 
   It is just evaluating the root-mean-squared SI's for a display purpose. 
   You can just run the section. 

   .. code-block:: matlab
      
      %% getting rmsSI from SI
      rmsSI = bmMriPhi_fromSI_rmsSI(SI, nCh, N, nShot); 


3. **Extracting one Reference Signal to Start With** 

   The goal of this section is to extract one reference physiological 
   signal to start the procedure of cardiac binning. More signals will be 
   generated later.   

   .. code-block:: matlab

      %% getting standart_reference_signal from SI

      [s_ref, ...
      t_ref, ...
      Fs_ref, ...
      nu_ref, ...
      imNav, ...
      ind_shot_min, ...
      ind_shot_max, ...
      ind_SI_min, ...
      ind_SI_max, ... 
      s_reverse_flag   ] = ...
      bmMriPhi_fromSI_get_standart_reference_signal(  rmsSI, ...
                                                      nCh, ...
                                                      N, ...
                                                      nSeg, ...
                                                      nShot ); 

   
   Run the section and you will see a graphical interface appear. 
   By pressing ctr+E you will see the imcontrast interface appear. 
   
   You may be able to adjust to contrast in order to see some vertical 
   strikes that are typical of cardiac mouvement, as on the following figure. 

   Press shift + E to freeze the chosen contrast, else it will be lost. 


   .. image:: ../images/cardiac_binning/cardiac_binning_01.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_01


   You need now to define 3 pairs of lines by 6 clicks (and some possible re-adjustments) 
   and then close the window to terminate the section.


   The first pair of lines is to define a horizontal window. 

      - Do `s + Left Click` to set the left end of the window.
      - Do `s + Right Click` to set the right end of the window.

   As for respiratory binning, the program is going to construct 
   internally the even extension of the reference signal extracted 
   by the present section. Observe next figure to select the left and 
   right end of the horizontal window so that no pathology occurs, 
   if possible (it is not critical but do your best). 
   
   .. image:: ../images/cardiac_binning/even_extension.png
      :width: 90%
      :align: center
      :alt: Even Extension and Associated Pathologies
   
   In order to avoid pathologies in the even extension of the reference signal, 
   we will select the left and right ends (yellow vertical bars) of the 
   horizontal window either in two maxima of the respiratory patern, or in two minima.
   You can zoom with the loop to click precisely. 
   
   In the case of cardiac binning, 
   it may be trycky to tarjet two minima or maxima. We suggest to put the vertical lines
   on two white strikes. If that is too sunjective, just do your best, it is not 
   critical anyway.  

   Note that the left end of that horizontal window also serve to exclude the 
   non-steady-state acquired data.

   Here is an example of the selection for the left and right ends of the horizontal
   window. 

   .. image:: ../images/cardiac_binning/cardiac_binning_02.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_02


   .. image:: ../images/cardiac_binning/cardiac_binning_03.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_03
 

   You have now to define the lower and upper bound of the vertical window that
   contains the some caracteristic patterns of cardiac motion. The best way to do it
   is to select some vertical window that seems to contain some cardiac pattern
   and then adjust it as described below. Make two clicks as follows: 

      - Do `x + Left Click` to set the lower bound of the window.
      - Do `x + Right Click` to set the upper end of the window.

   After these two clicks you may see someting like this: 

   .. image:: ../images/cardiac_binning/cardiac_binning_04.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_04

    
   The red line is the reference signal generated from the selected windows. 
   It is a weighted average of the grey values in the vertical window. 
   You have now to adjust it: 

      - press the up-arrow to shift the vertical window up, 
      - press the down-arrow to shift the vertical window down,
      - press the ctrl+right-arrow to increase the width of vertical window,
      - press the ctrl+left-arrow to decrease the width of vertical window,
   
   You can also play with the displayed signal without chaning its values internally, 
   by using following keys: 

      - press ctrl+up-arrow to increase the displayed amplitude of the reference signal,
      - press ctrl+down-arrow to decrease the displayed amplitude of the reference signal.
      - press ctrl+R to flip up-down the reference signal. 

   After playing with those adjustments, you may be able to end up with a reference 
   signal that peaks together with the strikes due to cardiac motion. If you are lucky, 
   you may see someting like this:   
      
   .. image:: ../images/cardiac_binning/cardiac_binning_05.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_05

   If the strikes due to cardiac movement are not visible, just set a vertical window
   that you suspect to contain information about cardiat motion. The filtering
   of the signal below may reveal some cardiac dependent signal.  


   Finally, chose a vertical window that will serve for display purpose 
   only in the rest of the precedure.

      - press n + left-click to select the lower bound of the display window, 
      - press n + right-click to select the upper bound of the display window. 


   After those clicks, you should see someting like this: 

   .. image:: ../images/cardiac_binning/cardiac_binning_06.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_06  


   You can now close the windows and the chosen reference signal will
   automatically be saved. 



4. **Graphical Frequency Selector**

   We will now bandpass filter the reference signal. Run the following section.  

   .. code-block:: matlab

      %% graphical frequency selector
      [ s_ref_lowPass, ...
      s_ref_bandPass, ...
      lowPass_filter, ...
      bandPass_filter ] = ...
      bmMriPhi_graphical_frequency_selector(  s_ref, ...
                                              t_ref, ...
                                              Fs_ref, ...
                                              nu_ref, ...
                                              imNav   ); 
                                                               

   You should then see the graphical frequency selector appear. In the left pannel is the 
   frequency spectrum of the reference signal displayed, and the right pannel 
   is the reference signal displayed.  
   On the left pannel, in the upper line of buttons, press the more right button the stretch 
   the frequency axis to the right until you see a similar picture like the following.  

   .. image:: ../images/cardiac_binning/cardiac_binning_07.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_07  

   Still on the left pannel, in the lower line of buttons, on the right, press the "<<<" button
   to decrese the value of the maximum frequency of the filter. You may have to press many times 
   until the effect appears on the displayed range of frequencies. You can also use the buttons 
   "<<" and "<" to be more precise. Try to identify the peak arround the base frequency of 
   the cardiac signal, and create a lowpass filter that include that peak. Then increase the 
   minimum frequency of the filter to make it bandpass, so that only the frequencies arround
   the base frequency of the cardiac signal are accepted by the filter. Here is an example: 

   .. image:: ../images/cardiac_binning/cardiac_binning_08.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_08  
   
   Then press the button "Filter Signal". 
   The filtered signal appears then in blue on the right pannel. 
   You can press "Hide Yelow" to discard the reference signal. 
   
   .. image:: ../images/cardiac_binning/cardiac_binning_09.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_09  
   
   
   You can stretch the time axis in both directions using the "<<<" and ">>>" buttons  
   and navigate using the "--->" and  "<---" buttons to inspect the filtered 
   reference signal. Make sure that the signal looks like a sinusoid modulated in 
   amplitude and frequency, but that no harmonic of the base frequency are expressed. 
   There should ideally be no ringing in the filtered signal. If needed, you can 
   re-adjust the filter and press "Filter Signal" again, 
   until the filtered signal looks like a modulated sinusoid. 

   You can change the contrast of the background in the right 
   pannel with the imcontrast tool of Matlab by pressing the "imcontrast" button. 
   But once you have changed the contrast, press the "fix contrast" buton, else
   the changes in contrast will be lost. 
   
   By adjusting the contrast, you should observe
   that the filtered signal oscilated together with the vertical strikes due to 
   cardiac motion. This confirms that the correct peak was selected in the frequency
   spectrum. If you cannot see those strikes, a good rule of thumb is that the first
   peak in the frequency spectrum is due to respiratory motion, and the second
   is due do cardiac motion. 
   

      .. image:: ../images/cardiac_binning/cardiac_binning_10.png
         :width: 90%
         :align: center
         :alt: cardiac_binning_10  


   You can now close the window and the filter will be saved.   
 

5. **Reformating the Filtered Signal**

   Just execute the following automatic section. 

   .. code-block:: matlab

      %% reformated_signal_ref
      check_image = rmsSI(ind_SI_min:ind_SI_max, :); 
      reformated_signal_ref = ...
      bmMriPhi_fromSI_standartSignal_to_reformatedSignal(   s_ref_bandPass, ...
                                                            nSeg, ...
                                                            nShot, ...
                                                            ind_shot_min, ...
                                                            ind_shot_max, ...
                                                            check_image   ); 
      

                                                                              

   A figure appears then to show the filtered signal reformated with the correct size. 
   You can check on that figure that the filtered signal oscillate toghether with the 
   background. 

   .. image:: ../images/cardiac_binning/cardiac_binning_11.png
      :width: 90%
      :align: center
      :alt: resp_confirm  

   You can close that figure and go to the next section. 


6. **Looking for Signal Candidates in Order to Create a Phase**

   This section is automatic and requires no input. The called functions
   will creates some signal candidates that will be used hereafter to 
   create a phase. Just execute it and go to the next section. 

   .. code-block:: matlab
      
      %% extracting reformated_signal_list from SI 
      if nSignal_to_select > 1 
         nSignal_to_select_minus_1 = nSignal_to_select - 1; 
         reformated_signal_list = ...
         bmMriPhi_fromSI_collect_signal_list(   filter_type, ...
                                                t_ref, ...
                                                nu_ref, ...
                                                SI, ...
                                                lowPass_filter, ...
                                                bandPass_filter, ...
                                                nCh, ...
                                                N, ...
                                                nSeg, ...
                                                nShot, ...
                                                nSignal_to_select_minus_1, ...
                                                signal_exploration_level, ...
                                                ind_shot_min, ...
                                                ind_shot_max, ...
                                                ind_SI_min, ...
                                                ind_SI_max,...
                                                s_reverse_flag   );
      else
         reformated_signal_list = []; 
      end

      reformated_signal_list = cat( 1, ...
                                    reformated_signal_ref, ...
                                    reformated_signal_list); 








7. **Selecting the Best Candidate Signals**

   After executing the following section, you will see a sequence of figures appear 
   showing some candidate signales in their phase space. After closing the window 
   of a candidate signal, answer if you accept of reject the signal. A signal that 
   spins arround the center without crossing the center is considered of good 
   quality to evaluate a phase and should be accepted. A signal that crosses the 
   center is considered of bad quality to evaluate a phase and should be rejected.   

   .. code-block:: matlab
      
      %% computing card phase
      [cardPhase, cardPhase_list] = ...
      bmMriPhi_signalList_to_phase(  reformated_signal_list  ); 


   
   Here is an example of candidate signal: 

   .. image:: ../images/cardiac_binning/cardiac_binning_12.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_12 

This signal is of good quality because it is not present in the center. This 
should be accepted in the following dialog box: 

   .. image:: ../images/cardiac_binning/cardiac_binning_13.png
      :width: 40%
      :align: center
      :alt: cardiac_binning_13 


Here is another example of candidate signal: 

   .. image:: ../images/cardiac_binning/cardiac_binning_14.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_14 

This signal is of bad quality because it present in the center. This 
should be rejected in the following dialog box: 

   .. image:: ../images/cardiac_binning/cardiac_binning_15.png
      :width: 40%
      :align: center
      :alt: cardiac_binning_15 


After you gave an answer for every of the candidate signals, 
two graph are displayed: 

   - one showing each phase computed from each accepted signals. All the phases have to approximatelly agree together. That means that all signals measure the same cardiac phase. 
   - another showing the combination of all phases computed from each accepted signals. That phase will be used to create the binning masks. 

Here a are some example of these two graphs: 

   .. image:: ../images/cardiac_binning/cardiac_binning_16.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_16 

   .. image:: ../images/cardiac_binning/cardiac_binning_17.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_17

You can now close all figures and go to the last section. 


8. **Create the Masks**

   Here is the last section for cardiac binning. You can run it. 

   .. code-block:: matlab                 

      %% mask_construction
      cMask = bmMriPhi_phase_to_mask(cardPhase, nMask, maskWidth); 

   .. image:: ../images/cardiac_binning/cardiac_binning_18.png
      :width: 90%
      :align: center
      :alt: cardiac_binning_18 

   The binning mask are displayed and stored in the variable cMask. Note that the first lines are 
   excuded by all masks, in accordance with the selection of the horizontal window at the beginning
   of the script. 
   
   You can now save the binning mask on the disk for a future purpose.                                           
   



