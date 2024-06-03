% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmDoubleFA_solve(c, beta, ratio, precision)

maxAngle = 0.9*pi; 

precision = precision/2;

alpha = 0:precision:maxAngle;
f = (sin(ratio*alpha)./sin(alpha)).*(1 - cos(alpha)*beta)./(1 - cos(ratio*alpha)*beta);

f(1) = f(2) ;
f = max(f, -4); 

[myMin, myIndex] = min(abs(f-c));

out = alpha(myIndex);


end




