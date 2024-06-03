% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myIm = bmImPseudoDiffusion(argIm, varargin)

% initial -----------------------------------------------------------------

nIter = bmVarargin(varargin); 
if isempty(nIter)
   nIter = 1;  
end

[myIm, imDim, imSize] = bmImReshape(single(squeeze(argIm))); 


if imDim == 1
    
   myShiftList = [    0; 
                      1; 
                     -1; 
                                ]; 
                            
elseif imDim == 2
    
   myShiftList = [   0,  0; 
                     0,  1; 
                     0, -1; 
                     1,  0; 
                    -1,  0; 
                                ];  
elseif imDim == 3
    
    myShiftList = [   0,   0,  0; 
                      0,   0,  1; 
                      0,   0, -1;
                      0,   1,  0;
                      0,  -1,  0;
                      1,   0,  0;
                     -1,   0,  0;
                                    ]; 
end



% convolution
nShift = size(myShiftList, 1); 
for i = 1:nIter    

    temp_im             = zeros(imSize, 'single');
    for j = 1:nShift
        temp_im = temp_im + circshift(myIm, myShiftList(j, :));  
    end    
    myIm = temp_im./(imDim*2+1);
end

myIm              = reshape(myIm, size(argIm));

end