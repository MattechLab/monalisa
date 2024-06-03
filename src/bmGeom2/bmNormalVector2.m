% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function ey = bmNormalVector2(ex)

    ey = zeros(2, 1); 
    ey(1) =  ex(2); 
    ey(2) = -ex(1); 

end