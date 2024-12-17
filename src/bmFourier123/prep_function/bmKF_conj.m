function KF_conj = bmKF_conj(C_conj, N_u, n_u, dK_u, nCh, varargin)
% KF_conj = bmKF_conj(C_conj, N_u, n_u, dK_u, nCh, varargin)
%
% This function generates a kernel matrix K used for deapodization of the
% data that was gridded to a uniform grid using windows, considering the
% conjugate of the coil sensitivity (if given) and the conjugate Fourier
% factor F_conj.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   C_conj (array): The conjugate of the coil sensitivity. Has to be given
%   as the conjugate (conj(C)). Can be given as [] if the coil sensitvity
%   should not be included.
%   N_u (list): The size of the grid for which K should be generated.
%   n_u (list): The size of the grid in the image space.
%   dK_u (list): The distances between grid points in every dimension. Same
%   size as N_u.
%   nCh (int): Number of channels (coils). K will be repeated for each
%   channel.
%   varargin{1}: Char that contains the kernel type. Either 'gauss' or 
%   'kaiser'. Default value is 'gauss'.
%   varargin{2}: Integer that contains the window width. Default value is 3 
%   for 'gauss' and 'kaiser'.
%   varargin{3}: List that contains the kernel parameter. Default value is 
%   [0.61, 10] for 'gauss' and [1.95, 10, 10] for 'kaiser'.
%
% Returns:
%   KF_conj (array): The kernel matrix scaled by the factor F and C_conj if
%   given. The matrix is given as a single in the column format (nPt, nCh).


% Extract optional arguments and set default values for empty ones.
[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);  

% Convert variables to the correct format
C_conj      = single(bmBlockReshape(C_conj, n_u)); 
N_u         = single(N_u(:)'); 
n_u         = single(n_u(:)'); 
dK_u        = single(dK_u(:)'); 
nWin        = single(nWin(:)'); 
kernelParam = single(kernelParam(:)'); 
nCh         = single(nCh); 

% Generate kernel matrix for deapodization
K       = single(bmK(N_u, dK_u, nCh, kernelType, nWin, kernelParam));

% Crop data to grid of size n_u and return to column format
K       = bmImCrope(K, N_u, n_u);
K       = single(bmColReshape(K, n_u));

% Fourier factor -> scaling needed due to MATLAB iFFT implementation
F_conj  = single(1/prod(dK_u(:))); 

% Mutliply K with F_conj, and with C_conj if C_conj is not empty
if isempty(C_conj)
    KF_conj = single(K*F_conj);
else
    C_conj      = single(bmColReshape(C_conj, n_u));
    KF_conj = single(K.*F_conj.*C_conj);
end

end