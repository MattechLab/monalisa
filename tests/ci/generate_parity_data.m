function generate_parity_data()
%GENERATE_PARITY_DATA Run tutorial scripts and export rich parity snapshots.
%   This function is intended to be called from CI / pre-push hooks. It:
%     1) Ensures tutorial data is downloaded.
%     2) Runs all tutorial_1 scripts (coil sensitivity, binning, mitosius prep,
%        and reconstructions) which call save_parity_snapshot at key steps.
%     3) Stores structured parity datasets under <monalisaRoot>/parity.
%
%   Scripts are run via RUN in the base workspace; after each script this
%   function clears the base workspace to avoid retaining large arrays and
%   multiplying peak memory usage across steps.
%
%   Environment:
%     MONALISA_GENERATE_PARITY_STEPS — optional comma-separated subset, e.g.
%       "coil,binnings" to skip heavy steps (mitosius,recon) on low-RAM machines.
%       Default: all steps (coil,binnings,mitosius,recon).

thisFile = mfilename('fullpath');
testsDir = fileparts(thisFile);
monalisaRoot = fileparts(fileparts(testsDir));

addpath(genpath(fullfile(monalisaRoot, 'src')));
addpath(genpath(fullfile(monalisaRoot, 'demo')));
addpath(genpath(fullfile(monalisaRoot, 'tests')));

% Ensure data is downloaded using tutorial helper (idempotent if already present)
% try
%     run(fullfile(monalisaRoot, 'demo', 'data_demo', 'data_8_tutorial_1', 'downloadData.m'));
% catch ME
%     warning('generate_parity_data:downloadDataFailed', 'downloadData.m failed: %s', ME.message);
% end

stepsEnv = lower(strtrim(getenv('MONALISA_GENERATE_PARITY_STEPS')));
if isempty(stepsEnv)
    steps = {'coil', 'binnings', 'mitosius', 'recon'};
else
    steps = strtrim(strsplit(stepsEnv, ','));
    steps = cellfun(@strtrim, steps, 'UniformOutput', false);
    steps = steps(~cellfun('isempty', steps));
end

% Run tutorial scripts with built-in parity snapshot export
if ismember('coil', steps)
    try
        run(fullfile(monalisaRoot, 'demo', 'script_demo', 'script_tutorial_1', 'coilSensitivityEstimation_script.m'));
    catch ME
        warning('generate_parity_data:tutorialFailed', 'Tutorial script failed: %s', ME.message);
    end
    evalin('base', 'clear');
end

if ismember('binnings', steps)
    try
        run(fullfile(monalisaRoot, 'demo', 'script_demo', 'script_tutorial_1', 'binnings_script.m'));
    catch ME
        warning('generate_parity_data:binningsFailed', 'binnings_script.m failed: %s', ME.message);
    end
    evalin('base', 'clear');
end

if ismember('mitosius', steps)
    try
        run(fullfile(monalisaRoot, 'demo', 'script_demo', 'script_tutorial_1', 'mitosius_script.m'));
    catch ME
        warning('generate_parity_data:mitosiusFailed', 'mitosius_script.m failed: %s', ME.message);
    end
    evalin('base', 'clear');
end

if ismember('recon', steps)
    try
        run(fullfile(monalisaRoot, 'demo', 'script_demo', 'script_tutorial_1', 'reconstructions_script.m'));
    catch ME
        warning('generate_parity_data:reconFailed', 'reconstructions_script.m failed: %s', ME.message);
    end
    evalin('base', 'clear');
end

fprintf('generate_parity_data: parity snapshots generated under %s\n', fullfile(monalisaRoot, 'parity'));
end
