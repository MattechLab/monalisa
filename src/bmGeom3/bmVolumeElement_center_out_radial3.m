% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function v = bmVolumeElement_center_out_radial3(t)

if not(size(t, 1)== 3)
   error('The trajectory must be 3Dim');
   return; 
end

[t, ~, formatedIndex, formatedWeight] = bmTraj_formatTraj(t); 
centerFlag = 0; 
if norm(t(:, 1)) < (100*eps) % ------------------------------------------------ magic number
    centerFlag = true; 
    t = t(:, 2:end); 
end

t       = bmTraj_lineReshape(t);
imDim   = size(t, 1); 
N       = size(t, 2); 
nLine   = size(t, 3); 

e = bmTraj_lineDirection(t); 

% construction of dr ------------------------------------------------------ 
dr = zeros(N, nLine); 
for i = 1:nLine
    dr(:, i) = t(:, :, i)'*e(:, i); 
end
dr = bmVolumeElement1(dr); % Here, the size(dr) must be [N, nLine]


r_1 = zeros(1, 1, size(t, 3)); 
for i = 1:imDim
    r_1 = r_1 + t(i, 1, :).^2;
end
r_1 = sqrt(r_1); 
r_1 = r_1(:)'; 


r_2 = zeros(1, 1, size(t, 3)); 
for i = 1:imDim
    r_2 = r_2 + t(i, 2, :).^2;
end
r_2 = sqrt(r_2); 
r_2 = r_2(:)'; 

if centerFlag
    dr(1, :) = r_2/2;
else
    dr(1, :) = (r_1 + r_2)/2;
end
% END_construction of dr --------------------------------------------------



% construction of ds ------------------------------------------------------
ds = squeeze(4*pi*bmTraj_squaredNorm(t)/nLine); % This is for 3DimRadial.
% END_construction of ds --------------------------------------------------


v = dr(:)'.*ds(:)'; 


% center volume element if exist ------------------------------------------
if centerFlag
    dr_0 = mean(r_1/2, 2);
    v0 = (4/3)*pi*(dr_0^3);
    v = [v0, v(:)'];
end
% END_center volume element if exist --------------------------------------



v = v(:)'; 
v = v(1, formatedIndex(:)').*formatedWeight(:)'; 

end