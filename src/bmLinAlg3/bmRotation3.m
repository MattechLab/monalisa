% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function R = bmRotation3(psi, theta, phi)

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
    
    
R = R_phi*R_theta*R_psi; 
    
end