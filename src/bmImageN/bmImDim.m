% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [n, s, varargout] = bmImDim(a)

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


sx = []; 
sy = []; 
sz = []; 

if n > 0
   sx =  s(1, 1); 
end
if n > 1
   sy =  s(1, 2); 
end
if n > 2
   sz =  s(1, 3); 
end


if nargout > 2
   varargout{1} = sx;  
end
if nargout > 3
   varargout{2} = sy;  
end
if nargout > 4
   varargout{3} = sz;  
end


end