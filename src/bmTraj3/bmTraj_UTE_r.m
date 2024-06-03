% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% We aknowledge
% 
% Jean Delacost 
%
% for his work on UTE MRI.
% Originally, the first code for UTE trajectories 
% in this toolbox came from him. 



% N is the half number of points. 
% Typically 2*N = 384 and N = 192; 

function r = bmTraj_UTE_r(N, t0, t_grad_start, t_grad_ramp, dt, dK_n)

t1 = t_grad_start; 
t2 = t1 + t_grad_ramp; 

t1 = t1 - t0; 
t2 = t2 - t0; 
t0 = 0;  

t = (0:N-1)*dt; 
p = 1/dt; 


m1  = double(  (t <  t1)  ); 
m2  = double(  (t >= t1) & (t <= t2)  ); 
m3  = double(  (t > t2)  ); 

r   = m1.*0 + m2.*p.*(  (t - t1).^2  )/(t2 - t1)/2 + m3.*p.*(t - (t2 + t1)/2  ); 

r = (2*N*dK_n)*r/N/2; 

end