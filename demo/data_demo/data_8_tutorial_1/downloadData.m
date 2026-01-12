function downloadData()
%DOWNLOADDATA Download tutorial data from Google Drive
%   Cross-platform: Windows / macOS / Linux

    fprintf('Downloading tutorial data...\n');

    scriptDir = fileparts(mfilename('fullpath'));

    files = {
        '11p1lUw4pcj_xp1kPuKv3LO_cfcyYlnw_', 'bodyCoil.dat'
        '12sYtd-KfkZYM8IBzg_DGXsxT3n_uHSLf', 'brainScan.dat'
        '1dd8I74Hy4Hb97SF-fHBIkrZP_JzwpMa0', 'surfaceCoil.dat'
    };

    opts = weboptions('Timeout', 120);

    for i = 1:size(files,1)
        fileId  = files{i,1};
        outFile = fullfile(scriptDir, files{i,2});
        url     = sprintf('https://drive.google.com/uc?export=download&id=%s', fileId);

        fprintf('→ %s\n', files{i,2});

        try
            websave(outFile, url, opts);
            fprintf('  ✓ done\n');
        catch ME
            fprintf('  ✗ failed: %s\n', ME.message);
        end
    end

    fprintf('\nAll downloads completed.\n');
end
