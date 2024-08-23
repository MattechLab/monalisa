function [psi, theta, phi] = bmPsi_theta_phi(R)
% [psi, theta, phi] = bmPsi_theta_phi(R)
%
% This function calculates the proper Euler angles for a rotation matrix of
% R = Z(phi)Y(theta)Z(psi), where Z and Y are the rotation matrices around
% the respective axes.
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
%   R (array): Contains the rotation matrix calculated by multiplying
%       Z(phi)Y(theta)Z(psi). Is of size [3,3] or [9].
%
% Returns:
%   psi (double): Euler angle of the third elementary rotation matrix.
%   theta (double): Euler angle of the second elementary rotation matrix.
%   phi (double): Euler angle of the first elementary rotation matrix.

% For floating point error
myEps = eps;

R = reshape(R, [3, 3]);

% Third column allows simple calculation of theta and phi
n = R(:, 3); 

% Calculate spherical coordinates of n -> Euler angles
[theta, phi]    = bmTheta_phi(n); 

% Check for Gimbal lock condition (n = [0;0;1])
if (  1 - abs(cos(theta))  ) > myEps
    [~ , psi]   = private_theta_psi( R(3, :)' );
else
    psi         = private_psi(R(:, 1), cos(theta) );
end

% Make phi and psi positive (theta always positive as calculated with acos)
if phi < 0
    phi = phi + 2*pi; 
end
if psi < 0
    psi = psi + 2*pi; 
end
    
end


function [theta, psi] = private_theta_psi(n)
% This function calculates the Euler angles theta and psi. Assuming the
% rotation matrix is calculated with Z(phi)Y(theta)Z(psi). n has to be the
% third row of the rotation matrix.
% In this case n = [-sin(theta)cos(psi), sin(theta)sin(psi), cos(theta)]

% For floating point error
myEps = eps;

% Have n as a column vector and ensure unit length of 1
n = reshape(n, [3, 1]);
n = n/norm(n);

% Calculate theta
theta       = acos(  n(3, 1)  );

% Calculate psi without using atan
sin_theta   = sqrt(n(1, 1)^2 + n(2, 1)^2);

cos_psi     = -n(1, 1)/sin_theta;
sin_psi     =  n(2, 1)/sin_theta;

norm_psi    = sqrt(cos_psi^2 + sin_psi^2);
cos_psi     = cos_psi/norm_psi;
sin_psi     = sin_psi/norm_psi;

% Check for Gimbal lock condition (n = [0;0;1])
if (  1 - abs(n(3, 1))  ) > myEps
    % Extract phase angle using euler's formula
    psi         = angle(  complex(cos_psi, sin_psi)  );
else
    % Psi is 0 if cos(theta) is 1 or -1
    psi = 0; 
end

end



function psi = private_psi(n, cos_theta)
% This function is used to calculate psi if cos_theta is 1 or -1

% Have n as a column vector and ensure unit length of 1
n = reshape(n, [3, 1]);
n = n/norm(n);

if cos_theta > 0 % cos_theta is 1
    psi = angle(complex(  n(1, 1), n(2, 1) )); 
else % cos_theta is -1
    psi = angle(complex( -n(1, 1), n(2, 1) )); 
end

end




