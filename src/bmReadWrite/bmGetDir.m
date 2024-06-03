% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmGetDir()   
    
    myDir = 0; 
    myDir = uigetdir; 
    
    if isnumeric(myDir)
        varargout{1} = 0; 
        varargout{2} = 0; 
        varargout{3} = 0; 
        return; 
    end
    
    if not(exist(myDir,'dir')==7)
        varargout{1} = 0; 
        varargout{2} = 0; 
        varargout{3} = 0; 
        return; 
    end
    
    myPath = [myDir '\']; 
    myDirName = myDir(length(fileparts(myDir))+2:end); 
    
    varargout{1} = myDir; 
    varargout{2} = myPath; 
    varargout{3} = myDirName; 
    
    
end