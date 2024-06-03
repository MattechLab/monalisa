% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function KF = bmKF(C, N_u, n_u, dK_u, nCh, varargin)

% argin_initial -----------------------------------------------------------
[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);  

C           = single(bmBlockReshape(C, n_u)); 
N_u         = single(N_u(:)');
n_u         = single(n_u(:)');
dK_u        = single(dK_u(:)'); 
nWin        = single(nWin(:)'); 
kernelParam = single(kernelParam(:)');
nCh         = single(nCh); 

% END_argin_initial -------------------------------------------------------

K = single(bmK(N_u, dK_u, nCh, kernelType, nWin, kernelParam));

K = bmImCrope(K, N_u, n_u);
K = single(bmColReshape(K, n_u));

F = single(1/prod(N_u(:))/prod(dK_u(:))); 

if isempty(C)
    KF = single(K*F); 
else    
    C      = single(bmColReshape(C, n_u));
    KF     = single(K.*F.*C);
end

end