% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function ind_u = bmTraj_partialCartesian_ind_u(t, N_u, dK_u)

N_u     = N_u(:)'; 
dK_u    = dK_u(:)'; 
imDim   = size(N_u(:), 1); 

t = bmPointReshape(t); 
for n = 1:imDim
    t(n, :) = round(t(n, :)/dK_u(1 ,n) + N_u(1, n)/2 + 1); 
end

if imDim == 1
    ind_u =  1 + (t(1, :) - 1); 
elseif imDim == 2
    ind_u =  1 + (t(1, :) - 1) + N_u(1, 1)*(t(2, :) - 1); 
elseif imDim == 3
    ind_u =  1 + (t(1, :) - 1) + N_u(1, 1)*(t(2, :) - 1) + N_u(1, 1)*N_u(1, 2)*(t(3, :) - 1);
end

end