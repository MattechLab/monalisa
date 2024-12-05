function cropped_im = bmImCrope(arg_im, N_u, n_u)
% croped_im = bmImCrope(arg_im, N_u, n_u)
%
% This function croppes the data from grid of size N_u to grid of size n_u. 
% Both sizes have to be either even or odd. N_u has be bigger than n_u.
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
%   arg_im (array): Data that should be cropped.
%   N_u (list): Size of the grid occupied by the data in block format.
%   n_u (list): Size of the grid on which the data should be cropped. If
%   N_u is odd, this has to be odd as well. Same for N_u even.
%
% Results:
%   cropped_im (array): Data cropped and given in block format. Or the same
%   format as the input if no cropping is needed.

% Prepare dimensions
imDim = size(N_u(:), 1); 
N_u = N_u(:)'; 
n_u = n_u(:)'; 

% Check if cropping is needed
if isequal(N_u, n_u) 
   cropped_im = arg_im; 
   return; 
end

% Transform uncropped data into block format
cropped_im = bmBlockReshape(arg_im, N_u); 

if imDim == 1 % See imDim == 3 for comments
    Nx = N_u(1, 1);
    nx = n_u(1, 1); 
    ind_x = Nx/2+1 - nx/2:Nx/2+1 + nx/2-1; 
    cropped_im = cropped_im(ind_x, :); 
end

if imDim == 2 % See imDim == 3 for comments
    Nx = N_u(1, 1);
    nx = n_u(1, 1);
    Ny = N_u(1, 2);
    ny = n_u(1, 2);   
    ind_x = Nx/2+1 - nx/2:Nx/2+1 + nx/2-1;
    ind_y = Ny/2+1 - ny/2:Ny/2+1 + ny/2-1; 
    cropped_im = cropped_im(ind_x, ind_y, :); 
end

if imDim == 3
    % Extract sizes
    Nx = N_u(1, 1); 
    nx = n_u(1, 1);
    Ny = N_u(1, 2);
    ny = n_u(1, 2);
    Nz = N_u(1, 3);
    nz = n_u(1, 3);

    % Crop data around center of N_u
    ind_x = Nx/2+1 - nx/2:Nx/2+1 + nx/2-1; 
    ind_y = Ny/2+1 - ny/2:Ny/2+1 + ny/2-1; 
    ind_z = Nz/2+1 - nz/2:Nz/2+1 + nz/2-1; 
    cropped_im = cropped_im(ind_x, ind_y, ind_z, :); 
end

end



