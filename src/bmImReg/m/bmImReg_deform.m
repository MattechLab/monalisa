% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x_deform = bmImReg_deform(v, x, n_u, X, Y, Z, varargin)

[interp_method, circular_option] = bmVarargin(varargin); 

if isempty(interp_method)
    interp_method = 'cubic'; 
end
if isempty(circular_option)
    circular_option = true; 
end

imDim       = size(n_u(:), 1);
[X, Y, Z]   = bmImGrid(n_u, X, Y, Z); 

x = bmBlockReshape(x, n_u);
v = bmImReg_deformField_to_positionField(v, n_u, X, Y, Z, circular_option);
v = bmBlockReshape(v, n_u); 

if imDim == 2
    x_deform = interpn(X, Y, x, v(:, :, 1), v(:, :, 2), interp_method);
elseif imDim == 3
    x_deform = interpn(X, Y, Z, x, v(:, :, :, 1), v(:, :, :, 2), v(:, :, :, 3), interp_method);
end

x_deform(isnan(x_deform)) = 0; 

end