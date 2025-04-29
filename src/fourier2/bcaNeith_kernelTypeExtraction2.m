
% 
% Berk Can Acikgoz
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 



% This is the script where the kernel is moved around the undersampled
% k-space to extract the all possible types of kernel shapes where a
% unique interpolator should be calculated.

function kern_types = bcaNeith_kernelTypeExtraction(kspace,kernel)
    
    [Nx,Ny,~] = size(kspace);  % Extract data size
    
    Nxk = kernel(1); % Extract kernel 
    Nyk = kernel(2); % sizes
    
    
    xstride = (Nxk-1)/2; % Setting the  properties of how
    ystride = (Nyk-1)/2; % kernel is convolved

    kern_types = []; % Initialize the kernel types data structure
    k = 1;           % Counter for types

    for i = 1+xstride:Nx-xstride
        for j = 1+ystride:Ny-ystride

            if abs(kspace(i,j)) == 0 % If data is missing, we will try to 
                                     % find the type of kernel that is 
                                     % required for this data
                                     % point, otherwise no need to bother!
        
                %%% Steps of creating a vector for the particular kernel:
                %%% extract the neighboring k-space points, create a mask
                %%% from them, replace the values with 1 if it is nonzero
                %%% (i.e. acquired data), vectorize the mask and finally
                %%% normalize for later cross-correlation calculation 
                %%% (i.e. its correlation is 1 iff it is dot-producted 
                %%% with itself)
                kspace_kern = ...
                    kspace(i-xstride:i+xstride, j-ystride:j+ystride);

                kspace_kern_mask = (abs(kspace_kern)>0);
                
                kspace_kern_mask = 1*kspace_kern_mask(:);

                if norm(kspace_kern_mask(:))>0

                    % kspace_kern_mask = normalize(kspace_kern_mask, 'norm');

                    kspace_kern_mask = kspace_kern_mask/norm(kspace_kern_mask(:));
                    
                    
                else

                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
                if k == 1 % If there is no saved kernel type yet, initialize
                    kern_types(:,k) = kspace_kern_mask;
                    k = k + 1;
                else

                    %%% If there are some types of kernels already saved, 
                    %%% we will take the dot product of the current kernel 
                    %%% type vector with what is already saved. If there 
                    %%% is a match (i.e. if case below), do not save the 
                    %%% current kernel type as a new one.
                    if nnz(abs((kern_types'*kspace_kern_mask) - 1)<1e-9)

                    else
                        
                        kern_types(:,k) = kspace_kern_mask;
                        k = k + 1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end
        end
    end
end
