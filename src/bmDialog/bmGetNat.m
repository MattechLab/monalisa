% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmGetNat()
    
    myAnswer = inputdlg({'Enter a natural number : '}, 'bmGetNnat',[1 40]);     
    
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
    if length(myAnswer) > 1
       out = 0; 
       return; 
    end
    
    out = fix(abs(myAnswer)); 
     
     
end