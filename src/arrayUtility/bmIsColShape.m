function out = bmIsColShape(x, N_u)
% out = bmIsColShape(x, N_u)
%
% This function checks if the data in array x is in the column format, 
% i.e., contains a column vector for each channel.
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
%   x (array): Array of which the format should be tested.
%   N_u (list): Size of the data of one channel in x.
%
% Returns:
%   out (logical): 1 if x is in column format, 0 if not.

% Calculate number of channels
nCh = size(x(:), 1)/prod(N_u(:)); 

% Calculate the size of the data in column format and get the size of x
myColSize = [prod(N_u(:)), nCh]; 
mySize = size(x); 

% Compare sizes to determine if x is in column format or not
if isequal(mySize, myColSize) 
    out = true; 
else
    out = false; 
end

end