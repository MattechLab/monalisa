function out_im = bmImZeroFill(arg_im, N_u, n_u, argType)
% out_im = bmImZeroFill(arg_im, N_u, n_u, argType)
%
% This function padds the image data with zeros if the k-space grid is
% bigger than the image space grid.
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
%   arg_im (array): The data in the image space to be padded.
%   N_u (list): The grid size in the k-space.
%   n_u (list): The grid size in the image space.
%   argType (char): The type of the to be padded array. Can be
%    'real_double', 'real_single', 'complex_double' and 'complex_single'.

% Have sizes in the correct format
N_u = N_u(:)'; 
n_u = n_u(:)'; 
imDim = size(N_u(:), 1); 

% Have image in the correct format
arg_im      = bmBlockReshape(arg_im, n_u);
arg_im_size = size(arg_im);
arg_im_size = arg_im_size(:)'; 

% Get number of channels
if isequal(arg_im_size, n_u)
    nCh = 1;
else
    nCh = arg_im_size(1, end);
end

% Create zero array of the correct type
out_im      = bmZero([N_u, nCh], argType); 

if imDim == 1 % See imDim == 3 for comments
    Nx = N_u(1, 1);
    nx = u(1, 1);
    ind_x = (Nx/2+1-nx/2):(Nx/2+1+nx/2-1); 
    out_im(ind_x, :) = arg_im; 
end

if imDim == 2 % See imDim == 3 for comments
    Nx = N_u(1, 1); 
    nx = n_u(1, 1); 
    Ny = N_u(1, 2); 
    ny = n_u(1, 2); 
    ind_x = (Nx/2+1-nx/2):(Nx/2+1+nx/2-1);
    ind_y = (Ny/2+1-ny/2):(Ny/2+1+ny/2-1);    
    out_im(ind_x, ind_y, :) = arg_im; 
end

if imDim == 3
    % Get sizes the grids in every dimension
    Nx = N_u(1, 1);
    nx = n_u(1, 1);
    Ny = N_u(1, 2);
    ny = n_u(1, 2);
    Nz = N_u(1, 3);
    nz = n_u(1, 3);

    % Set indicies of the image in the padded array (center indicies)
    ind_x = (Nx/2+1-nx/2):(Nx/2+1+nx/2-1);
    ind_y = (Ny/2+1-ny/2):(Ny/2+1+ny/2-1);
    ind_z = (Nz/2+1-nz/2):(Nz/2+1+nz/2-1);

    % Replace center of zero array with the image -> padded image
    out_im(ind_x, ind_y, ind_z, :) = arg_im; 
end

end