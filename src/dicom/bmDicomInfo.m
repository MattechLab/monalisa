% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function dicomInfo = bmDicomInfo(varargin)

myFile      = 0; 
myDir       = 0; 
myPath      = 0; 
myFileName  = 0; 
myDirName   = 0; 

dirFlag     = 0; 
pathFlag    = 0; 
fileFlag    = 0; 

% We are only interested by the dir, the path or the file
if nargin == 0
    [myDir, myPath, ~] = bmGetDir;
    dirFlag = 1; 
    if isnumeric(myDir)
        imagesTable = 0; 
        return;  
    end
    
elseif nargin > 0
    if length(varargin)> 2
        error('Wrong list of arguments'); 
        return; 
    end
    
    for i = 1:2:length(varargin)
        switch varargin{i}
            case 'Dir'
                myDir = varargin{i+1};
                dirFlag = 1; 
            case 'Path'
                myPath = varargin{i+1};
                pathFlag = 1; 
            case 'File'
                myFile = varargin{i+1};
                fileFlag = 1; 
            otherwise
                error('Wrong list of arguments');
        end
    end
          
end


if dirFlag
    myPath = [myDir '\'];  
elseif pathFlag
    myDir = myPath(1:end-1);
elseif fileFlag
    myDir = fileparts(myFile); 
    myPath = [myDir '\'];  
else
    error('Directory or file not specified')
    return;     
end

if not(bmCheckDir(myDir))
    imagesTable = 0; 
    return; 
end

if fileFlag
   dicomInfo = dicominfo(myFile); 
   return;  
end

myFileNameList = bmNameList(myDir); 
myFileNameList = sort(myFileNameList); 

if isempty(myFileNameList)
    imagesTable = 0; 
    return; 
end

numOfImages = length(myFileNameList); 

for i = 1:numOfImages
    dicomInfo{i} =  dicominfo([myPath myFileNameList{i}]);
end
   
end