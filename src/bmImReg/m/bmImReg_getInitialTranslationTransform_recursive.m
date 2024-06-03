% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [v, myTranslationTransform, imReg] = bmImReg_getInitialTranslationTransform_recursive(imRef, imMov, nIter_max, X, Y, Z)

halfPixLength   = 1/2; % ------------------------------------------------------------ magic_number

n_u         = size(imRef); 
n_u         = n_u(:)'; 
imDim       = size(n_u(:), 1); 
[X, Y, Z]   = bmImGrid(n_u, X, Y, Z); 

myTranslationTransform        = bmImReg_translationTransform; 
temp_translationTransform     = bmImReg_translationTransform; 

myTranslationTransform.t      = zeros([imDim, 1], 'single');
imReg                         = imMov; 

% test_im = imReg; 

for i = 1:nIter_max
    
    temp_translationTransform   = bmImReg_getInitialTranslationTransform_estimate(imRef, imReg, X, Y, Z);

    myTranslationTransform.t    =  temp_translationTransform.t + myTranslationTransform.t; 

    v                           = bmImReg_transform_to_deformField(myTranslationTransform, n_u);
    
    imReg                       = bmImReg_deform(v, imMov, n_u, X, Y, Z);

    % test_im = cat(3, test_im, imReg); 
        
    if norm(temp_translationTransform.t) < halfPixLength
        break; 
    end
    
end

    imReg = bmImReg_deform(v, imMov, n_u, X, Y, Z);
    
    % bmImage(test_im)
    
end