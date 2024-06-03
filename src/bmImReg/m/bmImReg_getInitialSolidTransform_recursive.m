% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [v, mySolidTransform, imReg] = bmImReg_getInitialSolidTransform_recursive( imRef, imMov, nIter_max, ...
                                                                                    initialTranslationTransform, ...
                                                                                    X, Y, Z)

halfPixLength   = 1/2; % ------------------------------------------------------------ magic_number

n_u         = size(imRef); 
n_u         = n_u(:)'; 
imDim       = size(n_u(:), 1); 
[X, Y, Z]   = bmImGrid(n_u, X, Y, Z); 

mySolidTransform        = bmImReg_solidTransform; 
temp_solidTransform     = bmImReg_solidTransform; 

if ~isempty(initialTranslationTransform)
    
    mySolidTransform.t      = initialTranslationTransform.t;
    
else

    if imDim == 2
        myTrans = bmImReg_getInitialTranslationTransform_estimate_2(imRef, imMov, X, Y, Z);
        mySolidTransform.t = myTrans.t;
    elseif imDim == 3
        mySolidTransform.t      = zeros([imDim, 1], 'single');
    end
    
end

mySolidTransform.c_ref  = bmImReg_getCenterMass_estimate(imRef, X, Y, Z); 
mySolidTransform.R      = eye(imDim); 

imReg                   = imMov; 

% test_im = imReg; 

for i = 1:nIter_max
    
    temp_solidTransform     = bmImReg_getInitialSolidTransform_estimate(imRef, imReg, X, Y, Z);

    mySolidTransform.t      =  mySolidTransform.R*temp_solidTransform.t + mySolidTransform.t; 
    
    mySolidTransform.R      =  mySolidTransform.R*temp_solidTransform.R; 
    
    v                       = bmImReg_transform_to_deformField(mySolidTransform, n_u, X, Y, Z);
    
    imReg                   = bmImReg_deform(v, imMov, n_u, X, Y, Z);


    % test_im = cat(imDim+1, test_im, imReg); 
    
    R_rest   = temp_solidTransform.R - eye(imDim); 
    R_rest   = sqrt(  (norm(R_rest(:))^2)/imDim  ); 
    t_rest   = norm(temp_solidTransform.t); 
    
    if (t_rest < halfPixLength) && (R_rest < halfPixLength)
        break; 
    end
    
end

    imReg   = bmImReg_deform(v, imMov, n_u, X, Y, Z);
    m       = bmElipsoidMask(n_u, n_u/2);
    imReg   = imReg.*single(m); 
    
    % bmImage(test_im)
    
end