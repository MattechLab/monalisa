% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function p = bmImReg_deformField_to_positionField(v, n_u, X, Y, Z, varargin)

circular_option = bmVarargin(varargin); 
if isempty(circular_option)
    circular_option = true; 
end

n_u     = n_u(:)';
imDim   = size(n_u(:), 1);
v       = bmBlockReshape(v, n_u);
p       = zeros(size(v), 'single'); 

if imDim > 1
    [X, Y, Z] = bmImGrid(n_u, X, Y, Z); 
end

if imDim == 1
    X           = bmCol(1:n_u(1, 1)); 
    
    p(:, 1)     = v(:, 1) + X(:, 1);
    
    if circular_option
        p(:, 1)     = mod( v(:, 1) + X(:, 1), n_u(1, 1) ) + 1;
        
        p(:, 1) = private_replace_smaller(p(:, 1), 1);
        p(:, 1) = private_replace_larger(p(:, 1),  n_u(1, 1));
    end
    
elseif imDim == 2
    
    p(:, :, 1)  = v(:, :, 1) + X;
    p(:, :, 2)  = v(:, :, 2) + Y;
    
    if circular_option
        p(:, :, 1)  = mod( p(:, :, 1) - 1, n_u(1, 1) ) + 1;
        p(:, :, 2)  = mod( p(:, :, 2) - 1, n_u(1, 2) ) + 1;
        
        p(:, :, 1) = private_replace_smaller(p(:, :, 1), 1);
        p(:, :, 2) = private_replace_smaller(p(:, :, 2), 1);
        p(:, :, 1) = private_replace_larger(p(:, :, 1), n_u(1, 1));
        p(:, :, 2) = private_replace_larger(p(:, :, 2), n_u(1, 2));
    end

elseif imDim == 3
    
    p(:, :, :, 1)  = v(:, :, :, 1) + X;
    p(:, :, :, 2)  = v(:, :, :, 2) + Y;
    p(:, :, :, 3)  = v(:, :, :, 3) + Z;
    
    
    if circular_option
        p(:, :, :, 1)  = mod( p(:, :, :, 1) - 1, n_u(1, 1) ) + 1;
        p(:, :, :, 2)  = mod( p(:, :, :, 2) - 1, n_u(1, 2) ) + 1;
        p(:, :, :, 3)  = mod( p(:, :, :, 3) - 1, n_u(1, 3) ) + 1;
        
        p(:, :, :, 1) = private_replace_smaller(p(:, :, :, 1), 1);
        p(:, :, :, 2) = private_replace_smaller(p(:, :, :, 2), 1);
        p(:, :, :, 3) = private_replace_smaller(p(:, :, :, 3), 1);
        
        p(:, :, :, 1) = private_replace_larger(p(:, :, :, 1), n_u(1, 1));
        p(:, :, :, 2) = private_replace_larger(p(:, :, :, 2), n_u(1, 2));
        p(:, :, :, 3) = private_replace_larger(p(:, :, :, 3), n_u(1, 3));
    end
    
end

end

function q = private_replace_smaller(p, c)
    q = p; 
    m = (q < c); 
    q(m) = c;
end

function q = private_replace_larger(p, c)
    q = p; 
    m = (q > c); 
    q(m) = c;
end