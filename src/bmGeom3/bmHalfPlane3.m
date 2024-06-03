% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function m = bmHalfPlane3(argPlane, N_u)

N_u = N_u(:)'; 

p = argPlane.p; 
n = argPlane.n; 

[X, Y, Z] = ndgrid(1:N_u(1, 1), 1:N_u(1, 2), 1:N_u(1, 3));

x = cat(1, X(:)', Y(:)', Z(:)');
p = repmat(p(:), [1, size(x, 2)]); 
x = x - p; 

m = reshape(sign(n'*x) > 0, N_u);

end