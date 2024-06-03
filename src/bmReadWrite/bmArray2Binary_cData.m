% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmArray2Binary_cData(realData, imagData, argDir, realFileName, imagFileName)

bmArray2Binary(realData, argDir, realFileName, 'single');
bmArray2Binary(imagData, argDir, imagFileName, 'single');

end