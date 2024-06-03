% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmTraj_N_u(t)

t = bmPointReshape(t); 
imDim   = size(t, 1);

[nLine, N_u] = bmTraj_nLine(t);
if N_u < 8 % ------------------------------------------------------------------ magic number
    N_u = 256; % -------------------------------------------------------------- magic number
end


N_u     = repmat(N_u, [1, imDim]); 
N_u     = N_u(:)'; 
varargout{1} = N_u; 


end