% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmFile2Array(argDir, argName, argChar, argType)

if argChar == 'd'
    myVarName = argName;
    myFileNameH = strcat(argName,'.hdat');
    myFileNameD = strcat(argName,'.dat');

    myFilePath = strcat(argDir, '/', myFileNameH); 
    
    myNdims = textread(myFilePath,'%u',1); 
    myNumbers = textread(myFilePath,'%u',myNdims+2);
    % myLength = myNumbers(end);
    mySize = myNumbers(2:end-1);
    myLength = 1; 
    for i = 1:length(mySize)
        myLength = myLength*mySize(i); 
    end
    
    if myNdims == 1
    out = zeros(mySize',1);
    else
    out = zeros(mySize');        
    end
    
    myFilePath = strcat(argDir, '/', myFileNameD);
    myFile = fopen(myFilePath);
    out(:) = fread(myFile,myLength,argType);
    fclose(myFile);

elseif argChar == 't'
    myVarName = argName;
    myFileName = strcat(argName,'.txt');

    myFilePath = strcat(argDir, '/', myFileName);
    
    myNdims = textread(myFilePath,'%u',1);
    myNumbers = textread(myFilePath,'%u',myNdims+2);
    myLength = myNumbers(end);
    mySize = myNumbers(2:end-1);
     
    if myNdims == 1
    out = zeros(mySize',1);
    else
    out = zeros(mySize');        
    end
     
    out = dlmread(myFilePath,' ', 3, 0);
    out = reshape(out, mySize');
    
elseif argChar == 'c'
    myVarName = argName;
    myFileName = strcat(argName,'.csv');

    myFilePath = strcat(argDir, '/', myFileName);
     
    myNdims = textread(myFilePath,'%u',1);
    myNumbers = textread(myFilePath,'%u',myNdims+2);
    myLength = myNumbers(end);
    mySize = myNumbers(2:end-1);
     
    if myNdims == 1
    out = zeros(mySize',1);
    else
    out = zeros(mySize');        
    end
     
    temp = dlmread(myFilePath,' ',4,0);
    
    for i = 1:length(temp(:))/mySize(1)/mySize(2)
        out(:,:,i) = temp((i-1)*mySize(1)+1:i*mySize(1), :);
    end

    out = reshape(out, mySize');

end




