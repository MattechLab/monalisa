% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmBackGradientT(g, n_u, dX_u)

imDim = size(n_u(:), 1);
nPt_u = prod(n_u(:)); 

x = bmZero([nPt_u, 1], 'complex_single'); 

for n = 1:imDim
    x = x + bmBackGradient_nT(g(:, n), n_u, dX_u, n);
end

end