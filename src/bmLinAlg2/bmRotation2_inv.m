% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function R_inv = bmRotation2_inv(phi)

phi   = -phi; 

R_inv = [   
            cos(phi)    -sin(phi)
            sin(phi)     cos(phi)
        ]; 

end