% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% t is the argument grid.

% phi are the argument phase values corresponding to the gridd t. phi must
% be normalized between 0 and 1.

% s is the querry gridd. 

% psi are the querry values corresponding interpollated on the querry
% grid s. 

function psi = bmPhaseInterp2(t1, t2, phi, s1, s2) 

x_interp = interpn(t1, t2, cos(2*pi*phi), s1, s2);
y_interp = interpn(t1, t2, sin(2*pi*phi), s1, s2);
psi = mod(angle(complex(x_interp, y_interp))/2/pi, 1);

end