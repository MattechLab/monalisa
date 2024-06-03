% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [ox, oy] = bmTwoLinesIntersect(ax, ay, bx, by, cx, cy, dx, dy)

a = [ax, ay]; 
b = [bx, by]; 
c = [cx, cy]; 
d = [dx, dy]; 

n = (b-a)/norm(b-a); 
m = (d-c)/norm(d-c);

p = a; 
q = c; 
r = p-q; 

x = cross([n, 0], [m, 0]); 
y = cross([m, 0], [r, 0]); 


t_abs = norm(y)/norm(x); 

if norm(y - t_abs*x) < norm(y)
    t = t_abs; 
else
    t = -t_abs; 
end

o = p + t*n; 

ox = o(1); 
oy = o(2); 


end