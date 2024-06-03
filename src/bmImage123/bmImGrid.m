% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [X, Y, Z] = bmImGrid(n_u, X, Y, Z)

n_u = n_u(:)';
imDim = size(n_u(:), 1);

if imDim == 2
    if isempty(X) || isempty(Y)
        [X, Y] = ndgrid(1:n_u(1, 1), 1:n_u(1, 2));
    end
elseif imDim == 3
    if isempty(X) || isempty(Y) || isempty(Z)
        [X, Y, Z] = ndgrid(1:n_u(1, 1), 1:n_u(1, 2), 1:n_u(1, 3));
    end
end


end