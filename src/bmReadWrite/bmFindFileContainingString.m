% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmFindFileContainingString(argDir, argString)

myDirList   = bmDirList(argDir, true);
nDir        = length(myDirList); 

for i = 1:nDir
    myNameList = bmNameList(myDirList{i});
    nName = length(myNameList);
    for j = 1:nName
        
        tempFile = [myDirList{i}, '\', myNameList{j}];
        if bmCheckFile(tempFile, false)
            temp_fid = fopen(tempFile);
            
            myFind      = []; 
            myFind_flag = false; 
            while not(feof(temp_fid))
                myLine = fgetl(temp_fid);
                myFind = strfind(myLine, argString);
                if not(isempty(myFind))
                    myFind_flag = true; 
                end
            end
            if myFind_flag
               disp(myNameList{j}); 
            end
            
            fclose(temp_fid);
        end
          
    end
end

end