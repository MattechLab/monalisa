% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function outIm = bmImResize(argIm, n_u, N_u, varargin)

interp_option = bmVarargin(varargin); 
if isempty(interp_option)
    interp_option = 'cubic'; 
end

N_u = N_u(:)'; 
n_u = n_u(:)'; 

imDim   = size(n_u(:), 1); 
nCh     = size(argIm(:), 1)/prod(n_u(:)); 
myIm    = reshape(argIm, [n_u, nCh]); 
outIm   = zeros([N_u, nCh]); 
if not(isreal(myIm))
   outIm = complex(outIm, outIm);  
end

if not(isequal(imDim, size(N_u(:), 1)  ))
    error('n_u and N_u must correspond to the same image dimension. '); 
    return; 
end



if imDim == 1
    myIm = cat(1, myIm, myIm(1, :)); 
end
if imDim == 2
    myIm = cat(1, myIm, myIm(1, :, :));
    myIm = cat(2, myIm, myIm(:, 1, :));
end
if imDim == 3
    myIm = cat(1, myIm, myIm(1, :, :, :));
    myIm = cat(2, myIm, myIm(:, 1, :, :));
    myIm = cat(3, myIm, myIm(:, :, 1, :));
end



nu_x = []; 
nu_y = []; 
nu_z = []; 


Nu_x = []; 
Nu_y = []; 
Nu_z = []; 

if imDim > 0
    nu_x = n_u(1, 1);
    Nu_x = N_u(1, 1);
end
if imDim > 1
    nu_y = n_u(1, 2);
    Nu_y = N_u(1, 2);
end
if imDim > 2
    nu_z = n_u(1, 3);
    Nu_z = N_u(1, 3);
end 


x1 = []; 
x2 = []; 
y1 = []; 
y2 = []; 
z1 = []; 
z2 = []; 


if imDim > 0
    
    x1 = linspace(0, 1, nu_x+1);
    x2 = mod(0.5 + [-Nu_x/2:Nu_x/2 - 1]/Nu_x, 1); 
    
end
if imDim > 1
    
    y1 = linspace(0, 1, nu_y+1);
    y2 = mod(0.5 + [-Nu_y/2:Nu_y/2 - 1]/Nu_y, 1); 

end
if imDim > 2
    
    z1 = linspace(0, 1, nu_z+1);
    z2 = mod(0.5 + [-Nu_z/2:Nu_z/2 - 1]/Nu_z, 1); 
    
end
    
    

if imDim == 1
   
    x1 = ndgrid(x1(:)); 
    x2 = ndgrid(x2(:)); 
    
    for i = 1:nCh
        outIm(:, i) = interpn(x1, myIm(:, i), x2, interp_option);
    end
    
elseif imDim == 2
    
    [x1, y1] = ndgrid(x1(:), y1(:)); 
    [x2, y2] = ndgrid(x2(:), y2(:)); 
    
    for i = 1:nCh
        outIm(:, :, i) = interpn(x1, y1, myIm(:, :, i), x2, y2, interp_option);
    end
    
elseif imDim == 3
    
    [x1, y1, z1] = ndgrid(x1(:), y1(:), z1(:)); 
    [x2, y2, z2] = ndgrid(x2(:), y2(:), z2(:));
    
    for i = 1:nCh
        outIm(:, :, :, i) = interpn(x1, y1, z1, myIm(:, :, :, i), x2, y2, z2, interp_option);
    end
    
end

if bmIsColShape(argIm, N_u);
    outIm = bmColReshape(outIm, N_u);
else bmIsBlockShape(argIm, N_u);
    outIm = bmBlockReshape(outIm, N_u);
end




end