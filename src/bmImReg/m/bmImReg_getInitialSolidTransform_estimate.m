% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function mySolidTransform = bmImReg_getInitialSolidTransform_estimate(imRef, imMov, X, Y, Z)

mySolidTransform = bmImReg_solidTransform; 

n_u         = size(imRef);
n_u         = n_u(:)';
imDim       = size(n_u(:), 1);

imRef       = single(abs(imRef));
imMov       = single(abs(imMov));

[X, Y, Z]   = bmImGrid(n_u, X, Y, Z);

c_mov       = bmCol(  bmImReg_getCenterMass_estimate(imMov, X, Y, Z)  );
c_ref       = bmCol(  bmImReg_getCenterMass_estimate(imRef, X, Y, Z)  );

mySolidTransform.c_ref  = c_ref; 
mySolidTransform.t      = c_mov(:) - c_ref(:); 
mySolidTransform.R      = eye(imDim); 


v           = bmImReg_transform_to_deformField(mySolidTransform, n_u, X, Y, Z); 
imMov       = bmImReg_deform(v, imMov, n_u, X, Y, Z); 
c_mov       = bmCol(  bmImReg_getCenterMass_estimate(imMov, X, Y, Z)  );

m       = bmElipsoidMask(size(imRef), size(imRef)/2); 
imRef   = imRef.*m; 
imMov   = imMov.*m; 

if imDim == 2
    
    [v_ref_1, v_ref_2] = private_vEig2(imRef, X, Y, Z, c_ref);
    [v_mov_1, v_mov_2] = private_vEig2(imMov, X, Y, Z, c_mov);
    R = private_find_rotation2(v_ref_1, v_ref_2, v_mov_1, v_mov_2, imRef, imMov, c_ref, c_mov, X, Y, Z);
    
    % plot ----------------------------------------------------------------
    %     bmImage(imRef)
    %     hold on
    %     plot( [c_ref(2), 100*v_ref_1(2) + c_ref(2)], [c_ref(1), 100*v_ref_1(1) + c_ref(1)], '.-')
    %     plot( [c_ref(2), 100*v_ref_2(2) + c_ref(2)], [c_ref(1), 100*v_ref_2(1) + c_ref(1)], '.-')
    %
    %     bmImage(imMov)
    %     hold on
    %     plot( [c_mov(2), 100*v_mov_1(2) + c_mov(2)], [c_mov(1), 100*v_mov_1(1) + c_mov(1)], '.-')
    %     plot( [c_mov(2), 100*v_mov_2(2) + c_mov(2)], [c_mov(1), 100*v_mov_2(1) + c_mov(1)], '.-')
    % END_plot ------------------------------------------------------------
    
    
    
elseif imDim == 3
    
    [v_ref_1, v_ref_2, v_ref_3] = private_vEig3(imRef, X, Y, Z, c_ref);
    [v_mov_1, v_mov_2, v_mov_3] = private_vEig3(imMov, X, Y, Z, c_mov);
    R = private_find_rotation3(v_ref_1, v_ref_2, v_ref_3, v_mov_1, v_mov_2, v_mov_3, imRef, imMov, c_ref, c_mov, X, Y, Z);
        
end

mySolidTransform.R = R; 

end


function [v_1, v_2] = private_vEig2(argIm, X, Y, Z, c)

n_u = size(c); 
n_u = n_u(:)'; 
imDim = size(n_u(:), 1); 

[X, Y, Z] = bmImGrid(n_u, X, Y, Z); 

X = X - c(1, 1);
Y = Y - c(2, 1);

Ixx =  sum(  (Y(:).^2).*argIm(:) );
Iyy =  sum(  (X(:).^2).*argIm(:) );
Ixy = -sum(  X(:).*Y(:).*argIm(:)  );

I = [
    Ixx, Ixy;
    Ixy, Iyy;
    ];

[v, ev] = eig(I);

v_1 = v(:, 1)/norm(v(:, 1));
v_1 = cat(1, v_1, 0);
v_2 = v(:, 2)/norm(v(:, 2));
v_2 = cat(1, v_2, 0);

myCross = cross(  v_1, v_2  );
myCross = myCross(3);
if myCross < 0
    temp     = v_1;
    v_1  = v_2;
    v_2  = temp;
end

end


function [v_1, v_2, v_3] = private_vEig3(argIm, X, Y, Z, c)

n_u = size(c); 
n_u = n_u(:)'; 
imDim = size(n_u(:), 1); 

[X, Y, Z] = bmImGrid(n_u, X, Y, Z); 

X = X - c(1, 1); 
Y = Y - c(2, 1);
Z = Z - c(3, 1); 

Ixx = sum(  (Y(:).^2 + Z(:).^2).*argIm(:) );
Iyy = sum(  (X(:).^2 + Z(:).^2).*argIm(:) );
Izz = sum(  (X(:).^2 + Y(:).^2).*argIm(:) );

Ixy = -sum(  X(:).*Y(:).*argIm(:)  );
Ixz = -sum(  X(:).*Z(:).*argIm(:)  );
Iyz = -sum(  Y(:).*Z(:).*argIm(:)  );

I = [
    Ixx, Ixy, Ixz;
    Ixy, Iyy, Iyz;
    Ixz, Iyz, Izz;
    ];

[v, ev] = eig(I);

v_1 = v(:, 1)/norm(v(:, 1));
v_2 = v(:, 2)/norm(v(:, 2));
v_3 = v(:, 3)/norm(v(:, 3));

myCross = cross(  v_1, v_2  );
myDiff_1 = norm(myCross - v_3);
myDiff_2 = norm(myCross + v_3);

if myDiff_2 < myDiff_1
    v_3 = -v_3; 
end

end



function R = private_find_rotation2(v_ref_1, v_ref_2, v_mov_1, v_mov_2, imRef, imMov, c_ref, c_mov, X, Y, Z)

R = []; 

n_u         = size(imRef);
n_u         = n_u(:)';
imDim       = size(n_u(:), 1);

R_ref_1 = cat(2,  v_ref_1(:),  v_ref_2(:), [0, 0, 1]');
R_ref_2 = cat(2, -v_ref_1(:), -v_ref_2(:), [0, 0, 1]');

R_mov_1 = cat(2,  v_mov_1(:),  v_mov_2(:), [0, 0, 1]');
R_mov_2 = cat(2, -v_mov_1(:), -v_mov_2(:), [0, 0, 1]');

R1 = R_mov_1*inv(R_ref_1);
R2 = R_mov_1*inv(R_ref_2);
R3 = R_mov_2*inv(R_ref_1);
R4 = R_mov_2*inv(R_ref_2);

R = cat(2, R1(:), R2(:), R3(:), R4(:)); 

myDiff          = repmat(R1(:), [1, 4]) - R;
myDiff          = sqrt(sum(myDiff.^2, 1));
[myMax, myInd]  = max(myDiff);
R1              = R(:, 1);
R2              = R(:, myInd);

R1 = reshape(R1, [3, 3]);
R2 = reshape(R2, [3, 3]);

R1 = R1(1:2, 1:2);
R2 = R2(1:2, 1:2);

s1          = bmImReg_solidTransform;
s1.R        = R1;
s1.t        = [0, 0]';
s1.c_ref    = c_mov;

s2          = bmImReg_solidTransform;
s2.R        = R2;
s2.t        = [0, 0]';
s2.c_ref    = c_mov;

v1 = bmImReg_transform_to_deformField(s1, n_u, X, Y, Z);
v2 = bmImReg_transform_to_deformField(s2, n_u, X, Y, Z);

imDef_1 = bmImReg_deform(v1, imMov, n_u, X, Y, Z);
imDef_2 = bmImReg_deform(v2, imMov, n_u, X, Y, Z);

if sum( (imDef_1(:) - imRef(:)).^2 ) < sum( (imDef_2(:) - imRef(:)).^2 )
    R = R1; 
else
    R = R2;
end


end


function R = private_find_rotation3(v_ref_1, v_ref_2, v_ref_3, v_mov_1, v_mov_2, v_mov_3, imRef, imMov, c_ref, c_mov, X, Y, Z)

    myEps = 1e-4; % ------------------------------------------------------------- magic_number

    R = []; 

    n_u         = size(imRef);
    n_u         = n_u(:)';
    imDim       = size(n_u(:), 1);

    R_ref_1 = cat(2,   v_ref_1(:),   v_ref_2(:),  v_ref_3(:));
    R_ref_2 = cat(2,   v_ref_1(:),  -v_ref_2(:), -v_ref_3(:));
    R_ref_3 = cat(2,  -v_ref_1(:),   v_ref_2(:), -v_ref_3(:));
    R_ref_4 = cat(2,  -v_ref_1(:),  -v_ref_2(:),  v_ref_3(:));

    R_mov_1 = cat(2,   v_mov_1(:),   v_mov_2(:),  v_mov_3(:));
    R_mov_2 = cat(2,   v_mov_1(:),  -v_mov_2(:), -v_mov_3(:));
    R_mov_3 = cat(2,  -v_mov_1(:),   v_mov_2(:), -v_mov_3(:));
    R_mov_4 = cat(2,  -v_mov_1(:),  -v_mov_2(:),  v_mov_3(:));

    R1  = R_mov_1*inv(R_ref_1);
    R2  = R_mov_1*inv(R_ref_2);
    R3  = R_mov_1*inv(R_ref_3);
    R4  = R_mov_1*inv(R_ref_4);
    R5  = R_mov_2*inv(R_ref_1);
    R6  = R_mov_2*inv(R_ref_2);
    R7  = R_mov_2*inv(R_ref_3);
    R8  = R_mov_2*inv(R_ref_4);
    R9  = R_mov_3*inv(R_ref_1);
    R10 = R_mov_3*inv(R_ref_2);
    R11 = R_mov_3*inv(R_ref_3);
    R12 = R_mov_3*inv(R_ref_4);
    R13 = R_mov_4*inv(R_ref_1);
    R14 = R_mov_4*inv(R_ref_2);
    R15 = R_mov_4*inv(R_ref_3);
    R16 = R_mov_4*inv(R_ref_4);

    R = cat(2,  R1(:),  R2(:),  R3(:),  R4(:),  R5(:),  R6(:),  R7(:),  R8(:), ...
                R9(:), R10(:), R11(:), R12(:), R13(:), R14(:), R15(:), R16(:)); 

       myCount = 0; 
       while size(R, 2) > 0
           myCount = myCount + 1; 
           R_list(:, myCount) = R(:, 1);
           myDiff = repmat(   R(:, 1),   [1, size(R, 2)]  ) - R;
           myDiff = sqrt(sum(myDiff.^2, 1));
           myMask = (myDiff > myEps);
           R = R(:, myMask);
       end

       R_list = reshape(  R_list, [3, 3, size(R_list, 2)]  ); 
       
       mySum = zeros(1, size(R_list, 3)); 
       for i = 1:size(R_list, 3)
           s            = bmImReg_solidTransform;
           s.R          = R_list(:, :, i);
           s.t          = [0, 0, 0]';
           s.c_ref      = c_mov;
           
           v            = bmImReg_transform_to_deformField(s, n_u);
           imDef        = bmImReg_deform(v, imMov, n_u, X, Y, Z);
           mySum(1, i)  = sum( (imDef(:) - imRef(:)).^2 ); 
       end

       [myMin, myInd]   = min(mySum); 
        R               = R_list(:, :, myInd); 

end


