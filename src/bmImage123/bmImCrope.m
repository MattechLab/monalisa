% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function croped_im = bmImCrope(arg_im, N_u, n_u)

imDim = size(N_u(:), 1);
N_u = N_u(:)'; 
n_u = n_u(:)'; 

if isequal(N_u, n_u)
   croped_im = arg_im; 
   return; 
end

croped_im = bmBlockReshape(arg_im, N_u); 

if imDim == 1
   Nx = N_u(1, 1);
   nx = n_u(1, 1); 
   ind_x = Nx/2+1 - nx/2:Nx/2+1 + nx/2-1; 
   croped_im = croped_im(ind_x, :); 
end

if imDim == 2
   Nx = N_u(1, 1);
   nx = n_u(1, 1);
   Ny = N_u(1, 2);
   ny = n_u(1, 2);   
   ind_x = Nx/2+1 - nx/2:Nx/2+1 + nx/2-1;
   ind_y = Ny/2+1 - ny/2:Ny/2+1 + ny/2-1; 
   croped_im = croped_im(ind_x, ind_y, :); 
end

if imDim == 3
   Nx = N_u(1, 1);
   nx = n_u(1, 1);
   Ny = N_u(1, 2);
   ny = n_u(1, 2);
   Nz = N_u(1, 3);
   nz = n_u(1, 3);
   ind_x = Nx/2+1 - nx/2:Nx/2+1 + nx/2-1; 
   ind_y = Ny/2+1 - ny/2:Ny/2+1 + ny/2-1; 
   ind_z = Nz/2+1 - nz/2:Nz/2+1 + nz/2-1; 
   croped_im = croped_im(ind_x, ind_y, ind_z, :); 
end



end



