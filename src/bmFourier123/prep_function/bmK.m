% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function K = bmK(N_u, dK_u, nCh, varargin)

% argin initial -----------------------------------------------------------
arg_osf = 2;  % --------------------------------------------------------------- magic_number

[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);  

N_u         = double(int32(N_u(:)'));
N_u_os      = round(N_u*arg_osf);
imDim       = size(N_u(:), 1); 
dK_u        = double(single(dK_u(:)')); 
nWin        = double(single(nWin(:)')); 
kernelParam = double(single(kernelParam(:)')); 
nCh         = double(single(nCh)); 

if sum(mod(N_u(:), 2)) > 0
   error('N_u must have all components even for the Fourier transform. ');
   return; 
end
% END_argin initial -------------------------------------------------------


Nx_u = 0; 
Ny_u = 0; 
Nz_u = 0; 
if imDim == 1
    Nx_u = N_u(1, 1);
end
if imDim == 2
    Nx_u = N_u(1, 1);
    Ny_u = N_u(1, 2);
end
if imDim == 3
    Nx_u = N_u(1, 1);
    Ny_u = N_u(1, 2);
    Nz_u = N_u(1, 3);
end

x = []; 
y = []; 
z = []; 
if imDim == 1
    x = [-Nx_u*arg_osf/2:Nx_u*arg_osf/2-1]/arg_osf;
    x = ndgrid(x);
    d = sqrt(x(:).^2);
    d = reshape(d, [N_u_os, 1]); 
end
if imDim == 2
    x = [-Nx_u*arg_osf/2:Nx_u*arg_osf/2-1]/arg_osf;
    y = [-Ny_u*arg_osf/2:Ny_u*arg_osf/2-1]/arg_osf;
    [x, y] = ndgrid(x, y); 
    d = sqrt(x(:).^2 + y(:).^2);
    d = reshape(d, N_u_os);
end
if imDim == 3
    x = [-Nx_u*arg_osf/2:Nx_u*arg_osf/2-1]/arg_osf;
    y = [-Ny_u*arg_osf/2:Ny_u*arg_osf/2-1]/arg_osf;
    z = [-Nz_u*arg_osf/2:Nz_u*arg_osf/2-1]/arg_osf;
    [x, y, z] = ndgrid(x, y, z); 
    d = sqrt(x(:).^2 + y(:).^2 + z(:).^2);
    d = reshape(d, N_u_os);
end

if strcmp(kernelType, 'gauss')
    mySigma     = kernelParam(1);
    K_max       = kernelParam(2); 
    myWeight    = normpdf(d(:), 0, mySigma);
elseif strcmp(kernelType, 'kaiser')
    myTau       = kernelParam(1);
    myAlpha     = kernelParam(2);
    K_max       = kernelParam(3); 
    I0myAlpha   = besseli(0, myAlpha);
    
    myWeight    = max(1-(d/myTau).^2, 0);
    myWeight    = myAlpha*sqrt(myWeight);
    myWeight    = besseli(0, myWeight)/I0myAlpha;
end
myWeight = bmBlockReshape(myWeight, N_u_os); 

nWin_half = fix(nWin/2);
if imDim == 1
    x_mask = (x < nWin_half) | (x > nWin_half);
    myWeight(x_mask) = 0; 
end
if imDim == 2
    x_mask = (x < -nWin_half) | (x > nWin_half);
    y_mask = (y < -nWin_half) | (y > nWin_half);
    myWeight(x_mask) = 0; 
    myWeight(y_mask) = 0; 
end
if imDim == 3
    x_mask = (x < -nWin_half) | (x > nWin_half);
    y_mask = (y < -nWin_half) | (y > nWin_half);
    z_mask = (z < -nWin_half) | (z > nWin_half);
    myWeight(x_mask) = 0; 
    myWeight(y_mask) = 0; 
    myWeight(z_mask) = 0; 
end
 
if imDim == 1
    K = bmDFT1(myWeight, N_u_os, 1./N_u); 
elseif imDim == 2
    K = bmDFT2(myWeight, N_u_os, 1./N_u); 
elseif imDim == 3
    K = bmDFT3(myWeight, N_u_os, 1./N_u); 
end

if imDim == 1
    x_center    = N_u_os(1, 1)/2+1;
    x_half      = N_u(1, 1)/2;
    x_ind       = x_center-x_half:x_center+x_half-1; 
    
    K = K(:); 
    K = K(x_ind, 1);
    
elseif imDim == 2
    x_center    = N_u_os(1, 1)/2+1;
    x_half      = N_u(1, 1)/2;
    x_ind       = x_center-x_half:x_center+x_half-1; 
    
    y_center    = N_u_os(1, 2)/2+1;
    y_half      = N_u(1, 2)/2;
    y_ind       = y_center-y_half:y_center+y_half-1; 
    
    K = K(x_ind, y_ind);
    
elseif imDim == 3
    x_center    = N_u_os(1, 1)/2+1;
    x_half      = N_u(1, 1)/2;
    x_ind       = x_center-x_half:x_center+x_half-1; 
    
    y_center    = N_u_os(1, 2)/2+1;
    y_half      = N_u(1, 2)/2;
    y_ind       = y_center-y_half:y_center+y_half-1; 
    
    z_center    = N_u_os(1, 3)/2+1;
    z_half      = N_u(1, 3)/2;
    z_ind       = z_center-z_half:z_center+z_half-1; 
    
    K = K(x_ind, y_ind, z_ind);
end
K = abs(real(K)); 
K = K/max(abs(K(:))); 
K = 1./K; 
K = min(K, K_max); 
K = repmat(K(:), [1, nCh]);
K = single(K); 


end % END_function


