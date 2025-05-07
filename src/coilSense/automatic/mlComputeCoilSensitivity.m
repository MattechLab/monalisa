function C = mlComputeCoilSensitivity(BCreader, HCreader, CoilSensitivityFrameSize, autoFlag, nIter)
% mlComputeCoilSensitivity computes the coil sensitivity map using 
% prescan acquisitions from body and surface coils.
%
% This function assumes the rawDataReaders are ready to be used
%
% This function estimates the coil sensitivity profiles of the surface 
% coils using body coil data as a reference. The estimation process 
% is too complex to be described here. Detailed description can be found
% int the Monalisa original paper.
%
% Authors:
%   Mauro Leidi
%   HES-SO
%   Lausanne - Switzerland
%   May 2025
%
% Parameters:
%   BCreader (struct): Acquisition reader object for the body coil prescan
%   HCreader (struct): Acquisition reader object for the surface coil prescan
%   CoilSensitivityFrameSize (1x3 array, optional): Size of the frame 
%       used for sensitivity estimation (e.g., [48, 48, 48]). Default is [48, 48, 48].
%   autoFlag (bool, optional): Flag to enable automatic mask generation.
%       If true, automatic masking is applied. Default is true.
%   nIter (int, optional): Number of iterations for coil sensitivity refinement.
%       Default is 5.
%
% Returns:
%   C (array): Estimated coil sensitivity map

% Set default frame size if not provided
if nargin < 3 || isempty(CoilSensitivityFrameSize)
    CoilSensitivityFrameSize = [48, 48, 48];
end

% Set default for automatic masking flag
if nargin < 4 || isempty(autoFlag)
    autoFlag = true;
end

% Set default number of refinement iterations
if nargin < 5 || isempty(nIter)
    nIter = 5;
end

% Step 1: Load non-Cartesian body coil data
[y_body, t, ve] = bmCoilSense_nonCart_data(BCreader, CoilSensitivityFrameSize);

% Step 2: Load non-Cartesian surface coil data
y_surface = bmCoilSense_nonCart_data(HCreader, CoilSensitivityFrameSize);

% Step 3: Compute k-space sampling step size from body coil FoV
dK_u = [1, 1, 1] ./ BCreader.acquisitionParams.FoV;

% Step 4: Build sparse system matrices for reconstruction
[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, CoilSensitivityFrameSize, dK_u);

% Step 5: Automatically generate a binary mask for reliable regions
mask = bmCoilSense_nonCart_mask_automatic(y_body, Gn, autoFlag);

% Step 6: Estimate reference image and sensitivity from body coil
[y_ref, C_ref] = bmCoilSense_nonCart_ref(y_body, Gn, mask, []);

% Step 7: Estimate primary surface coil sensitivities
C_array_prime = bmCoilSense_nonCart_primary(y_surface, y_ref, C_ref, Gn, ve, mask);

% Step 8: Refine coil sensitivities using iterative optimization
[C, ~] = bmCoilSense_nonCart_secondary(y_surface, C_array_prime, y_ref, C_ref, Gn, Gu, Gut, ve, nIter, false);

end
