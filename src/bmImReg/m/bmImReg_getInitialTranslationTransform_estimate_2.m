% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myTranslationTransform = bmImReg_getInitialTranslationTransform_estimate_2(imRef, imMov, X, Y, Z)

n_u = size(imRef); 
n_u = n_u(:)'; 
imDim = size(n_u(:), 1); 

myTranslationTransform      = bmImReg_translationTransform; 

[X, Y, Z] = bmImGrid(n_u, X, Y, Z);  



s = ones(1, imDim)*48; % ----------------------------------------------------- magic number
a = bmImResize(imRef, n_u, s); 
b = bmImResize(imMov, n_u, s); 
f = n_u./s; 
r = zeros(s);

if imDim == 2
    
    for i = 1:s(1, 1)
        for j = 1:s(1, 2)
            
            imShift = circshift(a, [i, j]);
            r(i, j) = sum(abs(  imShift(:) - b(:)  ));
            
        end
    end
    
elseif imDim == 3
    
    for i = 1:s(1, 1)
        i
        for j = 1:s(1, 2)
            for k = 1:s(1, 3)
                
                imShift = circshift(a, [i, j, k]);
                r(i, j, k) = sum(abs(  imShift(:) - b(:)  ));
                
            end
        end
    end
    
end

[myMin, myInd] = min(r(:)); 

t = bmIndex2MultiIndex(myInd, s); 

myTranslationTransform.t = t(:).*f(:); 

end