% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmCheckDir(argDir, dlgFlag)

    if nargin < 2
        dlgFlag = true; 
    end
    
    out = 1; 
    
    if isnumeric(argDir)
        out = 0; 
        return; 
    end
    
    if not(exist(argDir,'dir')==7)
        out = 0;
        if dlgFlag
            errordlg('Directory does not exist'); 
        end
    end
end