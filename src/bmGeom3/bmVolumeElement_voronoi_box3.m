% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function ve = bmVolumeElement_voronoi_box3(t, N_u, d_u)

N_u = double(N_u(:)'); 
d_u = double(d_u(:)'); 
t   = bmPointReshape(t); 
nPt = size(t, 2);

Nx = N_u(1, 1) + 1; 
Ny = N_u(1, 2) + 1; 
Nz = N_u(1, 3) + 1; 

x           =  -(Nx/2)*d_u(1, 1);
y           = [-(Ny/2):(Ny/2-1)]*d_u(1, 2);
z           = [-(Nz/2):(Nz/2-1)]*d_u(1, 3);
[x, y, z]   = ndgrid(x, y, z); 
p1          = cat(1, x(:)', y(:)', z(:)');

x           =  (Nx/2 - 1)*d_u(1, 1);
y           = [-(Ny/2):(Ny/2-1)]*d_u(1, 2);
z           = [-(Nz/2):(Nz/2-1)]*d_u(1, 3);
[x, y, z]   = ndgrid(x, y, z); 
p2          = cat(1, x(:)', y(:)', z(:)');

x           = [-(Nx/2-1):(Nx/2-2)]*d_u(1, 1);
y           =  -(Ny/2)*d_u(1, 2);
z           = [-(Nz/2):(Nz/2-1)]*d_u(1, 3);
[x, y, z]   = ndgrid(x, y, z); 
p3          = cat(1, x(:)', y(:)', z(:)');

x           = [-(Nx/2-1):(Nx/2-2)]*d_u(1, 1);
y           =   (Ny/2-1)*d_u(1, 2);
z           = [-(Nz/2):(Nz/2-1)]*d_u(1, 3);
[x, y, z]   = ndgrid(x, y, z); 
p4          = cat(1, x(:)', y(:)', z(:)');

x           = [-(Nx/2-1):(Nx/2-2)]*d_u(1, 1);
y           = [-(Ny/2-1):(Ny/2-2)]*d_u(1, 2);
z           = -(Nz/2)*d_u(1, 3);
[x, y, z]   = ndgrid(x, y, z); 
p5          = cat(1, x(:)', y(:)', z(:)');

x           = [-(Nx/2-1):(Nx/2-2)]*d_u(1, 1);
y           = [-(Ny/2-1):(Ny/2-2)]*d_u(1, 2);
z           = (Nz/2-1)*d_u(1, 3);
[x, y, z]   = ndgrid(x, y, z); 
p6          = cat(1, x(:)', y(:)', z(:)');

t = cat(2, t, p1, p2, p3, p4, p5, p6); 
ve = bmVoronoi(t);   
ve = ve(1, 1:nPt); 

end