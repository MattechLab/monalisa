% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [theta, phi] = bmTheta_phi(n)

myEps = eps; % ----------------------------------------------------------------- magic_number

n = reshape(n, [3, 1]);
n = n/norm(n);

theta = acos(  n(3, 1)  );

if (  1 - abs(n(3, 1))  ) > myEps
    
    sin_theta = sqrt(n(1, 1)^2 + n(2, 1)^2);
    
    cos_phi = n(1, 1)/sin_theta;
    sin_phi = n(2, 1)/sin_theta;
    
    norm_phi = sqrt(cos_phi^2 + sin_phi^2);
    cos_phi = cos_phi/norm_phi;
    sin_phi = sin_phi/norm_phi;
    
    phi = angle(  complex(cos_phi, sin_phi)  );
    
else
    phi = 0;
end


end
