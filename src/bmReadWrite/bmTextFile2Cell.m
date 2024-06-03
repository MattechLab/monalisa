% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function c = bmTextFile2Cell(arg_file)

fid = fopen(arg_file, 'r'); 
i = 1; 
current_line = fgetl(fid); 
c{i} = current_line; 
while ischar(current_line)
    i = i+1; 
    current_line = fgetl(fid); 
    c{i} = current_line; 
end
fclose(fid); 

c = c(:); 

end