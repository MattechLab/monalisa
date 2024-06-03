% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTraj_random1_non_k0(nPt, N_u, dK_u)

myEps = 100*eps; % -------------------------------------------------------- magic_number

N_u     = double(N_u(:)');
dK_u    = double(dK_u(:)');

lx = (N_u(1, 1)-1)*dK_u(1, 1); 

sx = N_u(1, 1)/2*dK_u(1, 1); 

x = (rand(1, nPt)*lx) - sx;
t = x(:)'; 

n = abs(t); 
m = (n < myEps); 
t(:, m(:)') = []; 



nPt_miss = nPt - size(t, 2); 

for i = 1:nPt_miss
    
    x = rand*lx - sx;
    n = abs(x);
    while (n < myEps)
        x = rand*lx - sx;
        n = abs(x);
    end
    
    t = cat(2, x, t); 
    
end

if size(t, 2) ~= nPt
   error('The output traj has wrong size. ');  
   return; 
end

end