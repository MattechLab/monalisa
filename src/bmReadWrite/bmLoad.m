% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmLoad(arg_file)

temp_load   = load(  [arg_file, '.mat']  );
temp_name   = fieldnames(temp_load);
out         = temp_load.(temp_name{1});

end