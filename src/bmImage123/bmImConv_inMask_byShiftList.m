% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out_1 = bmImConv_inMask_byShiftList(argIm, argShiftList, argMask, varargin)

nIter = []; 
if length(varargin) > 0
   nIter = varargin{1};  
end
if isempty(nIter)
   nIter = 1;  
end

% initial
argIm = single(argIm); 
argMask = logical(argMask); 
argSize = size(argIm);
argSize = argSize(:)'; 

myDim = bmNdim(argIm); 
if myDim == 1 
   argSize = [max(argSize(:)), 1];
   argIm   = argIm(:); 
   argMask = argMask(:);
end

myMask_neg = not(argMask); 
out_1 = argIm;
out_1(myMask_neg) = 0; 
out_2 = zeros(argSize, 'single'); 

nShift = size(argShiftList, 1); 

% numOfNonZero
myNumOfNonZero = zeros(argSize, 'single'); 
for i = 1:nShift
   myNumOfNonZero = myNumOfNonZero + single(circshift(argMask, argShiftList(i, :)));  
end
myNumOfNonZero(myMask_neg) = 1;  


% convolution
for i = 1:nIter
    for j = 1:nShift
       out_2 = out_2 + circshift(out_1, argShiftList(j, :));  
    end
    out_1 = out_2./myNumOfNonZero; 
    out_1(myMask_neg) = 0;
    out_2 = zeros(argSize, 'single'); 
end

out_1(myMask_neg) = argIm(myMask_neg); 


end