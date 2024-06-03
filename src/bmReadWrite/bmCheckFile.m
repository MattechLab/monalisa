% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmCheckFile(argFile, dlgFlag)
    out = 1; 
    if not(exist(argFile,'file')==2)
        out = 0;
        if dlgFlag
            errordlg('File does not exist'); 
        end
    end
end