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
%
% Parameters:
%   mriAcquisition_node (struct): A struct that must contain the field
%   'pulseq_path' pointing to the Pulseq sequence file (filename.seq)
%
% Returns:
%   t (array): Normalized trajectory array of shape [N, nSeg, nShot, 3],
%   scaled to have maximum absolute value of 0.5

% 1) Assert existence of non-empty field 'pulseq_path'
assert(isprop(mriAcquisition_node, 'pulseqTrajFile_name') && ...
       ~isempty(mriAcquisition_node.pulseqTrajFile_name), ...
       'mriAcquisition_node must contain a non-empty field ''pulseqTrajFile_name''.');

% 2) Assert that Pulseq toolbox is available on MATLAB path
assert(exist('mr.Sequence', 'class') == 8, ...
       'Pulseq toolbox not found. Please ensure it is added to the MATLAB path.');

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
nShot_off = mriAcquisition_node.nShot_off; 
flagSelfNav = mriAcquisition_node.selfNav_flag;

k_trj = reshape(kspace_traj, [size(kspace_traj,1), N, nSeg, nShot]);



% 8) Permute to [3,N, nSeg, nShot]
%k_trj = permute(k_trj, [2, 3, 4, 1]);

% 9) Filter out SI projections and non steady state readouts
if flagSelfNav
   k_trj(:, :, 1, :) = [];  
end
if nShot_off > 0
   k_trj(:, :, :, 1:nShot_off) = [];  
end

% 10) Normalize to max amplitude 0.5
R = max(abs(k_trj(:)));
t = k_trj / R * 0.5;

% 11) Resize to shape [3, N, (nSeg - flagselfnav) * (nShot - nshotoff)] considering nShot_off and flagSelfNav
% Resize to shape [3, N, nSeg, nShot] considering nShot_off and flagSelfNav
mySize = size(t); 
mySize = mySize(:)'; 
t = reshape(t, [mySize(1, 1), mySize(1, 2), mySize(1, 3)*mySize(1, 4)]); 

end
