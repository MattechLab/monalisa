function t = mlTrajFromPulseq(mriAcquisition_node)
% t = mlTrajFromPulseq(mriAcquisition_node)
%
% This function generates a k-space trajectory from a Pulseq sequence file.
%
% Authors:
%   Mauro Leidi
%   HES-SO
%   May 2025
%
%   Yiwei Jia
%   extract traj from pulseq seq file
%   fixed the mismatch between pulseq and monalisa
%   July 2025
%
% Parameters:
%   mriAcquisition_node (struct): A struct that must contain the field
%   'pulseq_path' pointing to the Pulseq sequence file (filename.seq)
%
% Returns:
%   t (array): Normalized trajectory array of shape [3, N, nSeg, nShot],
%   scaled to have maximum absolute value of 0.5*N*dk

% 1) Assert existence of non-empty field 'pulseq_path'
assert(isprop(mriAcquisition_node, 'pulseqTrajFile_name') && ...
       ~isempty(mriAcquisition_node.pulseqTrajFile_name), ...
       'mriAcquisition_node must contain a non-empty field ''pulseqTrajFile_name''.');

% 2) Assert that Pulseq toolbox is available on MATLAB path
assert(exist('mr.Sequence', 'class') == 8, ...
       'Pulseq toolbox not found. Please ensure it is added to the MATLAB path.');
warning('Extracting the trajectory from pulse sequence file....')
% 3) Create sequence object
seq = mr.Sequence();

% 4) Read the Pulseq sequence file
seq.read(mriAcquisition_node.pulseqTrajFile_name);

% 5) Calculate k-space trajectory
kspace_traj = seq.calculateKspacePP();

% 6) Reshape to [3, N, nSeg, nShot]
nSeg            = mriAcquisition_node.nSeg; 
nShot           = mriAcquisition_node.nShot; 
N               = mriAcquisition_node.N; 
FoV             = mriAcquisition_node.FoV; 
nShot_off = mriAcquisition_node.nShot_off; 
flagSelfNav = mriAcquisition_node.selfNav_flag;


k_trj = reshape(kspace_traj, [size(kspace_traj,1), N, nSeg, nShot]);

% 7) Normalize the trajectory 
%   before eliminating non-steady state shots and self navigation segs
%   to match the calculation with monalisa bmTraj*
%   scale the range to [-0.5, 0.5-1/N] --> scale up to 0.5*N*dK == 0.5*N/FoV

% compute distances from the k space center for each sampled point
distances = vecnorm(k_trj, 2,1);
% R: the maximum distance of the point from the trajectory in k-space to
% the center
R = max(distances(:));
k_trj = k_trj/R*0.5*N/FoV;

% 9) Filter out SI projections and non steady state readouts
if flagSelfNav
   k_trj(:, :, 1, :) = [];  
end
if nShot_off > 0
   k_trj(:, :, :, 1:nShot_off) = [];  
end


% 11) Resize to shape [3, N, (nSeg - flagselfnav) * (nShot - nshotoff)] considering nShot_off and flagSelfNav
% Resize to shape [3, N, nSeg, nShot] considering nShot_off and flagSelfNav
mySize = size(k_trj); 
mySize = mySize(:)'; 
t = reshape(k_trj, [mySize(1, 1), mySize(1, 2), mySize(1, 3)*mySize(1, 4)]); 

end
