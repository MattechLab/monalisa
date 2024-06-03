% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmNumList(argNum)
    
    argNum      = argNum - 1; 
    numOfDigits = length(num2str(argNum)); 
    myString1   = num2str(10^numOfDigits);
    myString1   = myString1(2:end); 
    myLength1   = length(myString1); 
    
    out = cell(argNum, 1);
    
    for i = 0:argNum
        myString2 = num2str(i); 
        myLength2 = length(myString2); 
        out{i + 1} = [myString1(1:myLength1 - myLength2) myString2];  
    end

end