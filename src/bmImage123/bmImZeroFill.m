% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out_im = bmImZeroFill(arg_im, N_u, n_u, argType)

N_u = N_u(:)'; 
n_u = n_u(:)'; 
imDim = size(N_u(:), 1); 

arg_im      = bmBlockReshape(arg_im, n_u);
arg_im_size = size(arg_im);
arg_im_size = arg_im_size(:)'; 

if isequal(arg_im_size, n_u)
    nCh = 1;
else
    nCh = arg_im_size(1, end);
end

out_im      = bmZero([N_u, nCh], argType); 

if imDim == 1
    Nx = N_u(1, 1);
    nx = u(1, 1);
    ind_x = (Nx/2+1-nx/2):(Nx/2+1+nx/2-1); 
    out_im(ind_x, :) = arg_im; 
end

if imDim == 2
    Nx = N_u(1, 1); 
    nx = n_u(1, 1); 
    Ny = N_u(1, 2); 
    ny = n_u(1, 2); 
    ind_x = (Nx/2+1-nx/2):(Nx/2+1+nx/2-1);
    ind_y = (Ny/2+1-ny/2):(Ny/2+1+ny/2-1);    
    out_im(ind_x, ind_y, :) = arg_im; 
end

if imDim == 3
    Nx = N_u(1, 1);
    nx = n_u(1, 1);
    Ny = N_u(1, 2);
    ny = n_u(1, 2);
    Nz = N_u(1, 3);
    nz = n_u(1, 3);
    ind_x = (Nx/2+1-nx/2):(Nx/2+1+nx/2-1);
    ind_y = (Ny/2+1-ny/2):(Ny/2+1+ny/2-1);
    ind_z = (Nz/2+1-nz/2):(Nz/2+1+nz/2-1);
    out_im(ind_x, ind_y, ind_z, :) = arg_im; 
end

end