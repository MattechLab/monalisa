function dataDir = bmLocateTutorialDataDir(monalisaRoot, subFolder)
%BmLocateTutorialDataDir Locate demo data directory from multiple known paths.
%   dataDir = bmLocateTutorialDataDir(monalisaRoot, subFolder)
%   subFolder default is 'data_8_tutorial_1'.

if nargin < 2
    subFolder = 'data_8_tutorial_1';
end

candidates = {
    fullfile(monalisaRoot, 'demo', 'data_demo', subFolder),
    fullfile(monalisaRoot, 'src', 'sparseMat', 'mex', 'data_demo', subFolder),
    fullfile(monalisaRoot, 'demo', 'data_demo', subFolder),
};

% also include neighbors of current script path
candidates{end+1} = fullfile(monalisaRoot, 'demo', 'script_demo', 'script_tutorial_1', '..', '..', 'data_demo', subFolder);

requiredFiles = {'brainScan.dat', 'bodyCoil.dat', 'surfaceCoil.dat'};
for i = 1:numel(candidates)
    cand = candidates{i};
    if all(cellfun(@(f) exist(fullfile(cand, f), 'file') == 2, requiredFiles))
        dataDir = cand;
        return;
    end
end

checkedPaths = strjoin(candidates, newline);
error('bmLocateTutorialDataDir:MissingData', ...
    'Could not locate tutorial data dir "%s". Checked:\n%s', subFolder, checkedPaths);
end