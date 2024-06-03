% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function outInd = bmMultiIndex2Index(argMultiInd, argSize)

myMultiInd  = argMultiInd(:)';
mySize      = argSize(:)';

myMultiInd  = myMultiInd - 1;
L = size(mySize, 2);

outInd = myMultiInd(1, 1);
for i = 2:L
    outInd = outInd + myMultiInd(1, i)*prod(mySize(1, 1:i-1));
end

outInd = outInd + 1;

end