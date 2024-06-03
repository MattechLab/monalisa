% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myIm = bmImPseudoDiffusion_inMask(argIm, argMask, varargin)

% initial -----------------------------------------------------------------

nIter = bmVarargin(varargin); 
if isempty(nIter)
   nIter = 1;  
end

[myIm, imDim, imSize] = bmImReshape(single(squeeze(argIm))); 
myMask = reshape(logical(argMask), imSize); 
myMask_neg = not(myMask); 



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

    myIm(myMask_neg)    = 0; 
    temp_im             = zeros(imSize, 'single');
    myNumOfNeighb       = zeros(imSize, 'single');
    
    for j = 1:nShift
        temp_im = temp_im + circshift(myIm, myShiftList(j, :));  
        myNumOfNeighb = myNumOfNeighb + single(circshift(myMask, myShiftList(j, :)));
    end
    
    myNumOfNeighb(myNumOfNeighb == 0) = 1;
    myIm = temp_im./myNumOfNeighb;
end

myIm              = reshape(myIm, size(argIm)); 
myMask_neg        = reshape(myMask_neg, size(argIm)); 
myIm(myMask_neg)  = argIm(myMask_neg); 

end