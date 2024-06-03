% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

%
% The output is in col_shape.
% 

function v = bmImReg_transform_to_deformField(argTransform, n_u, X, Y, Z)

imDim       = size(n_u(:), 1);
n_u         = n_u(:)';
[X, Y, Z]   = bmImGrid(n_u, X, Y, Z); 

if strcmp(argTransform.class_type, 'bmImReg_translationTransform')
    
    t = argTransform.t(:);
    
    if imDim == 2
        vx = ones(n_u)*t(1, 1);
        vy = ones(n_u)*t(2, 1);
        
        v = cat(2, vx(:), vy(:));
        
    elseif imDim == 3
        vx = ones(n_u)*t(1, 1);
        vy = ones(n_u)*t(2, 1);
        vz = ones(n_u)*t(3, 1);
        
        v = cat(2, vx(:), vy(:), vz(:));
        
    end
    
elseif strcmp(argTransform.class_type, 'bmImReg_solidTransform')
    
    [X, Y, Z] = bmImGrid(n_u, X, Y, Z); 
    
    t       = argTransform.t(:);
    c_ref   = argTransform.c_ref(:);
    R       = argTransform.R;
    
    if imDim == 2

        r = cat(1, X(:)', Y(:)'); 
        r = r - repmat(c_ref(:), [1, prod(n_u(:))]); 
        v = R*r - r + repmat(t(:), [1, prod(n_u(:))]); 
        v = cat(2, v(1, :)', v(2, :)');
        
    elseif imDim == 3
        
        r = cat(1, X(:)', Y(:)', Z(:)'); 
        r = r - repmat(c_ref(:), [1, prod(n_u(:))]); 
        v = R*r - r + repmat(t(:), [1, prod(n_u(:))]);
        v = cat(2, v(1, :)', v(2, :)', v(3, :)');
        
    end
    
    
    
elseif strcmp(argTransform.class_type, 'bmImReg_directTransform')
    
    v = bmColReshape(argTransform.v, n_u); 
    
end

end