% Bastien Milani (modified by Mauro Leidi)
% CHUV and UNIL
% Lausanne - Switzerland
% Jul 2024 

function compile_mex_for_monalisa()
    % compile_mex_for_monalisa - Compiles the necessary files based on the operating system.
    %
    % Usage:
    %   compile_mex_for_monalisa()
    %       Automatically detects the OS and sets the necessary variables.


    % Determine the operating system and get compilation script dir
     % Get the path of the current script
    currentScriptPath = mfilename('fullpath');
    argDir = fileparts(fileparts(fileparts(currentScriptPath)));
    % Add the root directory and all its subdirectories to the MATLAB search path
    addpath(genpath(fileparts(argDir)));
    mex_dir_file = fullfile(argDir, 'bmMex', 'txt', 'bmMex_dir_blanc.txt');
    
    cuda_I_dir = [];
    cuda_L_dir = [];
    fftw_I_dir = [];
    fftw_L_dir = [];
    if ~isempty(mex_dir_file)
    [   cuda_I_dir, ...
        cuda_L_dir, ...
        fftw_I_dir, ...
        fftw_L_dir] = bmMex_extern_dir(mex_dir_file); 
    end
    
    
    
    myCurrentDir = cd;

    disp(argDir)
    myDirList = cat(1, argDir, bmDirList(argDir, true));
    for i = 1:length(myDirList)
        cd(myDirList{i});
        
        if ispc
            command_file =  [myDirList{i}, '/mex_command_windows.txt'];
        elseif ismac
            command_file = [myDirList{i}, '/mex_command_mac_llvm.txt'];
        elseif isunix
            command_file = [myDirList{i}, '/mex_command_linux.txt'];
        else
            error('Unsupported operating system');
        end
        
        if (exist(command_file) == 2)
                    
            text_cell = bmTextFile2Cell(command_file);
            [myCommand, myCommand_flag] = bmMex_cell2command(   text_cell, ...
                                                                cuda_I_dir, ...
                                                                cuda_L_dir, ...
                                                                fftw_I_dir, ...
                                                                fftw_L_dir); 
            if ismac
                % Search for libomp directory on macOS (adjust for other platforms if needed)
                libomp_dirs = dir('/opt/homebrew/opt/libomp');  % Example path where Homebrew installs packages
                
                if isempty(libomp_dirs)
                    error('libomp not found. Install libomp or adjust path accordingly.');
                end
                
                LIBOMP_ROOT = libomp_dirs(1).folder;
                % Replace $LIBOMP_ROOT with actual value of LIBOMP_ROOT
                myCommand = strrep(myCommand, '$LIBOMP_ROOT', LIBOMP_ROOT);
            end
            if myCommand_flag
                disp(myCommand);
                eval(myCommand);
            end
            
        end
            
        cd(myCurrentDir);
    
    end