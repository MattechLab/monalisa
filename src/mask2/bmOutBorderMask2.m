% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function return the inner mask for a matrix. 

function G = bmOutBorderMask2(M)


G = true(size(M)+2); 
G(2:end-1, 2:end-1) = false(size(M));


end
