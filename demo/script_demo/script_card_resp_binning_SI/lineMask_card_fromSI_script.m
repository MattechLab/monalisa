%%
filter_type                 = 'bandPass'; %      'lowPass' for resp. binning 
                                          % or   'bandPass' for card. binning
nMask                       = 20; % Should be adapted to heart_rate.  
maskWidth                   = 1; 
nSignal_to_select           = 20; % 1 manually, untrended, selected signal for resp. binning
                                  % 15 to 25 for card. binning. 

signal_exploration_level    = 'medium'; % 'leight' or 'medium' or 'heavy'

nCh                         = 42; 
N                           = 480; 
nSeg                        = 22; 
nShot                       = 2055;

nLine                       = nSeg*nShot; 
nPt                         = N*nLine; 


%%

reconDir = '/Users/mauroleidi/Desktop/recon_eva'; 
f = [reconDir, '/raw_data/meas_MID00530_FID154908_BEAT_LIBREon_eye.dat']; 

SI = bmTwix_getFirstProjOfShot(f); 

%% getting rmsSI from SI
rmsSI = bmMriPhi_fromSI_rmsSI(SI, nCh, N, nShot); 

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
 s_reverse_flag   ] = bmMriPhi_fromSI_get_standart_reference_signal(   rmsSI, ...
                                                                       nCh, ...
                                                                       N, ...
                                                                       nSeg, ...
                                                                       nShot    ); 


%% graphical frequency selector
[ s_ref_lowPass, ...
  s_ref_bandPass, ...
  lowPass_filter, ...
  bandPass_filter ] = bmMriPhi_graphical_frequency_selector(  s_ref, ...
                                                              t_ref, ...
                                                              Fs_ref, ...
                                                              nu_ref, ...
                                                              imNav     ); 

                                                          

%% reformated_signal_ref
check_image = rmsSI(ind_SI_min:ind_SI_max, :); 
reformated_signal_ref = bmMriPhi_fromSI_standartSignal_to_reformatedSignal( s_ref_bandPass, ...
                                                                            nSeg, ...
                                                                            nShot, ...
                                                                            ind_shot_min, ...
                                                                            ind_shot_max, ...
                                                                            check_image   ); 

                                                                        
%% extracting reformated_signal_list from SI 
if nSignal_to_select > 1 
    nSignal_to_select_minus_1 = nSignal_to_select - 1; 
    reformated_signal_list = bmMriPhi_fromSI_collect_signal_list(   filter_type, ...
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

reformated_signal_list = cat(1, reformated_signal_ref, reformated_signal_list); 


%% computing card phase
[cardPhase, cardPhase_list] = bmMriPhi_signalList_to_phase(  reformated_signal_list  ); 

%% mask_construction
cMask = bmMriPhi_phase_to_mask(cardPhase, nMask, maskWidth); 


















