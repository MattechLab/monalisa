% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmCoilSense_nonCart_dataFromTwix(argFile, N_u, N, nSeg, nShot, nCh, FoV, nShotOff)
% The result of this function is the rawdata, the trajectory point t=(x,y,z) (3,Npoints) and the volume elements 
% Maybe we can input as argument the trajectory to avoid the call
% bmTraj_fullRadial3_phyllotaxis_lineAssym2 that assumes a trajectory type
% We can have a general function bmCoilSense_nonCart_dataFromTwix that can
% be called for several trajectory types.

myTwix      = bmTwix(argFile);  
dK_u_raw    = [1, 1, 1]./FoV;  


myMriAcquisition_node                = bmMriAcquisitionParam([]); 
myMriAcquisition_node.N              = N; 
myMriAcquisition_node.nSeg           = nSeg; 
myMriAcquisition_node.nShot          = nShot;
myMriAcquisition_node.FoV            = FoV; 
myMriAcquisition_node.nCh            = nCh; 
myMriAcquisition_node.nEcho          = 1; 

myMriAcquisition_node.selfNav_flag   = true; 
myMriAcquisition_node.nShot_off      = nShotOff; 
myMriAcquisition_node.roosk_flag     = false; 

% extract rawdata
y = bmTwix_data(myTwix, myMriAcquisition_node);
% compute trajectory
t = bmPointReshape(bmTraj_fullRadial3_phyllotaxis_lineAssym2(myMriAcquisition_node));

% compute volume elements
if (nargout ==  1) || (nargout == 2)
    ve      = ones(1, size(t, 2));
elseif nargout == 3
    ve      = bmVolumeElement(t, 'voronoi_full_radial3');
end

% keep only data in a box to keep the frequencies for lower resolution 
[y, t, ve]  = bmLowRes(y, t, ve, N_u, dK_u_raw);
y           = bmPermuteToCol(y); 

    
if nargout > 0 
    varargout{1}    = y;
end
if nargout > 1
    varargout{2}    = t;
end
if nargout > 2
    varargout{3}    = ve;
end

    
end