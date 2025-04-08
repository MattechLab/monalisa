function ve_out = bmY_ve_reshape(ve, y_size)
% ve_out = bmY_ve_reshape(ve, y_size)
%
% This function reshapes the array with the volume elements calculated for
% the data y to match the size of y given in y_size. If y_size indicates
% more elements than given in ve, the values in ve are repeated to match
% the given size. This means that if y_size has more channels than ve, ve
% is repeated for every channel. If ve is a scalar, ve is repeated for
% every datapoint.
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
%   ve (array): The volume elements of the data that should be resized and
%   reshaped to match the size given in y_sze.
%   y_size (list): The size of the data.
%
% Returns:
%   ve_out (array): Array (or vector) matching the size given in y_size,
%    with some ve values repeated if necessary.

% Transform to row vector
y_size  = y_size(:)';

% Return out of the function if ve already has the correct size
if (size(ve, 1) == y_size(1, 1)) && (size(ve, 2) == y_size(1, 2)) 
    ve_out = ve; 
    return; 
end

% Get number of points and channels
nPt      = y_size(1, 1); 
nCh      = y_size(1, 2); 

% Throw error if y has only one element
if (nPt == 1) && (nCh == 1) 
   error('ve is not reshapable in the given size. ');
end

% Get size of ve
s1 = size(ve, 1); 
s2 = size(ve, 2);

% Check if y has the data of each channels as rows (rawFlag = true) or 
% columns (rawFlag = false)
rawFlag = false; 

if (nPt < nCh)
    % Changes values for variables if each row represents a channel
    rawFlag = true; 
    temp = nPt; 
    nPt  = nCh; 
    nCh  = temp; 
end

if (s1 == 1) && (s2 == 1)
    % If ve is a single value, repeat it for every point
    ve_out = ve*ones(nPt, nCh);

elseif (s1 > 1) && (s2 == 1)
    % If ve is a column vector, repeat it for every channel
    ve_out = repmat(ve, [1, nCh]); 

elseif (s1 == 1) && (s2 > 1)
    % If ve is a row vector, change it to a column vector and repeat it for 
    % every channel
    ve_out = repmat(ve(:), [1, nCh]); 
    
elseif (s1 > 1) && (s2 > 1)
    % If ve is already an array, transpose if the sizes are not correct
    if not(s1 == nPt) || not(s2 == nCh) 
        ve_out = ve.';
    end
end

% Transpose if each row represents a channel
if rawFlag
   ve_out = ve_out.';  
end

% Throw error if reshaping failed
if not(isequal(size(ve_out), y_size)) 
    error('ve is not reshapable in the given size. ');  
end

end