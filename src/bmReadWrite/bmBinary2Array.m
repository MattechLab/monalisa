% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmBinary2Array(argDir, argFileName)

myFileNameH = strcat(argFileName,'.hdat'); 
myFileNameD = strcat(argFileName,'.dat'); 

myFile = strcat(argDir, '/', myFileNameH); 

myCell = textread(myFile, '%s'); 
myNdims = str2num(myCell{1}); 
mySize = zeros(1, myNdims); 
for i = 1:myNdims
   mySize(i) = str2num(myCell{i+1});  
end
myLength = str2num(myCell{myNdims+2}); 
myType = myCell{myNdims+3}; 
myOctetNum = str2num(myCell{myNdims+4}); 


if strcmp(myType, 'longlong')
    myType = 'int64';
end

out = zeros(1, myLength); 

myFile = strcat(argDir, '/', myFileNameD);
myFileStream = fopen(myFile);
out(:) = fread(myFileStream, myLength, myType);
fclose(myFileStream);

out = reshape(out, mySize); 

if strcmp(myType, 'int')
    out = int32(out);
elseif strcmp(myType, 'int64')
    out = int64(out);
elseif strcmp(myType, 'double')
    out = double(out);
elseif strcmp(myType, 'float')
    out = single(out);
end


end


