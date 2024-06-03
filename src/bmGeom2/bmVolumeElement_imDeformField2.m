% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function v = bmVolumeElement_imDeformField2(vf, N_u)

if not(size(vf, 1) == 2)
    error('The trajectory must be 2Dim. '); 
    return; 
end

    N_u  = N_u(:)'; 
    Nx_u = N_u(1, 1); 
    Ny_u = N_u(1, 2);
   
    x_u = 1:N_u(1, 1); 
    y_u = 1:N_u(1, 2); 
    [x_u, y_u] = ndgrid(x_u, y_u); 
    vf = reshape(vf, [2, prod(N_u(:))]  );
    t = cat(1, x_u(:)' + vf(1, :), y_u(:)' + vf(2, :)); 
    t = reshape(t, [2, N_u]); 
    
    s =     t(:, 1:end-1 , 1:end-1); 
    s = s + t(:, 2:end   , 1:end-1); 
    s = s + t(:, 1:end-1 , 2:end); 
    s = s + t(:, 2:end   , 2:end); 
    s = s/4; 
    
    
    a = s(:, 1:end-1, 1:end-1); 
    b = s(:, 2:end  , 1:end-1); 
    c = s(:, 1:end-1, 2:end); 
    d = s(:, 2:end  , 2:end); 
    
    a = reshape(a, [2, (Nx_u-2) * (Ny_u-2) ]); 
    b = reshape(b, [2, (Nx_u-2) * (Ny_u-2) ]); 
    c = reshape(c, [2, (Nx_u-2) * (Ny_u-2) ]);
    d = reshape(d, [2, (Nx_u-2) * (Ny_u-2) ]); 
    
    a = cat(1, a, zeros(1, size(a, 2))  ); 
    b = cat(1, b, zeros(1, size(b, 2))  ); 
    c = cat(1, c, zeros(1, size(c, 2))  ); 
    d = cat(1, d, zeros(1, size(d, 2))  ); 
    
    
    
    v = (  abs(cross(b - a, c - a)) + abs(cross(c - b, d - b))  )/2;
    v = v(3, :); 
    v = reshape(v, N_u-2); 
    
    v = cat(1, v(1, :), v, v(end, :)); 
    v = cat(2, v(:, 1), v, v(:, end)); 
    v = reshape(v, [1, prod(N_u(:))]  ); 

end