% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTraj_random3_k0(nPt, N_u, dK_u)

myEps = 100*eps; % -------------------------------------------------------- magic_number

N_u     = double(N_u(:)');
dK_u    = double(dK_u(:)');

lx = (N_u(1, 1)-1)*dK_u(1, 1); 
ly = (N_u(1, 2)-1)*dK_u(1, 2); 
lz = (N_u(1, 3)-1)*dK_u(1, 3);

sx = N_u(1, 1)/2*dK_u(1, 1); 
sy = N_u(1, 2)/2*dK_u(1, 2);
sz = N_u(1, 3)/2*dK_u(1, 3);

x = (rand(1, nPt)*lx) - sx;
y = (rand(1, nPt)*ly) - sy;
z = (rand(1, nPt)*lz) - sz;

t = cat(1, x(:)', y(:)', z(:)'); 

n = sqrt( t(1, :).^2 + t(2, :).^2 + t(3, :).^2 ); 
m = (n < myEps); 
if sum(  m(:)  ) == 0
    t = cat(2, [0, 0, 0]', t(:, 1:end-1));  
end

if size(t, 2) ~= nPt
   error('The output traj has wrong size. ');  
   return; 
end

end