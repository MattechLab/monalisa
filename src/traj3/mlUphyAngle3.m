function [theta, phi] = mlUphyAngle3(nseg, nshot, varargin)
% [theta, phi] = mlUphyAngle3(nseg, nshot, varargin)
%
% Calculates spherical coordinates for all points (nseg * nshot) of the
% uniform phyllotaxis spiral UPhy. This spiral covers the north hemisphere only. 
% The radius r is constant and not defined by this function.
%
% Authors:
%   Mauro Leidi
%   HES-SO
%   Lausanne - Switzerland
%   May 2025
%
% Parameters:
%   nseg (int): Number of segments per shot
%   nshot (int): Number of shots of the acquisition
%   varargin (bool, optional): Flag if the first segment acquired is the
%   same for all shots (self navigation). Default value is 0.
%
% Returns:
%   theta (array): List containing the polar angle for every point of the
%   spiral
%   phi (array): List containing the azimuthal angle for every point of the
%   spiral

% Define golden angle 
goldNum     = (1 + sqrt(5))/2;
goldAngle   = 2*pi - (2*pi / goldNum);

% Define flag
flagSelfNav = 0;
if ~isempty(varargin)
    flagSelfNav = varargin{1};
end

% Define total number of points / segments
nseg_tot = nseg*nshot;
if flagSelfNav
    nseg_pure = nseg_tot - nshot;
else
    nseg_pure = nseg_tot;
end

% Ratio for polar angle theta
q = pi/2; 

% Set up arrays
phi     = zeros(1, nseg_tot);
theta   = zeros(1, nseg_tot);

% Angle index, differs from myIndex if flagSelfNav = true
myCounter = 1;

% Calculate spiral
for i = 1:nseg
    for j = 1:nshot
        myIndex = i + (j-1) * nseg;
        % Set angles to 0 if flagSelfNav = true (top of sphere)
        if flagSelfNav && (i == 1)
            phi(myIndex) = 0;
            theta(myIndex) = 0;
        else
            % Calculate angle for each segment
            phi(myIndex) = mod(myCounter*goldAngle, (2*pi));
            theta(myIndex) = q*arcos(1 - myCounter/nseg_pure);
            myCounter = myCounter + 1;
        end
    end
end


end