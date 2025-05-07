function [theta, phi] = mlFlexyphyAngle3(nseg, nshot, varargin)
% [theta, phi] = mlFlexyphyAngle3(nseg, nshot, varargin)
%
% Calculates spherical coordinates for all points (nseg * nshot) of the
% flexyphy spiral. This spiral covers the north hemisphere only (For each redout it only computes the most external point) 
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


% Define flag
flagSelfNav = 0;
if ~isempty(varargin)
    flagSelfNav = varargin{1};
end

% Set the seed for reproducibility and it should be the same as the one used in acquition
rng(1,'twister'); 

% Randomly shuffle the list, this gives a random permutation
shuffling = randperm(nshot);

nseg_tot = nshot * nseg; % = shot x segments

phi=zeros(1,nseg_tot);
theta=zeros(1,nseg_tot);

x = zeros (1, nseg_tot);
y = zeros (1, nseg_tot);
z = zeros (1, nseg_tot);

if flagSelfNav
    N = nseg_tot - nshot; 
else
    N = nseg_tot ; 
end

Gn = (1 + sqrt(5))/2;
Gn_ang = 2*pi - (2*pi / Gn);
count = 1;

for seg = 1:nseg
    for shot = 1:nshot

        myIndex = seg + (shot-1) * nseg;

        if flagSelfNav && seg == 1

            theta(myIndex) = 0;
            phi(myIndex) = 0;

        else

            % HERE I COMPUTE A COUNT2, this is decoupling techinque
            count2 = shuffling(shot) + (seg-2)*nshot;
            theta(myIndex) =  acos(1 - count2/N);
            % THE azimuthal angle is unchanged (= decoupling)
            phi(myIndex) = mod ( (count)*Gn_ang, (2*pi) );
            count = count + 1;

        end

        % x(myIndex)= sin(theta(myIndex))*cos(phi(myIndex));
        % y(myIndex)= sin(theta(myIndex))*sin(phi(myIndex));
        % z(myIndex)= cos(theta(myIndex));

    end
end

end