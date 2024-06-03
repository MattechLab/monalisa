% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [X1_mean, Y1_mean, Z1_mean, X2_mean, Y2_mean, Z2_mean] = bmCheckCoilPositions(im_main, im_prescan, n_u)

im_main     = abs(im_main); 
im_prescan  = abs(im_prescan); 

n_u = n_u(:)'; 
imDim = size( n_u(:) , 1);

nCh = size(im_main, imDim + 1); 

X1_mean = zeros(1, nCh); 
Y1_mean = zeros(1, nCh); 
Z1_mean = zeros(1, nCh); 

X2_mean = zeros(1, nCh); 
Y2_mean = zeros(1, nCh); 
Z2_mean = zeros(1, nCh); 

if imDim == 1
    error('Case not implemented'); 
    return; 
end

if imDim == 2
    
    nx = n_u(1, 1); 
    ny = n_u(1, 2); 

    [X, Y] = ndgrid(nx, ny);
    
    
    for i = 1:nCh
        temp_im = im_main(:, :, i); 
        temp_im = temp_im/sum(temp_im(:)); 
        
        X_mean(1, i) = sum(  X(:).*temp_im(:)  );
        Y_mean(1, i) = sum(  Y(:).*temp_im(:)  );
    end
    
    return; 
end


if imDim == 3
    
    nx = n_u(1, 1); 
    ny = n_u(1, 2); 
    nz = n_u(1, 3); 

    [X, Y, Z] = ndgrid(1:nx, 1:ny, 1:nz);
    
    X = X - (nx/2 + 1); 
    Y = Y - (ny/2 + 1); 
    Z = Z - (nz/2 + 1); 
    
    
    for i = 1:nCh
        temp_im = im_main(:, :, :, i); 
        temp_im = temp_im/sum(temp_im(:)); 
        
        X1_mean(1, i) = sum(  X(:).*temp_im(:)  );
        Y1_mean(1, i) = sum(  Y(:).*temp_im(:)  );
        Z1_mean(1, i) = sum(  Z(:).*temp_im(:)  );

    end
    
    for i = 1:nCh
        temp_im = im_prescan(:, :, :, i); 
        temp_im = temp_im/sum(temp_im(:)); 
        
        X2_mean(1, i) = sum(  X(:).*temp_im(:)  );
        Y2_mean(1, i) = sum(  Y(:).*temp_im(:)  );
        Z2_mean(1, i) = sum(  Z(:).*temp_im(:)  );

    end
    
        a = 0.65; 
        X2_mean = X2_mean*a;
        Y2_mean = Y2_mean*a;
        Z2_mean = Z2_mean*a;
    
        figure
        hold on
        plot3(X1_mean, Y1_mean, Z1_mean, 'b.')
        plot3(X2_mean, Y2_mean, Z2_mean, 'r.')
        
        for i = 1:nCh
           plot3([X1_mean(1, i), X2_mean(1, i)], ...
                 [Y1_mean(1, i), Y2_mean(1, i)], ...   
                 [Z1_mean(1, i), Z2_mean(1, i)], 'k-');  
        end
        
    
    return; 
end

end



