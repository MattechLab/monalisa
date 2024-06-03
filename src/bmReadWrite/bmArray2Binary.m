% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmArray2Binary(argArray, argDir, argFileName, argType)

if strcmp(argType, 'double')
    argArray = double(argArray); 
    myType   = 'double';
elseif strcmp(argType, 'int')
    argArray = int32(argArray);
    myType   = 'int';
elseif strcmp(argType, 'int64')
    argArray = int64(argArray);
    myType   = 'int64';
elseif strcmp(argType, 'single')
    argArray = single(argArray);
    myType = 'float'; 
else
    error('Type is unknown'); 
    return; 
end


myFileNameH = strcat(argFileName,'.hdat');
myFileNameD = strcat(argFileName,'.dat');

myFile = strcat(argDir, '/', myFileNameH);

myNdims  = ndims(argArray);
mySize   = size(argArray);
myLength = length(argArray(:)'); 
 
if strcmp(myType, 'int')
    myOctetNum = 4;
elseif strcmp(myType, 'int64')
    myOctetNum = 8;
elseif strcmp(myType, 'double')
    myOctetNum = 8;
elseif strcmp(myType, 'float')
    myOctetNum = 4;
end



myNdims_string = num2str(myNdims);
mySize_string = num2str(mySize(1));
for i = 2:size(mySize, 2)
    mySize_string = [mySize_string, ' ', num2str(mySize(i))];
end
myLength_string = num2str(myLength);
myOctetNum_string = num2str(myOctetNum); 
if strcmp(myType, 'int64')
   myType_string = 'longlong';  
else
    myType_string = myType; 
end


dlmwrite(myFile, myNdims_string,                'delimiter', '', 'newline','pc');
dlmwrite(myFile, mySize_string,      '-append', 'delimiter', '', 'newline','pc');
dlmwrite(myFile, myLength_string,    '-append', 'delimiter', '', 'newline','pc');
dlmwrite(myFile, myType_string,      '-append', 'delimiter', '', 'newline','pc');
dlmwrite(myFile, myOctetNum_string,  '-append', 'delimiter', '', 'newline','pc');



myFile = strcat(argDir, '/', myFileNameD);
myFileStream = fopen(myFile, 'w');
fwrite(myFileStream, argArray, myType);
fclose(myFileStream);

end


