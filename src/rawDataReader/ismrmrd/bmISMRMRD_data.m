function y_raw = bmISMRMRD_data(myData, myMriAcquisition_node)
% y_raw = bmISMRMRD_data(myData, myMriAcquisition_node)
% 
% This function returns the raw MRI data from ISMRMRD file /dataset/data 
% struct based on acquisition parameters.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation)
%
% Parameters:
%   myData (struct): Struct containing MRI data in ISMRMRD style.
%   myMriAcquisition_node (struct): Struct containing acquisition 
%   parameters.
%
% Returns:
%   y_raw (array): Raw MRI data in the [nCh, N, nLine] shape, where nLine
%    is nShot * nSeg, which can change depending on the selfNav_flag and 
%    nShot_off in myMriAcquisition_node. Given in single precision.
%
% Notes:
%   This function reshapes and processes the raw data based on the
%   acquisition parameters such as the number of segments, shots,
%   channels, and echoes. It also handles optional flags for self
%   navigation and ROOSK.
%
% Example:
%   y_raw = bmISMRMRD_data(myData, myMriAcquisition_node);

N               = myMriAcquisition_node.N; 
nSeg            = myMriAcquisition_node.nSeg;  
nShot           = myMriAcquisition_node.nShot;  
nCh             = myMriAcquisition_node.nCh; 
nEcho           = myMriAcquisition_node.nEcho; 
nLine           = myMriAcquisition_node.nLine;

selfNav_flag    = myMriAcquisition_node.selfNav_flag; 
nShot_off       = myMriAcquisition_node.nShot_off; 
roosk_flag      = myMriAcquisition_node.roosk_flag;


% Initialize y
y_raw = complex(zeros([N, nCh, nLine]));

% Extract data
raw_data = myData.data;
for i = 1:nLine
    acq = raw_data{i};
    acq = reshape(acq, [2, N, nCh]); % [complex, N, nCh]
    y_raw(:,:,i) = squeeze(acq(1,:,:) + 1i * acq(2,:,:));
end

% Change data to single precision
y_raw = single(y_raw);

if nEcho == 1
    % Change structure to [nCh, N, nLine] and seperate nLine into nSeg and
    % nShot
    y_raw   = permute(y_raw, [2, 1, 3]);
    y_raw   = reshape(y_raw, [nCh, N, nSeg, nShot]);

    % If a navigation was acquired it should be removed from the rawdata
    % (remove first segment)
    if selfNav_flag 
        y_raw(:, :, 1, :) = [];
        nSeg = nSeg - 1;
    end

    % Remove all shots that were not in steady state
    if nShot_off > 0
        y_raw(:, :, :, 1:nShot_off) = [];
        nShot = nShot - nShot_off;
    end

    % ask Bastien?
    if roosk_flag
        y_raw = y_raw(:, 1:2:end, :, :);
        N = N/2;
    end

    % Reshape the output to [nCh, N, nSeg*nShot]
    y_raw  = reshape(y_raw, [nCh, N, nSeg*nShot]);

elseif nEcho == 2
    error('bmTwix_data : nEcho == 2, case not implemented, yet. But we have to do it for Giulia''s data ! ');
    
else
    error('bmTwix_data : case not implemented. ');
end

end
