function [n, s, varargout] = bmImDim(a)
% [n, s, varargout] = bmImDim(a)
%
% This function returns the number of dimensions and size of the input 
% array. Can optionally return the x, y and z size, which are the size of 
% the first three dimensions of the input array.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   a (array): The array of which the dimension and size should be
%    returned. Can be empty.
%
% Returns:
%   n (int): The number of dimensions.
%   s (list): The size of each dimension as a list.
%   varargout{1}: Integer containing the size of the first dimension. Empty
%   if n < 1
%   varargout{1}: Integer containing the size of the second dimension. 
%   Empty if n < 2
%   varargout{1}: Integer containing the size of the third dimension. Empty
%   if n < 3

% Get dimension and size of the input
n = ndims(a); 
s = size(a);
s = s(:)'; 

% Handle cases for n <= 2 (ndims is always >= 2 even for vectors or empty 
% variables)
if n == 2    
   if min(s(:)) == 0
      % Empty
      n = 0; 
   elseif min(s(:)) == 1
      % Vector
      n = 1; 
   else
      n = 2;
   end
end


sx = []; 
sy = []; 
sz = []; 

% Get size of first dimension
if n > 0
   sx =  s(1, 1);  
end

% Get size of second dimension
if n > 1
   sy =  s(1, 2); 
end

% Get size of third dimension
if n > 2
   sz =  s(1, 3); 
end

% Return sizes that are required
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