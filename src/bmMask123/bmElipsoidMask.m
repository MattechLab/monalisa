% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% 
% r is the list of radius
%
% varargin{1} is the center. 
%
% The center of the image, with coord zeros, has 
% voxel position arg_size/2+1 by definition. 

function m = bmElipsoidMask(arg_size, r, varargin)

c = bmVarargin(varargin); 

arg_size    = arg_size(:)'; 
r           = r(:)'; 
if ~isempty(c)
    c       = c(:)'; 
end

imDim       = size(arg_size(:), 1); 

if imDim == 2
    if arg_size(1, 1) == 1
        arg_size = arg_size(1, 2);
        imDim = 1;
    elseif arg_size(1, 2) == 1
        arg_size = arg_size(1, 1);
        imDim = 1;
    end
end

m = []; 

if imDim == 1
   
    m           = zeros(arg_size(1, 1), 1); 
    if isempty(c)
       c = 0;  
    end
    
    X = - arg_size(1, 1)/2:arg_size(1, 1)/2-1;
    rX = r(1, 1);
    cX = c(1, 1); 
    
    m = sqrt((  (X - cX)/rX  ).^2) <= 1; 
    
    
end


if imDim == 2
   
    m           = zeros(arg_size); 
    if isempty(c)
       c = [0, 0]; 
    end
    
    X = - arg_size(1, 1)/2:arg_size(1, 1)/2-1;
    rX = r(1, 1);
    cX = c(1, 1); 
    
    Y = - arg_size(1, 2)/2:arg_size(1, 2)/2-1;
    rY = r(1, 2);
    cY = c(1, 2); 
    
    [X, Y] = ndgrid(X, Y); 
    
    m = sqrt(  ((X - cX)/rX).^2 + ((Y - cY)/rY).^2    ) <= 1; 
    
    
end

if imDim == 3
   
    m           = zeros(arg_size); 
    if isempty(c)
       c = [0, 0, 0]; 
    end
    
    X = - arg_size(1, 1)/2:arg_size(1, 1)/2-1;
    rX = r(1, 1);
    cX = c(1, 1); 
    
    Y = - arg_size(1, 2)/2:arg_size(1, 2)/2-1;
    rY = r(1, 2);
    cY = c(1, 2); 
    
    Z = - arg_size(1, 3)/2:arg_size(1, 3)/2-1;
    rZ = r(1, 3);
    cZ = c(1, 3); 
    
    [X, Y, Z] = ndgrid(X, Y, Z); 
    
    m = sqrt(  ((X - cX)/rX).^2 + ((Y - cY)/rY).^2 + ((Z - cZ)/rZ).^2    ) <= 1; 
    
    
end

m = logical(m); 

end