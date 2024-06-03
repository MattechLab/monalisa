% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTraj_centerOutRadial3_phyllotaxis(nseg, nshot, flagSelfNav, r)

N = size(r(:), 1); 

[polarAngle azimuthalAngle] = phyllotaxis3D_Jean_for_monalisa(nseg, nshot, flagSelfNav, true);
         
azimuthal  = repmat(azimuthalAngle(:)',[N 1]);
polar      = repmat(pi/2-polarAngle(:)',[N 1]);
R          = repmat(r(:),[1 nseg*nshot]);

[x,y,z]    = sph2cart(azimuthal,polar,R);
t = cat(3, x, y, z);
t = permute(t, [3, 1, 2]); 

end 




