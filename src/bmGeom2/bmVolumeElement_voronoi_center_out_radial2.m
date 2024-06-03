% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function v = bmVolumeElement_voronoi_center_out_radial2(t)

imDim   = size(t, 1);
if not(imDim == 2)
   error('The trajectory must be 2Dim. ');
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



% constructing ds ---------------------------------------------------------
myAngle = angle(complex(  e(1, :), e(2, :)  ));
[myAngle, myPerm]   = sort(myAngle); 
[~,    myInvPerm]   = sort(myPerm);
myAngle = myAngle(:)'; 

myCutSpace    = (pi - myAngle(1, end)) + (myAngle(1, 1) - (-pi)); 
myVoronoi_1   = (myAngle(1, 2) - myAngle(1, 1))/2 + myCutSpace/2;
myVoronoi_end = (myAngle(1, end) - myAngle(1, end-1))/2 + myCutSpace/2;
myAngleVoronoi = bmVoronoi(myAngle(:)'); 
myAngleVoronoi = myAngleVoronoi(:)'; 
myAngleVoronoi(1, 1)    = myVoronoi_1; 
myAngleVoronoi(1, end)  = myVoronoi_end;
myAngleVoronoi = myAngleVoronoi(1, myInvPerm); 
myAngleVoronoi = repmat(myAngleVoronoi, [N, 1]); 

ds = bmTraj_norm(t).*myAngleVoronoi; % This is for 2DimRadial. 
% END_constructing ds -----------------------------------------------------


v = dr(:)'.*ds(:)'; 


% center volume element if exist ------------------------------------------
if centerFlag
    dr_0 = mean(r_1/2, 2);
    v0 = pi*(dr_0^2);
    v = [v0, v(:)'];
end
% END_center volume element if exist --------------------------------------



v = v(:)'; 
v = v(1, formatedIndex(:)').*formatedWeight(:)'; 

end