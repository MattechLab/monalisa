% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmPermuteToPoint(y, argSize)

out = [];
if iscell(y)
    out  = cell(size(y));
    for i = 1:size(y(:), 1)
        out{i} = bmPermuteToPoint(y{i}, argSize);
    end
    return;
end

if isempty(y)
   out = []; 
   return; 
end

nPt     = prod(argSize(:)); 
nCh     = size(y(:), 1)/nPt; 
y       = reshape(y, [nPt, nCh]); 
out     = y.'; 


end