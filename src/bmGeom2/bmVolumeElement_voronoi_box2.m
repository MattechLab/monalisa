% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function ve = bmVolumeElement_voronoi_box2(t, N_u, d_u)

N_u = double(N_u(:)'); 
d_u = double(d_u(:)'); 
t   = bmPointReshape(t); 
nPt = size(t, 2);


Nx = N_u(1, 1) + 1; 
Ny = N_u(1, 2) + 1; 

p1_x    =  -(Nx/2)*ones(1, Ny)*d_u(1, 1); 
p1_y    = (-(Ny/2):(Ny/2-1))*d_u(1, 2);
p1      = cat(1, p1_x(:)', p1_y(:)'); 

p2_x    = (Nx/2-1)*ones(1, Ny)*d_u(1, 1); 
p2_y    = (-(Ny/2):(Ny/2-1))*d_u(1, 2);
p2      = cat(1, p2_x(:)', p2_y(:)'); 

p3_x    = (-(Nx/2-1):(Nx/2-2))*d_u(1, 1);
p3_y    =  -(Ny/2)*ones(1, Nx-2)*d_u(1, 2); 
p3      = cat(1, p3_x(:)', p3_y(:)'); 

p4_x    = (-(Nx/2-1):(Nx/2-2))*d_u(1, 1);
p4_y    =  (Ny/2-1)*ones(1, Nx-2)*d_u(1, 2); 
p4      = cat(1, p4_x(:)', p4_y(:)'); 

t = cat(2, t, p1, p2, p3, p4); 
ve = bmVoronoi(t);   
ve = ve(1, 1:nPt); 

end