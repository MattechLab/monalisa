% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmPermuteToCol(y, varargin)

argSize = bmVarargin(varargin); 

out = [];
if iscell(y)
    out  = cell(size(y));
    for i = 1:size(y(:), 1)
        out{i} = bmPermuteToCol(y{i}, argSize);
    end
    return;
end

if isempty(y)
   out = []; 
   return; 
end

if isempty(argSize)
    nCh = size(y, 1); 
    nPt = size(y(:), 1)/nCh; 
else
    nPt     = prod(argSize(:)); 
    nCh     = size(y(:), 1)/nPt;    
end

y       = reshape(y, [nCh, nPt]);
out     = y.';


end