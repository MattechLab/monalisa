% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [ind_1, ind_2, myWeight, Dn] = bmImDeformField_sparseMat_ind_weight(v, N_u, Dn, torus_flag) 

% initial -----------------------------------------------------------------
v           = double(bmPointReshape(v)); 
Dn          = double(Dn(:)');  
N_u         = double(N_u(:)'); 

imDim       = double(size(v, 1)); 
nPt         = double(size(v, 2));


if nPt ~= prod(N_u(:))
   error([  'In bmImDeformField_Gn_Gu_Gut : the deformation', ... 
            ' field must have as many vectors as ', ...
            'the number of pixel(voxel) in the image. ']);  
end
% END_initial -------------------------------------------------------------


% preparing Nu and t and --------------------------------------------------
Nx_u = 0; 
Ny_u = 0; 
Nz_u = 0; 
if imDim == 1
    Nx_u = N_u(1, 1);
    
    v = reshape(v, [1, Nx_u]); 
    x_u = ndgrid(1:Nx_u);
    t = x_u(:)' + v;
end
if imDim == 2
    Nx_u = N_u(1, 1);
    Ny_u = N_u(1, 2); 
    
    v = reshape(v, [2, Nx_u*Ny_u]); 
    [x_u, y_u] = ndgrid(1:Nx_u, 1:Ny_u);
    t = cat(1, x_u(:)', y_u(:)') + v;
end
if imDim == 3
    Nx_u = N_u(1, 1);
    Ny_u = N_u(1, 2);
    Nz_u = N_u(1, 3);
    
    v = reshape(v, [3, Nx_u*Ny_u*Nz_u]); 
    [x_u, y_u, z_u] = ndgrid(1:Nx_u, 1:Ny_u, 1:Nz_u);
    t = cat(1, x_u(:)', y_u(:)', z_u(:)') + v;
end
x_u = 0;
y_u = 0;
z_u = 0;
% END_preparing Nu and t and ----------------------------------------------


% deleting trajectory points that are out of the spat ---------------------
deleteMask = false(1, nPt); 
if imDim > 0
    deleteMask = deleteMask | (t(1, :) < 1) | (t(1, :) > Nx_u);  
end
if imDim > 1
    deleteMask = deleteMask | (t(2, :) < 1) | (t(2, :) > Ny_u);  
end
if imDim > 2
    deleteMask = deleteMask | (t(3, :) < 1) | (t(3, :) > Nz_u);  
end 
% END_deleting trajectory points that are out of the spat -----------------


if imDim == 1
    cx = ndgrid(0:1);
    c = cx(:)';
elseif imDim == 2
    [cx, cy] = ndgrid(0:1, 0:1);
    c = [cx(:)'; cy(:)'];
elseif imDim == 3
    [cx, cy, cz] = ndgrid(0:1, 0:1, 0:1); 
    c = [cx(:)'; cy(:)'; cz(:)'];
end

c = repmat(c, [1, 1, nPt]); 
nNb = double(size(c, 2)); 

t_floor = floor(t);
t_rest  = t - t_floor; 

t_floor = reshape(t_floor, [imDim, 1, nPt]);
t_floor =  repmat(t_floor, [1, nNb, 1]); 

t_rest  = reshape(t_rest,  [imDim, 1, nPt]); 
t_rest  =  repmat(t_rest,  [1, nNb, 1]); 


d = t_rest - c; 
temp_square = 0; 
for i = 1:imDim
    temp_square = temp_square + d(i, :, :).^2; 
end
d = sqrt(temp_square); 

if ~isempty(Dn)
    Dn = reshape(Dn, [1, nPt]);
    Dn =  repmat(Dn, [nNb, 1]);
end

myWeight = exp(-1./(1-d.^2));
myWeight(isinf(myWeight)) = 0;
myWeight = myWeight.*double(abs(d) < 1); % bump-function
myWeight = reshape(myWeight, [nNb, nPt]); 

n = t_floor + c; 

d = 0; 
t_floor = 0; 
t_rest = 0; 

if imDim == 1
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1;
    n = 1 + (n(1, :, :) - 1);
elseif imDim == 2
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1;
    n(2, :, :) = mod(n(2, :, :)-1, Ny_u)+1;
    n = 1 + (n(1, :, :) - 1) + (n(2, :, :) - 1)*Nx_u;
elseif imDim == 3
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1;
    n(2, :, :) = mod(n(2, :, :)-1, Ny_u)+1;
    n(3, :, :) = mod(n(3, :, :)-1, Nz_u)+1;
    n = 1 + (n(1, :, :) - 1) + (n(2, :, :) - 1)*Nx_u + (n(3, :, :) - 1)*Nx_u*Ny_u;
end

myOne = ones(1, nPt); 


if not(torus_flag)
    n(:, :, deleteMask) = [];
    myWeight(:, deleteMask) = [];
    myOne(1, deleteMask) = 0;
    if ~isempty(Dn)
        Dn(:, deleteMask) = [];
    end
end



ind_1 = double(n(:)); 
ind_2 = double(bmSparseMat_r_nJump2index(nNb*myOne)'); 
myWeight = double(myWeight(:)); 
Dn = double(Dn(:)); 


end