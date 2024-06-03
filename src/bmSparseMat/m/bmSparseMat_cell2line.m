% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmSparseMat_cell2line(argCell, varargin)

myVararginFlag = false;
if length(varargin) > 0
    myVararginFlag = true;
    tempNumOfInd = varargin{1}(:)';
end




myLength = length(argCell);
if ~myVararginFlag
    tempNumOfInd = zeros(1, myLength);
    for i = 1:myLength
        tempNumOfInd(i) = size(argCell{i}, 2);
    end
end

tempNumOfInd_64 = int64(tempNumOfInd); 
mySum_64 = sum(tempNumOfInd_64, 2, 'native'); % This sum must be done in int64 !

out = zeros(1, mySum_64); 

currentInd_1 = int64(1);
currentInd_2 = int64(0);
myLength_64  = int64(myLength); 
myOne_64     = int64(1); 
for i = myOne_64:myLength_64
    currentInd_2 = currentInd_2 + tempNumOfInd_64(i);
    out(1, currentInd_1:currentInd_2) = (argCell{i}(:))';
    currentInd_1 = currentInd_2 + myOne_64;
end



end