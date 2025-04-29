% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function return the inner mask for a matrix. 

function G = bm2DimInBorderMask(M)


G = true(size(M)); 
G(2:end-1, 2:end-1) = false(size(M)-2);


end
