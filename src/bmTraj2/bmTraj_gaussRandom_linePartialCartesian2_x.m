% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [t, varargout] = bmTraj_gaussRandom_linePartialCartesian2_x(N_u, dK_u, nLine, argSigma)

N_u     = N_u(:)'; 
dK_u    = dK_u(:)'; 

Nx  = N_u(1, 1); 
Ny  = N_u(1, 2); 

dKx = dK_u(1, 1); 
dKy = dK_u(1, 2);  

kx = (-Nx/2:Nx/2 - 1)*dKx; 
ky = (-Ny/2:Ny/2 - 1)*dKy; 

mySigma = argSigma*Nx; 
myMu    = Nx/2+1; 

x = 1:Nx; 
p = exp(-0.5*((x-myMu)/mySigma).^2  );
p = p/sum(p(:)); 


m = zeros(1, Nx); 
while sum(m(:)) < nLine
   myInd = round(1 + rand*(Nx - 1));
   if rand <= p(1, myInd)
      m(1, myInd) = 1;  
   end
end

% figure
% plot(m, 'o')

m = logical(m); 
ky = ky(1, m); 

kx = repmat(kx(:) , [1, nLine]);  
ky = repmat(ky(:)', [Nx, 1]); 

t = cat(1, kx(:)', ky(:)'); 

varargout{1} = m; 

end

