% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmBlockReshape(argIn, N_u)

if iscell(argIn)
    out  = cell(size(argIn));
    for i = 1:size(argIn(:), 1)
        out{i} = bmBlockReshape(argIn{i}, N_u);
    end
    return;
end

if isempty(argIn)
   out = []; 
   return; 
end

N_u = N_u(:)'; 
nCh = size(argIn(:), 1)/prod(N_u(:)); 
out = reshape(argIn, [N_u, nCh]); 

end