% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmSave(arg_file, arg_var)

myName = inputname(2); 
eval([myName, ' = arg_var; ']); 
save(arg_file, myName, '-v7.3'); 

end