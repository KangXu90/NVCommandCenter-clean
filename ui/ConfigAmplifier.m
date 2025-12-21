function varargout = ConfigAmplifier(varargin)
% CONFIGAMPLIFIER MATLAB code for ConfigAmplifier.fig
%      CONFIGAMPLIFIER, by itself, creates a new CONFIGAMPLIFIER or raises the existing
%      singleton*.
%
%      H = CONFIGAMPLIFIER returns the handle to a new CONFIGAMPLIFIER or the handle to
%      the existing singleton*.
%
%      CONFIGAMPLIFIER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGAMPLIFIER.M with the given input arguments.
%
%      CONFIGAMPLIFIER('Property','Value',...) creates a new CONFIGAMPLIFIER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ConfigAmplifier_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ConfigAmplifier_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ConfigAmplifier

% Last Modified by GUIDE v2.5 20-Jan-2025 14:29:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConfigAmplifier_OpeningFcn, ...
                   'gui_OutputFcn',  @ConfigAmplifier_OutputFcn, ...
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


% --- Executes just before ConfigAmplifier is made visible.
function ConfigAmplifier_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConfigAmplifier (see VARARGIN)

% Choose default command line output for ConfigAmplifier
handles.output = hObject;

% setup the microwave amplifier
MA = instrfind('Type', 'visa-serial', 'RsrcName', 'ASRL5::INSTR', 'Tag', '');
% Create the VISA-Serial object if it does not exist
% otherwise use the object that was found.
if isempty(MA)
    MA = visa('NI', 'ASRL5::INSTR');
    
else
    fclose(MA);
    MA = MA(1);
end
handles.MA = MA;
fopen(handles.MA);
currentGain = query(handles.MA,'RFG?');
Gainnumber = regexp(currentGain,'000?(\d+)','tokens');
set(handles.editGain,'string',Gainnumber{1});
% Update handles structure
fclose(handles.MA);
guidata(hObject, handles);

% UIWAIT makes ConfigAmplifier wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ConfigAmplifier_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editGain_Callback(hObject, eventdata, handles)
% hObject    handle to editGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGain as text
%        str2double(get(hObject,'String')) returns contents of editGain as a double


% --- Executes during object creation, after setting all properties.
function editGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartGain_Callback(hObject, eventdata, handles)
% hObject    handle to editStartGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartGain as text
%        str2double(get(hObject,'String')) returns contents of editStartGain as a double


% --- Executes during object creation, after setting all properties.
function editStartGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStopGain_Callback(hObject, eventdata, handles)
% hObject    handle to editStopGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStopGain as text
%        str2double(get(hObject,'String')) returns contents of editStopGain as a double


% --- Executes during object creation, after setting all properties.
function editStopGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStopGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPoints_Callback(hObject, eventdata, handles)
% hObject    handle to editPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPoints as text
%        str2double(get(hObject,'String')) returns contents of editPoints as a double


% --- Executes during object creation, after setting all properties.
function editPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Setup.
function Setup_Callback(hObject, eventdata, handles)
% hObject    handle to Setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Gain = get(handles.editGain,'String');
StartGain = get(handles.editStartGain,'String');
StopGain = get(handles.editStopGain,'String');
Points = get(handles.editPoints,'String');
fopen(handles.MA);
fprintf(handles.MA,['LEVEL:GAIN',Gain{1}]);
if  get(handles.powerSwitch,'Value')
fprintf(handles.MA,'POWER:ON');
else
fprintf(handles.MA,'POWER:OFF');
end

currentState = query(handles.MA,'STATE?');
currentFault = query(handles.MA,'FSTA?');
currentGain = query(handles.MA,'RFG?');

currentHours = query(handles.MA,'OHP?');
currentQuery = [currentState, currentFault,currentGain,currentHours];
% Gainnumber = regexp(currentGain,'000?(\d+)','tokens');
set(handles.textQuery,'string',currentQuery);

fclose(handles.MA);
% if 
% fprintf(MA,['LEVEL:GAIN',GAIN]);


% --- Executes on button press in PowerSwitch.
function PowerSwitch_Callback(hObject, eventdata, handles)
% hObject    handle to PowerSwitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PowerSwitch


% --- Executes on button press in powerSwitch.
function powerSwitch_Callback(hObject, eventdata, handles)
% hObject    handle to powerSwitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of powerSwitch


% --- Executes on button press in pushbuttonQuery.
function pushbuttonQuery_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fopen(handles.MA);
currentState = query(handles.MA,'STATE?');
currentFault = query(handles.MA,'FSTA?');
currentGain = query(handles.MA,'RFG?');

currentHours = query(handles.MA,'OHP?');
currentQuery = [currentState, currentFault,currentGain,currentHours];
% Gainnumber = regexp(currentGain,'000?(\d+)','tokens');
set(handles.textQuery,'string',currentQuery);

fclose(handles.MA);


% --- Executes on button press in pushbuttonResetFault.
function pushbuttonResetFault_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonResetFault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fopen(handles.MA);

fprintf(handles.MA,'RESET');

fclose(handles.MA);


% --- Executes on button press in pushbuttonResetFactory.
function pushbuttonResetFactory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonResetFactory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fopen(handles.MA);

fprintf(handles.MA,'DEFAULT:FATORY');

fclose(handles.MA);
