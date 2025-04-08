function R = bmRotation3(psi, theta, phi)
% R = bmRotation3(psi, theta, phi)
%
% This function calculates the rotation matrix R by means of matrix
% multiplication of three single matrices that each represent the elemental
% rotation around an axis (X, Y, Z or 1,2,3).
% This rotation matrix is calculated as R = Z(phi)*Y(theta)*Z(psi).
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
%   psi (double): Euler angle of the third elementary rotation matrix.
%   theta (double): Euler angle of the second elementary rotation matrix.
%   phi (double): Euler angle of the first elementary rotation matrix.
% 
% Returns:
%   R (array): A 3x3 rotation matrix.

R_psi =     [   
                cos(psi)    -sin(psi)   0
                sin(psi)     cos(psi)   0
                0            0          1
            ]; 

    
R_theta =    [
                cos(theta) 0   sin(theta)
                0          1   0
               -sin(theta) 0   cos(theta)
             ];

    
R_phi =     [   
                cos(phi)    -sin(phi)   0
                sin(phi)     cos(phi)   0
                0            0          1
            ]; 
    
% Calculate rotation matrix
R = R_phi*R_theta*R_psi; 
    
end