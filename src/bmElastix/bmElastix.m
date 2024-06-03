% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% usage  : varargout = bmElastix(argImageList, 
%                                nDim, 
%                                argParamFile, 
%                                argTempDir, 
%                                varargin)
%
%
%
%
%
% argImageList must be an array of numbers. Its size must be [A, B, C] with 
% A, B > 20 and C > 1 for 2Dim images. Or it must be [A, B, C, D] with 
% A, B, C > 20 and D > 1 for 3Dim images.
% 
% nDim must be 2 for 2Dim images, or 3 for 3Dim images. 
%
% argParamFile must be the long name of a valid elastix parameter file.
%
% argTempDir must be the long name of a non-existant directory. This is a
% temporary directory that is created to save temporary data. 
%
% varargin can contain at any place ..., 'FixIndex', argInt, ... where
% argInt must be an integer, to specify the index of the fix image in
% argImageList.
%
% varargin can contain at any place ..., 'Mask', argMaskList, ... where
% argMaskList must be a binary mask. It must be of size [A, B, C] or of 
% size [A, B] for 2Dim Images. It must be of size [A, B, C, D] or of 
% size [A, B, C] for 3Dim Images.
%
% varargin can contain at any place ..., 'ClearTempDir', 'off', ... This
% will prevent the temporary files and folders to be deleted at the end of
% the registration. 
%
% varargout{1} is the returned list of registered images
% and is of size [A, B, C] for 2Dim images or of size [A, B, C, D] for
% 3Dim images. 
%
% varargout{2} is the returned list of deformation fields 
% and is of size [A, B, 2, C] for 2Dim images or of size [A, B, C, 3, D] 
% for 3Dim images.  
%
% varargout{3} is the list of the long file names of the generated 
% deformation-parameter files. 




function varargout = bmElastix(argImageList,... 
                               nDim,... 
                               argParamFile,... 
                               argTempDir, ...
                               varargin)

                               
                               
% constant ----------------------------------------------------------------
nImage = size(argImageList, nDim+1);
myGain = 1e3; % magic number
% end_constant ------------------------------------------------------------



% varargin ----------------------------------------------------------------
myFixIndex = 1;
myMaskFlag = false;
myClearFlag = true; 

if length(varargin) > 1
    for i = 1:length(varargin) - 1
        if strcmp(varargin{i}, 'FixIndex')
            myFixIndex = varargin{i+1};
        end
        if strcmp(varargin{i}, 'Mask')
            myMaskFlag = true;
            myMaskList = double(logical(varargin{i+1}));
            if ndims(myMaskList) == nDim
                
                if nDim == 2
                    myMaskList = repmat(myMaskList, [1, 1, nImage]);
                elseif nDim == 3
                    myMaskList = repmat(myMaskList, [1, 1, 1, nImage]);
                end
                
            end
        end
        if strcmp(varargin{i}, 'ClearTempDir') && strcmp(varargin{i+1}, 'off')
            myClearFlag = false; 
        end
    end
end
% end_varargin ------------------------------------------------------------



% preparing_folders -------------------------------------------------------
if bmCheckDir(argTempDir, false); 
   error('The proposed temporary folder already exist. Please choose another directory name.');
   varargout{1} = 0; 
   varargout{2} = 0; 
   varargout{3} = 0; 
   return; 
end
bmCreateDir(argTempDir); 
copyfile(argParamFile, argTempDir);

[~ , argParamFileName] = fileparts(argParamFile); 
argParamFileName = [argParamFileName, '.txt']; 

tempCd = cd;
cd(argTempDir);

tempInDir = [argTempDir, '\tempIn'];
bmCreateDir(tempInDir);

tempOutDir = [argTempDir, '\tempOut'];
bmCreateDir(tempOutDir);

for i = 1:nImage
    myDeformParamDirName{i} = ['deformParam_', num2str(i)];
    bmCreateDir([tempOutDir, '\', myDeformParamDirName{i}]);
    
    myResultDirName{i} = ['result_', num2str(i)];
    bmCreateDir([tempOutDir, '\', myResultDirName{i}]);
end
% end_preparing_folders ---------------------------------------------------





% preparing_images --------------------------------------------------------
argImageList = double(abs(argImageList));
myMin = min(argImageList(:));
myImageList = argImageList - myMin;
myMax = max(myImageList(:));
myImageList = myImageList*myGain/myMax;

if nDim == 2
    myDeformFieldList = zeros(size(myImageList, 1), size(myImageList, 2), 2, nImage); 
elseif nDim == 3
    myDeformFieldList = zeros(size(myImageList, 1), size(myImageList, 2), size(myImageList, 3), 3, nImage);     
end
    
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
    
    if myMaskFlag
        if nDim == 2
            tempImage = myMaskList(:, :, i);
        elseif nDim == 3
            tempImage = myMaskList(:, :, :, i);
        end
        myNii = make_nii(tempImage);
        myMaskFileName{i} = ['mask_', num2str(i),'.nii'];
        save_nii(myNii, [tempInDir, '\', myMaskFileName{i}]);
    end
    
end
% end_writing_images_on_disk ----------------------------------------------





% registration ------------------------------------------------------------
for i = 1:nImage
    if i ~= myFixIndex
        if myMaskFlag
            myCommand =    ['elastix', ...
                            ' -f tempIn\', myImageFileName{myFixIndex},...
                            ' -m tempIn\', myImageFileName{i},...
                            ' -fMask tempIn\', myMaskFileName{myFixIndex}, ...
                            ' -mMask tempIn\', myMaskFileName{i}, ...
                            ' -p ', argParamFileName,...
                            ' -out tempOut\', myDeformParamDirName{i}];
        else
            myCommand =    ['elastix', ...
                            ' -f tempIn\', myImageFileName{myFixIndex},...
                            ' -m tempIn\', myImageFileName{i},...
                            ' -p ', argParamFileName,...
                            ' -out tempOut\', myDeformParamDirName{i}];
        end
        system(myCommand);
    end
end
% end_registration --------------------------------------------------------







% applying_deformation ----------------------------------------------------
for i = 1:nImage
    if i ~= myFixIndex
        myCommand =    ['transformix', ...
                        ' -in tempIn\',  myImageFileName{i}, ...
                        ' -out tempOut\', myResultDirName{i},...
                        ' -tp tempOut\', myDeformParamDirName{i}, '\TransformParameters.0.txt -def all'];
        system(myCommand);
    end
end
% end_applying_deformation ------------------------------------------------






% loading_images_and_fileList ---------------------------------------------
 myDeformParamFileList = cell(1, nImage); 
for i = 1:nImage
    if i ~= myFixIndex
        temp = load_nii(['tempOut\', myResultDirName{i}, '\result.nii']);
        
        if nDim == 2
            myImageList(:, :, i) = temp.img;
        elseif nDim == 3
             myImageList(:, :, :, i) = temp.img;
        end
        
        temp = load_nii(['tempOut\', myResultDirName{i}, '\deformationField.nii']);
        
        if nDim == 2
            myDeformFieldList(:, :, :, i) = squeeze(temp.img);
        elseif nDim == 3
            myDeformFieldList(:, :, :, :, i) = squeeze(temp.img);
        end
        
        myDeformParamFileList{i} = [tempOutDir, '\', myDeformParamDirName{i}, '\TransformParameters.0.txt']; 
    end
end
% end_loading_images_and_fileList -----------------------------------------


myImageList = myImageList*myMax/myGain;
myImageList = myImageList + myMin;

varargout{1} = myImageList; 
varargout{2} = myDeformFieldList; 
varargout{3} = myDeformParamFileList; 

cd(tempCd);

if myClearFlag
   bmDeleteFolder(argTempDir);  
end


end
