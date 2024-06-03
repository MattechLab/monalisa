% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This take into account the distance from the origin and the presence of a
% jump. The replacement is not iterative. 
% Having a large radius is a necessary condition for a point to be added as
% problematic. 
%
% This function is for k0- and nonk0- trajectories. 

function out = bmVolumeElement_replace_radial_v2(x, v)

x = bmPointReshape(x); 
v = v(:)'; 

th_factor = 1.5; % ----------------------------------------------------------- magic number

imDim = size(x, 1); 
nPt   = size(x, 2); 
out   = v; 


myProblemMask = isnan(out) | isinf(out) | isempty(out) | not(isnumeric(out)) | (out <= 0);
out(myProblemMask) = -1;


myRadius = zeros(1, nPt); 
for i = 1:imDim
   myRadius = myRadius + x(i, :).^2;  
end
myRadius        = sqrt(myRadius); 
myRadius_max    = max(myRadius(:));
myRadius_min    = min(myRadius(:));
myRadius_half   = (myRadius_max + myRadius_min)/2;
isRadius_L      = (myRadius >= myRadius_half);

myTrajDiff = x(:, 2:end) - x(:, 1:end-1); 
myTrajJump = zeros(1, nPt - 1); 
for i = 1:imDim
    myTrajJump = myTrajJump + myTrajDiff(i, :).^2; 
end
myTrajJump = sqrt(myTrajJump); 
myTrajJump_th = median(myTrajJump)*th_factor; 

myTrajJumpMask_left = (myTrajJump > myTrajJump_th); 
myTrajJumpMask_left = [myTrajJumpMask_left, false]; 
myTrajJumpMask_right = circshift(myTrajJumpMask_left, [0, 1]); 


myProblemMask = (myTrajJumpMask_left | myTrajJumpMask_right) & isRadius_L;  
if isRadius_L(1, 1)
    myProblemMask(1, 1) = true;
end
if isRadius_L(1, end)
    myProblemMask(1, end) = true;
end
if (norm(x(:, 1)) < 10*eps) && (out(1, 1) > 0)
    myProblemMask(1, 1) = false; 
end
out(1, myProblemMask) = -1;



myMask = (out == -1); 

isRadius_L      = (myRadius(myMask) >= myRadius_half);
isRadius_S      = (myRadius(myMask) < myRadius_half);

myRightRadius   = circshift(myRadius, [0, -1]); 
isRightRadius_L = (myRightRadius(myMask) >= myRadius_half);
isRightRadius_S = (myRightRadius(myMask) < myRadius_half);

myLeftRadius    = circshift(myRadius, [0,  1]); 
isLeftRadius_L  = (myLeftRadius( myMask) >= myRadius_half);
isLeftRadius_S  = (myLeftRadius( myMask) < myRadius_half);


myLeftVolume    = circshift(out, [0,  1]);
myLeftVolume    =  myLeftVolume(myMask);

myRightVolume   = circshift(out, [0, -1]);
myRightVolume   = myRightVolume(myMask);


myLeftAccept  = (isRadius_S & isLeftRadius_S)  | (isRadius_L & isLeftRadius_L);
myLeftAccept  = (myLeftAccept & (myLeftVolume > 0)  ); 

myRightAccept = (isRadius_S & isRightRadius_S) | (isRadius_L & isRightRadius_L); 
myRightAccept = (myRightAccept & (myRightVolume > 0)  );


myProblemMask = myLeftAccept + myRightAccept; 
myProblemMask = (myProblemMask == 0); 
if sum(myProblemMask(:) > 0)
    error('In bmVoronoi : some problematic volume elements could not be replaced. ');
    out = []; 
    return; 
end

myReplaceVolume = (myLeftVolume.*myLeftAccept + myRightVolume.*myRightAccept)./(myLeftAccept + myRightAccept);
out(myMask) = myReplaceVolume;

myProblemMask = isnan(out) | isinf(out) | isempty(out) | not(isnumeric(out)) | (out <= 0);
if sum(myProblemMask(:) > 0)
    error('In bmVoronoi : some problematic volume elements could not be replaced. ');
    out = []; 
    return; 
end


end