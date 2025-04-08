function v = bmVolumeElement_voronoi_full_radial3(t)
% v = bmVolumeElement_voronoi_full_radial3(t)
%
% This function calculates the volume elements of a sphere using a radial
% trajectory to be defined. This is done by calculating the surface of the
% sphere through Voronoi cells.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   t (array): Radial trajectory with nPt points.
%
% Returns:
%   v (array): Row vectory containing the volume element for each point in
%    the trajectory. Has size [1, nPt].

%% Setup and check validity of input
if not(size(t, 1) == 3)
    error('This function is for 3D trajectory only. ');
    return; 
end

% Reshape trajectory
t       = bmTraj_lineReshape(t); 
imDim   = size(t, 1);  
N       = size(t, 2); 
nLine   = size(t, 3); 

% Get line directions
e = bmTraj_lineDirection(t); 
if (N/2 - fix(N/2)) > 0
    error(['The number of points per line must be even, because the ', ...
           '0 must be at index position N/2+1']); 
       return; 
end


%% Construct dr (radius)
dr = zeros(N, nLine);
for i = 1:nLine
    dr(:, i) = t(:, :, i)'*e(:, i); 
end

% Here, the size(dr) must be [N, nLine]
dr = bmVolumeElement1(dr); 


%% Construct ds (surface)
% Calculate surface of sphere using Voronoi diagram with last point on 
% line as seed
ds = bmSphericalVoronoi_1(t, 'half');

% Copy area for every point of the line
ds = repmat(ds, [N, 1]); 

% Weight surfaces by their distance from the origin
ds = ds.*squeeze(bmTraj_squaredNorm(t)); 

%% Calculate dV (volume)
% Calculate the volume elements dV
v = dr(:)'.*ds(:)';

% Recalculate center volume elements
dr_0 = mean(dr(N/2+1, :), 2)/2; 
v(1, N/2+1:N:end) = (4/3)*pi*(dr_0^3)/(2*nLine);

end

%% Local functions

function v = bmSphericalVoronoi_1(t, half_or_full)
% v = bmSphericalVoronoi_1(t, half_or_full)
%
% This function calculates area using a Voronoi diagram on a spherical 
% surface using the last point of each line (N) as the seed for the region
%
% Parameters:
%   t (array): Trajectory of with size [imDim, N, nLine], where imDim
%    is the number of dimensions, N the number of points per line and nLine
%    the number of lines
%    half_or_full (string): If the string is 'half' the negative
%    counterparts are concatenated to cover the full sphere (use this if 
%    the trajectory only covers the top hemisphere)
%
% Returns:
%   v (array): Averaged area

% Get information
imDim = size(t, 1); 
N = size(t, 2); 
nLine = size(t, 3); 


s = squeeze(t(:, end, :)); % Take last point of each line (seeds)
s_norm = zeros(1, size(s, 2));
for i = 1:imDim
    s_norm = s_norm + s(i, :).^2;
end
s_norm = sqrt(s_norm); 
s_norm_rep = repmat(s_norm, [size(s, 1), 1]);
s = s./s_norm_rep; % Normalize


% Add negative counterparts to cover whole sphere if only top hemisphere is
% given (if half is true)
if strcmp(half_or_full, 'half')
    s = cat(2, s, -s); 
end

myIndex = 1:size(s, 2);


% Devide coordinates into positive and negative hemispheres
% X-division
temp_mask = s(1, :) >= 0;
s_p1    = s(:, temp_mask); % Only positive values of x
ind_p1  = myIndex(1, temp_mask); % Their indexes

temp_mask = s(1, :) <= 0;
s_m1    = s(:, temp_mask); % Only negative values of x
ind_m1  = myIndex(1, temp_mask); % Their indexes


% Y-division
temp_mask = s(2, :) >= 0;
s_p2    = s(:, temp_mask); % Only positive values of y
ind_p2  = myIndex(1, temp_mask); % Their indexes

temp_mask = s(2, :) <= 0;
s_m2    = s(:, temp_mask); % Only negative values of y
ind_m2  = myIndex(1, temp_mask); % Their indexes


% Z-division
temp_mask = s(3, :) >= 0;
s_p3    = s(:, temp_mask); % Only positive values of z
ind_p3  = myIndex(1, temp_mask); % Their indexes

temp_mask = s(3, :) <= 0;
s_m3    = s(:, temp_mask); % Only negative values of z
ind_m3  = myIndex(1, temp_mask); % Their indexes


% Calculate Voronoi volumes for each hemisphere
v_p1 = bmSphericalVoronoi_2(s_p1(3, :), s_p1(2, :),  s_p1(1, :));
v_m1 = bmSphericalVoronoi_2(s_m1(3, :), s_m1(2, :), -s_m1(1, :)); % Minus to align to primary axis

v_p2 = bmSphericalVoronoi_2(s_p2(3, :), s_p2(1, :),  s_p2(2, :));
v_m2 = bmSphericalVoronoi_2(s_m2(3, :), s_m2(1, :), -s_m2(2, :));

v_p3 = bmSphericalVoronoi_2(s_p3(1, :), s_p3(2, :),  s_p3(3, :));
v_m3 = bmSphericalVoronoi_2(s_m3(1, :), s_m3(2, :), -s_m3(3, :));


% Combine calculated volumes
v = zeros(6, size(s, 2));
v(1, ind_p1) = v_p1;
v(2, ind_m1) = v_m1;
v(3, ind_p2) = v_p2;
v(4, ind_m2) = v_m2;
v(5, ind_p3) = v_p3;
v(6, ind_m3) = v_m3;
v = v(:, 1:nLine);


% Average calculated area
myWeight = (v > 0);
v = sum(v, 1)./sum(myWeight, 1);

end




function out = bmSphericalVoronoi_2(s1, s2, s3)
% out = bmSphericalVoronoi_2(s1, s2, s3)
%
% This function calculates the spherical Voronoi area for a given set of 
% points
%
% Parameters:
%   s1 (array): Axis 1 of sphere
%   s2 (array): Axis 2 of sphere
%   s3 (array): Axis 3 and primary axis of sphere
%
% Returns:
%   out (array): Voronoi area

% Combine input into a single matrix
s = cat(1, s1(:)', s2(:)', s3(:)');
nPt = size(s, 2); 
myIndex = 1:nPt; 
myIndex = myIndex(:)'; 

% Set angles and heights
myAngle = acos(1/sqrt(3));
myAngle = (pi/2 - myAngle)/3; 
h1 = sin(1*myAngle);  
h2 = sin(2*myAngle);  
h3 = sin(3*myAngle);  

% Filter points based on height
myMask_1 = (s(3, :) < h1); 
s(:, myMask_1) = []; 
myIndex(:, myMask_1) = []; 
myMask_2 = s(3, :) < h2;

% Poject the points onto 2D plane
p = s(1:2, :)./repmat(s(3, :), [2, 1]); 

% Calculate the Voronoi diagram
myVoronoi = bmVoronoi(p); 
myVoronoi = myVoronoi(:)'; % Make sure it is a row vector
myVoronoi(1, myVoronoi <= 0) = 0; % Remove invalid volumes
myVoronoi(1, myMask_2) = 0;
myVoronoi = myVoronoi.*abs(s(3, :).^3); % Account for spherical volume elements (weighting)

% Output Voronoi area
out = zeros(1, nPt); 
out(1, myIndex) = myVoronoi; 

end



