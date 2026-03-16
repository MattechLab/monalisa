function save_parity_snapshot(rootDir, scriptName, stepIndex, stepName, dataStruct, extraMeta)
%SAVE_PARITY_SNAPSHOT Save rich parity information for Python comparison.
%   SAVE_PARITY_SNAPSHOT(ROOTDIR, SCRIPTNAME, STEPINDEX, STEPNAME, DATASTRUCT, EXTRAMETA)
%   writes a snapshot containing:
%     - data.mat  : MATLAB struct with fields from DATASTRUCT
%     - meta.json : JSON metadata describing the snapshot and run context
%
%   ROOTDIR    : root directory where the "parity" folder will be created.
%   SCRIPTNAME : logical name of the entry-point script (e.g. 'coilSensitivityEstimation').
%   STEPINDEX  : integer index to keep a stable, ordered sequence of snapshots.
%   STEPNAME   : short identifier for the snapshot within the script (e.g. 'coil_sensitivity_final').
%   DATASTRUCT : struct whose fields are the arrays/variables to export.
%   EXTRAMETA  : (optional) struct with additional metadata fields to merge into meta.json.
%
%   The on-disk layout is:
%     ROOTDIR/parity/SCRIPTNAME/<STEPINDEX>_<STEPNAME>/
%       data.mat
%       meta.json

if nargin < 6
    extraMeta = struct();
end

if ~isstruct(dataStruct)
    error('save_parity_snapshot:InvalidData', 'DATASTRUCT must be a struct.');
end

parityRoot = fullfile(rootDir, 'parity', scriptName);
if ~exist(parityRoot, 'dir')
    mkdir(parityRoot);
end

stepFolder = sprintf('%04d_%s', stepIndex, stepName);
snapshotDir = fullfile(parityRoot, stepFolder);
if ~exist(snapshotDir, 'dir')
    mkdir(snapshotDir);
end

% Save raw numeric data in a single MAT-file
dataFile = fullfile(snapshotDir, 'data.mat');
save(dataFile, '-struct', 'dataStruct', '-v7');

% Build metadata struct
meta = struct();
meta.version = 1;
meta.script_name = scriptName;
meta.step_index = stepIndex;
meta.step_name = stepName;
meta.timestamp = datestr(now, 'yyyy-mm-ddTHH:MM:SS.FFF');

% MATLAB and environment information
meta.matlab_version = version;
meta.platform = computer;

% Try to capture git information if available (best-effort)
try
    [st, hash] = system('git rev-parse HEAD');
    if st == 0
        meta.git_commit = strtrim(hash);
    end
catch
    % ignore git errors
end

% Variable-level metadata: names and sizes
varNames = fieldnames(dataStruct);
varMeta = struct('name', {}, 'size', {});
for k = 1:numel(varNames)
    vn = varNames{k};
    val = dataStruct.(vn);
    vm = struct();
    vm.name = vn;
    vm.size = size(val);
    varMeta(end+1) = vm; %#ok<AGROW>
end
meta.variables = varMeta;

% Merge user-provided metadata
userFields = fieldnames(extraMeta);
for k = 1:numel(userFields)
    fn = userFields{k};
    meta.(fn) = extraMeta.(fn);
end

% Write JSON metadata
metaFile = fullfile(snapshotDir, 'meta.json');
jsonText = jsonencode(meta, 'PrettyPrint', true);
fid = fopen(metaFile, 'w');
if fid < 0
    error('save_parity_snapshot:IOError', 'Failed to open %s for writing.', metaFile);
end
cleaner = onCleanup(@() fclose(fid));
fwrite(fid, jsonText, 'char');

fprintf('save_parity_snapshot: saved snapshot in %s\n', snapshotDir);

