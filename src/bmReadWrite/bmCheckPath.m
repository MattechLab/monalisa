% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmCheckPath(argPath, dlgFlag)

    if nargin < 2
        dlgFlag = 1
    end

    out = 1;
    if not(argPath(end) == '\')
        out = 0;
        if dlgFlag
            errordlg('Path does not exist'); 
        end
    end

    argPath = argPath(1:end-1); 
    if not(exist(argPath,'dir')==7)
        out = 0;
        if dlgFlag
            errordlg('Path does not exist'); 
        end
    end
    
end