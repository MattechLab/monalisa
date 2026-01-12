function downloadData()
%DOWNLOADDATA Download tutorial data using curl/wget via system()
% Works on Windows / macOS / Linux

    fprintf('Downloading tutorial data...\n');

    scriptDir = fileparts(mfilename('fullpath'));
    cd(scriptDir);

    files = {
        '11p1lUw4pcj_xp1kPuKv3LO_cfcyYlnw_', 'bodyCoil.dat'
        '12sYtd-KfkZYM8IBzg_DGXsxT3n_uHSLf', 'brainScan.dat'
        '1dd8I74Hy4Hb97SF-fHBIkrZP_JzwpMa0', 'surfaceCoil.dat'
    };

    for i = 1:size(files,1)
        fileId  = files{i,1};
        outFile = files{i,2};

        fprintf('→ %s\n', outFile);

        cmd = buildDownloadCommand(fileId, outFile);

        [status, out] = system(cmd);

        if status == 0 && exist(outFile,'file')
            fprintf('  ✓ done\n');
        else
            fprintf('  ✗ failed\n');
            disp(out);
        end
    end

    fprintf('\nAll downloads completed.\n');
end


function cmd = buildDownloadCommand(fileId, outFile)
%BUILD DOWNLOAD COMMAND FOR CURRENT OS

    url = sprintf( ...
        'https://drive.usercontent.google.com/download?id=%s&confirm=xxx', ...
        fileId);

    if ispc
        % Windows: curl is available by default (Win10+)
        cmd = sprintf('curl -L "%s" -o "%s"', url, outFile);
    else
        % macOS / Linux
        cmd = sprintf('curl -L "%s" -o "%s"', url, outFile);
    end
end
