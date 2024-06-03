% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmYesNo()
    
    myAnswer = questdlg('Accept ?');     
    
    if isempty(myAnswer)
       out = ''; 
       return; 
    end
    
    
    if strcmp(myAnswer, 'Yes')
        out = true;
    else
        out = false;
    end
     
     
end