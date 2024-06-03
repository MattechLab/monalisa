% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myMask = bmSphereMask(argImage, argCenter, argRadius)

myImage = squeeze(argImage);
mySize  = size(myImage);
myNdims = length(mySize);

if (mySize(1) == 1) || (mySize(2) == 1)
    myNdims = 1;
    mySize = length(myImage);
    myImage = reshape(myImage, [length(myImage) 1]);
    myGridd = [1:mySize] - argCenter(1);
    myDist = abs(myGridd);
    
    myMask = ones(size(myImage));
    myMask(myDist > argRadius) = 0;
    myMask = reshape(myMask, size(argImage));
    myMask = logical(myMask);
    return;
end

for i = 1:myNdims
    myReshapeVec = ones(1,myNdims);
    myReshapeVec(i) = mySize(i);
    myGridd_1D{i} = reshape(1:mySize(i), myReshapeVec);
end

for i = 1:myNdims
    myRepVec = mySize;
    myRepVec(i) = 1;
    myGriddCell{i} = repmat(myGridd_1D{i}, myRepVec) - argCenter(i);
end

myDistSqr = zeros(size(myGriddCell{1}));
for i = 1:myNdims
    myDistSqr = myDistSqr + myGriddCell{i}.^2;
end
myDist = sqrt(myDistSqr);
myMask = ones(size(myImage));
myMask(myDist > argRadius) = 0;
myMask = reshape(myMask, size(argImage));
myMask = logical(myMask);

end

