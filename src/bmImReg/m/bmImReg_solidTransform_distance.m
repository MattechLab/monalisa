% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function d = bmImReg_solidTransform_distance(T1, T2, half_imRadius)

c1  = T1.c_ref;
c2  = T2.c_ref;

if norm(c1(:) - c2(:)) > 0
    d = Inf;
    return;
end

t1 = T1.t;
t2 = T2.t;

n = abs(half_imRadius);

imDim = size(t1(:), 1);

if imDim == 2
    
    a1 = T1.R(:, 1)*n;
    a2 = T2.R(:, 1)*n;
    
    p1 = cat(1, t1(:), a1(:));
    p2 = cat(1, t2(:), a2(:));
    
    d = norm(p1(:) - p2(:))/2;
    
elseif imDim == 3
    
    R1 = T1.R;
    R2 = T2.R;
    R = R1*inv(R2);
    dR = norm(bmCol(  (R - eye(imDim))*n  ));
    dt = norm(  t1(:) - t2(:)  ); 
    
    d = sqrt(  (dR^2 + dt^2)/6  ); 
    
end

end