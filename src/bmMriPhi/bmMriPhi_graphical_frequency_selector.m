% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmMriPhi_graphical_frequency_selector(varargin)
% BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR MATLAB code for bmMriPhi_graphical_frequency_selector.fig
%      BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR, by itself, creates a new BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR or raises the existing
%      singleton*.
%
%      H = BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR returns the handle to a new BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR or the handle to
%      the existing singleton*.
%
%      BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR.M with the given input arguments.
%
%      BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR('Property','Value',...) creates a new BMMRIPHI_GRAPHICAL_FREQUENCY_SELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bmMriPhi_graphical_frequency_selector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bmMriPhi_graphical_frequency_selector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bmMriPhi_graphical_frequency_selector

% Last Modified by GUIDE v2.5 31-Oct-2022 15:45:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1; 
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bmMriPhi_graphical_frequency_selector_OpeningFcn, ...
                   'gui_OutputFcn',  @bmMriPhi_graphical_frequency_selector_OutputFcn, ...
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
end

% --- Executes just before bmMriPhi_graphical_frequency_selector is made visible.
function bmMriPhi_graphical_frequency_selector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bmMriPhi_graphical_frequency_selector (see VARARGIN)

% Choose default command line output for bmMriPhi_graphical_frequency_selector
handles.output               = hObject;

handles.s_ref                = varargin{1};
handles.t_ref                = varargin{2};
handles.Fs_ref               = varargin{3};
handles.nu_ref               = varargin{4};
handles.imNav                = varargin{5}; 

handles.s_lowPass            = []; 
handles.s_bandPass           = []; 
handles.lowPass_filter       = [];
handles.bandPass_filter      = [];

handles.ind_plot_min_A       = []; 
handles.ind_plot_max_A       = []; 
handles.ind_plot_min_0_A     = []; 
handles.ind_plot_max_0_A     = []; 

handles.ind_Hplot_min_B      = []; 
handles.ind_Hplot_max_B      = []; 
handles.ind_Hplot_min_0_B    = []; 
handles.ind_Hplot_max_0_B    = []; 

handles.ind_Vplot_min_B      = []; 
handles.ind_Vplot_max_B      = []; 
handles.ind_Vplot_min_0_B    = []; 
handles.ind_Vplot_max_0_B    = []; 

handles.s_plot_center        = [];
handles.s_plot_amp           = [];

handles.ind_nu_min           = []; 
handles.ind_nu_max           = []; 

handles.cLim                 = [min(handles.imNav(:)), max(handles.imNav(:))]; 

handles.yellow_flag          = true; 

% Update handles structure
guidata(hObject, handles);

mainFunction(hObject, handles); 

% UIWAIT makes bmMriPhi_graphical_frequency_selector wait for user response (see UIRESUME)
uiwait(handles.figure1);

end


% --- Outputs from this function are returned to the command line.
function varargout = bmMriPhi_graphical_frequency_selector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.s_lowPass; 
varargout{2} = handles.s_bandPass; 
varargout{3} = handles.lowPass_filter; 
varargout{4} = handles.bandPass_filter; 

delete(handles.figure1)

end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

end



function mainFunction(hObject, handles)

L = size(handles.s_ref, 2); 

handles.ind_plot_min_A      = L/2+1; 
handles.ind_plot_max_A      = L; 

handles.ind_plot_min_0_A    = L/2+1; 
handles.ind_plot_max_0_A    = L; 

handles.ind_nu_min          = L/2+1;
handles.ind_nu_max          = L;






L = size(handles.imNav, 2); 

handles.ind_Hplot_min_B      = 1; 
handles.ind_Hplot_max_B      = L; 

handles.ind_Hplot_min_0_B    = 1; 
handles.ind_Hplot_max_0_B    = L; 





L = size(handles.imNav, 1); 

handles.ind_Vplot_min_B      = 1; 
handles.ind_Vplot_max_B      = L; 
handles.ind_Vplot_min_0_B    = 1; 
handles.ind_Vplot_max_0_B    = L; 

handles.s_plot_center        = ceil(L/2);
handles.s_plot_amp           = ceil(L/4);





guidata(hObject, handles);

myRefresh_A(hObject, handles); 
myRefresh_B(hObject, handles); 

end % END_mainFunction

function myRefresh_A(hObject, handles)

Fs_ref = handles.Fs_ref;  
nu_ref = handles.nu_ref; 

ind_plot_min    = handles.ind_plot_min_A; 
ind_plot_max    = handles.ind_plot_max_A; 
ind_nu_min      = handles.ind_nu_min; 
ind_nu_max      = handles.ind_nu_max; 

Fs_plot         = abs(Fs_ref(ind_plot_min:ind_plot_max)); 
nu_plot         = nu_ref(ind_plot_min:ind_plot_max);

nu_mask_plot    = []; 
if ~isempty(handles.bandPass_filter)
    nu_mask_plot = handles.bandPass_filter(ind_plot_min:ind_plot_max); 
end


Fs_part = abs(Fs_ref(ind_nu_min:ind_nu_max));
nu_part = nu_ref(ind_nu_min:ind_nu_max);

axes(handles.axes3);
hold off
plot(nu_plot, Fs_plot, 'k.-')
hold on
plot(nu_part, Fs_part, 'b.-')

if ~isempty(nu_mask_plot)
   plot(nu_plot, nu_mask_plot*max(Fs_plot(:)), 'r.-');  
end

hold off

axis([nu_plot(1), nu_plot(end), 0, max(Fs_plot(:))]); 

guidata(hObject, handles);

end

function myRefresh_B(hObject, handles)

    imNav           = handles.imNav;
    s               = handles.s_ref;
    s_bandPass      = handles.s_bandPass; 
    
    mySize_1        = size(imNav, 1); 
    mySize_2        = size(imNav, 2); 
    
    myMu            = handles.s_plot_center; 
    mySigma         = handles.s_plot_amp;

    ind_Hplot_min    = handles.ind_Hplot_min_B;
    ind_Hplot_max    = handles.ind_Hplot_max_B;
    ind_Vplot_min    = handles.ind_Vplot_min_B;
    ind_Vplot_max    = handles.ind_Vplot_max_B;

    im_plot         = imNav(ind_Vplot_min:ind_Vplot_max, ind_Hplot_min:ind_Hplot_max);
    s_plot          = s(1, ind_Hplot_min:ind_Hplot_max);
    
    s_filtered_plot = []; 
    if ~isempty(s_bandPass)
        s_filtered_plot = s_bandPass(1, ind_Hplot_min:ind_Hplot_max); 
    end

    axes(handles.axes2); 
    hold off
    imagesc(im_plot); 
    set(gca, 'YDir', 'normal');
    colormap gray
    caxis(handles.cLim(:)'); 
    hold on
    
    if handles.yellow_flag
        plot(myMu + mySigma*s_plot, 'y.-'); 
    end
    
    if ~isempty(s_filtered_plot)
        plot(myMu + mySigma*s_filtered_plot, 'b.-'); 
    end
    
    hold off
    
    guidata(hObject, handles);
end


% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    1+1; 
end


% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    1+1; 
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_plot_min_A; 
b       = handles.ind_plot_max_A;
a_min   = handles.ind_plot_min_0_A; 

a       = floor(  (5*a - b)/4  );

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_plot_min_A = a; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_plot_min_A; 
b       = handles.ind_plot_max_A;
a_min   = handles.ind_plot_min_0_A; 

a       = floor(  (3*a + b)/4  );

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_plot_min_A = a; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_plot_min_A; 
b       = handles.ind_plot_max_A;
b_max   = handles.ind_plot_max_0_A; 

b       = ceil(  (3*b + a)/4  );

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_plot_max_A = b; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_plot_min_A; 
b       = handles.ind_plot_max_A;
b_max   = handles.ind_plot_max_0_A; 

b       = ceil(  (5*b - a)/4  );

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_plot_max_A = b; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
b_max   = handles.ind_plot_max_0_A; 

c       = handles.ind_plot_min_A; 
d       = handles.ind_plot_max_A; 

delta_b = ceil(  (d-c)/50  );
delta_b = max(1, delta_b); 
b       = b - delta_b; 

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_nu_max = b; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
b_max   = handles.ind_plot_max_0_A; 

c       = handles.ind_plot_min_A; 
d       = handles.ind_plot_max_A; 

delta_b = ceil(  (d-c)/500  );
delta_b = max(1, delta_b); 
b       = b - delta_b; 

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_nu_max = b; 


guidata(hObject, handles);
myRefresh_A(hObject, handles); 

end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
b_max   = handles.ind_plot_max_0_A; 

c       = handles.ind_plot_min_A; 
d       = handles.ind_plot_max_A; 

delta_b = ceil(  (d-c)/50  );
delta_b = max(1, delta_b); 
b       = b + delta_b; 

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_nu_max = b; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
b_max   = handles.ind_plot_max_0_A; 

b       = ceil(  (5*b - a)/4  );

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_nu_max = b; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
b_max   = handles.ind_plot_max_0_A; 

c       = handles.ind_plot_min_A; 
d       = handles.ind_plot_max_A; 

delta_b = ceil(  (d-c)/500  );
delta_b = max(1, delta_b); 
b       = b + delta_b; 

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_nu_max = b; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
b_max   = handles.ind_plot_max_0_A; 

b       = floor(  (3*b + a)/4  );

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_nu_max = b; 


guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
a_min   = handles.ind_plot_min_0_A; 

c       = handles.ind_plot_min_A; 
d       = handles.ind_plot_max_A; 

delta_a = ceil(  (d-c)/50  );
delta_a = max(1, delta_a); 
a       = a - delta_a; 

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_nu_min = a; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
a_min   = handles.ind_plot_min_0_A; 

c       = handles.ind_plot_min_A; 
d       = handles.ind_plot_max_A; 

delta_a = ceil(  (d-c)/500  );
delta_a = max(1, delta_a); 
a       = a - delta_a; 

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_nu_min = a; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
a_min   = handles.ind_plot_min_0_A; 

c       = handles.ind_plot_min_A; 
d       = handles.ind_plot_max_A; 

delta_a = ceil(  (d-c)/50  );
delta_a = max(1, delta_a); 
a       = a + delta_a; 

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_nu_min = a; 


guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
a_min   = handles.ind_plot_min_0_A; 

a       = ceil(  (3*a + b)/4  );

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_nu_min = a; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
a_min   = handles.ind_plot_min_0_A; 

c       = handles.ind_plot_min_A; 
d       = handles.ind_plot_max_A; 

delta_a = ceil(  (d-c)/500  );
delta_a = max(1, delta_a); 
a       = a + delta_a; 

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_nu_min = a; 

guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_nu_min; 
b       = handles.ind_nu_max;
a_min   = handles.ind_plot_min_0_A; 

a       = floor(  (5*a - b)/4  );

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_nu_min = a; 


guidata(hObject, handles);
myRefresh_A(hObject, handles); 
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_Hplot_min_B; 
b       = handles.ind_Hplot_max_B;
a_min   = handles.ind_Hplot_min_0_B; 

a       = floor(  (5*a - b)/4  );

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_Hplot_min_B = a; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_Hplot_min_B; 
b       = handles.ind_Hplot_max_B;
a_min   = handles.ind_Hplot_min_0_B; 

a       = floor(  (3*a + b)/4  );

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_Hplot_min_B = a; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end

% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_Hplot_min_B; 
b       = handles.ind_Hplot_max_B;
b_max   = handles.ind_Hplot_max_0_B; 

b       = ceil(  (3*b + a)/4  );

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_Hplot_max_B = b; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end

% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_Hplot_min_B; 
b       = handles.ind_Hplot_max_B;
b_max   = handles.ind_Hplot_max_0_B; 

b       = ceil(  (5*b - a)/4  );

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_Hplot_max_B = b; 


guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a           = handles.ind_Hplot_min_B; 
b           = handles.ind_Hplot_max_B;
a_min       = handles.ind_Hplot_min_0_B;
delta_ind   = b - a; 

a           = floor(  a - (b-a)/6  );
a           = max(a, a_min); 
b           = a + delta_ind; 

handles.ind_Hplot_min_B = a; 
handles.ind_Hplot_max_B = b; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end

% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a           = handles.ind_Hplot_min_B; 
b           = handles.ind_Hplot_max_B;
b_max       = handles.ind_Hplot_max_0_B;
delta_ind   = b - a; 

b           = ceil(  b + (b-a)/6  );
b           = min(b, b_max); 
a           = b - delta_ind; 

handles.ind_Hplot_min_B = a; 
handles.ind_Hplot_max_B = b; 


guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = handles.s_plot_amp; 

b = handles.ind_Vplot_min_B;
c = handles.ind_Vplot_max_B;
a_max = c - b; 

a = ceil(a*1.1); 
a = min(a, a_max); 

handles.s_plot_amp = a; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end

% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = handles.s_plot_amp; 
a_min = 0.1; 

a = floor(a/1.1); 
a = max(a, a_min); 
handles.s_plot_amp = a; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end

% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = handles.s_plot_center; 

b = handles.ind_Vplot_min_B;
c = handles.ind_Vplot_max_B;
a_min = 0; 

a = floor(a - (c-b)/100); 
a = max(a, a_min); 

handles.s_plot_center = a; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = handles.s_plot_center; 

b = handles.ind_Vplot_min_B;
c = handles.ind_Vplot_max_B;
d = handles.ind_Vplot_max_0_B;

a_max = d; 

a = ceil(a + (c-b)/100); 
a = min(a, a_max); 

handles.s_plot_center = a; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imcontrast(handles.axes2);
 
end

% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.cLim = get(handles.axes2,'CLim');

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

s   = handles.s_ref; 
t   = handles.t_ref; 
Fs  = handles.Fs_ref; 
nu  = handles.nu_ref; 

L = size(s, 2); 

ind_nu_min = handles.ind_nu_min; 
ind_nu_max = handles.ind_nu_max; 

bump_jump_width = (ind_nu_max - ind_nu_min)/50; % ---------------------------- magic_number

if (ind_nu_min == L/2+1) && (ind_nu_max == L)
    m1          = true(1, L);
    m2          = false(1, L); 
    bandPass    = double(m1 - m2);
    lowPass     = double(m1); 
elseif (ind_nu_min == L/2+1) && (ind_nu_max < L)
    m1          = (   abs(nu) <= abs(  nu(1, ind_nu_max)  )   );
    m1          = bmDoor2Bump(m1, bump_jump_width);
    m2          = false(1, L); 
    bandPass    = double(m1 - m2);
    lowPass     = double(m1);  
elseif (ind_nu_min > L/2+1) && (ind_nu_max == L)
    m1          = true(1, L);
    m2          = (   abs(nu) <  abs(  nu(1, ind_nu_min)  )   ); 
    m2          = bmDoor2Bump(m2, bump_jump_width);
    bandPass    = double(m1 - m2);
    lowPass     = double(m1);  
elseif (  ind_nu_min > L/2+1  ) && (  ind_nu_max < L  )
    m1          = (   abs(nu) <= abs(  nu(1, ind_nu_max)  )   );
    m1          = bmDoor2Bump(m1, bump_jump_width);
    m2          = (   abs(nu) <  abs(  nu(1, ind_nu_min)  )   ); 
    m2          = bmDoor2Bump(m2, bump_jump_width);
    bandPass    = double(m1 - m2);
    lowPass     = double(m1);  
else 
    error('Case not implemented. ')
end

s_lowPass   = real(bmIDF(lowPass.*Fs, nu, [], 2, 2));
s_bandPass  = real(bmIDF(bandPass.*Fs, nu, [], 2, 2));


handles.lowPass_filter  = lowPass;
handles.bandPass_filter = bandPass;
handles.s_bandPass      = s_bandPass; 
handles.s_lowPass       = s_lowPass; 


% figure
% hold on
% plot(nu, abs(Fs), '.-')
% plot(nu, m*max(abs(Fs(:))), '.-')


guidata(hObject, handles);
myRefresh_A(hObject, handles); 
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.yellow_flag = false; 
guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end

% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.yellow_flag = true; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a       = handles.ind_Vplot_min_B; 
b       = handles.ind_Vplot_max_B;
a_min   = handles.ind_Vplot_min_0_B; 

a       = floor(  (3*a + b)/4  );

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_Vplot_min_B = a; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end

% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a       = handles.ind_Vplot_min_B; 
b       = handles.ind_Vplot_max_B;
b_max   = handles.ind_Vplot_max_0_B; 

b       = ceil(  (3*b + a)/4  );

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_Vplot_max_B = b; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a       = handles.ind_Vplot_min_B; 
b       = handles.ind_Vplot_max_B;
a_min   = handles.ind_Vplot_min_0_B; 

a       = floor(  (5*a - b)/4  );

a       = min(a, b-1); 
a       = max(a, a_min);

handles.ind_Vplot_min_B = a; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a       = handles.ind_Vplot_min_B; 
b       = handles.ind_Vplot_max_B;
b_max   = handles.ind_Vplot_max_0_B; 

b       = ceil(  (5*b - a)/4  );

b       = max(a+1, b); 
b       = min(b, b_max);

handles.ind_Vplot_max_B = b; 


guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a           = handles.ind_Vplot_min_B; 
b           = handles.ind_Vplot_max_B;
b_max       = handles.ind_Vplot_max_0_B;
delta_ind   = b - a; 

b           = ceil(  b + (b-a)/6  );
b           = min(b, b_max); 
a           = b - delta_ind; 

handles.ind_Vplot_min_B = a; 
handles.ind_Vplot_max_B = b; 


guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a           = handles.ind_Vplot_min_B; 
b           = handles.ind_Vplot_max_B;
a_min       = handles.ind_Vplot_min_0_B;
delta_ind   = b - a; 

a           = floor(  a - (b-a)/6  );
a           = max(a, a_min); 
b           = a + delta_ind; 

handles.ind_Vplot_min_B = a; 
handles.ind_Vplot_max_B = b; 

guidata(hObject, handles);
myRefresh_B(hObject, handles); 
end
