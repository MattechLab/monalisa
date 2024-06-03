% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function outIndex = bmFirstIndex(argString, argVal, argVec)

argVec = argVec(:)'; 

if strcmp(argString, 'equalTo')
    myMask = (argVec == argVal);
elseif strcmp(argString, 'smallerThan')
    myMask = (argVec < argVal);
elseif strcmp(argString, 'biggerThan')
    myMask = (argVec > argVal);
elseif strcmp(argString, 'smallerEqualThan')
    myMask = (argVec <= argVal);
elseif strcmp(argString, 'biggerEqualThan')
    myMask = (argVec >= argVal);
end


myIndexList = 1:length(argVec);
myIndexList = myIndexList(myMask);

if isempty(myIndexList)
    outIndex = length(argVec) + 1;
else
    outIndex = myIndexList(1);
end

end