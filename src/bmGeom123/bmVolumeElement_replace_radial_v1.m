% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This take into account the distance from the origin and the presence of
% jumps. But not the change of direction. The replacement is iterative. 
% Having a large radius is a necessary condition for a point to be added as
% problematic. 
%
% This function is for k0- and nonk0- trajectories. 
%
% This is suitable for radial. 

function out = bmVolumeElement_replace_radial_v1(x, v)

x = bmPointReshape(x); 
v = v(:)'; 


nIter_max   = 6;   % ---------------------------------------------------------- magic number
th_factor_1 = 2;   % ---------------------------------------------------------- magic number
th_factor_2 = 1.5; % ---------------------------------------------------------- magic number


imDim = size(x, 1); 
nPt   = size(x, 2); 
out   = v; 

% we replace problematic volumes by -1. 
myProblemMask = isnan(out) | isinf(out) | isempty(out) | not(isnumeric(out)) | (out <= 0);
out(myProblemMask) = -1;


% we add other volumes to the list of problematic volumes. 
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
myTrajJump          = sqrt(myTrajJump); 
myTrajJump_median   = median(myTrajJump); 


myRadius_th  = myRadius_max - th_factor_1*myTrajJump_median; 
myRadiusMask = (myRadius >= myRadius_th); 


myProblemMask = myRadiusMask & isRadius_L;  
if isRadius_L(1, 1)
    myProblemMask(1, 1) = true;
end
if isRadius_L(1, end)
    myProblemMask(1, end) = true;
end
% we replace these added problematic volumes by -1. 
out(1, myProblemMask) = -1;

% definition of shifted lists
myRightRadius   = circshift(myRadius, [0, -1]);
myLeftRadius    = circshift(myRadius, [0,  1]);

myTrajJump_th   = myTrajJump_median*th_factor_2;
isJumpRight     = (myTrajJump > myTrajJump_th) & isRadius_L(1, 1:end-1);
isJumpRight     = [isJumpRight, true];
isJumpLeft      = circshift(isJumpRight, [0, 1]);


% we replace all the problematic volumes, the added and the others. 
nIter = 1;
myMask = (out == -1); 
while (sum(myMask(:)) > 0) && nIter <= nIter_max    
    
    myRightVolume   = circshift(out, [0, -1]);
    myRightVolume   =  myRightVolume(myMask);
    myLeftVolume    = circshift(out, [0,  1]);
    myLeftVolume    =  myLeftVolume(myMask);
    
    
    isRadius_L      = (myRadius(myMask) >= myRadius_half);
    isRadius_S      = (myRadius(myMask) < myRadius_half);
    
    isRightRadius_L = (myRightRadius(myMask) >= myRadius_half);
    isRightRadius_S = (myRightRadius(myMask) < myRadius_half);
    
    isLeftRadius_L  = (myLeftRadius( myMask) >= myRadius_half);
    isLeftRadius_S  = (myLeftRadius( myMask) < myRadius_half);
    
    
    isJumpRight_masked = isJumpRight(myMask);
    isJumpLeft_masked  = isJumpLeft(myMask);
    
    
    myLeftAccept  = (isRadius_S & isLeftRadius_S)  | (isRadius_L & isLeftRadius_L);
    myLeftAccept  = myLeftAccept & (myLeftVolume > 0) & not(isJumpLeft_masked);
    
    myRightAccept = (isRadius_S & isRightRadius_S) | (isRadius_L & isRightRadius_L);
    myRightAccept = myRightAccept & (myRightVolume > 0) & not(isJumpRight_masked);
    
    
    
    weightAccept = (myRightAccept + myLeftAccept); 
    zeroAcceptMask = (weightAccept == 0);
    weightAccept(zeroAcceptMask) = 1; 
    
    
    myReplaceVolume = (myLeftVolume.*myLeftAccept + myRightVolume.*myRightAccept)./weightAccept;
    myReplaceVolume(zeroAcceptMask) = -1; 
    out(myMask) = myReplaceVolume;
    myMask = (out < 0); 
    out(myMask) = -1;
    nIter = nIter + 1;
end


myProblemMask = isnan(out) | isinf(out) | isempty(out) | not(isnumeric(out)) | (out <= 0);
if sum(myProblemMask(:) > 0)
    error('In bmVoronoi : some problematic volume elements could not be replaced. ');
    out = []; 
    return; 
end

end