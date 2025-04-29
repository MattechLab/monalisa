
% 
% Berk Can Acikgoz
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 

% This is the function where the interpolator matrices (interp_kerns) for 
% each type of the kernel undersampling pattern types (kern_types)
% are calculated with pseudo-inverse.

function interp_kerns = bcaNeith_interpolatorExtraction(calib, kern_types, kernel)
    [Nx,Ny,~] = size(calib);  % Extract data size

    Nxk = kernel(1); % Extract kernel 
    Nyk = kernel(2); % sizes

    xstride = (Nxk-1)/2; % Setting the 
    xm = (Nxk+1)/2;      % properties of how
    ystride = (Nyk-1)/2; % kernel is 
    ym = (Nyk+1)/2;      % convolved

    kern_types = kern_types>0; % safety check, practically does nothing

    for i = 1:size(kern_types,2)

        t = 1; % Counter for the types of kernels, done with kernels 
               % interpolation matrices are varying sizes, so cell 
               % structure is used to store them

        ci = []; % Initialization of the vector of 
                 % input points (interpolate from)

        co = []; % Initialization of the vector of 
                 % output points (interpolate to)

        kern_mask = reshape(kern_types(:,i), kernel); % Extract the mask of
                                                      % specific kernel
                                                      % type
                                                      % which is 1 for 
                                                      % theacquired point


        for x = 1+xstride:Nx-xstride
            for y = 1+ystride:Ny-ystride

                calib_inp = [];
                calib_out = [];

                for xx = -xstride:xstride
                    for yy = -ystride:ystride
                        if kern_mask(xx+xm,yy+ym)>0 % check if the current 
                                                    % kernel is suitable
                                                    % for interpolate-to
                            calib_inp = [calib_inp; squeeze(calib(x+xx,y+yy,:))]; 
                            
                            % Extract the k-space points to 
                            % interpolate-from
                        end
                    end
                end

                if isempty(calib_inp) % safety check which stops the run 
                                      % if there is no data to interpolate
                                      % from 
                else

                    %%% Filling the input and output vectors. With this
                    %%% naming convention, the problem is formulated as
                    %%% M*ci = co, and M is the interpolator to solve for
                    ci(:,t) = calib_inp;
                    calib_out = [calib_out, squeeze(calib(x,y,:))];
                    co(:,t) = calib_out;
                    t = t+ 1;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                end
    
            end
        end
    
        
        M = co*pinv(ci); % Solve the problem M*ci = co as least-squares 
%          A=ci';
%          b=co';
%          M= ((A'*A))\(A'*b);
%          M = M';
        interp_kerns{i} = M; % Save the interpolator of the ith kernel type
                             % to the cell
                             
    end
end