% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmCoilSense_pinv(C, x0, n_u)

C       = single(bmColReshape(C, n_u)); 
x0      = single(bmColReshape(x0, n_u)); 
x       = sum(conj(C).*x0, 2)./sum(abs(C).^2, 2);
x       = bmBlockReshape(x, n_u); 

end