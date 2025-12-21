function varargout = ConfigTaborProteus(varargin)
% CONFIGTABORPROTEUS MATLAB code for ConfigTaborProteus.fig
%      CONFIGTABORPROTEUS, by itself, creates a new CONFIGTABORPROTEUS or raises the existing
%      singleton*.
%
%      H = CONFIGTABORPROTEUS returns the handle to a new CONFIGTABORPROTEUS or the handle to
%      the existing singleton*.
%
%      CONFIGTABORPROTEUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGTABORPROTEUS.M with the given input arguments.
%
%      CONFIGTABORPROTEUS('Property','Value',...) creates a new CONFIGTABORPROTEUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ConfigTaborProteus_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ConfigTaborProteus_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ConfigTaborProteus

% Last Modified by GUIDE v2.5 28-Aug-2024 17:02:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConfigTaborProteus_OpeningFcn, ...
                   'gui_OutputFcn',  @ConfigTaborProteus_OutputFcn, ...
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


% --- Executes just before ConfigTaborProteus is made visible.
function ConfigTaborProteus_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConfigTaborProteus (see VARARGIN)

% Choose default command line output for ConfigTaborProteus
handles.output = hObject;

handles.hSignalGenerator = varargin{1};

ConfigureSignalGeneratorFunctions('Initialize',hObject,handles);

% set(handles.editFrequency1,'String',1e+09);
set(handles.checkboxApply6dB1,'Value',1);
set(handles.popupmenuInterpolation,'Value',4);
set(handles.popupmenuDACmode,'Value',3);
set(handles.editSamplingRate,'String',9e+9);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ConfigTaborProteus wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ConfigTaborProteus_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenuChannel.
function popupmenuChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Chann = get(handles.popupmenuChannel, 'Value');
handles.hSignalGenerator.Channel = Chann;
ConfigureSignalGeneratorFunctions('Initialize',hObject,handles);





% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuChannel


% --- Executes during object creation, after setting all properties.
function popupmenuChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel1 is resized.
function uipanel1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuDACmode.
function popupmenuDACmode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDACmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuDACmode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDACmode


% --- Executes during object creation, after setting all properties.
function popupmenuDACmode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuDACmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuInterpolation.
function popupmenuInterpolation_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuInterpolation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuInterpolation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuInterpolation


% --- Executes during object creation, after setting all properties.
function popupmenuInterpolation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuInterpolation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFrequency1_Callback(hObject, eventdata, handles)
% hObject    handle to editFrequency1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrequency1 as text
%        str2double(get(hObject,'String')) returns contents of editFrequency1 as a double


% --- Executes during object creation, after setting all properties.
function editFrequency1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrequency1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPhase1_Callback(hObject, eventdata, handles)
% hObject    handle to editPhase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPhase1 as text
%        str2double(get(hObject,'String')) returns contents of editPhase1 as a double


% --- Executes during object creation, after setting all properties.
function editPhase1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPhase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxApply6dB1.
function checkboxApply6dB1_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxApply6dB1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxApply6dB1



function editSamplingRate_Callback(hObject, eventdata, handles)
% hObject    handle to editSamplingRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSamplingRate as text
%        str2double(get(hObject,'String')) returns contents of editSamplingRate as a double


% --- Executes during object creation, after setting all properties.
function editSamplingRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamplingRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFrequency2_Callback(hObject, eventdata, handles)
% hObject    handle to editFrequency2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrequency2 as text
%        str2double(get(hObject,'String')) returns contents of editFrequency2 as a double


% --- Executes during object creation, after setting all properties.
function editFrequency2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrequency2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPhase2_Callback(hObject, eventdata, handles)
% hObject    handle to editPhase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPhase2 as text
%        str2double(get(hObject,'String')) returns contents of editPhase2 as a double


% --- Executes during object creation, after setting all properties.
function editPhase2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPhase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxApply6dB2.
function checkboxApply6dB2_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxApply6dB2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxApply6dB2



function editAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to editAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAmplitude as text
%        str2double(get(hObject,'String')) returns contents of editAmplitude as a double


% --- Executes during object creation, after setting all properties.
function editAmplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radioRFOn.
function radioRFOn_Callback(hObject, eventdata, handles)
% hObject    handle to radioRFOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioRFOn


% --- Executes on button press in radioRFOff.
function radioRFOff_Callback(hObject, eventdata, handles)
% hObject    handle to radioRFOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioRFOff


% --- Executes on button press in pushbuttonSetChannel.
function pushbuttonSetChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureSignalGeneratorFunctions('SetOutput',hObject, eventdata, handles);


% --- Executes on button press in pushbuttonSetSweep.
function pushbuttonSetSweep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureSignalGeneratorFunctions('SetFrequencySweep',hObject, eventdata, handles);


% --- Executes on selection change in popupmenuNCOmode.
function popupmenuNCOmode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuNCOmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuNCOmode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuNCOmode


% --- Executes during object creation, after setting all properties.
function popupmenuNCOmode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuNCOmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSweepStop2_Callback(hObject, eventdata, handles)
% hObject    handle to editSweepStop2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSweepStop2 as text
%        str2double(get(hObject,'String')) returns contents of editSweepStop2 as a double


% --- Executes during object creation, after setting all properties.
function editSweepStop2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSweepStop2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSweepStart2_Callback(hObject, eventdata, handles)
% hObject    handle to editSweepStart2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSweepStart2 as text
%        str2double(get(hObject,'String')) returns contents of editSweepStart2 as a double


% --- Executes during object creation, after setting all properties.
function editSweepStart2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSweepStart2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSweepStart1_Callback(hObject, eventdata, handles)
% hObject    handle to editSweepStart1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSweepStart1 as text
%        str2double(get(hObject,'String')) returns contents of editSweepStart1 as a double


% --- Executes during object creation, after setting all properties.
function editSweepStart1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSweepStart1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSweepStop1_Callback(hObject, eventdata, handles)
% hObject    handle to editSweepStop1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSweepStop1 as text
%        str2double(get(hObject,'String')) returns contents of editSweepStop1 as a double


% --- Executes during object creation, after setting all properties.
function editSweepStop1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSweepStop1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSweepPoints1_Callback(hObject, eventdata, handles)
% hObject    handle to editSweepPoints1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSweepPoints1 as text
%        str2double(get(hObject,'String')) returns contents of editSweepPoints1 as a double


% --- Executes during object creation, after setting all properties.
function editSweepPoints1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSweepPoints1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSweepPoints2_Callback(hObject, eventdata, handles)
% hObject    handle to editSweepPoints2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSweepPoints2 as text
%        str2double(get(hObject,'String')) returns contents of editSweepPoints2 as a double


% --- Executes during object creation, after setting all properties.
function editSweepPoints2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSweepPoints2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSweepZoneState1.
function checkboxSweepZoneState1_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSweepZoneState1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSweepZoneState1


% --- Executes on button press in checkboxSweepZoneState2.
function checkboxSweepZoneState2_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSweepZoneState2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSweepZoneState2


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in togglebuttonLinkFrequency.
function togglebuttonLinkFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonLinkFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonLinkFrequency


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over togglebuttonLinkFrequency.
function togglebuttonLinkFrequency_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to togglebuttonLinkFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobuttonLinkFrequency.
function radiobuttonLinkFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonLinkFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonLinkFrequency


% --- Executes on button press in pushbuttonQuery.
function pushbuttonQuery_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureSignalGeneratorFunctions('Query',hObject, eventdata, handles);


% --- Executes on button press in pushbuttonUpdateFrequency.
function pushbuttonUpdateFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUpdateFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SweepStart1 = get(handles.editSweepStart1,'String');
SweepStop1 = get(handles.editSweepStop1,'String');
SweepPoints1 = get(handles.editSweepPoints1,'String');
SweepStart2 = 2*2.87e9-str2double(SweepStart1);
SweepStop2 = 2*2.87e9-str2double(SweepStop1);
SweepPoints2 = str2double(SweepPoints1);
set(handles.editSweepStart2,'String',sprintf('%.4g',SweepStart2));
set(handles.editSweepStop2,'String',sprintf('%.4g',SweepStop2));
set(handles.editSweepPoints2,'String',sprintf('%.4g',SweepPoints2));
