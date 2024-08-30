function KF = bmKF(C, N_u, n_u, dK_u, nCh, varargin)
% KF = bmKF(C, N_u, n_u, dK_u, nCh, varargin)
%
% This function generates a kernel matrix K used for deapodization of the
% data that was gridded to a uniform grid using windows, considering the
% coil sensitivity (if given) and scaled by a factor F (I DON'T YET
% UNDERSTAND WHY) THIS NEEDS SOME MORE WORK DONE ON
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
%   C (array): The coil sensitivity? Can give as [] if not used. (NOT YET
%    ENCOUNTERED) 
%   N_u (list): The size of the grid for which K should be generated.
%   n_u (list): The size of the grid that the returned data should have.
%    This can be smaller, but not bigger, than the grid given by N_u.
%   dK_u (list): The distances between grid points in every dimension. Same
%    size as N_u.
%   nCh (int): Number of channels (coils). K will be repeated for each
%   channel.
%   varargin{1}: Char that contains the kernel type. Either 'gauss' or 
%    'kaiser'. Default value is 'gauss'.
%   varargin{2}: Integer that contains the window width. Default value is 3 
%    for 'gauss' and 'kaiser'.
%   varargin{3}: List that contains the kernel parameter. Default value is 
%    [0.61, 10] for 'gauss' and [1.95, 10, 10] for 'kaiser'.
%
% Returns:
%   KF (array): The kernel matrix scaled by the factor F and C if given.
%    The matrix is given as a single in the column format (nPt, nCh).

% Extract opional arguments and set default values if empty
[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);

% Convert variables to the correct format
C           = single(bmBlockReshape(C, n_u)); 
N_u         = single(N_u(:)');
n_u         = single(n_u(:)');
dK_u        = single(dK_u(:)'); 
nWin        = single(nWin(:)'); 
kernelParam = single(kernelParam(:)');
nCh         = single(nCh); 

% Generate kernel matrix for deapodization
K = single(bmK(N_u, dK_u, nCh, kernelType, nWin, kernelParam));

% Crop data to grid of size n_u and return to column format
K = bmImCrope(K, N_u, n_u);
K = single(bmColReshape(K, n_u));

% Calculate some scaling factor (NOT YET SURE WHAT IT IS EXACTLY) that is
% calculated by multiplying the grid size by its spacing and deviding by
% it. Could also be seen as the mutliplication of FOV with the resolution
% in image space.
F = single(1/prod(N_u(:))/prod(dK_u(:))); 

% Mutliply K with F, and with C if C is not empty
if isempty(C)
    KF = single(K*F); 
else    
    C      = single(bmColReshape(C, n_u));
    KF     = single(K.*F.*C);
end

end