% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [outImagesTable outSlope outOffset outFit] = bmLocalPhaseLift3(argImagesTable, argTime, varargin)

argSize = size(argImagesTable); 
mySize = [prod(argSize(1:end-1)) argSize(end)];

if length(argTime) == 1
    t = 0:argTime:(mySize(2)-1)*argTime;
elseif length(argTime > 1)
    t = squeeze(argTime);
    t = reshape(t, [1 length(t)]);
else
    error('Wrong list of arguments.')
    return;
end

if not(length(t) == mySize(2))
    error('Wrong list of arguments.')
    return;
end

myImagesTable = reshape(argImagesTable, mySize); 

myImagesTable_start = myImagesTable(:,1);
for i = 2:mySize(2)
    myImagesTable(:,i) = myImagesTable(:,i)-myImagesTable_start;
end
myImagesTable(:,1) = zeros(mySize(1), 1); 

normFactor = 1;
if (length(varargin) > 0) && strcmp(varargin{1}, 'Normalize')
    if length(varargin) > 1
        normFactor = varargin{2};
    else
        normFactor = max(myImagesTable(:))+1; % for a coding of the phase with entire numbers
    end
end
myImagesTable = myImagesTable/normFactor;

mySum = zeros(mySize(1),1);
myDiff = zeros(mySize(1), mySize(2)-1); 
for i = 2:mySize(2)
   myDiff(:,i-1) = myImagesTable(:,i)-myImagesTable(:,i-1);
   mySum = mySum + double(myDiff(:,i-1) >= 0) - double(myDiff(:,i-1) < 0);  
end
myPositiveSign = (mySum >= 0);
myNegativeSign = (mySum <  0);

for i = 2:mySize(2);
    myPositiveMask = (myDiff(:,i-1) >= 0);
    myNegativeMask = (myDiff(:,i-1) <  0); 
    
    myPlusMask =  logical(myPositiveSign.*myNegativeMask);
    myMinusMask = logical(myNegativeSign.*myPositiveMask);
    
    for j = i:mySize(2)
        temp = myImagesTable(:,j);
        temp(myPlusMask)  = temp(myPlusMask)+1;
        temp(myMinusMask) = temp(myMinusMask)-1;
        myImagesTable(:,j) = temp;
    end
end

for i = 2:mySize(2);
    
    myDiff(:,i-1) = myImagesTable(:,i)-myImagesTable(:,i-1);
    
    myMinusMask = (myDiff(:,i-1) >= 0.5);
    myPlusMask  = (myDiff(:,i-1) < -0.5); 
      
    for j = i:mySize(2)
        temp = myImagesTable(:,j);
        temp(myPlusMask)  = temp(myPlusMask)+1;
        temp(myMinusMask) = temp(myMinusMask)-1;
        myImagesTable(:,j) = temp;
    end
end

myImagesTable = myImagesTable*normFactor + repmat(myImagesTable_start, [1 mySize(2)]); 
[outOffset, outSlope, outFit] = bmAffineFit(myImagesTable, t);

outImagesTable = myImagesTable;

outImagesTable = reshape(outImagesTable, argSize); 
outFit = reshape(outFit, argSize);
outSlope = reshape(outSlope, argSize(1:end-1)); 
outOffset = reshape(outOffset, argSize(1:end-1)); 


end