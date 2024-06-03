% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function f = bmGauss_function(x, myMu, mySigma)

f = 1/sqrt(2*pi)/mySigma*exp(-(x-myMu).^2/mySigma^2/2); 

end