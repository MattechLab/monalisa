% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023 
%
%
%
% y is the data.
%
% t is the trajectory;
%
% ve is the volumeElement;
%
% C is the coil sensitivity. 
%
% N_u is the size of the fourier grid. 
%
% n_u is the size of the image (can be empty). 
%
% dK_u is the edge-size of a cell of the fourier grid. 

function x = bmNonUniformFourier_pinv_gpuNUFFT(y, t, ve, C, N_u, n_u, dK_u, ve_max)

% initial -----------------------------------------------------------------

if isempty(n_u)
   n_u = N_u;  
end

if sum(mod(N_u(:), 2)) > 0
   error('N_u must have all components even for the Fourier transform. ');
   return; 
end
if sum(mod(n_u(:), 2)) > 0
   error('n_u must have all components even for the Fourier transform. ');
   return; 
end

if size(y, 2) >= size(y, 1)
   y = y.';  
end

t       = double(bmPointReshape(t)); 
y       = single(bmPointReshape(y)); 
ve_col  = single(min(ve(:), ve_max)); 
ve      = single(  bmY_ve_reshape(ve_col, size(y))  ); 
C       = single(C); 

nPt = size(t, 2); 

N_u         = double(int32(N_u(:)' ));
n_u         = double(int32(n_u(:)' ));
dK_u        = double(single(dK_u(:)'));


% gpuNUFFT_initial
t_gpuNUFFT      = bmTraj_rescaleToUnitCube(t, N_u, dK_u); 
ve_gpuNUFFT     = ones(nPt, 1); 

osf = bmOverSamplingFactor_for_gpuNUFFT(N_u, n_u); 
kw = 3; %3 or 1 also possible (nearest neighbor) ------------------------------------------------------- magic_number
sw = 6; % N_u should be a multiple of an sw related number --------------------------------------------- magic_number
atomic = true; % for rapidity AND for F' (backward NUFFT) to be correct !!!
textures = true; % for rapidity
loadbalancing = true; % for rapidity

F_gpuNUFFT = gpuNUFFT(t_gpuNUFFT, ve_gpuNUFFT(:), osf, kw, sw, n_u, [], atomic, textures, loadbalancing);
factor_gpuNUFFT         = 1/sqrt(prod(N_u(:)))/prod(dK_u(:));

% END_gpuNUFFT_initial



% calibration for rescaling 
h_calib         = single(  bmElipsoidMask(n_u, n_u/4)  ); % -------------------- magic number
if isempty(C)
    ve_calib = ve_col; 
else
    ve_calib = ve; 
end

y_calib         = bmSimulateMriData(h_calib, C, t, N_u, n_u, dK_u); 
x_calib         = factor_gpuNUFFT*(  F_gpuNUFFT'*(y_calib.*ve_calib)  ); 
if not(isempty(C))
    C = bmBlockReshape(C, n_u);
    x_calib = bmCoilSense_pinv(C, x_calib, n_u);
end
x_calib = abs(x_calib); 
mask_calib      = bmElipsoidMask(n_u, n_u/4)  ; % ------------------------- magic_number
val_calib       = x_calib(mask_calib); 
factor_rescale  = 1/mean(  val_calib(:)  ); 
% END_calibration for rescaling 


% END_initial -------------------------------------------------------------


% NUFFT
x = factor_rescale*factor_gpuNUFFT*(  F_gpuNUFFT'*(y.*ve)  );

% eventual coil_combine
if not(isempty(C))
    C = bmBlockReshape(C, n_u);
    x = bmCoilSense_pinv(C, x, n_u);
end


end % END_function



