% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function f = bmTSV(x, N_u, dX_u)

x       = reshape(x, [prod(N_u(:)), 1]); 
imDim   = size(N_u(:), 1);
N_u     = N_u(:)';
dX_u    = dX_u(:)';
D_u     = prod(dX_u(:));

f = 0; 
for n = 1:imDim
    g_part  = bmBackGradient_n(x, N_u, dX_u, n);
    mySquaredNorm  = D_u*bmX_norm(g_part, dX_u, true)^2;
    f = f + mySquaredNorm; 
end


end