% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function KF_conj = bmKF_conj(C_conj, N_u, n_u, dK_u, nCh, varargin)

% argin_initial -----------------------------------------------------------

warning(['In KF_conj : make sure you gave ''conj(C)'' ',...
         'as argument and not C !']); 

[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);  

C_conj      = single(bmBlockReshape(C_conj, n_u)); 
N_u         = single(N_u(:)'); 
n_u         = single(n_u(:)'); 
dK_u        = single(dK_u(:)'); 
nWin        = single(nWin(:)'); 
kernelParam = single(kernelParam(:)'); 
nCh         = single(nCh); 
% END_argin_initial -------------------------------------------------------


K       = single(bmK(N_u, dK_u, nCh, kernelType, nWin, kernelParam));
K       = bmImCrope(K, N_u, n_u);
K       = single(bmColReshape(K, n_u));

F_conj  = single(1/prod(dK_u(:))); 

if isempty(C_conj)
    KF_conj = single(K*F_conj);
else
    C_conj      = single(bmColReshape(C_conj, n_u));
    KF_conj = single(K.*F_conj.*C_conj);
end

end