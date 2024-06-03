% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmDeleteFolder(argDir)

if bmCheckDir(argDir, 0)
    temp_dir = cd;
    cd(argDir); cd ..
    rmdir(argDir, 's');
    
    if bmCheckDir(temp_dir, 0)
        cd(temp_dir);
    end
end

end