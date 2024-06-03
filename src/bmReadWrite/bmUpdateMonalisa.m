% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmUpdateMonalisa(dir_bmToolBox, dir_monalisa)


L_bm = size(dir_bmToolBox(:), 1);
L_ml = size(dir_monalisa(:), 1);

rel_dirList = bmDirList(dir_monalisa, true); 
nDir = size(rel_dirList(:), 1); 
for i = 1:nDir
   rel_dirList{i}(1:L_ml) = [];  
end



for i = 1:nDir
    temp_rel_dir    = rel_dirList{i}; 
    ml_temp_dir     = [dir_monalisa,  temp_rel_dir];
    bm_temp_dir     = [dir_bmToolBox, temp_rel_dir];
    temp_name_list  = bmNameList(ml_temp_dir); 
    
    for j = 1:size(temp_name_list(:), 1)
        temp_name = temp_name_list{j}; 
        ml_temp_file = [ml_temp_dir, '/', temp_name];
        bm_temp_file = [bm_temp_dir, '/', temp_name];
        
        if bmCheckFile(ml_temp_file, false) 
            bmDeleteFile(ml_temp_file); 
            
            if bmCheckFile(bm_temp_file, false)
                copyfile(bm_temp_file, ml_temp_file); 
            end
        end
    end
end