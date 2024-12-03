function varargout = bmCoilSense_nonCart_dataFromTwix(argFile, N_u, N, nSeg, nShot, nCh, FoV, nShotOff)
% varargout = bmCoilSense_nonCart_dataFromTwix(argFile, N_u, N, nSeg, ...
%   nShot, nCh, FoV, nShotOff)
%
% This function constraints data from a non cartesian 3D radial trajectory 
% to fit into the given cartesian grid, adapting the resolution of the 
% image. The data is read from a a Siemens' raw data file. It is assumed 
% that the acquisition is done with self navigation
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   argFile (char): String containing the path to the file which contains
%   the Twix object.
%   N_u (1D array): Contains the size of the grid for every dimension
%   N (int): Number of points per segment
%   nSeg (int): Number of segments per shot
%   nShot (int): Number of shots per acquisition
%   nCh (int): Number of channels / coils
%   FoV (1D array): Contains acquisition FoV (image space)
%   nShotOff (int): Number of shots to be discarded from the start
%
% Returns (optional):
%   varargout{1} (y): 2D array containing the raw MRI data from the twix 
%   object. The size is [#points, nCh].
%   varargout{2} (t): 2D array containing points of the trajectory in the 
%   k-space. The size is [3, #points].
%   varargout{3} (ve): Array containing the volume elements for every point 
%   of the trajectory.

% We can have a general function bmCoilSense_nonCart_dataFromTwix that can
% be called for several trajectory types.

% Extract twix object
myTwix      = bmTwix(argFile);  
dK_u_raw    = [1, 1, 1]./FoV;  

% Create object to better transfer the variables
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

% Extract rawdata
y = bmTwix_data(myTwix, myMriAcquisition_node);

% Compute trajectory and express it as points in 3 dimensions [3, #points]
% Maybe we can input as argument the trajectory to avoid the call
% bmTraj_fullRadial3_phyllotaxis_lineAssym2 that assumes a trajectory type
t = bmPointReshape(...
    bmTraj_fullRadial3_phyllotaxis_lineAssym2(myMriAcquisition_node));

% Compute volume elements if third output is required
if (nargout ==  1) || (nargout == 2)
    ve      = ones(1, size(t, 2));
elseif nargout == 3
    ve      = bmVolumeElement(t, 'voronoi_full_radial3');
end

% Only keep data in a box to keep the frequencies for lower resolution 
[y, t, ve]  = bmLowRes(y, t, ve, N_u, dK_u_raw);
y           = bmPermuteToCol(y); 

% Return data if required
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