% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function a = bmRMS(x, N_u)

c   = bmColReshape(x, N_u); 
a   = squeeze(sqrt(mean(abs(c).^2, 2)));

if bmIsColShape(x, N_u)
    a = bmColReshape(a, N_u); 
elseif bmIsBlockShape(x, N_u)
    a = bmBlockReshape(a, N_u);     
end

end