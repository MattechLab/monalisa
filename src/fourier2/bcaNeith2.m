% 
% Berk Can Acikgoz
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 
% 
% This function is an implementation of 2-dimensional GRAPPA. 

function res = bcaNeith2(kspace, calib, kern)
    
    
    padsize = (kern-1)/2;                     % Padding the k-space first 
                                              % so that edge of the   
    kspace = padarray(kspace, [padsize 0],0); % k-space is also filled, 
                                              % otherwise kernel 
                                              % cannot move at the edge
    
    %%% Call the main functionality functions one by one
    kern_types = bcaNeith_kernelTypeExtraction(kspace, kern); 
    
    interp_kerns = bcaNeith_interpolatorExtraction(calib, kern_types, kern);

    res = bcaNeith_interpolatekSpace(kspace, interp_kerns, kern_types, kern);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    res(1:padsize(1), :,:) = []; % Remove the paddin to retain 
    res(:,1:padsize(1),:) = [];  % the original size
    res(end-padsize(1)+1:end, :,:) = [];
    res(:,end-padsize(1)+1:end,:) = [];


end
