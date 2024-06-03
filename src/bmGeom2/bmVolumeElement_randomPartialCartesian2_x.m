% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function ve = bmVolumeElement_randomPartialCartesian2_x(t, N_u, dK_u)

N_u  = N_u(:)'; 
dK_u = dK_u(:)'; 

Nx = N_u(1, 1); 
Ny = N_u(1, 2); 

dKx = dK_u(1, 1); 
dKy = dK_u(1, 2); 

t = bmPointReshape(t); 
nPt = size(t, 2); 
nLine = nPt/Nx; 

t   = reshape(t, [2, Nx, nLine]); 
t1  = bmPointReshape(squeeze(t(2, 1, :))); 

ve  = bmVolumeElement1(t1); 
ve  = repmat(ve(:)', [Nx, 1]); 
ve  = dKx*ve(:)'; 

end