% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023
%
% usage : varargout = bmTransformix(argImageList, 
%                                   nDim, 
%                                   argDeformParamFile)
%
%   
%
%
%
% argImageList is the list of images to be transformed and must be of size
% [A, B, C] for 2Dim Images or [A, B, C, D] for 3Dim images. 
% 
% argDeformParamFile must be the name of a valid elastix tranformation 
% file, typically generated with the elastix executable.  
% 


function varargout = bmTransformix(argImageList, ...
                                   nDim, ...
                                   argDeformParamFile)

                                   
% constant ----------------------------------------------------------------
nImage = size(argImageList, nDim + 1); 

myGain = 1e3; % magic number
% end_constant ------------------------------------------------------------



% preparing_folders -------------------------------------------------------
[argTempDir, argDeformParamFileName] = fileparts(argDeformParamFile);
argDeformParamFileName = [argDeformParamFileName, '.txt']; 

tempCd = cd;
cd(argTempDir);

tempInDir = [argTempDir, '\tempIn'];
bmDeleteFolder(tempInDir);
bmCreatFolder(tempInDir);

tempOutDir = [argTempDir, '\tempOut'];
bmDeleteFolder(tempOutDir);
bmCreatFolder(tempOutDir);

for i = 1:nImage
    myResultDirName{i} = ['result_', num2str(i)];
    bmCreatFolder([tempOutDir, '\', myResultDirName{i}]);
end
% end_preparing_folders ---------------------------------------------------





% preparing_images --------------------------------------------------------
argImageList = double(argImageList); 
myMin = min(argImageList(:)); 
myImageList = argImageList - myMin;
myMax = max(myImageList(:));
myImageList = myImageList*myGain/myMax;
% end_preparing_images ----------------------------------------------------





% writing_images_on_disk --------------------------------------------------
for i = 1:nImage
    
    if nDim == 2
        tempImage = myImageList(:, :, i); 
    elseif nDim == 3
        tempImage = myImageList(:, :, :, i);
    end
    
    myNii = make_nii(tempImage);
    myImageFileName{i} = ['image_', num2str(i),'.nii'];
    save_nii(myNii, [tempInDir, '\', myImageFileName{i}]);    
end
% end_writing_images_on_disk ----------------------------------------------







% applying_deformation ----------------------------------------------------
for i = 1:nImage
    myCommand =    ['transformix', ...
                    ' -in tempIn\',  myImageFileName{i}, ...
                    ' -out tempOut\', myResultDirName{i},...
                    ' -tp ', argDeformParamFileName, ' -def all'];
    system(myCommand);
end
% end_applying_deformation ------------------------------------------------






% loading_images ----------------------------------------------------------
for i = 1:nImage
    temp = load_nii(['tempOut\', myResultDirName{i}, '\result.nii']);
    
    if nDim == 2
        myImageList(:, :, i) = temp.img;
    elseif nDim == 3
        myImageList(:, :, :, i) = temp.img;
    end
end
% end_loading_images ------------------------------------------------------



myImageList = myImageList*myMax/myGain;
myImageList = myImageList + myMin;

varargout{1} = myImageList; 

cd(tempCd);

bmDeleteFolder(tempInDir);
bmDeleteFolder(tempOutDir); 


end
