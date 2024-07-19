function C = bmCoilSense_prescan_coilSense(x_body, x_surface, m, n_u)
% bmCoilSense_prescan_coilSense - Estimate coil sensitivity maps from pre-scan images.
%
% Usage:
%   C = bmCoilSense_prescan_coilSense(x_body, x_surface, m, n_u)
%
% Inputs:
%   x_body    : Body coil prescan image (1D, 2D, or 3D).
%   x_surface : Surface (array) coil prescan image (1D, 2D, or 3D).
%   m         : Mask segmenting the non-zero signal volume, with dimensions matching the images.
%   n_u       : Image size excluding channels (e.g., [96, 96] or [64, 56, 32]).
%
% Outputs:
%   C         : Estimated coil sensitivity maps (complex single).
%
% Description:
%   This function estimates the sensitivity maps of MRI coils using pre-scan images from body and surface coils.
%   It normalizes the coil images, estimates sensitivity maps using pseudo-diffusion, and refines them using
%   the Laplace equation solver.
%
% Steps:
%   1. Reshape and normalize the body and surface coil images.
%   2. Compute an initial estimate of the body coil sensitivity.
%   3. Refine the sensitivity map using pseudo-diffusion and the Laplace equation solver.
%   4. Estimate and refine sensitivity maps for each surface coil.
%
% Author:
%   Bastien Milani, CHUV and UNIL, Lausanne, Switzerland, May 2023

L_nIter             = 1000; % ------------------------------------------------------ magic number
L_th                = 1e-4; % ------------------------------------------------------ magic number
x_body_ind          = 1; % --------------------------------------------------------- magic number
nIter_smooth        = 2; % --------------------------------------------------------- magic number

n_u             = n_u(:)'; 
imDim           = size(n_u(:), 1);
nCh             = size(x_surface(:), 1)/prod(n_u(:)); 

x_body          = single(bmColReshape(  x_body,       n_u)); 
rms_body        = single(bmColReshape(  bmRMS(x_body, n_u), n_u));
x_body          = x_body(:, x_body_ind);  
x_surface       = single(bmColReshape(  x_surface,    n_u)); 

m               = logical(bmColReshape(m, n_u));  
m_neg           = not(m);                          
m_rep           = repmat(m(:), [1, nCh]);          
m_neg_rep       = not(m_rep); 

x_body          = bmBlockReshape(x_body, n_u); 
rms_body        = bmBlockReshape(rms_body, n_u); 
x_surface       = bmBlockReshape(x_surface, n_u); 
m               = bmBlockReshape(m, n_u); 
m_neg           = bmBlockReshape(m_neg, n_u);                         

x_body_norm     = sqrt(sum(  abs(x_body(:)).^2       , 1));  
x_surface_norm  = bmColReshape(x_surface, n_u); 
x_surface_norm  = sqrt(sum(  abs(x_surface_norm).^2  , 1)); 
x_surface_norm  = mean(x_surface_norm, 2); 

x_body      = x_body/x_body_norm; 
rms_body    = rms_body/x_body_norm; 
x_surface   = x_surface/x_surface_norm; 

x_body(m_neg)   = 1; 
rms_body(m_neg) = 1; 

C_body_abs      = bmImPseudoDiffusion_inMask(  abs(x_body)./rms_body  , m, nIter_smooth);
C_body_phi      = zeros(size(C_body_abs));
C_body          = C_body_abs.*exp(1i*C_body_phi);
C_body(m_neg)   = 0; 
C_body          = bmImLaplaceEquationSolver(C_body, m, L_nIter, L_th, 'omp');

anat            = x_body./C_body; 
anat(m_neg)     = 1;

C = bmZero([n_u, nCh], 'complex_single');  

for i = 1:nCh
    if imDim == 1
        temp_im = x_surface(:, i); 
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat, m, nIter_smooth); 
        temp_im(m_neg) = 0; 
        C(:, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');
        
    elseif imDim == 2
        temp_im = x_surface(:, :, i); 
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat, m, nIter_smooth); 
        temp_im(m_neg) = 0; 
        C(:, :, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');

    elseif imDim == 3
        temp_im = x_surface(:, :, :, i); 
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat, m, nIter_smooth); 
        temp_im(m_neg) = 0; 
        C(:, :, :, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');

    end
end

C = bmBlockReshape(C, n_u); 

end

