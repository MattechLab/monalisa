function varargout = bmLowRes(c, t, ve, N_u, dK_u) 
% varargout = bmLowRes(c, t, ve, N_u, dK_u)
%
% This function ensures that the points of the trajectory are inside the
% new grid defined by N_u and dK_u. It removes the points, the 
% corresponding data from the channels and the volume elements and returns 
% them if asked for.
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
%   c (array): Contains the data from the channels corresponding to the
%    points in the trajectory t.
%   t (array): Contains the trajectory (coordinates).
%   ve (array): Contains the volume elements for each point in the
%    trajectory.
%   N_u (array): Has the same dimension as t and contains the size of the
%    new grid for each dimension.
%   dK_u (array): Has the same dimension as N_u and contains the distance
%    between every point of the new grid in each dimension.
%
% Returns:
%   varargout{1} (array): Channel data of size [nCh, nPt], where nPt is the
%    new number of points after excluding the points outside the new grid.
%   varargout{2} (array): Trajectory of size [nDim, nPt], where nPt is the
%    new number of points after excluding the points outside the new grid.
%   varargout{3} (list): Volume elements of size [1, nPt], where nPt is the
%    new number of points after excluding the points outside the new grid.


myEps = eps*1e3; % --------------------------------------------------------- magic_number

N_u         = N_u(:)'; 
dK_u        = dK_u(:)'; 
t           = bmPointReshape(t); 
c           = bmPointReshape(c); 
ve          = bmPointReshape(ve); 

% Take dimensions from new grid
imDim       = size(N_u(:), 1); 
nPt         = size(t, 2); 

% Create mask to exclude points outside the grid
myMask = true(1, nPt); 
if imDim > 0 % Could be combined into a for loop
   temp_t    = t(1, :);
   % Take dK for first dimension 
   dK_temp   = dK_u(1, 1); 
   % Calculate max length in first dimension (FoV)
   L         = dK_temp*N_u(1, 1); 
   
   % Create mask to keep every point in t that is inside the FoV
   temp_mask = (-L/2 - myEps <= temp_t);
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask;  % Combine mask
end
if imDim > 1
   temp_t    = t(2, :);
   % Take dK for second dimension
   dK_temp   = dK_u(1, 2); 
   % Calculate max length in second dimension (FoV)
   L         = dK_temp*N_u(1, 2); 
   
   % Create mask to keep every point in t that is inside FoV
   temp_mask = (-L/2 - myEps <= temp_t); 
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask; % Combine mask
end
if imDim > 2
   temp_t    = t(3, :);
   % Take dK for third dimension
   dK_temp   = dK_u(1, 3); 
   % Calculate max length in third dimension (FoV)
   L         = dK_temp*N_u(1, 3); 
   
   % Create mask to keep every point in t that is inside FoV
   temp_mask = (-L/2 - myEps <= temp_t); 
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask; % Combine mask
end

% Return data if asked for
if nargout > 0
   varargout{1} = c(:, myMask);  
end
if nargout > 1
   varargout{2} = t(:, myMask);  
end
if nargout > 2
   varargout{3} = ve(:, myMask);  
end


end