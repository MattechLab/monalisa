% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% C can be empty. 

function y = bmSimulateMriData(h, C, t, N_u, n_u, dK_u)

if iscell(h)
    y = cell(size(h));
    for i = 1:size(y(:), 1)
        y{i} = bmSimulateMriData(h{i}, C, t{i}, N_u, n_u, dK_u);
    end
    y = reshape(y, size(h)); 
    return;
end

if isempty(C)
   C = bmOne([prod(n_u(:)), 1], 'complex_single');  
end

h = bmBlockReshape(h, n_u);
C = bmBlockReshape(C, n_u);
t = bmPointReshape(t);

imDim   = size(t, 1); 
nCh     = size(C(:), 1)/prod(n_u(:));
nPt     = size(t, 2);

N_u     = N_u(:)';
n_u     = n_u(:)';
dK_u    = dK_u(:)';

kx = []; 
ky = []; 
kz = []; 

if imDim == 1
    kx = [-N_u(1, 1)/2:N_u(1, 1)/2 - 1]*dK_u(1, 1);
    kx = ndgrid(kx); 
elseif imDim == 2
    kx = [-N_u(1, 1)/2:N_u(1, 1)/2 - 1]*dK_u(1, 1); 
    ky = [-N_u(1, 2)/2:N_u(1, 2)/2 - 1]*dK_u(1, 2);
    [kx, ky] = ndgrid(kx, ky); 
elseif imDim == 3
   kx = [-N_u(1, 1)/2:N_u(1, 1)/2 - 1]*dK_u(1, 1); 
   ky = [-N_u(1, 2)/2:N_u(1, 2)/2 - 1]*dK_u(1, 2); 
   kz = [-N_u(1, 3)/2:N_u(1, 3)/2 - 1]*dK_u(1, 3); 
   [kx, ky, kz] = ndgrid(kx, ky, kz); 
end

y = bmZero([nPt, nCh], 'complex_single');

for i = 1:nCh
    
    if imDim == 1
        temp_im = C(:, i).*h;
    elseif imDim == 2
        temp_im = C(:, :, i).*h;
    elseif imDim == 3
        temp_im = C(:, :, :, i).*h;
    end
    
    % eventual zero_filling
    if ~isequal(N_u, n_u)
        temp_im = bmImZeroFill(temp_im, N_u, n_u, 'complex_single');
    end
    
    for n = 1:imDim
        temp_im = fftshift(fft(ifftshift(temp_im, n), [], n), n)/N_u(1, n)/dK_u(1, n);
    end
    
    
    if imDim == 1
        temp_y = interpn(kx, temp_im, t(1, :), 'cubic');
    elseif imDim == 2
        temp_y = interpn(kx, ky, temp_im, t(1, :), t(2, :), 'cubic');
    elseif imDim == 3
        temp_y = interpn(kx, ky, kz, temp_im, t(1, :), t(2, :), t(3, :), 'cubic');
    end
    temp_y(isnan(temp_y)) = 0;
    
    y(:, i) = temp_y(:);
end

end