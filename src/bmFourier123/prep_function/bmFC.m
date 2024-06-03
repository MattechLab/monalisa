% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function FC = bmFC(C, N_u, n_u, dK_u)

% argin_initial -----------------------------------------------------------
if isempty(n_u)
   n_u = N_u;  
end

C       = single(   C                 ); 
N_u     = double(   int32(N_u(:)')    ); 
n_u     = double(   int32(n_u(:)')    ); 
dK_u    = double(   single(dK_u(:)')  ); 
% END_argin_initial -------------------------------------------------------
 
F       = single(  1/prod(N_u(:))/prod(dK_u(:))  ); 

C       = single(bmColReshape(C, n_u));
FC      = single(F*C);

end