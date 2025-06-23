function t = bmTraj(mriAcquisition_node)
% t = bmTraj(mriAcquisition_node)
%
% This function computes the k-space sampling trajectory for an MRI acquisition
% based on the specified trajectory type. It acts as a trajectory selector,
% dispatching to the appropriate generation method depending on the value
% of `traj_type` in the input struct.
%
% Supported trajectory types include:
%   - 'full_radial3_phylotaxis': Standard 3D phyllotaxis. See: https://onlinelibrary.wiley.com/doi/full/10.1002/mrm.22898
%   - 'uphy': Uniform phyllotaxis. 
%   - 'flexyphy': Phyllotaxis with randomized polar angles. See:
%   https://submissions.mirasmart.com/ISMRM2025/Itinerary/ConferenceMatrixEventDetail.aspx?ses=O-01
%   (need to add real reference)
%   - 'pulseq': Load trajectory from a Pulseq (.seq) file
%
% The returned trajectory is scaled and shaped for use in reconstruction.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   mriAcquisition_node (struct): A structure containing acquisition parameters.
%   Required fields:
%   - traj_type (string): Type of trajectory to use
%   - imDim (int): Number of spatial dimensions (2 or 3)
%   - nSeg (int): Number of readout segments
%   - nShot (int): Number of shots
%   - N (int): Number of points per readout
%   - selfNav_flag (bool): Whether the first segment is a navigator
%   - nShot_off (int): Number of shots to discard
%   - pulseq_path (string, optional): Path to Pulseq .seq file (required if traj_type = 'pulseq')
%
% Returns:
%   t (array): The normalized k-space trajectory, of shape 
%   [nDim, N, Nlines], where:
%   - nDim: Acquisition dimensionality (2 or 3)
%   - N: Number of points per readout
%   - Nlines: Effective number of lines = (nSeg - selfNav_flag) * (nShot - nShot_off)

% Sanity check and extract trajectory type
assert(isprop(mriAcquisition_node, 'traj_type'), ['Missing required field: ', 'traj_type']);
traj_type       = mriAcquisition_node.traj_type; 

t = []; 

% Trajectory selector: call selected trajectory implementation
if strcmpi(traj_type, 'full_radial3_phylotaxis')
    t = bmTraj_fullRadial3_phyllotaxis_lineAssym2(mriAcquisition_node);
elseif strcmpi(traj_type, 'uphy') %uniform phyllotaxis
    disp('Using the uniform phyllotaxis')
    t = bmTraj_fullRadial3_phyllotaxis_uniform_lineAssym2(mriAcquisition_node);
elseif strcmpi(traj_type, 'flexyphy') %flexyphy: uniform phyllotaxis with polar angle randomization
    disp('Using polar randomization')
    t = bmTraj_fullRadial3_phyllotaxis_random_lineAssym2(mriAcquisition_node);
% If you want to read a trajectory from the .seq pulseq file, use this
elseif strcmpi(traj_type, 'pulseq')
    t = mlTrajFromPulseq(mriAcquisition_node);
else
    error(['bmTraj: Unknown traj_type "' traj_type '". ' ...
           'This probably means your trajectory is not implemented. ' ...
           'You need to implement it yourself.']);
end

end