% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function g = bmTSV_gradient(x, N_u, dX_u)

x       = reshape(x, [prod(N_u(:)), 1]); 
imDim   = size(N_u(:), 1);
N_u     = N_u(:)';
dX_u    = dX_u(:)';
D_u     = prod(dX_u(:));

g = zeros([prod(N_u(:)), 1], 'single'); 
g = complex(g, g);
for n = 1:imDim
    g_part  = bmBackGradient_n(x, N_u, dX_u, n);
    g       = g + bmBackGradient_nT(g_part, N_u, dX_u, n);
end
g       = 2*D_u*g;
g = reshape(g, [prod(N_u(:)), 1]);

end