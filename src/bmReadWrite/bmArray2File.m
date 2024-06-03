% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmArray2File(argDir, argName, argArray, argChar, argType)

if argChar == 't'
    myVarName = argName;
    myFileName = strcat(argName,'.txt');
    myFilePath = strcat(argDir, '/', myFileName);

    myNdims = ndims(argArray);
    mySize = size(argArray);
    myLength = length(argArray(:)');

    dlmwrite(myFilePath, myNdims,'delimiter',' ', 'newline','pc');

    dlmwrite(myFilePath, mySize,'-append','delimiter',' ', 'newline','pc');

    dlmwrite(myFilePath, myLength,'-append','delimiter',' ', 'newline','pc');

    dlmwrite(myFilePath,argArray(:)','-append','delimiter',' ','precision',17, 'newline','pc');

elseif argChar == 'c'
    myVarName = argName;
    myFileName = strcat(argName,'.csv');
    myFilePath = strcat(argDir, '/', myFileName);

    myNdims = ndims(argArray);
    mySize = size(argArray);
    myLength = length(argArray(:)');

    dlmwrite(myFilePath, myNdims,'delimiter',' ', 'newline','pc');

    dlmwrite(myFilePath, mySize,'-append','delimiter',' ', 'newline','pc');

    dlmwrite(myFilePath, myLength,'-append','delimiter',' ', 'newline','pc');

    for i = 1:length(argArray(:))/mySize(1)/mySize(2)
        dlmwrite(myFilePath, '','-append','delimiter',' ', 'roffset',1);
        dlmwrite(myFilePath,argArray(:,:,i),'-append','delimiter',' ','precision',17, 'newline','pc');
    end

    
elseif argChar == 'd'
    myVarName = argName;
    myFileNameH = strcat(argName,'.hdat');
    myFileNameD = strcat(argName,'.dat');

    myFilePath = strcat(argDir, '/', myFileNameH);

    myNdims  = ndims(argArray);
    mySize   = size(argArray);
    myLength = length(argArray(:)');
    
    mySize_string = num2str(mySize(1)); 
    for i = 2:size(mySize, 2)
       mySize_string = [mySize_string, ' ', num2str(mySize(i))];  
    end
    
    myLength_string = num2str(myLength); 
    
    dlmwrite(myFilePath, myNdims,          'delimiter',' ', 'newline','pc');
    dlmwrite(myFilePath, mySize_string,    '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFilePath, myLength_string,  '-append', 'delimiter', '', 'newline','pc');
    

    myFilePath = strcat(argDir, '/', myFileNameD);
    myFile = fopen(myFilePath, 'w');
    fwrite(myFile,argArray,argType);
    fclose(myFile);

elseif argChar == 'm'
    myVarName = argName;
    myFileNameH = strcat(argName,'.hdat');
    myFileNameD = strcat(argName,'.dat');
    myFileNameM = strcat(argName,'_LOAD.m');

    myFilePath = strcat(argDir, '/', myFileNameH);

    myNdims = ndims(argArray);
    mySize = size(argArray);
    myLength = length(argArray(:)');

    dlmwrite(myFilePath, myNdims,   'delimiter',' ', 'newline','pc');
    dlmwrite(myFilePath, mySize,    '-append','delimiter',' ', 'newline','pc');
    dlmwrite(myFilePath, myLength,  '-append','delimiter',' ', 'newline','pc');

    myFilePath = strcat(argDir, '/', myFileNameD);
    myFile = fopen(myFilePath, 'w');
    fwrite(myFile,argArray,argType);
    fclose(myFile);

    myFilePath = strcat(argDir, '/', myFileNameM);

    myString = strcat('bmArrayLoadFilePath = '' ', myFileNameD,''';');
    dlmwrite(myFilePath,myString,'delimiter','', 'newline','pc');

    myString = strcat('bmArrayLoadLength = ',num2str(length(argArray(:))),';');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat('bmArrayLoadType ='' ', argType,''';');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = 'bmArrayLoadSize =[';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    dlmwrite(myFilePath,num2str(mySize),'-append','delimiter','', 'newline','pc');

    myString = '];';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat('clear',{' '}, argName, ';');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat(argName,' = zeros(bmArrayLoadSize)', ';');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = 'bmArrayLoadFile = fopen(bmArrayLoadFilePath);';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat(argName,'(:) = fread(bmArrayLoadFile, bmArrayLoadLength, bmArrayLoadType);');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = 'fclose(bmArrayLoadFile);';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = 'clear ans bmArrayLoadFile bmArrayLoadFilePath bmArrayLoadLength bmArrayLoadSize bmArrayLoadType';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');


    
elseif argChar == 's'
    myVarName = argName;
    myFileName = strcat(argName,'_LOAD.m');
    myFilePath = strcat(argDir, '/', myFileName);

    myNdims = ndims(argArray);
    mySize = size(argArray);
    myLength = length(argArray(:)');

    myString = strcat('myNdims =',num2str(myNdims),';');
    dlmwrite(myFilePath,myString,'delimiter','', 'newline','pc');

    myString = 'mySize =[';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    dlmwrite(myFilePath,num2str(mySize),'-append','delimiter','', 'newline','pc');

    myString = '];';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat('myLength = ',num2str(myLength),';');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = 'if myNdims == 1';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat(myVarName,' = zeros(mySize,1);');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = 'else';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat(myVarName,' = zeros(mySize);');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = 'end';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat(myVarName,'(:) = [');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    dlmwrite(myFilePath,argArray(:)','-append','delimiter',' ','precision',17, 'newline','pc');

    myString = '];';
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');

    myString = strcat('clear myNdims mySize myLength');
    dlmwrite(myFilePath,myString,'-append','delimiter','', 'newline','pc');
        
        
end
