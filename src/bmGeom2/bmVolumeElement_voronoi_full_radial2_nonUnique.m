% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% Each line must have the same number of points, say N. The zero must then
% be at index position N/2+1; N must thus be even. 

% The strategy adopted here to deal with nonUnique lines is to perturbe 
% randomly a little bit each line in order to separate them. The 
% perturbation is inversely proportional to the magic_number 
% perturbe_factor. 


function v = bmVolumeElement_voronoi_full_radial2_nonUnique(t, nAverage)

if nAverage > 1
   
    nPt = size(t(:), 1)/size(t, 1); 
    v = zeros(nAverage, nPt); 
    for i = 1:nAverage
       v(i, :) = bmCol(  bmVolumeElement_voronoi_full_radial2_nonUnique(t, 0)  )';  
    end
    v = mean(v, 1); 
    return; 
end

perturbe_factor = 100; % ---------------------------------------------------- magic_number

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

nAngle  = size(myAngle(:), 1); 
dAngle  = 2*pi/nAngle/perturbe_factor; 
myAngle = myAngle + 2*(rand(size(myAngle)) - 0.5)*dAngle; 

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