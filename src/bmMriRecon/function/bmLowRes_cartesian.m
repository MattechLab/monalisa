% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function c_out = bmLowRes_cartesian(c, N_u_curr, dK_u_curr, N_u_new, dK_u_new)

myEps = eps*1e3; % --------------------------------------------------------- magic_number

N_u_curr    = N_u_curr(:)'; 
dK_u_curr   = dK_u_curr(:)'; 
N_u_new     = N_u_new(:)'; 
dK_u_new    = dK_u_new(:)'; 

c           = bmPointReshape(c); 
imDim       = size(N_u_curr(:), 1); 

if imDim == 1
    t = bmTraj_cartesian1_lineAssym2(N_u_curr, dK_u_curr);
elseif imDim == 2
    t = bmTraj_cartesian2_lineAssym2(N_u_curr, dK_u_curr);
elseif imDim == 3
    t = bmTraj_cartesian3_lineAssym2(N_u_curr, dK_u_curr);
end

nPt = size(t, 2); 
myMask = true(1, nPt); 
if imDim > 0
   temp_t    = t(1, :)/dK_u_curr(1, 1);
   dK_temp   = dK_u_new(1, 1)/dK_u_curr(1, 1); 
   L         = dK_temp*N_u_new(1, 1); 
   temp_mask = (-L/2 - myEps <= temp_t); 
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask; 
end
if imDim > 1
   temp_t    = t(2, :)/dK_u_curr(1, 2);
   dK_temp   = dK_u_new(1, 2)/dK_u_curr(1, 2); 
   L         = dK_temp*N_u_new(1, 2); 
   temp_mask = (-L/2 - myEps <= temp_t); 
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask; 
end
if imDim > 2
   temp_t    = t(3, :)/dK_u_curr(1, 3);
   dK_temp   = dK_u_new(1, 3)/dK_u_curr(1, 3); 
   L         = dK_temp*N_u_new(1, 3); 
   temp_mask = (-L/2 - myEps <= temp_t);
   temp_mask = temp_mask & (temp_t <= L/2 - dK_temp + myEps);
   myMask    = myMask & temp_mask; 
end

c_out = c(:, myMask);

end