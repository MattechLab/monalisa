% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTraj_random1_k0(nPt, N_u, dK_u)

myEps = 100*eps; % ----------------------------------------------------------- magic_number

t = rand(1, nPt)*(N_u*dK_u - dK_u) - N_u/2*dK_u;
t = sort(t(:)'); 

if sum(  abs(t(:)) < myEps  ) == 0
    t = [0, t(1, 1:end-1)]; 
end

if size(t, 2) ~= nPt
   error('The output traj has wrong size. ');  
   return; 
end

end