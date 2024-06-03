% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmBump(x, xCut)

xCut = abs(xCut); 
x = x/xCut;
n = abs(x); 

y = exp( -1./(1-n.^2) )*exp(1); 
y((n >= 1)) = 0; 



end