% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTraj_randomPartialCartesian3_x(N_u, dK_u, myPerOne)

N_u     = N_u(:)'; 
dK_u    = dK_u(:)'; 

Nx  = N_u(1, 1); 
Ny  = N_u(1, 2); 
Nz  = N_u(1, 3); 

dKx = dK_u(1, 1); 
dKy = dK_u(1, 2); 
dKz = dK_u(1, 3); 

kx = (-Nx/2:Nx/2 - 1)*dKx; 
ky = (-Ny/2:Ny/2 - 1)*dKy; 
kz = (-Nz/2:Nz/2 - 1)*dKz; 

[ky, kz] = ndgrid(ky, kz); 
ky       = ky(:)'; 
kz       = kz(:)'; 

m = (rand(1, Ny*Nz) <= myPerOne); 
nLine = sum(m(:)); 
ky = ky(1, m); 
kz = kz(1, m); 

kx = repmat(kx(:) , [1, nLine]);  
ky = repmat(ky(:)', [Nx, 1]); 
kz = repmat(kz(:)', [Nx, 1]); 

t = cat(1, kx(:)', ky(:)', kz(:)'); 

end