% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmTraj_dK_u(t, varargin)

N_u  = []; 
if length(varargin) > 0
   N_u = varargin{1};  
end
if isempty(N_u)
   N_u = bmTraj_N_u(t); 
end
N_u = N_u(:)'; 

t = bmPointReshape(t); 
imDim = size(t, 1);

if imDim > 0
    x_max = max(t(1, :));
    x_min = min(t(1, :));
    dK_x = abs(x_max - x_min)/(N_u(1, 1)-1); 
end

if imDim > 1
    y_max = max(t(2, :));
    y_min = min(t(2, :));
    dK_y = abs(y_max - y_min)/(N_u(1, 2)-1);
end

if imDim > 2
    z_max = max(t(3, :));
    z_min = min(t(3, :));
    dK_z = abs(z_max - z_min)/(N_u(1, 3)-1);
end


if imDim == 2
    if abs(dK_x - dK_y)/max(dK_x, dK_y) < 0.02 % ------------------------------- magic number
        [~, ~, ~, dK_n] = bmTraj_nLine(t);
        
        dK_n_median = median(dK_n(:));
        dK_n(dK_n >   2*dK_n_median) = []; % --------------------------------------------- magic number
        dK_n(dK_n < 0.5*dK_n_median) = []; % --------------------------------------------- magic number
        dK_n = median(dK_n(:)); 
        
        dK_x = dK_n; 
        dK_y = dK_n; 
    end
end

if imDim == 3
    
    d1 = abs(dK_x - dK_y)/max(dK_x, dK_y); 
    d2 = abs(dK_y - dK_z)/max(dK_y, dK_z);
    d3 = abs(dK_z - dK_x)/max(dK_z, dK_x);
    
    if  max([d1, d2, d3]) < 0.02 % --------------------------------------------- magic number
        [~, ~, ~, dK_n] = bmTraj_nLine(t);
        
        dK_n_median = median(dK_n(:));
        dK_n(dK_n >   2*dK_n_median) = []; % --------------------------------------------- magic number
        dK_n(dK_n < 0.5*dK_n_median) = []; % --------------------------------------------- magic number
        dK_n = median(dK_n(:)); 
        
        
        dK_x = dK_n; 
        dK_y = dK_n; 
        dK_z = dK_n; 
    end
end





if imDim == 1
    varargout{1} = dK_x;
elseif imDim == 2
    varargout{1} = [dK_x, dK_y];
elseif imDim == 3
    varargout{1} = [dK_x, dK_y, dK_z];
end






end