function varargout = bmCoilSense_nonCart_data(reader, N_u)
% varargout = bmCoilSense_nonCart_data(reader, N_u)
%
% This function constraints non cartesian raw data to fit into a given Box centered 
% at the k-space center of size N_u*dK_u, effectively adapting the resolution of the reconstructed image. 
% N_u is the input parameter, while dK_u is estimated from the reader MriAcquisitionNode FOV.
% For more information about why Keeping the central regions, corresponds to lowering the image resolution,
% visit: https://mriquestions.com/field-of-view-fov.html
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   Mauro Leidi (Code adaptation)
%
% Parameters:
%   reader (RawDataReader): Object to parse the file which 
%   contains the data.
%   N_u (List): Contains the size of the grid for every dimension.
%
% Returns (optional):
%   varargout{1} (y): 2D array containing the raw MRI data from the ISMRMRD 
%   file. The size is [#points, nCh].
%   varargout{2} (t): 2D array containing points of the trajectory in the 
%   k-space. The size is [3, #points].
%   varargout{3} (ve): Array containing the volume elements for every point 
%   of the trajectory.

% We can have a general function bmCoilSense_nonCart_dataFromTwix that can
% be called for several trajectory types.

%% Get raw data
myMriAcquisition_node = reader.acquisitionParams;
% Define grid spaceing from acquisition FoV
dK_u_raw    = [1, 1, 1]./myMriAcquisition_node.FoV;

% Extract rawdata
y = reader.readRawData(true,true);

% Compute trajectory and express it as points in 3 dimensions [3, #points]
t = bmTraj(myMriAcquisition_node);
t = bmPointReshape(t);


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