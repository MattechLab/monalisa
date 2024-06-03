% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function R_inv = bmRotation3_inv(psi, theta, phi)

psi   = -psi; 
theta = -theta; 
phi   = -phi; 

R1 =    [   
            cos(psi)    -sin(psi)   0
            sin(psi)     cos(psi)   0
            0            0          1
        ]; 

    
R2 =    [
             cos(theta) 0   sin(theta)
             0          1   0
            -sin(theta) 0   cos(theta)
        ];

    
R3 =    [   
            cos(phi)    -sin(phi)   0
            sin(phi)     cos(phi)   0
            0            0          1
        ]; 
    
    
R_inv = R1*R2*R3; 
    

end