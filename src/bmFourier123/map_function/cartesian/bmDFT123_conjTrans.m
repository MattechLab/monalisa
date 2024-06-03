% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function starF = bmDFT123_conjTrans(x, N_u, dK_u)

if size(N_u(:), 1) == 1
    starF = bmDFT1_conjTrans(x, N_u, dK_u); 
elseif size(N_u(:), 1) == 2
    starF = bmDFT2_conjTrans(x, N_u, dK_u); 
elseif size(N_u(:), 1) == 3
    starF = bmDFT3_conjTrans(x, N_u, dK_u); 
end

end