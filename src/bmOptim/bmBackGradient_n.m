% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function g = bmBackGradient_n(x, n_u, dX_u, n)

imDim   = size(n_u(:), 1);
n_u     = n_u(:)';
dX_u    = dX_u(:)';


myShift = zeros(1, imDim);
myShift(1, n) = 1;


if imDim == 1
    
    x = reshape(x, [n_u, 1]);
    g = (  x - circshift(x, myShift)  )/dX_u(1, n);

    if n == 1
        g(1, 1) = 0;
    end
elseif imDim == 2
    
    x = reshape(x, n_u);
    g = (  x - circshift(x, myShift)  )/dX_u(1, n);

    if n == 1
        g(1, :) = 0;
    elseif n == 2
        g(:, 1) = 0;
    end
elseif imDim == 3
    
    x = reshape(x, n_u);
    g = (  x - circshift(x, myShift)  )/dX_u(1, n);

    if n == 1
        g(1, :, :) = 0;
    elseif n == 2
        g(:, 1, :) = 0;
    elseif n == 3
        g(:, :, 1) = 0;
    end
end

g = reshape(g, [prod(n_u(:)), 1]);

end