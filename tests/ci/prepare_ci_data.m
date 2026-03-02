function prepare_ci_data(dataDir)
% Prepare diversified CI test data outside the repository-tracked files.
% Data source policy:
% 1) Optional download from URL list in MONALISA_TEST_DATA_URLS (semicolon separated)
% 2) Optional tutorial-8 dataset download (MONALISA_USE_TUTORIAL8_DATA=true)
% 3) Always generate deterministic synthetic datasets

if nargin < 1 || isempty(dataDir)
    dataDir = fullfile('temp', 'ci_data');
end

if ~exist(dataDir, 'dir')
    mkdir(dataDir);
end

% Optional download of tutorial-8 demo data into temp directory.
useTutorial8 = strcmpi(strtrim(getenv('MONALISA_USE_TUTORIAL8_DATA')), 'true');
if useTutorial8
    tutorialDir = fullfile(dataDir, 'tutorial8');
    if ~exist(tutorialDir, 'dir')
        mkdir(tutorialDir);
    end
    download_tutorial8_data(tutorialDir);
end

% Try downloading external datasets if provided.
urlList = getenv('MONALISA_TEST_DATA_URLS');
if ~isempty(urlList)
    urls = split(string(urlList), ';');
    for i = 1:numel(urls)
        u = strtrim(urls(i));
        if strlength(u) == 0
            continue;
        end
        outFile = fullfile(dataDir, sprintf('external_%02d.mat', i));
        try
            websave(outFile, char(u));
            fprintf('Downloaded external test data: %s\n', outFile);
        catch ME
            warning('Could not download "%s": %s', u, ME.message);
        end
    end
end

% Deterministic synthetic datasets (diversified types/shapes).
rng(42);
cases = struct([]);

for k = 1:12
    nCh = randi([1, 4]);
    nPt = randi([4, 50]);
    raw = randn(nCh, nPt);
    if mod(k, 2) == 0
        raw = raw + 1i * randn(size(raw));
    end

    weight = rand(1, nCh * nPt);
    weight = reshape(weight, size(raw));
    scalarWeight = 0.5 + rand();

    cellX = {raw, raw * 2};
    cellY = {raw * 0.5, raw * 3};

    cases(k).id = k;
    cases(k).raw = raw; %#ok<*AGROW>
    cases(k).nCh = nCh;
    cases(k).weight = weight;
    cases(k).scalarWeight = scalarWeight;
    cases(k).cellX = cellX;
    cases(k).cellY = cellY;
end

save(fullfile(dataDir, 'synthetic_cases.mat'), 'cases', '-v7.3');
fprintf('Synthetic CI test data written to %s\n', fullfile(dataDir, 'synthetic_cases.mat'));

end

function download_tutorial8_data(outDir)
% Download tutorial 8 files (same IDs as demo/data_demo/data_8_tutorial_1/downloadData.m)

files = {
    '11p1lUw4pcj_xp1kPuKv3LO_cfcyYlnw_', 'bodyCoil.dat'
    '12sYtd-KfkZYM8IBzg_DGXsxT3n_uHSLf', 'brainScan.dat'
    '1dd8I74Hy4Hb97SF-fHBIkrZP_JzwpMa0', 'surfaceCoil.dat'
    };

for i = 1:size(files, 1)
    fileId = files{i, 1};
    outFile = fullfile(outDir, files{i, 2});
    url = sprintf('https://drive.usercontent.google.com/download?id=%s&confirm=xxx', fileId);

    % Keep behavior close to existing downloader: curl -L
    cmd = sprintf('curl -L "%s" -o "%s"', url, outFile);
    [status, out] = system(cmd); %#ok<ASGLU>

    if status == 0 && exist(outFile, 'file') == 2
        d = dir(outFile);
        if d.bytes > 0
            fprintf('Downloaded tutorial8 file: %s (%d bytes)\n', outFile, d.bytes);
            continue;
        end
    end

    warning('Could not download tutorial8 file to "%s".', outFile);
    if ~isempty(out)
        disp(out);
    end
end
end
