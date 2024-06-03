% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function im_out = bmImRotate3(arg_im, psi, theta, phi, varargin)

c = bmVarargin(varargin); 

n_u = size(arg_im); 
n_u = n_u(:)'; 
imDim = size(n_u(:), 1); 

[X, Y, Z] = bmImGrid(n_u, [], [], []); 

if isempty(c)
    m = bmElipsoidMask(n_u, n_u/2); 
    arg_im = arg_im.*m; 
    c = bmImReg_getCenterMass_estimate(arg_im, X, Y, Z); 
end

c = c(:); 
R = bmRotation3_inv(psi, theta, phi);  

P = cat(1, X(:)', Y(:)', Z(:)');
P = P - repmat(c(:), [1, prod(n_u(:))]); 
P = R*P; 
P = P + repmat(c(:), [1, prod(n_u(:))]); 

im_out = interpn(X, Y, Z, arg_im, P(1, :), P(2, :), P(3, :));
im_out(isnan(im_out)) = 0; 
im_out(isinf(im_out)) = 0; 
im_out = reshape(im_out, n_u); 

end