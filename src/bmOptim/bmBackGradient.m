% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function g = bmBackGradient(x, n_u, dX_u)

imDim = size(n_u(:), 1);
nPt_u = prod(n_u(:)); 

g = bmZero([nPt_u, imDim], 'complex_single'); 
for n = 1:imDim
    g(:, n) = bmBackGradient_n(x, n_u, dX_u, n);  
end 


end