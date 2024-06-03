% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myOsf = bmOverSamplingFactor_for_gpuNUFFT(N_u, n_u)

myOsf = []; 

if isequal(N_u, n_u)
   myOsf = 1; 
   return; 
end

N_u = N_u(:)'; 
n_u = n_u(:)'; 

imDim = size(N_u(:), 1); 

if imDim == 1
    myOsf = N_u(1, 1)/n_u(1, 1); 
    
elseif imDim == 2
    myOsf_1 = N_u(1, 1)/n_u(1, 1); 
    myOsf_2 = N_u(1, 2)/n_u(1, 2);
    
    if myOsf_1 ~= myOsf_2
       error('Oversampling for gpu_NUFFT must be isotropic. '); 
       return; 
    else
        myOsf = myOsf_1; 
    end
    
elseif imDim == 3
    myOsf_1 = N_u(1, 1)/n_u(1, 1); 
    myOsf_2 = N_u(1, 2)/n_u(1, 2);
    myOsf_3 = N_u(1, 3)/n_u(1, 3);
    
    if (myOsf_1 ~= myOsf_2)|(myOsf_1 ~= myOsf_3)
       error('Oversampling for gpu_NUFFT must be isotropic. '); 
       return; 
    else
        myOsf = myOsf_1; 
    end
    
end

if isempty(myOsf)
    error('Problem in ''bmOverSamplingFactor_for_gpuNUFFT'' '); 
    return; 
end


end