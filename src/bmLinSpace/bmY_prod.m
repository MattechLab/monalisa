% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function p = bmY_prod(y1, y2, d_n)

if ndims(y1) > 2
   error('This function is for 2Dim arrays only. ');  
   return; 
end

if not(isequal(size(y1), size(y2)))
    error('Both arrays must have the same size. '); 
    return; 
end

d_n = bmY_ve_reshape(d_n, size(y1)); 
if size(y1, 1) > size(y1, 2)
    p = sum(conj(y1).*(y2.*d_n), 1);
else 
    p = sum(conj(y1).*(y2.*d_n), 2);
end

end