% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function n = bmY_norm(y, d_n, varargin)

collapse_flag = bmVarargin(varargin); 
if isempty(collapse_flag)
    collapse_flag = false; 
end

if ndims(y) > 2
    error('This function is for 2Dim arrays only. ');
    return;
end


d_n = bmY_ve_reshape(d_n, size(y)); 
if size(y, 1) > size(y, 2)
    n = sqrt(abs(sum(conj(y).*(y.*d_n), 1)));
else
    n = sqrt(abs(sum(conj(y).*(y.*d_n), 2)));
end
if collapse_flag
   n = sqrt(sum(n(:).^2));  
end


end