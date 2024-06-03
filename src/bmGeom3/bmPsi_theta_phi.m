% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% 
% This function returns the Euler angles of a rotation matrix R. 
%

function [psi, theta, phi] = bmPsi_theta_phi(R)

myEps = eps; % ------------------------------------------------------------ magic_number

R = reshape(R, [3, 3]);

n = R(:, 3);
[theta, phi]    = bmTheta_phi(n);

if (  1 - abs(cos(theta))  ) > myEps
    [~ , psi]   = private_theta_psi( R(3, :)' );
else
    psi         = private_psi(R(:, 1), cos(theta) );
end

if phi < 0
    phi = phi + 2*pi; 
end
if psi < 0
    psi = psi + 2*pi; 
end
    
end


function [theta, psi] = private_theta_psi(n)

myEps = eps; % ---------------------------------------------------------------- magic_number

n = reshape(n, [3, 1]);
n = n/norm(n);

theta       = acos(  n(3, 1)  );

sin_theta   = sqrt(n(1, 1)^2 + n(2, 1)^2);

cos_psi     = -n(1, 1)/sin_theta;
sin_psi     =  n(2, 1)/sin_theta;

norm_psi    = sqrt(cos_psi^2 + sin_psi^2);
cos_psi     = cos_psi/norm_psi;
sin_psi     = sin_psi/norm_psi;

if (  1 - abs(n(3, 1))  ) > myEps
    psi         = angle(  complex(cos_psi, sin_psi)  );
else
    psi = 0; 
end

end



function psi = private_psi(n, cos_theta)

n = reshape(n, [3, 1]);
n = n/norm(n);

if cos_theta > 0
    psi = angle(complex(  n(1, 1), n(2, 1) )); 
else
    psi = angle(complex( -n(1, 1), n(2, 1) )); 
end

end




