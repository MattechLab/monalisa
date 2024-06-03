% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% For the mriPhi environment, a standart signal is a perLine, croped and 
% mirrored signal, which is also centered and reduced. 
%
% The argument s must be a raw_SI_signal i.e. one point per SI, with all
% the SI's. 
% 
% 


function s_out = bmMriPhi_fromSI_rawPerShotSignal_to_standartSignal(s, ...
                                                                    nSeg, ...
                                                                    nShot, ...
                                                                    ind_shot_min, ...
                                                                    ind_shot_max)

% signal is croped
s                   = s(:, ind_shot_min:ind_shot_max); 

nSignal             = size(s, 1); 

s_interpolant       = cat(  2, s, s(:, end-1)  ); 
nLine_to_interp     = nSeg*size(s, 2) + 1; 
t_interp            = 1:nLine_to_interp; 
t_interpolant       = t_interp(1:nSeg:end); 

s_out = zeros(nSignal, (nLine_to_interp - 1)*2  );  
for i = 1:nSignal
    
    % signal is interpolated for each line
    temp_s            = bmInterp1(t_interpolant, s_interpolant(i, :), t_interp);
    temp_s(:, end)    = [];
    
    % signal is mirrored
    temp_s            = cat(2, temp_s, flip(temp_s, 2)  );
    
    % signal is centered and reduced
    temp_s               = temp_s - mean(temp_s(:));
    temp_s               = temp_s/std(temp_s(:));

    
    s_out(i, :) = temp_s; 
    
end

end




