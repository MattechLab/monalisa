% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function v = bmVolumeElement_replace_cartesian(arg_v, N_u)

v = arg_v; 
imDim   = size(N_u(:), 1); 
v       = reshape(v, N_u); 

if imDim == 1
    v = v(:); 
    
    v(1, 1)     = [];
    v(end, 1)   = [];
    
    v = cat(1, v(1, 1), v, v(end, 1)); 
end

if imDim == 2
    v(:, 1)     = []; 
    v(:, end)   = [];
    
    v(1, :)     = []; 
    v(end, :)   = [];
    
    v = cat(1, v(1, :), v, v(end, :)); 
    v = cat(2, v(:, 1), v, v(: ,end)); 
end


if imDim == 3
   
    v(:, :,   1)     = []; 
    v(:, :, end)     = [];
    
    v(:, 1,   :)     = []; 
    v(:, end, :)     = [];
    
    v(1  , :, :)     = []; 
    v(end, :, :)     = [];
    
    
    v = cat(1, v(1, :, :), v, v(end, :, :)); 
    v = cat(2, v(:, 1, :), v, v(:, end, :));
    v = cat(3, v(:, :, 1), v, v(:, :, end));
end

v = v(:)'; 

end