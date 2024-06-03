% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% varargin{1} is 'windows' or 'linux' or 'mac';
% varargin{2} is the mex directory file. 

function bmMex(argDir, varargin)

if length(varargin) == 0
    myOS            = 'windows';
    mex_dir_file    = [argDir, '/bmMex/txt/bmMex_dir_blanc.txt']; 
elseif length(varargin) == 1
    myOS            = varargin{1};
    mex_dir_file    = [argDir, '/bmMex/txt/bmMex_dir_blanc.txt'];
elseif length(varargin) == 2
    myOS            = varargin{1};
    mex_dir_file    = varargin{2}; 
end

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
myDirList = cat(1, argDir, bmDirList(argDir, true));
for i = 1:length(myDirList)
    cd(myDirList{i});
    
    if strcmp(myOS, 'windows')
        command_file = [myDirList{i}, '/mex_command_windows.txt'];
    elseif strcmp(myOS, 'linux')
        command_file = [myDirList{i}, '/mex_command_linux.txt'];
    end
    
    if (exist(command_file) == 2)
                
        text_cell = bmTextFile2Cell(command_file);
        [myCommand, myCommand_flag] = bmMex_cell2command(   text_cell, ...
                                                            cuda_I_dir, ...
                                                            cuda_L_dir, ...
                                                            fftw_I_dir, ...
                                                            fftw_L_dir); 
        
        if myCommand_flag
            disp(myCommand);
            eval(myCommand);
        end
        
    end
    
    
end
cd(myCurrentDir);

end