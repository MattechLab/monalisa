% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myTranslationTransform = bmImReg_getInitialTranslationTransform_estimate(imRef, imMov, X, Y, Z)

n_u = size(imRef); 
n_u = n_u(:)'; 
imDim = size(n_u(:), 1); 

myTranslationTransform      = bmImReg_translationTransform; 

[X, Y, Z] = bmImGrid(n_u, X, Y, Z); 

c_ref = bmImReg_getCenterMass_estimate(imRef, X, Y, Z); 
c_mov = bmImReg_getCenterMass_estimate(imMov, X, Y, Z); 

myTranslationTransform.t    = c_mov(:) - c_ref(:); 

end