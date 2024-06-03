% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmCell2TextFile(arg_cell, arg_file)

fid = fopen(arg_file, 'wt');
for i = 1:numel(arg_cell)
    if arg_cell{i+1} == -1
        fprintf(fid, '%s', arg_cell{i});
        break; 
    else
        fprintf(fid, '%s\n', arg_cell{i});
    end
end
fclose(fid);

end