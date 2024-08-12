function e = bmTraj_lineDirection(t)
% e = bmTraj_lineDirection(t)
%
% This function calculates a normalized direction vector for every line
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   t (array): The trajectory given in lines. It must have the size 
%   [imDim, N, nLine], with N being the number of points per line
%
% Returns:
%   e (array): Contains the normalized directional vector for every line


% Get information from the trajectory
imDim = size(t, 1); 
N = size(t, 2); 
nLine = size(t, 3); 

% Creat array using the value of the first point of every line for the
% other points
t1 = repmat(t(:, 1, :), [1, N, 1]);


e = t - t1; % Calculate difference between points on line to the first point
e = e(:, ceil(N/2):end, :); % Only consider second half of the points on each line
% Compute norm
e_norm = zeros(1, size(e, 2), size(e, 3)); 
for i = 1:imDim
    e_norm = e_norm + e(i, :, :).^2;
end
e_norm = sqrt(e_norm); 
e_norm = repmat(e_norm, [imDim, 1, 1]); 
% Normalize
e = e./e_norm;
% Average over points (one value for every line) -> direction vector
e = squeeze(mean(e, 2)); 


end