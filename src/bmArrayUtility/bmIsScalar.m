% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmIsScalar(x)

out = false; 

if iscell(x)
    out = false; 
    return; 
end

if size(x(:), 1) == 1
    out = true; 
    return; 
else
    out = false; 
    return; 
end

end