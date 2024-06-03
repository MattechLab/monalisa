% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% t must be in the size [imDim, nPt] or reshapable, with imDim = 3; 
% y must be in the size [nCh,   nPt] or reshapable. 

function [y_out, t_out] = bmMergeMriData_partialCartesian3_x(y, t, N_u, dK_u)

N_u     = N_u(:)'; 
dK_u    = dK_u(:)'; 

imDim   = size(N_u(:), 1  ); 
if imDim ~= 3
   error('imDim must be equal to 3. ');  
   return; 
end

nPt     = size(  t(:), 1  )/imDim; 
nCh     = size(  y(:), 1  )/nPt; 

nx = N_u(1, 1); 
nLine = nPt/nx; 

t = reshape(t,   [imDim, nx, nLine]); 
y = reshape(y,   [nCh,   nx, nLine]);

t2 = squeeze(  t(2:3, 1, :)  ); 
ind_u = bmTraj_partialCartesian_ind_u(t2, N_u(1, 2:3), dK_u(1, 2:3)); 
ind_u = ind_u(:)'; 

if ~isequal(nLine, size(ind_u, 2))
   error('Problem in ''bmMergeMriData_partialCartesian3_x'' '); 
   return; 
end

y_out = complex(  zeros(size(y)), zeros(size(y))  ); 
t_out = zeros(size(t)); 

available_list = true(1, nLine); 
myCount = 0; 
for i = 1:nLine
    if available_list(1, i)
        
        myCount = myCount + 1; 
        
        ind_u_curr  = ind_u(1, i);
        lineMask    = (  ind_u_curr == ind_u  ); 
        
        available_list(1, lineMask) = false; 
        
        y_curr = y(:, :, lineMask); 
        y_curr = mean(y_curr, 3); 
        
        y_out(:, :, myCount) = y_curr; 
        t_out(:, :, myCount) = t(:, :, i); 
        
    end
end

y_out = y_out(:, :, 1:myCount); 
t_out = t_out(:, :, 1:myCount);

y_out = bmPointReshape(y_out); 
t_out = bmPointReshape(t_out); 

end

