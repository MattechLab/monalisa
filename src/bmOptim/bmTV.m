% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function f = bmTV(x, N_u, dX_u)

imDim   = size(N_u(:), 1);
N_u     = N_u(:)'; 
dX_u    = dX_u(:)'; 
D_u     = prod(dX_u(:)); 

f = 0; 
for n = 1:imDim
    g_part  = bmBackGradient(x, N_u, dX_u, n);
    myNorm  = sum(abs(g_part(:)), 1)*D_u; 
    f = f + myNorm; 
end

end