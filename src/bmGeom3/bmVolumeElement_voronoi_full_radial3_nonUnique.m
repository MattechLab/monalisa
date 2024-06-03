% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% The strategy adopted here to deal with nonUnique lines is to perturbe 
% randomly a little bit each line in order to separate them. The 
% perturbation is inversely proportional to the magic_number 
% perturbe_factor. 

function v = bmVolumeElement_voronoi_full_radial3_nonUnique(t)

% check -------------------------------------------------------------------
if not(size(t, 1) == 3)
    error('This function is for 3D trajectory only. ');
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
ds = bmSphericalVoronoi_1_nonUnique(t, 'half'); 
ds = repmat(ds, [N, 1]);

ds = ds.*squeeze(bmTraj_squaredNorm(t));
% END_constructing ds -----------------------------------------------------

v = dr(:)'.*ds(:)'; 

% center volume element ---------------------------------------------------
dr_0 = mean(dr(N/2+1, :), 2)/2; 
v(1, N/2+1:N:end) = (4/3)*pi*(dr_0^3)/(2*nLine);
% END_center volume element -----------------------------------------------

end


function v = bmSphericalVoronoi_1_nonUnique(t, half_or_full)

perturbe_factor = 1000; % ------------------------------------------------------- magic number

imDim = size(t, 1); 
N = size(t, 2); 
nLine = size(t, 3); 


s = squeeze(t(:, end, :));
s_norm = zeros(1, size(s, 2));
for i = 1:imDim
    s_norm = s_norm + s(i, :).^2;
end
s_norm = sqrt(s_norm);
s_norm_rep = repmat(s_norm, [size(s, 1), 1]);
s = s./s_norm_rep;

% random_perturbation -----------------------------------------------------

nPoint_s = size(s, 2); 
dS = 0; 
if strcmp(half_or_full, 'half')
    dS = 2*pi/nPoint_s; 
elseif strcmp(half_or_full, 'full')
    dS = 4*pi/nPoint_s; 
end
dL = sqrt(dS)/perturbe_factor; 
if (dL <= eps)
   error('The perturbation is too small'); 
   return; 
end

myRand = 2*(rand(size(s)) - 0.5)*dL; 
s = s + myRand; 

s_norm = zeros(1, size(s, 2));
for i = 1:imDim
    s_norm = s_norm + s(i, :).^2;
end
s_norm = sqrt(s_norm);
s_norm_rep = repmat(s_norm, [size(s, 1), 1]);
s = s./s_norm_rep;

% END_random_perturbation -------------------------------------------------

if strcmp(half_or_full, 'half')
    s = cat(2, s, -s);
end

myIndex = 1:size(s, 2);







temp_mask = s(1, :) >= 0;
s_p1    = s(:, temp_mask);
ind_p1  = myIndex(1, temp_mask);

temp_mask = s(1, :) <= 0;
s_m1    = s(:, temp_mask);
ind_m1  = myIndex(1, temp_mask);




temp_mask = s(2, :) >= 0;
s_p2    = s(:, temp_mask);
ind_p2  = myIndex(1, temp_mask);

temp_mask = s(2, :) <= 0;
s_m2    = s(:, temp_mask);
ind_m2  = myIndex(1, temp_mask);





temp_mask = s(3, :) >= 0;
s_p3    = s(:, temp_mask);
ind_p3  = myIndex(1, temp_mask);

temp_mask = s(3, :) <= 0;
s_m3    = s(:, temp_mask);
ind_m3  = myIndex(1, temp_mask);







v_p1 = bmSphericalVoronoi_2(s_p1(3, :), s_p1(2, :),  s_p1(1, :));
v_m1 = bmSphericalVoronoi_2(s_m1(3, :), s_m1(2, :), -s_m1(1, :));

v_p2 = bmSphericalVoronoi_2(s_p2(3, :), s_p2(1, :),  s_p2(2, :));
v_m2 = bmSphericalVoronoi_2(s_m2(3, :), s_m2(1, :), -s_m2(2, :));

v_p3 = bmSphericalVoronoi_2(s_p3(1, :), s_p3(2, :),  s_p3(3, :));
v_m3 = bmSphericalVoronoi_2(s_m3(1, :), s_m3(2, :), -s_m3(3, :));


v = zeros(6, size(s, 2));
v(1, ind_p1) = v_p1;
v(2, ind_m1) = v_m1;
v(3, ind_p2) = v_p2;
v(4, ind_m2) = v_m2;
v(5, ind_p3) = v_p3;
v(6, ind_m3) = v_m3;
v = v(:, 1:nLine);


myWeight = (v > 0);
v = sum(v, 1)./sum(myWeight, 1);

end




function out = bmSphericalVoronoi_2(s1, s2, s3)

s = cat(1, s1(:)', s2(:)', s3(:)');
nPt = size(s, 2); 
myIndex = 1:nPt; 
myIndex = myIndex(:)'; 


myAngle = acos(1/sqrt(3));
myAngle = (pi/2 - myAngle)/3; 
h1 = sin(1*myAngle);  
h2 = sin(2*myAngle);  
h3 = sin(3*myAngle);  



myMask_1 = (s(3, :) < h1); 
s(:, myMask_1) = []; 
myIndex(:, myMask_1) = []; 

myMask_2 = s(3, :) < h2;
p = s(1:2, :)./repmat(s(3, :), [2, 1]); 


myVoronoi = bmVoronoi(p); 
myVoronoi = myVoronoi(:)'; 
myVoronoi(1, myVoronoi <= 0) = 0; 
myVoronoi(1, myMask_2) = 0;
myVoronoi = myVoronoi.*abs(s(3, :).^3); 

out = zeros(1, nPt); 
out(1, myIndex) = myVoronoi; 



end



