% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmPointReshape(t, varargin)

argSize = bmVarargin(varargin); 

if iscell(t)
    out  = cell(size(t));
    for i = 1:size(t(:), 1)
        out{i} = bmPointReshape(t{i}, argSize);
    end
    return;
end

if ndims(t) == 2
    if (size(t, 1) == 1) || (size(t, 2) == 1)
        out = t(:).';
        return;
    end
end

argSize = bmVarargin(varargin); 
argSize = argSize(:)'; 
if isempty(argSize)
   nCh = size(t, 1);
else
    nCh =  argSize(1, 1); 
end

nPt = size(t(:), 1)/nCh; 
out = reshape(t, [nCh, nPt]);

end