% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t_out = bmTraj_rescaleToUnitCube(t, N_u, dK_u)

in_size = size(t); 
t = bmPointReshape(t); 
t_out = t; 

imDim = size(N_u(:), 1); 

if imDim > 0
    t_out(1, :) = t_out(1, :)/(  N_u(1, 1)*dK_u(1, 1)  );
end
if imDim > 1
    t_out(2, :) = t_out(2, :)/(  N_u(1, 2)*dK_u(1, 2)  );
end
if imDim > 2
    t_out(3, :) = t_out(3, :)/(  N_u(1, 3)*dK_u(1, 3)  );
end

t_out = reshape(t_out, in_size); 




if max(t_out(:)) > 0.5 
    warning(['The rescaled trajectory is out of the unit cube.', ...
             'The input trajectory may be wrong']); 
end

if min(t_out(:)) < -0.5 
    warning(['The rescaled trajectory is out of the unit cube.', ...
             'The input trajectory may be wrong']); 
end

if max(t_out(:)) < 0.5 - 3*mean(dK_u(:))
    warning(['The rescaled trajectory does not fill the unit cube.', ...
             'The input trajectory may be wrong or a bad sampling. ']); 
end

if min(t_out(:)) > -0.5 + 3*mean(dK_u(:))
    warning(['The rescaled trajectory does not fill the unit cube.', ...
             'The input trajectory may be wrong or a bad sampling. ']); 
end

end