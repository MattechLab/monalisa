% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmClearDir(argDir)

rmdir(argDir, 's'); 
mkdir(argDir); 

end