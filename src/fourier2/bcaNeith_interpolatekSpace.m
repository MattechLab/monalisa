
% 
% Berk Can A�ikg�z
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 



% This is the function where the missing k-space lines are filled with the
% acquired lines interpolated with already extracted interpolation
% kernels (interp_kerns)

function [res,kspace_interp] = bcaNeith_interpolatekSpace(kspace, interp_kerns, kern_types, kernel)

    [Nx,Ny,~] = size(kspace);  % Extract data size
    
    Nxk = kernel(1); % Extract kernel 
    Nyk = kernel(2); % sizes
    
    
    xstride = (Nxk-1)/2; % Setting the 
    xm = (Nxk+1)/2;      % properties of how
    ystride = (Nyk-1)/2; % kernel is 
    ym = (Nyk+1)/2;      % convolved
    
    kspace_interp = zeros(size(kspace)); % Initialize the "interpolated" k-space. 
                                         % Once filled, needs to be added on
                                         % top of the already acquired k-space
    
    for x = 1+xstride:Nx-xstride
        for y = 1+ystride:Ny-ystride
    
            if kspace(x,y)==0  % Check if the current position data is missing
    
                kspace_kern = ...  % Extract the k-space around the current 
                          ...  % k-space point using the kernel
                kspace(x-xstride:x+xstride, y-ystride:y+ystride);
            
                %%% Create a mask over extracted k-space neighborhood and 
                %%% determine which interpolator is suitable among the 
                %%% interp_kerns
                kspace_kern_mask = (abs(kspace_kern)>0);
                kspace_kern_mask = 1*kspace_kern_mask(:);
%                 kspace_kern_mask = normalize(kspace_kern_mask, 'norm');
                kspace_kern_mask = kspace_kern_mask*sqrt(1/(kspace_kern_mask'*kspace_kern_mask));
                type = find(abs((kern_types'*kspace_kern_mask) - 1)<1e-9);
                kern_mask = reshape(kspace_kern_mask, kernel);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
                if isempty(type)  % Do nothing if there is no matching kernel type
                                  % since we do not have an interpolator for it
                                  % this check practically does nothing. Only as a 
                                  %safety check for zero-filled k-spaces...
                else
        
        
                    M = interp_kerns{type}; % Extract the suitable interpolator 
                                            % (denoted with M)
            
            
                    %%% Extract the line to be interpolated (calib_inp) with M, do the
                    %%% forward operation (M*calib_inp) and save the interpolated lines
                    %%% to their appropriate locations in kspace_interp
                    calib_inp = []; 
                               
                    for xx = -xstride:xstride
                        for yy = -ystride:ystride
                            if kern_mask(xx+xm,yy+ym)>0
                                calib_inp = [calib_inp;squeeze(kspace(x+xx,y+yy,:))];
                            end
                        end
                    end
                 
                    kspace_interp(x,y,:)=M*calib_inp;
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            
            
        end
    end
    
    res = kspace_interp+kspace; % Add the interpolated k-space to the 
                                % acquired one. There is no overlap!
end
