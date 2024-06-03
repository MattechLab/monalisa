% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% t = 0:0.001:1;
% phi = mod(sin(pi*t) + t, 1);
% s = sort(rand(1, 10000));



% t is the argument grid.

% phi are the argument phase values corresponding to the gridd t. phi must
% be normalized between 0 and 1.

% s is the querry gridd.

% psi are the querry values corresponding interpollated on the querry
% grid s.

function psi = bmPhaseInterp1(t, phi, s)

x_interp = interpn(t, cos(2*pi*phi), s);
y_interp = interpn(t, sin(2*pi*phi), s);
psi = mod(angle(complex(x_interp, y_interp))/2/pi, 1);

end