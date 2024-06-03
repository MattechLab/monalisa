% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmGetNum()
    
    myAnswer = inputdlg({'Enter a number : '}, 'bmGetNum',[1 40]);     
    
    if isempty(myAnswer)
       out = 0; 
       return; 
    end
    
    
    if isempty(myAnswer{1})
       out = 0; 
       return; 
    end
    
    myAnswer = str2num(myAnswer{1}); 
    
    if isempty(myAnswer)
       out = 0; 
       return;  
    end
    
    out = myAnswer; 
     
     
end