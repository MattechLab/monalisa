% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function n = bmX_norm(x, d_u, varargin)

collapse_flag = bmVarargin(varargin); 
if isempty(collapse_flag)
    collapse_flag = false; 
end

if ndims(x) > 2
   error('This function is for 2Dim arrays only. ');  
   return; 
end

dV = prod(d_u(:));
if size(x, 1) > size(x, 2)
    n = sqrt(abs(sum(conj(x).*(x*dV), 1)));
else
    n = sqrt(abs(sum(conj(x).*(x*dV), 2)));
end
if collapse_flag
   n = sqrt(sum(n(:).^2));  
end
    
end