% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% Each line must have the same number of points, say N. The zero must then
% be at index position N/2+1; N must thus be even. 

function v = bmVolumeElement_full_radial3(t)


if not(size(t, 1) == 3)
   error('The trajectory must be 3Dim. ');
   return; 
end


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
    ds = squeeze(4*pi*bmTraj_squaredNorm(t)/(2*nLine)); % This is for 3DimRadial.
% END_constructing dr -----------------------------------------------------

v = dr(:)'.*ds(:)'; 

% center volume element ---------------------------------------------------
dr_0 = mean(dr(N/2+1, :), 2)/2; 
v0 = (4/3)*pi*(dr_0^3)/(2*nLine);
v(1, N/2+1:N:end) = v0; 
% END_center volume element -----------------------------------------------


end