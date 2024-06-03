% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myMask = bmScalarBinning(x, nBin)

x = x(:)'; 

N = size(x, 2);
myBinLength = fix(N/nBin); 

[mySort, myPerm] = sort(x);

myMask = false(nBin, N);
for i = 0:nBin-1
    myMask(i+1, i*myBinLength + 1 : (i+1)*myBinLength) = true;  
end
myMask(end, nBin*myBinLength:end) = true; 

[~, myInvPerm] = sort(myPerm); 
myMask = myMask(:, myInvPerm); 

end