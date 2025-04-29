
% 
% Berk Can Acikgoz
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 


%%% This is where all the calls to the other functions are done and real
%%% action happens!

function res = MATLABGrappa(kspace, calib, kern)


    padsize = (kern-1)/2;                           % Padding the k-space first 
                                                    % so that edge of the   
    kspace = padarray(kspace, [padsize 0],0);  % k-space is also filled, 
                                                    % otherwise kernel 
                                                    % cannot move at the edge
    

    %%% Call the main functionality functions one by one
    kern_types = bcaNeith_kernelTypeExtraction3(kspace, kern);

    interp_kerns = bcaNeith_interpolatorExtraction3(calib, kern_types, kern);

    [res, kspace_interp] = bcaNeith_interpolatekSpace3(kspace, interp_kerns, kern_types, kern);
    % "kspace_interp" variable holds the "interpolated (estimated)" kspace
    % lines where "res" contains the entire filled k-space


    % Removing the padding to keep the original size
    res(1:padsize(1),:, :,:) = [];
    res(:,1:padsize(2),:,:) = [];
    res(:,:,1:padsize(3),:) = [];
    res(end-padsize(1)+1:end, :,:,:) = [];
    res(:,end-padsize(2)+1:end,:,:) = [];
    res(:,:,end-padsize(3)+1:end,:) = [];




end

function res = isKern(kern)
    res = false;
    if length(kern)==3
        if kern(1)>1 && kern(2)>1 && kern(1)>1 
            if nnz(mod(kern-1),2)==0
                res = true;
            end
        end
    end

end