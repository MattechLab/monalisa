function save_parity_snapshot(rootDir, scriptName, stepIndex, stepName, dataStruct, extraMeta)
%SAVE_PARITY_SNAPSHOT Save parity data for cross-fork / Python comparison.
%   Writes under ROOTDIR/parity/SCRIPTNAME/<STEPINDEX>_<STEPNAME>/:
%     - fingerprints.json : SHA-256 per variable (stable layout; see below)
%     - meta.json         : run metadata (unchanged fields + parity policy info)
%     - data.mat          : optional small variables only (see policy)
%
%   Environment (optional):
%     MONALISA_PARITY_MAT_POLICY = split | full | off
%         split (default) — variables larger than the byte budget are stored
%             only as hashes; smaller ones go into data.mat
%         full — entire DATASTRUCT saved in data.mat (legacy; can be huge)
%         off  — hashes only, no MAT file
%     MONALISA_PARITY_MAX_VARIABLE_BYTES — per-variable byte budget for split
%         (default 52428800 ≈ 50 MiB). Non-finite or <=0 falls back to default.
%     MONALISA_PARITY_MAX_MAT_TOTAL_BYTES — split: total MAT byte budget (uncompressed est.)
%         for all variables included in data.mat (default 47185920 ≈ 45 MiB).
%     MONALISA_PARITY_GZIP = 0 | 1 — gzip data.mat when 1 (default 1)
%
%   Fingerprint rules (for reimplementation in Python/NumPy):
%     - real numeric: typecast of column vector val(:) to uint8 (column-major)
%     - complex: [real(val(:)); imag(val(:))] as typecast uint8
%     - logical: uint8(val(:))
%     - cell: recursive fingerprints joined with "|", then hash the UTF-8/ASCII string
%   NumPy: use the same raw layout as MATLAB's column-major storage (order='F').
%
%   Fingerprints are bitwise: tiny floating-point differences (BLAS/threading)
%   across machines can change hashes even when results are "almost equal".
%
%   See also: generate_parity_data, parityFingerprintVariable

if nargin < 6
    extraMeta = struct();
end

if ~isstruct(dataStruct)
    error('save_parity_snapshot:InvalidData', 'DATASTRUCT must be a struct.');
end

policy = getenv('MONALISA_PARITY_MAT_POLICY');
if isempty(policy)
    policy = 'split';
end
maxVarStr = getenv('MONALISA_PARITY_MAX_VARIABLE_BYTES');
if isempty(maxVarStr)
    maxVarBytes = 50 * 1024 * 1024;
else
    maxVarBytes = str2double(maxVarStr);
    if ~isfinite(maxVarBytes) || maxVarBytes <= 0
        maxVarBytes = 50 * 1024 * 1024;
    end
end
maxTotalStr = getenv('MONALISA_PARITY_MAX_MAT_TOTAL_BYTES');
if isempty(maxTotalStr)
    maxTotalBytes = 45 * 1024 * 1024;
else
    maxTotalBytes = str2double(maxTotalStr);
    if ~isfinite(maxTotalBytes) || maxTotalBytes <= 0
        maxTotalBytes = 45 * 1024 * 1024;
    end
end
maxFileStr = getenv('MONALISA_PARITY_MAX_FILE_BYTES');
if isempty(maxFileStr)
    maxFileBytes = 50 * 1024 * 1024;
else
    maxFileBytes = str2double(maxFileStr);
    if ~isfinite(maxFileBytes) || maxFileBytes <= 0
        maxFileBytes = 50 * 1024 * 1024;
    end
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

% Remove any previously generated MAT artifacts so we don't accidentally
% keep old huge blobs that violate GitHub file size limits.
matBase = fullfile(snapshotDir, 'data.mat');
if exist(matBase, 'file')
    delete(matBase);
end
matGz = fullfile(snapshotDir, 'data.mat.gz');
if exist(matGz, 'file')
    delete(matGz);
end

varNames = fieldnames(dataStruct);
fpRoot = struct('version', 1, 'script_name', scriptName, ...
    'step_index', stepIndex, 'step_name', stepName, 'variables', []);
fpList = [];
inMat = {};
fpOnly = {};
smallStruct = struct();
totalEstBytes = 0;

for k = 1:numel(varNames)
    vn = varNames{k};
    val = dataStruct.(vn);
    fpEntry = parityFingerprintVariable(vn, val);
    if isempty(fpList)
        fpList = fpEntry;
    else
        fpList = [fpList; fpEntry];
    end
    est = parityEstimateVariableBytes(val);
    includeInMat = false;
    switch lower(strtrim(policy))
        case 'full'
            includeInMat = true;
        case 'off'
            includeInMat = false;
        case 'split'
            includeInMat = est <= maxVarBytes && (totalEstBytes + est) <= maxTotalBytes;
        otherwise
            warning('save_parity_snapshot:UnknownPolicy', ...
                'Unknown MONALISA_PARITY_MAT_POLICY "%s"; using split.', policy);
            includeInMat = est <= maxVarBytes && (totalEstBytes + est) <= maxTotalBytes;
    end
    if includeInMat
        smallStruct.(vn) = val;
        inMat{end+1} = vn; %#ok<AGROW>
        totalEstBytes = totalEstBytes + est;
    else
        fpOnly{end+1} = vn; %#ok<AGROW>
    end
end
fpRoot.variables = fpList;

fpFile = fullfile(snapshotDir, 'fingerprints.json');
fid = fopen(fpFile, 'w');
if fid < 0
    error('save_parity_snapshot:IOError', 'Failed to open %s for writing.', fpFile);
end
cleanerFp = onCleanup(@() fclose(fid));
fwrite(fid, jsonencode(fpRoot, 'PrettyPrint', true), 'char');

meta = struct();
meta.version = 1;
meta.script_name = scriptName;
meta.step_index = stepIndex;
meta.step_name = stepName;
meta.timestamp = datestr(now, 'yyyy-mm-ddTHH:MM:SS.FFF');
meta.matlab_version = version;
meta.platform = computer;
meta.hostname = char(java.net.InetAddress.getLocalHost.getHostName);
meta.parity_mat_policy = policy;
meta.parity_max_variable_bytes = maxVarBytes;
meta.variables_in_mat = inMat;
meta.variables_fingerprint_only = fpOnly;
meta.parity_fingerprints_file = 'fingerprints.json';

try
    [st, hash] = system('git rev-parse HEAD');
    if st == 0
        meta.git_commit = strtrim(hash);
    end
catch
end
try
    [stBranch, branchName] = system('git rev-parse --abbrev-ref HEAD');
    if stBranch == 0
        meta.git_branch = strtrim(branchName);
    end
catch
end
try
    [stDirty, dirtyOut] = system('git status --porcelain');
    if stDirty == 0
        meta.git_dirty_worktree = ~isempty(strtrim(dirtyOut));
    end
catch
end
meta.monalisa_env = collectMonalisaEnv();

varMeta = struct('name', {}, 'size', {}, 'bytes_estimate', {}, 'storage', {}, 'fingerprint_sha256', {});
for k = 1:numel(varNames)
    vn = varNames{k};
    val = dataStruct.(vn);
    vm = struct();
    vm.name = vn;
    vm.size = size(val);
    vm.bytes_estimate = parityEstimateVariableBytes(val);
    if ismember(vn, inMat)
        vm.storage = 'mat';
    else
        vm.storage = 'fingerprint_only';
    end
    % fpList is built in the same order as varNames.
    vm.fingerprint_sha256 = fpList(k).sha256;
    varMeta(end+1) = vm; %#ok<AGROW>
end
meta.variables = varMeta;

% Also keep the full fingerprint list inside meta.json so that the snapshot
% is self-contained for comparison tooling that only reads meta.json.
meta.parity_fingerprints = fpList;

userFields = fieldnames(extraMeta);
for k = 1:numel(userFields)
    fn = userFields{k};
    meta.(fn) = extraMeta.(fn);
end

matBase = fullfile(snapshotDir, 'data.mat');
if ~isempty(fieldnames(smallStruct))
    save(matBase, '-struct', 'smallStruct', '-v7');
    d = dir(matBase);
    if ~isempty(d) && d.bytes > maxFileBytes
        delete(matBase);
        meta.data_file = '';
        % The MAT blob cannot be stored (size limit). Make metadata
        % reflect that everything is fingerprint-only.
        matVars = inMat;
        fpOnly = unique([fpOnly, matVars]);
        inMat = {};
        meta.variables_in_mat = inMat;
        meta.variables_fingerprint_only = fpOnly;
    else
        meta.data_file = 'data.mat';
    end
else
    meta.data_file = '';
end

metaFile = fullfile(snapshotDir, 'meta.json');
fid2 = fopen(metaFile, 'w');
if fid2 < 0
    error('save_parity_snapshot:IOError', 'Failed to open %s for writing.', metaFile);
end
cleanerMeta = onCleanup(@() fclose(fid2));
fwrite(fid2, jsonencode(meta, 'PrettyPrint', true), 'char');

fprintf('save_parity_snapshot: saved snapshot in %s (mat policy=%s, mat variables=%d)\n', ...
    snapshotDir, policy, numel(inMat));
end

function envStruct = collectMonalisaEnv()
%COLLECTMONALISAENV Capture MONALISA_* env vars for run reproducibility.
envStruct = struct();
try
    envRaw = getenv();
    if isstruct(envRaw)
        names = fieldnames(envRaw);
        for i = 1:numel(names)
            key = names{i};
            if startsWith(key, 'MONALISA_')
                envStruct.(key) = envRaw.(key);
            end
        end
    end
catch
    % Best effort only.
end
end
