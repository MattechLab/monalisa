% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function visits each cell of the given mitosius and clean all files
% with name listed in varargin in addition to all files with name 
% begining with 'slurm'. 

function bmMitosius_clean(mitosius_dir, varargin)

nName = length(varargin);
nameList = []; 
for i = 1:nName
    nameList{i} = varargin{i};
end

mitosius_nameList   = bmNameList(cell_dir, false);
mitosius_nameList   = mitosius_nameList(:); 
iMax                = size(mitosius_nameList(:), 1); 

for i = 1:iMax
    
    continue_flag = true; 
    if length(mitosius_nameList{i}) >= length('cell_')
        if strcmp(mitosius_nameList(i)(1:5), 'cell_')
            continue_flag = false;  
        end
    end
    if continue_flag
       continue;  
    end
    
    cell_dir        = [mitosius_dir, '/cell_', num2str(i)];
    cell_nameList   = bmNameList(cell_dir, false);
    cell_nName      = size(cell_nameList(:), 1);
    
    for j = 1:cell_nName
        temp_name = cell_nameList{j}; 
        temp_file = [cell_dir, '/', temp_name];
        if length(temp_name) >= length('slurm')
            if strcmp(temp_name(1:5), 'slurm')
                if bmCheckFile(temp_file)
                    bmDeleteFile(temp_file);
                end
            end
        end
    end
    
    
    for k = 1:nName
        for j = 1:cell_nName
            temp_name = cell_nameList{j};
            temp_file = [cell_dir, '/', temp_name];
            if strcmp(temp_name, nameList{k})
                if bmCheckFile(temp_file)
                    bmDeleteFile(temp_file);
                end
            end
        end
    end
        
end

end