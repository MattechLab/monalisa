% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function iF = bmIDF123(x, N_u, dK_u)

if size(N_u(:), 1) == 1
    iF = bmIDF1(x, N_u, dK_u); 
elseif size(N_u(:), 1) == 2
    iF = bmIDF2(x, N_u, dK_u); 
elseif size(N_u(:), 1) == 3
    iF = bmIDF3(x, N_u, dK_u); 
end

end