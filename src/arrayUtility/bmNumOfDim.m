% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function n = bmNumOfDim(a)

n = ndims(a);
s = size(a);
s = s(:)'; 

if n == 2
    if min(s(:)) == 0
        n = 0;
    elseif min(s(:)) == 1
        n = 1;
    else
        n = 2;
    end
end


end