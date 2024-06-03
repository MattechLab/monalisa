% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% im is the input image
% sx is the shift, in pixel, in dimension 1. 
% sy is the shift, in pixel, in dimension 2.

function out = bmImShift2(im, s)

s = s(:)'; 
sx = s(1, 1); 
sy = s(1, 2); 

n_u = size(im); 
n_u = n_u(:)'; 
nx = n_u(1, 1); 
ny = n_u(1, 2);

[X, Y] = ndgrid(1:nx, 1:ny);

X2 = X - sx; 
Y2 = Y - sy; 

out = interpn(X, Y, im, X2, Y2, 'cubic');
out(isnan(out)) = 0; 

end