function myTraj = bmTraj_fullRadial3_phyllotaxis_chris_lineAssym2(varargin)
% myTraj = bmTraj_fullRadial3_phyllotaxis_lineAssym2(varargin)
%
% This function creates and returns a phyllotaxis trajectory.
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
%   varargin: This input is either an bmMriAcquisitionParam object
%   containing the needed variables or the 6 variables seperatly:
%   N (int): Number of points on line
%   nSeg (int): Number of segments
%   nShot (int): Number of shots
%   dK_n (double): Distance between points of trajectory (1/FoV)
%   flagSelfNav (bool): First segment of each shot is at the top of the
%   sphere if true
%   nShot_off (int): Number of shots to be discarded
%
% Returns:
%   myTraj (array): Containing the trajectory in the shape [3, N, M], where
%   M = (nShot - nShot_off) * (nSeg - flagSelfNav)

if isempty(varargin)
   error('Wrong list of arguments. '); 
   
elseif isscalar(varargin)
   % Read variables from the bmMriAcquisitionParam object if given
   myMriAcquisParam = varargin{1};
   
   N_n         = myMriAcquisParam.N; 
   nSeg        = myMriAcquisParam.nSeg; 
   nShot       = myMriAcquisParam.nShot; 
   dK_n        = 1/mean(myMriAcquisParam.FoV(:)); 
   
   flagSelfNav = myMriAcquisParam.selfNav_flag;
   nShot_off   = myMriAcquisParam.nShot_off;

elseif length(varargin) == 6
   % Copy the variables if given seperately
   N_n         = varargin{1}; 
   nSeg        = varargin{2}; 
   nShot       = varargin{3}; 
   dK_n        = varargin{4}; 

   flagSelfNav = varargin{5}; 
   nShot_off   = varargin{6}; 

end


if fix(N_n/2) ~= N_n/2
   error('N_n must be even in ''bm3DimRadialTraj_phyllotaxis_2'' ! '); 
end

% Calculate spherical coordinates of phyllotaxis spiral given nSeg and
% nShot
[theta, phi] = bmPhyllotaxisAngle3(nSeg, nShot, flagSelfNav);

% shuffling of the polar coordinates according to Chris rule
sz=size(theta);
theta=reshape(theta,[nSeg,nShot]);
INC=nShot/((1 + sqrt(5))/2);
[~,i]=sort((mod((INC*(0:nShot-1)),nShot)));
theta=theta(:,i);
theta=reshape(theta,sz);

% Create radius for every point on the line through the origin
r = (-0.5 : 1/N_n : 0.5-(1/N_n));
% Repeat matrices to match N x nSeg * nShot
phi     = repmat(phi, [N_n, 1]);
theta   = repmat(theta,[N_n, 1]);
R       = repmat(r',[1, nShot*nSeg]);

% Calculate cartesian coordinates from spherical coordinates
x = reshape(R.*cos(phi).*sin(theta), [1, N_n, nSeg, nShot]); 
y = reshape(R.*sin(phi).*sin(theta), [1, N_n, nSeg, nShot]);
z = reshape(R.*cos(theta),           [1, N_n, nSeg, nShot]);

% Combine cartesian coordinates to points and scale to have the correct
% distance between the points (The coordinates where made with d=1)
myTraj = cat(1, x, y, z)*N_n*dK_n; 

% Remove first few shots and the first segments depending on the arguments
if flagSelfNav
   myTraj(:, :, 1, :) = [];  
end
if nShot_off > 0
   myTraj(:, :, :, 1:nShot_off) = [];  
end

% Resize to shape [3, N, nSeg, nShot] considering nShot_off and flagSelfNav
mySize = size(myTraj); 
mySize = mySize(:)'; 
myTraj = reshape(myTraj, [mySize(1, 1), mySize(1, 2), mySize(1, 3)*mySize(1, 4)]); 

end