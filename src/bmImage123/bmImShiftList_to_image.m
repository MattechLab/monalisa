% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImShiftList_to_image(argShiftList, varargin)

[argSize, myValList] = bmVarargin(varargin);
if isempty(argSize)
    argSize = max(argShiftList(:)) - min(argShiftList(:));
    if size(argShiftList, 2) == 1
        argSize = [argSize, 1];
    elseif size(argShiftList, 2) == 2
        argSize = [argSize, argSize];
    elseif size(argShiftList, 2) == 3
        argSize = [argSize, argSize, argSize];
    end
end
if isempty(myValList)
    myValList = ones(size(argShiftList, 1), 1);
end

argSize = argSize(:)'; 
nShift = size(argShiftList, 1) ;

out = zeros(argSize);  
[out, myDim, mySize] = bmImReshape(out);  
myCenter = fix(   mySize/2+1   );

if myDim == 0
    error('The dimension proposed by argSize is zero');
    return; 
    
elseif myDim == 1    
    for i = 1:nShift
        myIndex_x = argShiftList(i, 1) + myCenter(1, 1);
        out(myIndex_x, 1) = myValList(i, 1);
    end
    
elseif myDim == 2
    for i = 1:nShift
        myIndex_x = argShiftList(i, 1) + myCenter(1, 1);
        myIndex_y = argShiftList(i, 2) + myCenter(1, 2);
        out(myIndex_x, myIndex_y) = myValList(i, 1);
    end
    
elseif myDim == 3
    for i = 1:nShift
        myIndex_x = argShiftList(i, 1) + myCenter(1, 1);
        myIndex_y = argShiftList(i, 2) + myCenter(1, 2);
        myIndex_z = argShiftList(i, 3) + myCenter(1, 3);
        out(myIndex_x, myIndex_y, myIndex_z) = myValList(i, 1);
    end
    
end

end
