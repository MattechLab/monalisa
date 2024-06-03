% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmAxpy(a, x, y)

if iscell(a) & iscell(x) & iscell(y)
    
    N = size(x(:), 1) ;
    out = cell(size(x));
    
    for i = 1:N
        out{i} = a{i}.*x{i} + y{i};
    end
    
elseif ~iscell(a) & iscell(x) & iscell(y)
    
    N = size(x(:), 1) ;
    out = cell(size(x));
    
    
    if size(a(:), 1) == 1
        for i = 1:N
            out{i} = a*x{i} + y{i};
        end
    else
        for i = 1:N
            out{i} = a.*x{i} + y{i};
        end
    end
    
elseif ~iscell(a) & ~iscell(x) & ~iscell(y)
    
    if size(a(:), 1) == 1
        out = a*x + y;
    else
        out = a.*x + y;
    end
else
    error('In bmAxpy: case not implemented. '); 
end

end