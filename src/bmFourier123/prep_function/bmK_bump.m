% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function K = bmK_bump(N_u)

% argin initial -----------------------------------------------------------

arg_osf = 2; % --------------------------------------------------------------- magic_number

N_u         = double(int32(N_u(:)'));
N_u_os      = round(N_u*arg_osf);
imDim       = size(N_u(:), 1); 

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



myWeight = exp(-1./(1-d.^2));
myWeight(isinf(myWeight)) = 0;
myWeight = myWeight.*double(abs(d) < 1); % bump-function
 
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
K = real(K); 
K = K/max(abs(K(:))); 
K = single(1./K); 

end % END_function


