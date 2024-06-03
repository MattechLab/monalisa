% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmPlus(x, y)

if iscell(x) & iscell(y)
    
    N = size(x(:), 1) ;
    out = cell(size(x));
    
    for i = 1:N
        out{i} = x{i} + y{i};
    end
    
elseif ~iscell(x) & ~iscell(y)
    out = x + y;
else
    error('in bmPlus: case not implemented. '); 
end

end