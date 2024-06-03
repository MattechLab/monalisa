% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% Each line must have the same number of points, say N. The zero must then
% be at index position N/2+1; N must thus be even. 



function v = bmVolumeElement_voronoi_full_radial2(t)

% check -------------------------------------------------------------------
if not(size(t, 1) == 2)
   error('The trajectory must be 2Dim'); 
   return; 
end
% END_check ---------------------------------------------------------------


t       = bmTraj_lineReshape(t);  
imDim   = size(t, 1);
N       = size(t, 2); 
nLine   = size(t, 3); 


e = bmTraj_lineDirection(t); 
if (N/2 - fix(N/2)) > 0
    error(['The number of points per line must be even, because the ', ...
           '0 must be at index position N/2+1']); 
       return; 
end



% constructing dr --------------------------------------------------------- 
dr = zeros(N, nLine); 
for i = 1:nLine
    dr(:, i) = t(:, :, i)'*e(:, i); 
end
dr = bmVolumeElement1(dr); % Here, the size(dr) must be [N, nLine]
% END_constructing dr -----------------------------------------------------


% constructing ds ---------------------------------------------------------
ee = cat(2, e, -e); 
myAngle = angle(complex(  ee(1, :), ee(2, :)  ));
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
myAngleVoronoi = myAngleVoronoi(1, 1:nLine); 
myAngleVoronoi = repmat(myAngleVoronoi, [N, 1]); 

ds = squeeze(bmTraj_norm(t)).*myAngleVoronoi; % This is for 2DimRadial. 

% END_constructing ds -----------------------------------------------------

v = dr(:)'.*ds(:)'; 


% center volume element ---------------------------------------------------
dr_0 = dr(N/2+1, :); 
dr_0 = mean(dr_0(:), 1)/2; 
v0 = pi*(dr_0^2)/(2*nLine); 
v(1, N/2+1:N:end) = v0; 
% END_center volume element -----------------------------------------------


end