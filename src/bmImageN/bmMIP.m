% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function a = bmMIP(y, N_u)

c   = bmColReshape(y, N_u); 
a   = squeeze(max(abs(c), [], 2));

if bmIsColShape(y, N_u); 
    a = bmColReshape(a, N_u); 
elseif bmIsBlockShape(y, N_u); 
    a = bmBlockReshape(a, N_u);     
end

end