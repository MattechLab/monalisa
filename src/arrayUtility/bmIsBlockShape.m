function out = bmIsBlockShape(x, N_u)
% out = bmIsBlockShape(x, N_u)
%
% This function checks if the data in array x is in the block format, i.e.,
% contains a grid for each channel.
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
%   out (logical): 1 if x is in block format, 0 if not.

% Calculate the number of channels
nCh = size(x(:), 1)/prod(N_u(:)); 

% Calculate the size of the data in block format and get the size of x
myBlockSize = [N_u, nCh]; 
mySize = size(x);

% Compare sizes to determine if x is in block format or not
if isequal(mySize, myBlockSize)
    out = true; 
else
    out = false; 
end

end