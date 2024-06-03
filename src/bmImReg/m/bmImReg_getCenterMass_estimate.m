% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function c = bmImReg_getCenterMass_estimate(argIm, X, Y, Z, varargin)

myOption = bmVarargin(varargin);
if isempty(myOption)
    myOption = 'normal';
end

n_u  = size(argIm);
n_u  = n_u(:)';
imDim   = size(n_u(:), 1);
argIm   = single(abs(argIm));

if imDim == 2
    nx = n_u(1, 1);
    ny = n_u(1, 2);
elseif imDim == 3
    nx = n_u(1, 1);
    ny = n_u(1, 2);
    nz = n_u(1, 3);
end

[X, Y, Z] = bmImGrid(n_u, X, Y, Z);

if strcmp(myOption, 'normal')
    
    m = bmElipsoidMask(size(argIm), size(argIm)/2);
    argIm   = argIm.*m;
    im_sum  = sum(argIm(:));
    if im_sum == 0
        im_sum = 1;
    end
    
    if imDim == 2
        c_x = sum(X(:).*argIm(:))/im_sum;
        c_y = sum(Y(:).*argIm(:))/im_sum;
        c = [c_x, c_y].';
    elseif imDim == 3
        c_x = sum(X(:).*argIm(:))/im_sum;
        c_y = sum(Y(:).*argIm(:))/im_sum;
        c_z = sum(Z(:).*argIm(:))/im_sum;
        c = [c_x, c_y, c_z].';
    end
    
elseif strcmp(myOption, 'extended')
    
    imSupport = single(abs(argIm) > 0);
    
    if imDim == 2
        R2 = (X - (nx/2 + 1)).^2 + (Y - (ny/2 + 1)).^2;
    elseif imDim == 3
        R2 = (X - (nx/2 + 1)).^2 + (Y - (ny/2 + 1)).^2 + (Z - (nz/2 + 1)).^2;
    end
    
    
    if imDim == 2
        
        c       = zeros(imDim, 4);
        d       = zeros(1, 4);
        s       = zeros(4, imDim);
        
        sx = fix(  (n_u(1, 1) - 1)/2  ) + 1;
        sy = fix(  (n_u(1, 2) - 1)/2  ) + 1;
        
        s(1, :) = [0,     0];
        s(2, :) = [sx,    0];
        s(3, :) = [0,    sy];
        s(4, :) = [sx,   sy];
        
    elseif imDim == 3
        
        c       = zeros(imDim, 8);
        d       = zeros(1, 8);
        s       = zeros(8, imDim);
        
        sx = fix(  (n_u(1, 1) - 1)/2  ) + 1;
        sy = fix(  (n_u(1, 2) - 1)/2  ) + 1;
        sz = fix(  (n_u(1, 3) - 1)/2  ) + 1;
        
        s(1, :) = [0,      0,        0];
        s(2, :) = [sx,     0,        0];
        s(3, :) = [0,      sy,       0];
        s(4, :) = [0,      0,       sz];
        s(5, :) = [sx,     sy,       0];
        s(6, :) = [0,      sy,      sz];
        s(7, :) = [sx,     0,       sz];
        s(8, :) = [sx,     sy,      sz];
        
    end
    
    for i = 1:size(s, 1)
        myIm                = circshift(argIm, s(i, :));
        [temp_c, temp_d]    = private_get_c_d(myIm, m, X, Y, Z, R2, imDim);
        c(:, i)             = temp_c;
        d(1, i)             = temp_d;
        
        %         bmImage(myIm)
        %         hold on
        %         plot(c(2, i), c(1, i), 'r.')
        
    end
    
    [myMin, myInd]  = min(d);
    c               = c(:, myInd);
    s               = bmCol(  s(myInd, :)  );
    
    for i = 1:imDim
        c(i, 1) = mod(  c(i, 1) - s(i, 1) - 1, n_u(1, i)   ) + 1;
    end
      
end

end


function [c, d] = private_get_c_d(argIm, m, X, Y, Z, R2, imDim)

imSupport = single(  abs(argIm) > 0  );

d = sum(  R2(:).*imSupport(:), 1)/sum(argIm(:));

argIm = argIm.*m;
im_sum = sum(argIm(:));

if imDim == 2
    c_x = sum(X(:).*argIm(:))/im_sum;
    c_y = sum(Y(:).*argIm(:))/im_sum;
    c = [c_x, c_y].';
elseif imDim == 3
    c_x = sum(X(:).*argIm(:))/im_sum;
    c_y = sum(Y(:).*argIm(:))/im_sum;
    c_z = sum(Z(:).*argIm(:))/im_sum;
    c = [c_x, c_y, c_z].';
end



end