% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This file comes from the natural sharing in the research community. 
% The original file was unsigned. The original author
% remains therefore unkown. We would be happy to mention his name if he
% recognizes parts of his code. 

function mySerieList = bmDicomLoad(argDirectoryPath)

% initial myItemList and myNameList ---------------------------------------
myDicomdirPath = strcat(argDirectoryPath, '\DICOMDIR');
myInfo=dicominfo(myDicomdirPath);

myItemList = myInfo.DirectoryRecordSequence;
myNameList = fieldnames(myItemList);
% end initial myItemList and myNameList -----------------------------------

% initial counters --------------------------------------------------------
myPatientCounter    = 0;
myStudyCounter      = 0;
mySerieCounter      = 0;
myImageCounter      = 0;
% end initial counters ----------------------------------------------------

% counting the total number of series -------------------------------------
mySerieCounter = 0;
for i = 1:length(myNameList) % Begin loop over fields to count the number
    % of series.
    myItem     = getfield(myItemList,myNameList{i});
    myItemType = getfield(myItem,'DirectoryRecordType');
    
    if strcmp(myItemType,'SERIES')
        mySerieCounter = mySerieCounter + 1;
    end
end
% end counting the total number of series ---------------------------------

% initial of the output mySerieList ---------------------------------------
mySerieList = cell(1, mySerieCounter);
mySerieListLength = length(mySerieList);
mySerieCounter = 0;
% end initial of the output mySerieList -----------------------------------

% main loop loading the data in mySerieList -------------------------------
for i = 1:length(myNameList) % Begin loop over fields, note that
    % mySerieCounter is never reseted to 0.
    myItem = getfield(myItemList,myNameList{i});
    myItemType = getfield(myItem,'DirectoryRecordType');
    
    if strcmp(myItemType,'PATIENT')
        
        % counters
        myPatientCounter = myPatientCounter + 1;
        myStudyCounter   = 0;
        myImageCounter   = 0;
        
        
        
        myPatientName = myItem.PatientName.FamilyName;
        if isfield(myItem.PatientName,'GivenName')
            myPatientForename = myItem.PatientName.GivenName;
        else
            myPatientForename = 'none';
        end
        myPatientID         = myItem.PatientID;
        myPatientBirthDate  = myItem.PatientBirthDate;
        
    elseif strcmp(myItemType,'STUDY')
        
        % counters
        myStudyCounter = myStudyCounter + 1;
        myImageCounter = 0;
        
        
        myStudyDescription  = myItem.StudyDescription;
        myStudyDate         = myItem.StudyDate;
        myStudyID           = myItem.StudyID;
        myStudyFolder       = '';
        myStudyPath         = '';
        
        myStudyFolderFlag = 0;
        
    elseif strcmp(myItemType,'SERIES')
        
        % counters
        mySerieCounter = mySerieCounter + 1;
        myImageCounter = 0;
        
        
        
        % mySerieName
        % mySerieNumber
        % mySerieDate
        % mySerieTime
        % mySerieInstanceUID
        % mySerieFolder
        
        if isfield(myItem,'SeriesDescription')
            mySerieName = myItem.SeriesDescription;
        else
            mySerieName = 'no_name';
        end
        mySerieNumber      = myItem.SeriesNumber;
        mySerieDate        = myItem.SeriesDate;
        mySerieTime        = myItem.SeriesTime;
        mySerieInstanceUID = myItem.SeriesInstanceUID;
        mySerieFolder      = '';
        
        
        % filling the output mySerieList ------------------------------------------
        mySerieList{mySerieCounter}.patientName       = myPatientName;
        mySerieList{mySerieCounter}.patientForename   = myPatientForename;
        mySerieList{mySerieCounter}.patientID         = myPatientID;
        mySerieList{mySerieCounter}.patientBirthDate  = myPatientBirthDate;
        
        mySerieList{mySerieCounter}.studyDescription  = myStudyDescription;
        mySerieList{mySerieCounter}.studyDate         = myStudyDate;
        mySerieList{mySerieCounter}.studyID           = myStudyID;
        mySerieList{mySerieCounter}.studyFolder       = myStudyFolder;
        mySerieList{mySerieCounter}.studyPath         = myStudyPath;
        
        mySerieList{mySerieCounter}.serieName        = mySerieName;
        mySerieList{mySerieCounter}.serieNumber      = mySerieNumber;
        mySerieList{mySerieCounter}.serieDate        = mySerieDate;
        mySerieList{mySerieCounter}.serieTime        = mySerieTime;
        mySerieList{mySerieCounter}.serieInstanceUID = mySerieInstanceUID;
        mySerieList{mySerieCounter}.serieFolder      = mySerieFolder;
        
        mySerieList{mySerieCounter}.imagesTable       = [];
        mySerieList{mySerieCounter}.imageNameList     = [];
        mySerieList{mySerieCounter}.imageTimeList     = [];
        % end filling the output mySerieList --------------------------------------
        
    elseif strcmp(myItemType,'IMAGE') || strcmp(myItemType,'PRIVATE')
        
        % counters
        myImageCounter = myImageCounter + 1;
        
        % myImageNameList
        % mySerieFolder bis
        % myStudyFolder bis
        % myStudyPath   bis
        % myImageTimeList
        
        [myPathString, myImageName] = fileparts(myItem.ReferencedFileID);
        mySerieList{mySerieCounter}.imageNameList{myImageCounter} = myImageName;
        if myImageCounter == 1
            [myPathString, mySerieFolder] = fileparts(myPathString);
            mySerieList{mySerieCounter}.serieFolder = mySerieFolder;
            
            if myStudyFolderFlag == 0
                [myPathString, myStudyFolder] = fileparts(myPathString);
                myStudyPath = strcat(argDirectoryPath,'\DICOM\',myStudyFolder,'\');
                
                mySerieList{mySerieCounter}.studyFolder = myStudyFolder;
                mySerieList{mySerieCounter}.studyPath = myStudyPath;
                myStudyFolderFlag = 1;
            end
        end
        
        myImageLongNameForAcqTime = [myStudyPath,mySerieFolder,'\',myImageName];
        if exist(myImageLongNameForAcqTime) == 2
            myInfoForAcqTime = dicominfo(myImageLongNameForAcqTime);
            if isfield(myInfoForAcqTime,'AcquisitionTime')
                myTime = myInfoForAcqTime.AcquisitionTime;
                myImageTimeList(myImageCounter) = 3600*str2num(myTime(1:2))+60*str2num(myTime(3:4))+str2num(myTime(5:6))+10^(-6)*str2num(myTime(8:13));
            else
                myImageTimeList(myImageCounter) = 0;
            end
        else
            myImageTimeList(myImageCounter) = 0; 
        end
        mySerieList{mySerieCounter}.imageTimeList = myImageTimeList;
        
    else
        mySerieList{mySerieCounter}.imagesTable       = [];
        mySerieList{mySerieCounter}.imageNameList     = [];
        mySerieList{mySerieCounter}.imageTimeList     = [];
    end
end
% end main loop loading the data in mySerieList ---------------------------

% reordering the series by series time ------------------------------------
mySwitchFlag = 1;
while mySwitchFlag == 1
    mySwitchFlag = 0;
    for i = 1:mySerieListLength - 1
        if str2double(mySerieList{i+1}.serieTime) < str2double(mySerieList{i}.serieTime)
            myTemp = mySerieList{i+1};
            mySerieList{i+1} = mySerieList{i};
            mySerieList{i} = myTemp;
            mySwitchFlag = 1;
        end
    end
end
% end reordering the series by series time --------------------------------



% storing all the image matrices in a 3 dimensional array -----------------
for i = 1:mySerieListLength %begin loop over series
    if length(mySerieList{i}.imageNameList) == 0
        continue;
    end
    
    currentStudyPath = mySerieList{i}.studyPath;
    currentSerieFolder = mySerieList{i}.serieFolder;
    
    % we load the first dicom image of the serie
    firstDicomFileName = mySerieList{i}.imageNameList{1};
    firstDicomLongName = [currentStudyPath, currentSerieFolder,'\',firstDicomFileName]; 
    
    if exist(firstDicomLongName) ~= 2
        continue; 
    end
    firstDicom = dicomread(firstDicomLongName);

    if ndims(firstDicom) ~= 2
        continue;
    end
    
    myNumOfImages = length(mySerieList{i}.imageNameList);
    myImagesTable = zeros(size(firstDicom,1), size(firstDicom,2),myNumOfImages);
    
    for j = 1:myNumOfImages %begin loop over images
        myDicom = dicomread([currentStudyPath, currentSerieFolder,'\', mySerieList{i}.imageNameList{j}]);
        if isequal(size(firstDicom), size(myDicom)) == 0
            myDicom = zeros(size(firstDicom));
        end
        myImagesTable(:, :, j) = myDicom;
    end % end loop over images
    mySerieList{i}.imagesTable = myImagesTable;
    
end % end loop over series

% end storing all the image matrices in a 3 dimensional array -------------

end % end of the function
