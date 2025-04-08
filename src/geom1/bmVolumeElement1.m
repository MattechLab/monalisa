function out = bmVolumeElement1(x)
% out = bmVolumeElement1(x)
%
% This function computes volume elements or differences between points in 
% a sorted manner and returns these differences in the original input 
% order. 
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   x (array): Contains the points and size must be [N, nLine] with N the
%   number of points per line
%
% Returns:
%   out (array): Array with differences between midpoints calculated with 
%   x sorted after its first dimension. The size and order of the array is 
%   the same as x.
%
% Examples:
%   dr = bmVolumeElement1(dr)

% If x is a vector transform it into a column vector
if (size(x, 1) == 1) || (size(x, 2) == 1)
   x = x(:);  
end

% we sort x after its first line. 
[~, myPerm]     = sort(x(:, 1));
[~, myInvPerm]  = sort(myPerm);
mySort = x(myPerm, :);

% We compute the volume elements. 
myMid = (mySort(2:end, :) + mySort(1:end-1, :))/2; % Compute midpoints
myMid = [mySort(1, :) - (myMid(1, :) - mySort(1, :)); myMid; mySort(end, :) + (mySort(end, :) - myMid(end, :))]; % Include edge cases
myDiff = myMid(2:end, :) - myMid(1:end-1, :); % Difference between midpoints
out = myDiff(myInvPerm, :); % Reorder back before returning the value

end