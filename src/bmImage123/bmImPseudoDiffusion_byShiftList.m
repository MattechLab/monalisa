% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out_1 = bmImPseudoDiffusion_byShiftList(argIm, argShiftList, varargin)

nIter = []; 
if length(varargin) > 0
   nIter = varargin{1};  
end
if isempty(nIter)
   nIter = 1;  
end

% initial
argIm = single(squeeze(argIm)); 


myDim = bmNdim(argIm); 
if myDim == 1 
   argIm   = argIm(:); 
end
argSize = size(argIm); argSize = argSize(:)'; 


out_1 = argIm; 
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
end



end