function K = bmK(N_u, dK_u, nCh, varargin)
% K = bmK(N_u, dK_u, nCh, varargin)
%
% This function generates a kernel matrix K of size N_u to deapodizate 
% data that was gridded to a uniform grid using windows. 
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
%   N_u (list): Contains the size of the grid.
%   dK_u (list): Contains the distances between grid points in every
%   dimension. Same size as N_u.
%   nCh (int): Number of channels (coils). K will be repeated for each
%   channel.
%   varargin{1}: Char that contains the kernel type. Either 'gauss' or 
%   'kaiser' with 'gauss' being the default value.
%   varargin{2}: Integer that contains the window width. Default value is 3 
%   for 'gauss' and 'kaiser'.
%   varargin{3}: List that contains the kernel parameter. Default value is 
%   [0.61, 10] for 'gauss' and [1.95, 10, 10] for 'kaiser'.
%
% Results:
%   K (array): Kernel matrix that will be multiplied element-wise to the
%   gridded data to deapodize it.

%% Initialize arguments
% Oversampling factor (magic_number) (improve the interpolation accuracy)
arg_osf = 2;  

% Extract optional arguments and set default values if not provided
[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);

% Convert inputs to correct formats
N_u         = double(int32(N_u(:)')); 
N_u_os      = round(N_u*arg_osf);
imDim       = size(N_u(:), 1); 
dK_u        = double(single(dK_u(:)')); 
nWin        = double(single(nWin(:)')); 
kernelParam = double(single(kernelParam(:)')); 
nCh         = double(single(nCh)); 

% Check that all dimensions in N_u are even
if sum(mod(N_u(:), 2)) > 0 
    error('N_u must have all components even for the Fourier transform. ');
end


%% Extract grid dimensions
Nx_u = 0; 
Ny_u = 0; 
Nz_u = 0;
if imDim == 1
    Nx_u = N_u(1, 1);
end
if imDim == 2
    Nx_u = N_u(1, 1);
    Ny_u = N_u(1, 2);
end
if imDim == 3
    Nx_u = N_u(1, 1);
    Ny_u = N_u(1, 2);
    Nz_u = N_u(1, 3);
end


%% Create grid and compute distances
x = []; 
y = []; 
z = []; 
if imDim == 1 % See imDim == 3 for comments
    x = [-Nx_u*arg_osf/2:Nx_u*arg_osf/2-1]/arg_osf;
    x = ndgrid(x);
    d = sqrt(x(:).^2);
    d = reshape(d, [N_u_os, 1]); 
end
if imDim == 2 % See imDim == 3 for comments
    x = [-Nx_u*arg_osf/2:Nx_u*arg_osf/2-1]/arg_osf;
    y = [-Ny_u*arg_osf/2:Ny_u*arg_osf/2-1]/arg_osf;
    [x, y] = ndgrid(x, y); 
    d = sqrt(x(:).^2 + y(:).^2);
    d = reshape(d, N_u_os);
end
if imDim == 3
    % Create 1D oversampled grid for 3 dimensions going from 
    % -N_u/2 to N_u/2 in N_u*arg_osf steps
    x = [-Nx_u*arg_osf/2:Nx_u*arg_osf/2-1]/arg_osf; 
    y = [-Ny_u*arg_osf/2:Ny_u*arg_osf/2-1]/arg_osf;
    z = [-Nz_u*arg_osf/2:Nz_u*arg_osf/2-1]/arg_osf;

    % Create 3D oversampled grid 
    % (x,y,z containing the coordinates for every point)
    [x, y, z] = ndgrid(x, y, z); 

    % Calculate distance from center to every point
    d = sqrt(x(:).^2 + y(:).^2 + z(:).^2); 
    d = reshape(d, N_u_os);
end


%% Compute kernel weights
if strcmp(kernelType, 'gauss')
    mySigma     = kernelParam(1);
    K_max       = kernelParam(2); 

    % Calculate the Gaussian weight using the normal probability density 
    % function. The weights are higher for distances close to 0
    myWeight    = normpdf(d(:), 0, mySigma); 

elseif strcmp(kernelType, 'kaiser')
    myTau       = kernelParam(1);
    myAlpha     = kernelParam(2);
    K_max       = kernelParam(3); 
    I0myAlpha   = besseli(0, myAlpha);
    
    myWeight    = max(1-(d/myTau).^2, 0);
    myWeight    = myAlpha*sqrt(myWeight);

    % Compute modified Bessel function of the weight and normalize
    myWeight    = besseli(0, myWeight)/I0myAlpha; 
end

% Reshape weights to match oversampled grid size
myWeight = bmBlockReshape(myWeight, N_u_os); 


%% Apply windowing to kernel
% Window half-width (only integer part)
nWin_half = fix(nWin/2); 

if imDim == 1 % See imDim == 3 for comments
    x_mask = (x < nWin_half) | (x > nWin_half);
    myWeight(x_mask) = 0; 
end
if imDim == 2 % See imDim == 3 for comments
    x_mask = (x < -nWin_half) | (x > nWin_half);
    y_mask = (y < -nWin_half) | (y > nWin_half);
    myWeight(x_mask) = 0; 
    myWeight(y_mask) = 0; 
end
if imDim == 3 
    % Set weights to 0 outside the center included in the window-width
    x_mask = (x < -nWin_half) | (x > nWin_half);
    y_mask = (y < -nWin_half) | (y > nWin_half);
    z_mask = (z < -nWin_half) | (z > nWin_half);
    myWeight(x_mask) = 0; 
    myWeight(y_mask) = 0; 
    myWeight(z_mask) = 0; 
end


%% Compute DFT of the kernel
if imDim == 1
    K = bmDFT1(myWeight, N_u_os, 1./N_u); 
elseif imDim == 2
    K = bmDFT2(myWeight, N_u_os, 1./N_u); 
elseif imDim == 3
    K = bmDFT3(myWeight, N_u_os, 1./N_u); 
end


%% Crop the kernel to the original grid size
if imDim == 1 % See imDim == 3 for comments
    x_center    = N_u_os(1, 1)/2+1;
    x_half      = N_u(1, 1)/2;
    x_ind       = x_center-x_half:x_center+x_half-1; 
    
    K = K(:); 
    K = K(x_ind, 1);
    
elseif imDim == 2 % See imDim == 3 for comments
    x_center    = N_u_os(1, 1)/2+1;
    x_half      = N_u(1, 1)/2;
    x_ind       = x_center-x_half:x_center+x_half-1; 
    
    y_center    = N_u_os(1, 2)/2+1;
    y_half      = N_u(1, 2)/2;
    y_ind       = y_center-y_half:y_center+y_half-1; 
    
    K = K(x_ind, y_ind);
    
elseif imDim == 3
    % Get center indices of x coordinates
    x_center    = N_u_os(1, 1)/2+1; 
    x_half      = N_u(1, 1)/2;
    x_ind       = x_center-x_half:x_center+x_half-1; 

    % Get center indices of y coordinates
    y_center    = N_u_os(1, 2)/2+1; 
    y_half      = N_u(1, 2)/2;
    y_ind       = y_center-y_half:y_center+y_half-1; 
    
    % Get center indicies of z coordinates
    z_center    = N_u_os(1, 3)/2+1; 
    z_half      = N_u(1, 3)/2;
    z_ind       = z_center-z_half:z_center+z_half-1; 
    
    % Crop K to N_u by only taking the values in the center
    K = K(x_ind, y_ind, z_ind); 
end


%% Final adjustments to the kernel
% K should be real and positive, but account for noise
K = abs(real(K)); 
K = K/max(abs(K(:)));

% Inverse K, as it is used for deapodization (removing effect of windowing)
K = 1./K; 

% Clip K between 0 and K_max (noise reduction)
K = min(K, K_max); 

% Repeat K for every channel
K = repmat(K(:), [1, nCh]); 
K = single(K); 


end % END_function


