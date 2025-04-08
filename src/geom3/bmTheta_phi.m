function [theta, phi] = bmTheta_phi(n)
% [theta, phi] = bmTheta_phi(n)
%
% This function calculates the spherical coordinates describing the given 
% the vector n. 
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
%   n (list): The vector of which the spherical coordinates should be
%    calculated.
%
% Returns:
%   theta (double): Polar angle between n and the Z-axis (3rd axis). 
%    Describes the tilt away from the Z-axis.
%   phi (double): Azimuthal angle describing the orientation of n in the
%    XY-plane.
%
% Notes:
%   This function can be used to calculate the yaw and pitch Euler angles 
%   of a rotation. The calculation only works if the applied rotation is a 
%   rotation of a plane around the rotation axis n or the rotation matrix
%   is calculated using proper Euler angles and a matrix multiplication of
%   Z(phi)Y(theta)Z(psi), where Y and Z are the rotation matrices around
%   the respectve axis.
%
%   n = [sin(theta)cos(phi), sin(theta)sin(phi), cos(theta)]' in spherical 
%   coordinates.

% For floating point error
myEps = eps; 

% Have n as a column vector and ensure unit length of 1
n = reshape(n, [3, 1]); 
n = n/norm(n);

% Calculate the polar angle from the third element
theta = acos(  n(3, 1)  );  


% Check for Gimbal lock condition (n = [0;0;1])
if (  1 - abs(n(3, 1))  ) > myEps 
    % Calculate sin(theta) from spherical coordinates
    sin_theta = sqrt(n(1, 1)^2 + n(2, 1)^2);

    % Calculate sin and cos of phi from n1 and n2
    cos_phi = n(1, 1)/sin_theta;
    sin_phi = n(2, 1)/sin_theta;

    % Use Pythagorean identity to norm sin and cos of phi
    norm_phi = sqrt(cos_phi^2 + sin_phi^2);
    cos_phi = cos_phi/norm_phi;
    sin_phi = sin_phi/norm_phi;

    % Extract phase angle using euler's formula 
    phi = angle(  complex(cos_phi, sin_phi)  );
    
else
    % phi is zero if cos(theta) is 1 or -1
    phi = 0; 
end


end
