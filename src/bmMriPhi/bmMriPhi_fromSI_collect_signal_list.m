% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% argSI must be in the size [nCh, N, nShot] or reshapable. 

function s = bmMriPhi_fromSI_collect_signal_list(   filter_type, ...
                                                    t_ref, ...
                                                    nu_ref, ...
                                                    mySI, ... 
                                                    lowPass_filter, ...
                                                    bandPass_filter, ...
                                                    nCh, ...
                                                    N, ...
                                                    nSeg, ...
                                                    nShot, ...
                                                    nSignal_to_select, ...
                                                    signal_exploration_level, ...
                                                    ind_shot_min, ...
                                                    ind_shot_max, ...
                                                    ind_SI_min, ...
                                                    ind_SI_max, ...
                                                    s_reverse_flag)

                                                
                           
mySI = reshape(  mySI, [nCh, N, nShot]  ); 
mySI = mySI(:, ind_SI_min:ind_SI_max, :); 
N_croped = size(mySI, 2); 

s = []; 

% collecting_signals ------------------------------------------------------
if strcmp(signal_exploration_level, 'heavy')
    temp_s = reshape(mySI, [nCh*N_croped, nShot]); 
    s  = cat(1, s, real(temp_s), imag(temp_s), abs(temp_s));
end

mySI    = reshape(mySI, [nCh, N_croped, nShot]);  
temp_s  = squeeze(  sum(mySI, 2)  ); 
s       = cat(1, s, real(temp_s), imag(temp_s), abs(temp_s)); 

mySI    = reshape(mySI, [nCh, N_croped, nShot]);
temp_s  = squeeze(sum(abs(mySI), 2)); 
s       = cat(1, s, abs(temp_s)); 

mySI    = reshape(mySI, [nCh, N_croped, nShot]);
temp_s  = squeeze(sum(mySI, 1));
s       = cat(1, s, real(temp_s), imag(temp_s) ,abs(temp_s)); 

mySI    = reshape(mySI, [nCh, N_croped, nShot]);
temp_s  = squeeze(sum(abs(mySI), 1));
s       = cat(1, s, abs(temp_s)); 

temp_s  = reshape(mySI, [nCh*N_croped, nShot]);
temp_s  = squeeze(sum(temp_s, 1)); 
s       = cat(  1, s, real(temp_s), imag(temp_s), abs(temp_s)  ); 

temp_s  = reshape(mySI, [nCh*N_croped, nShot]);
temp_s  = squeeze(sum(abs(temp_s), 1)); 
s       = cat(  1, s, abs(temp_s) ); 
% END_collecting_signals --------------------------------------------------

if strcmp(signal_exploration_level, 'leight')
    s = s(1:100, :); 
elseif strcmp(signal_exploration_level, 'medium')
    1+1; 
end

if s_reverse_flag
   s = -s;  
end

% s is croped and perShot at this point. 
s = bmMriPhi_fromSI_rawPerShotSignal_to_standartSignal( s, ...
                                                        nSeg, ...
                                                        nShot, ...
                                                        ind_shot_min, ...
                                                        ind_shot_max  ); 

                                            
[s_lowPass, s_bandPass] = bmMriPhi_signal_selection(    s, ...
                                                        t_ref, ...
                                                        nu_ref, ...
                                                        lowPass_filter, ...
                                                        bandPass_filter, ...
                                                        nSignal_to_select  ); 

temp_s = [];          
if strcmp(filter_type, 'lowPass')
    temp_s = s_lowPass; 
elseif strcmp(filter_type, 'bandPass')
    temp_s = s_bandPass; 
else
    error('That filter_type is unknown. ');
    return; 
end

s = bmMriPhi_fromSI_standartSignal_to_reformatedSignal( temp_s, ...
                                                        nSeg, ...
                                                        nShot, ...
                                                        ind_shot_min, ...
                                                        ind_shot_max  );
                            


end