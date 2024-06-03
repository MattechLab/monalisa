% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmGetString()
    
    myAnswer = inputdlg({'Enter a string : '}, 'bmGetString',[1 40]);     
    
    if isempty(myAnswer)
       out = ''; 
       return; 
    end
    
    
    if isempty(myAnswer{1})
       out = ''; 
       return; 
    end
    

    out = myAnswer{1}; 
     
     
end