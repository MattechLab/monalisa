function mySquaredNorm = bmTraj_squaredNorm(t)
% mySquaredNorm = bmTraj_squaredNorm(t)
%
% This function calculates the squared norm (||t||^2) of the given 
% trajectory.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   t (array): Trajectory of any size of which the squared norm has to be 
%    calculated.
%
% Returns:
%   squaredNorm (array): Calculated squared norm of the trajectory with the
%    same size as t.

mySize = size(t); % Store size
mySize = mySize(:)'; 
t = bmPointReshape(t); % Change format to [dim, #points]


mySquaredNorm = zeros(1, size(t, 2));
% Calculate the square of each dimension and sum it
for i = 1:mySize(1, 1) 
    mySquaredNorm = mySquaredNorm + t(i, :).^2; 
end

% Change format back to the way the input was given
mySquaredNorm = reshape(mySquaredNorm, [1, mySize(1, 2:end)]); 

end