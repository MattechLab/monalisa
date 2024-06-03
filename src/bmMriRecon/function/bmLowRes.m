% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmLowRes(c, t, ve, N_u, dK_u)

myEps = eps*1e3; % --------------------------------------------------------- magic_number

N_u         = N_u(:)'; 
dK_u        = dK_u(:)'; 
t           = bmPointReshape(t); 
c           = bmPointReshape(c); 
ve          = bmPointReshape(ve); 

imDim       = size(N_u(:), 1); 
nPt         = size(t, 2); 

myMask = true(1, nPt); 
if imDim > 0
   temp_t    = t(1, :);
   dK_temp   = dK_u(1, 1); 
   L         = dK_temp*N_u(1, 1);
   
   temp_mask = (-L/2 - myEps <= temp_t); 
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask; 
end
if imDim > 1
   temp_t    = t(2, :);
   dK_temp   = dK_u(1, 2); 
   L         = dK_temp*N_u(1, 2);
   
   temp_mask = (-L/2 - myEps <= temp_t); 
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask; 
end
if imDim > 2
   temp_t    = t(3, :);
   dK_temp   = dK_u(1, 3); 
   L         = dK_temp*N_u(1, 3);
   
   temp_mask = (-L/2 - myEps <= temp_t); 
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask; 
end


if nargout > 0
   varargout{1} = c(:, myMask);  
end
if nargout > 1
   varargout{2} = t(:, myMask);  
end
if nargout > 2
   varargout{3} = ve(:, myMask);  
end


end