% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmGetFile()   
    
    failFlag    = 0; 
    
    myFileName  = 0; 
    myPath      = 0; 
    [myFileName myPath] = uigetfile; 
    
    if isnumeric(myFileName)
        failFlag = 1; 
    end
    if isnumeric(myPath)
        failFlag = 1;
    end
    
    if failFlag
        varargout{1} = 0; 
        varargout{2} = 0;
        varargout{3} = 0;
        varargout{4} = 0;
        varargout{5} = 0;
       return;  
    end
    
    myDir = myPath(1:end-1); 
    myFile = [myPath myFileName]; 
    
    if not(exist(myDir,'dir')==7)
        failFlag = 1; 
    end

    if not(exist(myFile,'file')==2)
        failFlag = 1; 
    end
    
    if failFlag
        varargout{1} = 0; 
        varargout{2} = 0;
        varargout{3} = 0;
        varargout{4} = 0;
        varargout{5} = 0;
       return;  
    end
    
    myDirName = myDir(length(fileparts(myDir))+2:end); 
    
    varargout{1} = myFile; 
    varargout{2} = myDir; 
    varargout{3} = myPath; 
    varargout{4} = myFileName; 
    varargout{5} = myDirName; 
    
end