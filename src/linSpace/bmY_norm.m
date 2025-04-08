function n = bmY_norm(y, d_n, varargin)
% n = bmY_norm(y, d_n, varargin)
%
% This function computes the weighted norm of the data y with the volume
% elements d_n. The norm is computed for every channel.
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
%   y (array): The data containing datapoints per channel.
%   d_n (array): The volume elements for every datapoint. Can be a scalar
%   taken for every datapoint, or can have different values for different
%   channels.
%   varargin{1}: Flag; collapses the output into a single value if true.
%   Another norm is calculated across channels to receive this value.
%   Default value is false.
%
% Returns:
%   n (list): The norms for every channel computed over the datapoints.
%   Only a scalar if y only contains one channel or the optional flag is
%   true. Row or column vector depending on y -> if size(y,2) = nCh then
%   size(n,2) = nCh and n is a row vector.


% Extract optional arguments
collapse_flag = bmVarargin(varargin); 

% Set default value
if isempty(collapse_flag) 
    collapse_flag = false; 
end

 % Throw an error if y has more than 2 dimensions
if ndims(y) > 2
    error('This function is for 2Dim arrays only. ');
end

% Reshape (and resize if necessary) d_n to match the size of y
d_n = bmY_ve_reshape(d_n, size(y)); 

% Calculate the weighted norm along the datapoints (1 norm per channel)
if size(y, 1) > size(y, 2)
    % Each column is a channel
    n = sqrt(abs(sum(conj(y).*(y.*d_n), 1)));
else
    % Each row is a channel
    n = sqrt(abs(sum(conj(y).*(y.*d_n), 2)));
end

% Collapse the norms into a single norm instead of having norms for each 
% channel
if collapse_flag 
   n = sqrt(sum(n(:).^2));  
end


end