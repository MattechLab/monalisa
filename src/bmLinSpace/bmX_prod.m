% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function p = bmX_prod(x1, x2, d_u)

if ndims(x1) > 2
   error('This function is for 2Dim arrays only. ');  
   return; 
end

if not(isequal(size(x1), size(x2)))
    error('Both arrays must have the same size. '); 
    return; 
end

dV = prod(d_u(:)); 
if size(x1, 1) > size(x1, 2)
    p = sum(conj(x1).*(x2*dV ), 1);
else
    p = sum(conj(x1).*(x2.*dV), 2);
end

end