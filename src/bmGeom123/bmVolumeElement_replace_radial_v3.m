% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023
 
% This takes into account the presence of jumps if the ditance from the
% origin is large enough. It takes also the non-separation and the change 
% of direction into account. The replacement is iterative. 
%
% Having a large radius is a necessary condition for a point to be added as
% problematic. 
%
% This function is for k0- and nonk0- trajectories. 
%
% This is suitable for radial. 


function out = bmVolumeElement_replace_radial_v3(x, v)

x = bmPointReshape(x); 
v = v(:)'; 

nIter_max = 6;   % ---------------------------------------------------------- magic number
th_n1 = 3.5; % -------------------------------------------------------------- magic number
th_n_de = 1/1000; % --------------------------------------------------------- magic number
myEps = 10*eps; % ----------------------------------------------------------- magic number
delta_separation = myEps/(th_n_de/1000); % ---------------------------------- magic number

imDim   = size(x, 1);
nPt     = size(x, 2);
out   = v; 
myProblemMask = isnan(out) | isinf(out) | isempty(out) | not(isnumeric(out)) | (out <= 0);
out(myProblemMask) = -1;

% radius ------------------------------------------------------------------
myRadius = zeros(1, nPt); 
for i = 1:imDim
   myRadius = myRadius + x(i, :).^2;  
end
myRadius        = sqrt(myRadius); 
myRadius_max    = max(myRadius(:));
myRadius_min    = min(myRadius(:));
myRadius_half   = (myRadius_max + myRadius_min)/2;
isRadius_L      = (myRadius >= myRadius_half);
% END_radius --------------------------------------------------------------



% jump_mask ---------------------------------------------------------------
d1 = x(:, 2:nPt) - x(:, 1:nPt-1);
d1 = [zeros(imDim, 1), d1];
n1 = zeros(1, nPt);
for i = 1:imDim
    n1 = n1 + d1(i, :).^2;
end
n1 = sqrt(n1);
n1(1, 1) = 0;
isJumpLeft    = ( n1(:)' > th_n1*median(n1(:)) ); 
isJumpRight   = circshift(isJumpLeft, [0, -1]);
isJumpLeft    = isJumpLeft  & isRadius_L;
isJumpRight   = isJumpRight & isRadius_L;
% END_jump_mask -----------------------------------------------------------


% nonSeparated_mask -------------------------------------------------------
nonSeparated_mask = (n1 <= delta_separation);
n1(1, nonSeparated_mask) = 1;
for i =1:imDim
    d1(i, nonSeparated_mask) = 0;
end
nonSeparated_mask = nonSeparated_mask | circshift(nonSeparated_mask, [0, -1]);
% END_nonSeparated_mask ---------------------------------------------------


% dirChangeMask -------------------------------------------------------
e  = d1./repmat(n1, [imDim, 1]);
de = e(:, 2:nPt) - e(:, 1:nPt-1);
de(:, 1) = zeros(imDim, 1);
de = [de, zeros(imDim, 1)];
n_de = zeros(1, nPt);
for i = 1:imDim
    n_de = n_de + de(i, :).^2;
end
n_de = sqrt(n_de);
dirChange_mask = (n_de > th_n_de);
% END_dirChangeMask -------------------------------------------------------

% outOfLine_mask ----------------------------------------------------------
outOfLine_mask = (isJumpLeft | isJumpRight | dirChange_mask | nonSeparated_mask);
% END_outOfLine_mask ------------------------------------------------------




% adding problematic values -----------------------------------------------
myProblemMask = outOfLine_mask & isRadius_L;  
if isRadius_L(1, 1)
    myProblemMask(1, 1) = true;
end
if isRadius_L(1, end)
    myProblemMask(1, end) = true;
end
if (norm(x(:, 1)) < myEps) && (out(1, 1) > 0)
    myProblemMask(1, 1) = false; 
end
out(1, myProblemMask) = -1;
myMask = (out == -1); 
% END_adding problematic values -------------------------------------------




% definition of shifted lists
myRightRadius   = circshift(myRadius, [0, -1]);
myLeftRadius    = circshift(myRadius, [0,  1]);



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