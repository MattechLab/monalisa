% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTraj_randomPartialCartesian2_x(N_u, dK_u, myPerOne)

N_u     = N_u(:)'; 
dK_u    = dK_u(:)'; 

Nx  = N_u(1, 1); 
Ny  = N_u(1, 2); 

dKx = dK_u(1, 1); 
dKy = dK_u(1, 2);  

kx = (-Nx/2:Nx/2 - 1)*dKx; 
ky = (-Ny/2:Ny/2 - 1)*dKy; 

m = (rand(1, Ny) <= myPerOne); 
nLine = sum(m(:)); 
ky = ky(1, m); 

kx = repmat(kx(:) , [1, nLine]);  
ky = repmat(ky(:)', [Nx, 1]); 

t = cat(1, kx(:)', ky(:)'); 

end