% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% x is a list of real numbers and y too. The pairs (x_i, y_i) are the
% control points of the interpolation. 
% k is the list of places where the interpolation is evaluated. 


function out = bmInterp1(x, y, k)

x = x(:)'; 
k = k(:)'; 

nSignal = size(y, 1); 
nPt = size(k, 2);

out = zeros(nSignal, nPt);

for i = 1:nSignal
    out(i, :) = interpn(x, y(i, :), k, 'pchip'); 
end


if  isa(y, 'single')
    out = single(out);
elseif isa(y, 'double')
    out = double(out);
end

end