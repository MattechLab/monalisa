% Bastien Milani
% CHUV and UNIL
% Lausanne - Swizerland
% May 2023

function varargout = bmDicomViewer(varargin)
% BMDICOMVIEWER MATLAB code for bmDicomViewer.fig
%      BMDICOMVIEWER, by itself, creates a new BMDICOMVIEWER or raises the existing
%      singleton*.
%
%      H = BMDICOMVIEWER returns the handle to a new BMDICOMVIEWER or the handle to
%      the existing singleton*.
%
%      BMDICOMVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BMDICOMVIEWER.M with the given input arguments.
%
%      BMDICOMVIEWER('Property','Value',...) creates a new BMDICOMVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bmDicomViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bmDicomViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bmDicomViewer

% Last Modified by GUIDE v2.5 11-Jun-2018 16:50:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bmDicomViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @bmDicomViewer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before bmDicomViewer is made visible.
function bmDicomViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bmDicomViewer (see VARARGIN)

% Choose default command line output for bmDicomViewer
handles.output = hObject;
interfaceOff(handles);
set(handles.pushbutton3, 'Enable', 'on'); 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bmDicomViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bmDicomViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curImNum = 1; 

guidata(hObject, handles);
refresh(hObject, handles); 

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1



% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.curImNum = max(handles.curImNum-1, 1); 

guidata(hObject, handles);
refresh(hObject, handles); 


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curImNum = min(handles.curImNum+1, size(handles.series{handles.curSeNum}.imagesTable, 3)); 

guidata(hObject, handles);
refresh(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles, varargin)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This funciton is the initialization, any variable must be initialized
% here. 

myDir = bmGetDir; 

if exist([myDir '\DICOMDIR']) == 0
    disp('DICOMDIR not found !');
    return; 
end

interfaceOff(handles); 
set(gcf,'Pointer','watch');
drawnow

handles.currentDir = myDir; 
handles.series = bmDicomLoad(handles.currentDir); 
load('gong.mat');
sound(y, Fs);


N = length(handles.series);
for i = 1:N
    mySerieName{i} = handles.series{i}.serieName;
    mySerieNumber{i} = handles.series{i}.serieNumber;
    mySerieDate{i} = handles.series{i}.serieDate;
    mySerieTime{i} = handles.series{i}.serieTime;
    mySerieFolder{i} = handles.series{i}.serieFolder;
end

myPatientName = handles.series{1}.patientName;
myPatientForename = handles.series{1}.patientForename;
myPatientID = handles.series{1}.patientID;
myPatientBirthDate = handles.series{1}.patientBirthDate;
myStudyDate = handles.series{1}.studyDate;
myStudyFolder = handles.series{1}.studyFolder;

handles.curSeNum = 1; 
handles.curImNum = 1; 
set(handles.listbox1, 'Value', 1); 


for i = 1:N
    
   if length(num2str(mySerieNumber{i})) == 1
       myString = '0';
   else
       myString = ''; 
   end
    
   listBoxString{i} = [myString num2str(mySerieNumber{i})]; 
   mySpace = '    '; 
   
   listBoxString{i} = [listBoxString{i} mySpace mySerieFolder{i}];
   listBoxString{i} = [listBoxString{i} mySpace mySerieTime{i}(1:2) ':' mySerieTime{i}(3:4) ':' mySerieTime{i}(5:6)];
   listBoxString{i} = [listBoxString{i} mySpace mySerieDate{i}(7:8) '.' mySerieDate{i}(5:6) '.' mySerieDate{i}(1:4)];
   listBoxString{i} = [listBoxString{i} mySpace mySerieName{i}]; 

end

set(handles.listbox1, 'String', listBoxString, 'Fontsize', 12); 

staticString2{1} = ['Subject Name']; 
staticString2{2} = ['Subject Forename']; 
staticString2{3} = ['Subject ID']; 
staticString2{4} = ['Subject Birthdate']; 
staticString2{5} = ''; 
staticString2{6} = ['Study Date']; 
staticString2{7} = ['Study Folder']; 
set(handles.text2, 'String', staticString2, 'Fontsize', 12);

staticString4{1} = [':  ' myPatientName]; 
staticString4{2} = [':  ' myPatientForename];
staticString4{3} = [':  ' myPatientID];
staticString4{4} = [':  ' myPatientBirthDate(7:8) '.' myPatientBirthDate(5:6) '.' myPatientBirthDate(1:4)];
staticString4{5} = ''; 
staticString4{6} = [':  ' myStudyDate(7:8) '.' myStudyDate(5:6) '.' myStudyDate(1:4)];
staticString4{7} = [':  ' myStudyFolder];
set(handles.text4, 'String', staticString4, 'Fontsize', 12);

guidata(hObject, handles);
set(gcf,'Pointer','arrow');
drawnow

refresh(hObject, handles); 
interfaceOn(handles); 
guidata(hObject, handles);


function interfaceOn(handles)

set(handles.pushbutton1,'Enable','on');
set(handles.pushbutton2,'Enable','on');
set(handles.pushbutton3,'Enable','on');
set(handles.pushbutton4,'Enable','on');
set(handles.pushbutton5,'Enable','on');

set(handles.listbox1,'Enable','on');



function interfaceOff(handles)

set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton3,'Enable','off');
set(handles.pushbutton4,'Enable','off');
set(handles.pushbutton5,'Enable','off');

set(handles.listbox1,'Enable','off');


function refresh(hObject, handles); 

myNum = get(handles.listbox1, 'value');
handles.curSeNum = myNum; 
guidata(hObject, handles);


axes(handles.axes1); 
imagesc(handles.series{handles.curSeNum}.imagesTable(:,:,handles.curImNum));
axis image
colormap gray

staticString3 = ['Name:' handles.series{handles.curSeNum}.imageNameList{handles.curImNum} '      '...
                 'Number:'   num2str(handles.curImNum) '      '...
                 'Acqu.Time:' num2str(handles.series{handles.curSeNum}.imageTimeList(handles.curImNum))]; 
set(handles.text3, 'String', staticString3, 'Fontsize', 12);


myPatientName = handles.series{handles.curSeNum}.patientName;
myPatientForename = handles.series{handles.curSeNum}.patientForename;
myPatientID = handles.series{handles.curSeNum}.patientID;
myPatientBirthDate = handles.series{handles.curSeNum}.patientBirthDate;
myStudyDate = handles.series{handles.curSeNum}.studyDate;
myStudyFolder = handles.series{handles.curSeNum}.studyFolder;

staticString4{1} = [':  ' myPatientName]; 
staticString4{2} = [':  ' myPatientForename];
staticString4{3} = [':  ' myPatientID];
staticString4{4} = [':  ' myPatientBirthDate(7:8) '.' myPatientBirthDate(5:6) '.' myPatientBirthDate(1:4)];
staticString4{5} = ''; 
staticString4{6} = [':  ' myStudyDate(7:8) '.' myStudyDate(5:6) '.' myStudyDate(1:4)];
staticString4{7} = [':  ' myStudyFolder];
set(handles.text4, 'String', staticString4, 'Fontsize', 12);

guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bmImage(squeeze(handles.series{handles.curSeNum}.imagesTable)); 


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

myDirNameList = bmNameList([handles.currentDir, '\DICOM']);
myDir = [handles.currentDir, '\DICOM\', myDirNameList{1}, '\']; 

myNumList = bmGetString;
myNumList = ['[', myNumList, ']'];
myNumList = str2num(myNumList);

serieNameList = cell(1, length(myNumList)); 
for i = 1:length(serieNameList)
   myTempString = num2str(myNumList(i));
   while length(myTempString) < 6
       myTempString = ['0', myTempString]; 
   end
   serieNameList{i} = ['SE', myTempString]; 
end


myListName = inputdlg({'Enter a list name : '}, 'List Name',[1 40]);
if isempty(myListName)
    errordlg('This name is not valid.')
    return;
end
if isempty(myListName{1})
    errordlg('This name is not valid.')
    return;
end
if length(myListName) > 1
    errordlg('This name is not valid.')
    return;
end
myListName = myListName{1}; 

save([myDir, myListName, '.mat'], 'serieNameList'); 
