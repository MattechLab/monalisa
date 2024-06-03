% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmColReshape(argIn, argSize)

if iscell(argIn)
    out  = cell(size(argIn));
    for i = 1:size(argIn(:), 1)
        out{i} = bmColReshape(argIn{i}, argSize);
    end
    return;
end

nPt = prod(argSize(:)); 
nCh = size(argIn(:), 1)/nPt;
out = reshape(argIn, [nPt, nCh]);

end