% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmTraj_resolution(t)

imDim = size(t, 1);

if imDim > 0
    x_max = max(t(1, :));
    x_min = min(t(1, :));
    dx = 1/abs(x_max - x_min); 
end

if imDim > 1
    y_max = max(t(2, :));
    y_min = min(t(2, :));
    dy = 1/abs(y_max - y_min); 
end

if imDim > 2
    z_max = max(t(3, :));
    z_min = min(t(3, :));
    dz = 1/abs(z_max - z_min); 
end



if imDim == 1
    varargout{1} = dx;
elseif imDim == 2
    varargout{1} = [dx, dy];
elseif imDim == 3
    varargout{1} = [dx, dy, dz];
end






end