% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function F = bmDFT123(x, N_u, dK_u)

if size(N_u(:), 1) == 1
    F = bmDFT1(x, N_u, dK_u); 
elseif size(N_u(:), 1) == 2
    F = bmDFT2(x, N_u, dK_u); 
elseif size(N_u(:), 1) == 3
    F = bmDFT3(x, N_u, dK_u); 
end

end