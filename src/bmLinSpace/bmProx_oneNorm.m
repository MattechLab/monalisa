% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function z = bmProx_oneNorm(w, s)

if iscell(w)
    z = cell(size(w));
    
    for i = 1:size(z(:), 1)
        z{i} = bmProx_oneNorm(w{i}, s);
    end
    
    return;
end

argSize = size(w); 

w = single(w(:)); 
s = single(abs(s)); 
N = size(w(:), 1); 
z = []; 

if isreal(w)
    z = zeros(N, 1, 'single'); 
    mask_plus   = single(w > s);  
    mask_minus  = single(w < -s);
    z = mask_plus.*(w - s) + mask_minus.*(w + s); 
    
else
    w_real = real(w); 
    w_imag = imag(w); 
    
    mask_plus   = single(w_real > s); 
    mask_minus  = single(w_real < -s);
    z_real      = mask_plus.*(w_real - s) + mask_minus.*(w_real + s); 
    mask_plus   = single(w_imag > s);  
    mask_minus  = single(w_imag < -s);
    z_imag      = mask_plus.*(w_imag - s) + mask_minus.*(w_imag + s);  
    z = complex(z_real, z_imag); 
    
end

z = reshape(z, argSize); 

end