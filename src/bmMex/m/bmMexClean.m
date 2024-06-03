% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% varargin{1} is the directory;
% varargin{2} is 'windows' or 'linux';

function bmMexClean(varargin)


if length(varargin) == 0
    argDir = 'C:/main/matlab/bmToolBox';
    myOS   = 'windows';
elseif length(varargin) == 1
    argDir = varargin{1};
    myOS   = 'windows';
elseif length(varargin) == 2
    argDir = varargin{1};
    myOS   = varargin{2};
end

myCurrentDir = cd;
myDirList = cat(1, argDir, bmDirList(argDir, true));
for i = 1:length(myDirList)
    cd(myDirList{i});
    
    myFileNameList = bmNameList(myDirList{i}, false);
    for j = 1:length(myFileNameList)
        myFileName = myFileNameList{j};
        
        if length(myFileName) >= 7
            if strcmp(myFileName(end-6:end), '.mexw64')
                bmDeleteFile([myDirList{i}, '/', myFileName]);
            end
            if strcmp(myFileName(end-6:end), '.mexa64')
                bmDeleteFile([myDirList{i}, '/', myFileName]);
            end
        end
    end
    
end
cd(myCurrentDir);

end