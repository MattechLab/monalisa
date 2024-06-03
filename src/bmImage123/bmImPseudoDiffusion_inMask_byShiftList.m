% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out_1 = bmImPseudoDiffusion_inMask_byShiftList(argIm, argShiftList, argMask, varargin)

nIter = []; 
if length(varargin) > 0
   nIter = varargin{1};  
end
if isempty(nIter)
   nIter = 1;  
end

% initial
argIm   = single(squeeze(argIm)); 
argMask = logical(argMask); 
argMask_neg = not(argMask); 

myDim = bmNdim(argIm); 
if myDim == 1 
   argIm   = argIm(:); 
   argMask = argMask(:); 
   argMask_neg = argMask_neg(:);  
end
argSize = size(argIm); argSize = argSize(:)'; 


out_1 = argIm; 
out_1(argMask_neg) = 0; 
nShift = size(argShiftList, 1); 

% convolution
for i = 1:nIter    
    myZeroMask = (out_1 == 0);
    myZeroMask = reshape(myZeroMask, argSize);
    myNonZeroMask = not(myZeroMask);

    out_2 = zeros(argSize, 'single');
    myNumOfNonZero = zeros(argSize, 'single');
    for j = 1:nShift
        out_2 = out_2 + circshift(out_1, argShiftList(j, :));  
        myNumOfNonZero = myNumOfNonZero + single(circshift(myNonZeroMask, argShiftList(j, :)));
    end
    myNumOfNonZero(myNumOfNonZero == 0) = 1;
    out_1 = out_2./myNumOfNonZero;
    out_1(argMask_neg) = 0; 
end

out_1(argMask_neg) = argIm(argMask_neg); 

end