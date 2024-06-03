% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmPhaseLift1(argSignal, varargin)

argSignalSize = size(argSignal);
mySignal = squeeze(argSignal);
mySize = size(mySignal);
mySignal = reshape(mySignal, [mySize(1) prod(mySize(2:end))]) ;
mySize = size(mySignal);

myTransposeFlag = false;
if (mySize(1) < 2) && (mySize(2) < 2)
    out = reshape(mySignal, argSignalSize);
    return;
elseif (mySize(1) < 2) && (ndims(mySignal) == 2)
    mySignal = mySignal';
    flipTemp = mySize(2);
    mySize(2) = mySize(1);
    mySize(1) = flipTemp;
    myTransposeFlag = true;
end

if length(varargin) > 0
    myLift = varargin{1}; 
else
    myLift = 2*pi; 
end

for i = 2:mySize(1)
    
    myMask = abs(mySignal(i,:) - mySignal(i-1,:)) > myLift/2;
    myValPlus  = abs(mySignal(i,:) + myLift - mySignal(i-1,:));
    myValMinus = abs(mySignal(i,:) - myLift - mySignal(i-1,:));
    
    myMaskPlus  = (myValPlus  < myValMinus).*myMask;
    myMaskMinus = (myValMinus < myValPlus ).*myMask;
    
    myMaskPlus  = repmat(myMaskPlus,  [mySize(1)-i+1 1]);
    myMaskMinus = repmat(myMaskMinus, [mySize(1)-i+1 1]);
    
    mySignal(i:end,:) = mySignal(i:end,:) + myMaskPlus*myLift;
    mySignal(i:end,:) = mySignal(i:end,:) - myMaskMinus*myLift;
    
end

if myTransposeFlag
    mySignal = mySignal';
    flipTemp = mySize(2);
    mySize(2) = mySize(1);
    mySize(1) = flipTemp;
end

out = reshape(mySignal, argSignalSize);

end