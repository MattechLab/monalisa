% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmShanna_partialCartesian(x, ind_u, FC, N_u, n_u, dK_u)

% argin_initial -----------------------------------------------------------
C_flag = false; 
if isempty(FC)
    FC = single(  1/prod(N_u(:))/prod(dK_u(:))  );  
    C_flag = false; 
else
    C_flag = true; 
end

if isempty(n_u)
   n_u = N_u;  
end

N_u         = double(  int32(N_u(:)')  ); 
n_u         = double(  int32(n_u(:)')  );
imDim       = size(N_u(:), 1);
x_size_2    = size(x, 2); 

if (size(x, 2) == 1)
    nCh = size(FC, 2);
else 
    nCh = size(x, 2); 
end

private_check(x, FC, N_u, n_u, nCh, C_flag);  
% END_argin_initial -------------------------------------------------------


% eventual channel extension
if x_size_2 < nCh
    x = repmat(x, [1, nCh]); 
end

% coil decombine
x = x.*FC; 

% eventual zero_filling
if ~isequal(N_u, n_u)
   x = bmBlockReshape(x, n_u);    
   x = bmImZeroFill(x, N_u, n_u, 'complex_single'); 
   x = bmColReshape(x, N_u); 
end

% fft
x = bmBlockReshape(x, N_u);
for n = 1:3
    if imDim > (n-1)
        x = fftshift(fft(ifftshift(x, n), [], n), n);
    end
end
x = bmColReshape(x, N_u);

% gridding
y = bmGu_partialCartesian(x, ind_u, N_u); 

end




function private_check(x, FC, N_u, n_u, nCh, C_flag)

if not(isa(x, 'single'))
    error('The data''x'' must be of class single');
    return; 
end

if not(isa(FC, 'single'))
    error('The ''FC'' must be of class single');
    return; 
end

if not(size(x, 1) == prod(n_u(:)))
        error('The data matrix ''x'' is not in the correct size');
        return;
end


if C_flag
    if not(isequal(size(FC), [prod(n_u(:)), nCh] ))
        error('The matrix ''C'' is probably not in the correct size');
        return;
    end
end













if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
    return;
end

if sum(mod(n_u(:), 2)) > 0
    error('n_u must have all components even for the Fourier transform. ');
    return;
end

end