% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function return a list of dir (not names), only of directories. 

% recursive_flag must be true for reccursive. 

function out = bmDirList(argDir, recursive_flag)

    if not(bmCheckDir(argDir, false))  
        out = []; 
        return;
    end; 
    
    myList = dir(argDir); 
    myList = myList(3:end);
    
    
    N = 0; 
    for i = 1:length(myList)
        temp_dir = [argDir, '/', myList(i).name];       
        if bmCheckDir(temp_dir, false)
            N = N + 1;  
        end
    end
    out = cell(N, 1); 
    myCount = 0; 
    for i = 1:length(myList)
        temp_dir = [argDir, '/', myList(i).name];       
        if bmCheckDir(temp_dir, false)
            myCount = myCount + 1; 
            out{myCount} = temp_dir; 
        end
    end    
    
    
    
    if recursive_flag
        for i = 1:N
            out = cat(1, out, bmDirList(out{i}, true));
        end
    end
    
    
end