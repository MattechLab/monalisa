% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function counts the number of folders in 'mitosius_dir' which name 
% begin by 'cell_'. 

function nCell = bmMitosius_nCell(mitosius_dir)

myList      = dir(mitosius_dir); 
myList      = myList(3:end); 

nCell = 0; 
for i = 1:size(myList(:), 1)
    
    
    
    if exist([mitosius_dir, '/', myList(i).name]) == 7
        temp_name = myList(i).name;
        if size(temp_name(:), 1) >= 5
            if strcmp(temp_name(1:5), 'cell_')
                nCell = nCell + 1;
            end
        end
    end
   
    
    
end

end