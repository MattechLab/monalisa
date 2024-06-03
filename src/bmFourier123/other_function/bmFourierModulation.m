% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y_out = bmFourierModulation(y, t, x_shift)

t   = bmPointReshape(t);
nPt = size(t, 2); 
y   = bmColReshape(y, nPt);
nCh = size(y, 1); 

myExp       = exp(-1i*2*pi*x_shift(:)'*t);
myExp       = repmat(myExp(:), [1, nCh]); 
y_out       = reshape(y.*myExp, size(y)); 

end