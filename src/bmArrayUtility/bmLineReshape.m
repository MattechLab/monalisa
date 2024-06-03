% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmLineReshape(argIn, argSize)

if iscell(argIn)
    out  = cell(size(argIn));
    for i = 1:size(argIn(:), 1)
        out{i} = bmLineReshape(argIn{i}, argSize);
    end
    return;
end

argSize = argSize(:)';
nCh     = argSize(1, 1);
N       = argSize(1, 2);

nLine = size(argIn(:), 1)/nCh/N;
out = reshape(argIn, [nCh, N, nLine]);

end