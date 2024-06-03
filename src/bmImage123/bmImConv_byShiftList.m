% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out_1 = bmImConv_byShiftList(argIm, argShiftList, varargin)

% varargin ----------------------------------------------------------------
[myKernelVal, nIter] = bmVarargin(varargin); 

if isempty(myKernelVal)
    myKernelVal = ones(size(argShiftList, 1), 1); 
end

if isempty(nIter)
   nIter = 1;  
end
% END_varargin ------------------------------------------------------------


% initial -----------------------------------------------------------------
argSize = size(argIm); 
mySize  = argSize(:)';

out_1 = single(argIm); 
if ndims(out_1) == 2
   if (mySize(1, 1) == 1) || (mySize(1, 2) == 1)
       out_1 = out_1(:); 
   end
end
mySize = size(out_1); 
out_2 = zeros(mySize, 'single');

nShift = size(argShiftList, 1); 
% END_initial -------------------------------------------------------------



% convolution -------------------------------------------------------------
for i = 1:nIter
    for j = 1:nShift
        out_2 = out_2 + circshift(out_1, argShiftList(j, :))*myKernelVal(j, 1);
    end
    out_1 = out_2/nShift;
    out_2 = zeros(argSize, 'single');
end
% END_convolution ---------------------------------------------------------


out_1 = reshape(out_1, argSize); 

end