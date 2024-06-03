% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [x, varargout] = bmUnionOfMriData_partialCartesian(y_cell, t_cell, N_u, dK_u)

y_cell      = y_cell(:); 
t_cell      = t_cell(:);
N_u         = N_u(:)'; 
dK_u        = dK_u(:)'; 

nCell       = size(y_cell, 1); 
imDim       = size(N_u(:), 1); 

myType      = bmType(y_cell{1}); 
x           = bmZero([prod(N_u(:)), nCh], myType); 
w           = bmZero([prod(N_u(:)),   1], myType); 


for i = 1:nCell
    ind_u = bmTraj_partialCartesian_ind_u(t_cell{i}, N_u, dK_u); 

    nPt_i = size(y_cell{i}, 1); 
    myOne = bmOne([nPt_i, 1], myType); 
    
    w = w + bmGut_partialCartesian(myOne,     ind_u, N_u); 
    x = x + bmGut_partialCartesian(y_cell{i}, ind_u, N_u); 
end

w = w(:); 
zero_mask = (w(:) == 0); 
one_mask  = (w(:) > 0); 
w(zero_mask) = 1; 

w = repmat(w(:), [1, size(x, 2)]); 
x = x./w; 


if imDim == 1
    t = bmTraj_cartesian1_lineAssym2(N_u, dK_u);
elseif imDim == 2
    t = bmTraj_cartesian2_lineAssym2(N_u, dK_u);
elseif imDim == 3
    t = bmTraj_cartesian3_lineAssym2(N_u, dK_u);
end
t = t(:, one_mask(:)'); 

if nargout > 1
   varargout{1} = t;  
end
if nargout > 2
    check_if_full = (sum(one_mask(:)) == prod(N_u(:))); 
    varargout{2}  = check_if_full; 
end


end