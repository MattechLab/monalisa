% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function FC_conj = bmFC_conj(C_conj, N_u, n_u, dK_u)

% argin_initial -----------------------------------------------------------
if isempty(n_u)
   n_u = N_u;  
end

C_conj      = single(   C_conj            ); 
N_u         = double(   int32(N_u(:)')    ); 
n_u         = double(   int32(n_u(:)')    ); 
dK_u        = double(   single(dK_u(:)')  ); 
% END_argin_initial -------------------------------------------------------

F_conj      = single(  1/prod(dK_u(:))  ); 
C_conj      = single(  bmColReshape(C_conj, n_u)  );
FC_conj     = single(  F_conj*C_conj  );

end