% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function v = bmVolumeElement_imDeformField3(vf, N_u)

if not(size(vf, 1) == 3)
    error('The trajectory must be 3Dim. '); 
    return; 
end

    N_u  = N_u(:)'; 
    Nx_u = N_u(1, 1); 
    Ny_u = N_u(1, 2);
    Nz_u = N_u(1, 3);
   
    x_u = 1:N_u(1, 1); 
    y_u = 1:N_u(1, 2);
    z_u = 1:N_u(1, 3);
    
    [x_u, y_u, z_u] = ndgrid(x_u, y_u, z_u); 
    vf = reshape(vf, [3, prod(N_u(:))]  );
    t = cat(1, x_u(:)' + vf(1, :), y_u(:)' + vf(2, :), z_u(:)' + vf(3, :)); 
    t = reshape(t, [3, N_u]); 
    
    s =     t(:, 1:end-1 , 1:end-1, 1:end-1);
    s = s + t(:, 2:end   , 1:end-1, 1:end-1); 
    s = s + t(:, 1:end-1 , 2:end  , 1:end-1); 
    s = s + t(:, 1:end-1 , 1:end-1, 2:end  );
    s = s + t(:, 2:end   , 2:end  , 1:end-1);
    s = s + t(:, 2:end   , 1:end-1, 2:end  );
    s = s + t(:, 1:end-1 , 2:end  , 2:end  );
    s = s + t(:, 2:end   , 2:end  , 2:end  );
    s = s/8; 
    
    
    a = s(:, 1:end-1 , 1:end-1, 1:end-1);
    b = s(:, 2:end   , 1:end-1, 1:end-1); 
    c = s(:, 1:end-1 , 2:end  , 1:end-1); 
    d = s(:, 1:end-1 , 1:end-1, 2:end  );
    e = s(:, 2:end   , 2:end  , 1:end-1);
    f = s(:, 2:end   , 1:end-1, 2:end  );
    g = s(:, 1:end-1 , 2:end  , 2:end  );
    h = s(:, 2:end   , 2:end  , 2:end  );
    
    a = reshape(a, [3, (Nx_u-2) * (Ny_u-2) * (Nz_u-2) ]); 
    b = reshape(b, [3, (Nx_u-2) * (Ny_u-2) * (Nz_u-2) ]); 
    c = reshape(c, [3, (Nx_u-2) * (Ny_u-2) * (Nz_u-2) ]);
    d = reshape(d, [3, (Nx_u-2) * (Ny_u-2) * (Nz_u-2) ]); 
    e = reshape(e, [3, (Nx_u-2) * (Ny_u-2) * (Nz_u-2) ]); 
    f = reshape(f, [3, (Nx_u-2) * (Ny_u-2) * (Nz_u-2) ]); 
    g = reshape(g, [3, (Nx_u-2) * (Ny_u-2) * (Nz_u-2) ]);
    h = reshape(h, [3, (Nx_u-2) * (Ny_u-2) * (Nz_u-2) ]);
    
    
    myArea = cross(b-a, c-a)/2; 
    myTop = d-a; 
    myVolume_1 = abs(myTop(1, :).*myArea(1, :) + myTop(2, :).*myArea(2, :) + myTop(3, :).*myArea(3, :))/3;
    
    myArea = cross(c-b, d-b)/2; 
    myTop = f-b; 
    myVolume_2 = abs(myTop(1, :).*myArea(1, :) + myTop(2, :).*myArea(2, :) + myTop(3, :).*myArea(3, :))/3;
    
    myArea = cross(c-b, f-b)/2; 
    myTop = e-b; 
    myVolume_3 = abs(myTop(1, :).*myArea(1, :) + myTop(2, :).*myArea(2, :) + myTop(3, :).*myArea(3, :))/3;
    
    myArea = cross(h-g, c-g)/2; 
    myTop = d-g; 
    myVolume_4 = abs(myTop(1, :).*myArea(1, :) + myTop(2, :).*myArea(2, :) + myTop(3, :).*myArea(3, :))/3;
    
    myArea = cross(c-h, d-h)/2; 
    myTop = f-h; 
    myVolume_5 = abs(myTop(1, :).*myArea(1, :) + myTop(2, :).*myArea(2, :) + myTop(3, :).*myArea(3, :))/3;
    
    myArea = cross(c-h, f-h)/2; 
    myTop = e-h; 
    myVolume_6 = abs(myTop(1, :).*myArea(1, :) + myTop(2, :).*myArea(2, :) + myTop(3, :).*myArea(3, :))/3;
    
    
    
    v = myVolume_1 + myVolume_2 + myVolume_3 + myVolume_4 + myVolume_5 + myVolume_6; 
    v = reshape(v, N_u-2); 
    v = cat(1, v(1, :, :), v, v(end, :,   :)); 
    v = cat(2, v(:, 1, :), v, v(:, end,   :));
    v = cat(3, v(:, :, 1), v, v(:, :  , end));
    v = reshape(v, [1, prod(N_u(:))]  ); 

end