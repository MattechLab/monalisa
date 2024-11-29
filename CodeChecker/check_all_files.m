
function check_all_files(qcFolder, codeFolder)
    % Check all .m files in a folder and subfolders using checkcode
    % Save the output to a text file
    % Example use:
    %   qcFolder = 'path/to/folder/for/saving/reportFolder'
    %   codeFolder = 'path/to/code_folder/'
    %   check_all_files(qcFolder, codeFolder)
    %   For monalisa: 
    %   codeFolder = '/Users/cag/Documents/forclone/monalisa/src'
    %   check_all_files(qcFolder, codeFolder)
    % Author: Yiwei Jia

    % Validate the input
    if nargin < 1
        error('Please specify the main folder path as input.');
    end

    % Open a text file to save the report
    reportFile = fullfile(qcFolder, 'checkcode_report.txt');
    fid = fopen(reportFile, 'w');
    if fid == -1
        error('Could not create report file at %s', reportFile);
    end

    % Get a list of all .m files in the folder and subfolders
    fileList = dir(fullfile(codeFolder, '**', '*.m'));

    % Loop through each file and run checkcode
    for k = 1:length(fileList)
        % Construct the full file path
        filePath = fullfile(fileList(k).folder, fileList(k).name);

        % Display and log the file being checked
        fprintf(fid, 'Analyzing: %s\n', filePath);
        fprintf('Analyzing: %s\n', filePath);

        % Run checkcode and capture the output
        issues = evalc('checkcode(filePath)');
        fprintf(fid, '%s\n', issues); % Write issues to the report file
        fprintf('%s\n', issues);     % Display issues in the MATLAB Command Window
    end

    % Close the report file
    fclose(fid);

    % Notify user
    fprintf('Checkcode report saved to: %s\n', reportFile);
end


