function varargout = ConfigureSignalGenerator(varargin)
% CONFIGURESIGNALGENERATOR M-file for ConfigureSignalGenerator.fig
%      CONFIGURESIGNALGENERATOR, by itself, creates a new CONFIGURESIGNALGENERATOR or raises the existing
%      singleton*.
%
%      H = CONFIGURESIGNALGENERATOR returns the handle to a new CONFIGURESIGNALGENERATOR or the handle to
%      the existing singleton*.
%
%      CONFIGURESIGNALGENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGURESIGNALGENERATOR.M with the given input arguments.
%
%      CONFIGURESIGNALGENERATOR('Property','Value',...) creates a new CONFIGURESIGNALGENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ConfigureSignalGenerator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ConfigureSignalGenerator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ConfigureSignalGenerator

% Last Modified by GUIDE v2.5 05-Jun-2024 15:18:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConfigureSignalGenerator_OpeningFcn, ...
                   'gui_OutputFcn',  @ConfigureSignalGenerator_OutputFcn, ...
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


% --- Executes just before ConfigureSignalGenerator is made visible.
function ConfigureSignalGenerator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConfigureSignalGenerator (see VARARGIN)

% Choose default command line output for ConfigureSignalGenerator
handles.output = hObject;

handles.hSignalGenerator = varargin{1};

ConfigureSignalGeneratorFunctions('Initialize',hObject,handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ConfigureSignalGenerator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ConfigureSignalGenerator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to editFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrequency as text
%        str2double(get(hObject,'String')) returns contents of editFrequency as a double


% --- Executes during object creation, after setting all properties.
function editFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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

% --- Executes on selection change in sweepType.
function sweepType_Callback(hObject, eventdata, handles)
% hObject    handle to sweepType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sweepType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sweepType


% --- Executes during object creation, after setting all properties.
function sweepType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sweepType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to editStartFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartFrequency as text
%        str2double(get(hObject,'String')) returns contents of editStartFrequency as a double


% --- Executes during object creation, after setting all properties.
function editStartFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStopFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to editStopFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStopFrequency as text
%        str2double(get(hObject,'String')) returns contents of editStopFrequency as a double


% --- Executes during object creation, after setting all properties.
function editStopFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStopFrequency (see GCBO)
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


% --- Executes on selection change in sweepTrigger.
function sweepTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to sweepTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sweepTrigger contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sweepTrigger


% --- Executes during object creation, after setting all properties.
function sweepTrigger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sweepTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonDone.
function buttonDone_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureSignalGeneratorFunctions('SetAll',hObject, eventdata, handles);
close();

% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close();

% --- Executes on button press in buttonSet.
function buttonSet_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureSignalGeneratorFunctions('SetAll',hObject, eventdata, handles);


% --- Executes on button press in boxAutoSet.
function boxAutoSet_Callback(hObject, eventdata, handles)
% hObject    handle to boxAutoSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of boxAutoSet


% --- Executes on button press in buttonQuery.
function buttonQuery_Callback(hObject, eventdata, handles)
% hObject    handle to buttonQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureSignalGeneratorFunctions('Query',hObject,handles)

% --- Executes on selection change in sweepDirection.
function sweepDirection_Callback(hObject, eventdata, handles)
% hObject    handle to sweepDirection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sweepDirection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sweepDirection


% --- Executes during object creation, after setting all properties.
function sweepDirection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sweepDirection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in freqMode.
function freqMode_Callback(hObject, eventdata, handles)
% hObject    handle to freqMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns freqMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from freqMode


% --- Executes during object creation, after setting all properties.
function freqMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateFreButton.
function updateFreButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateFreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StartFreq = get(handles.editStartFrequency,'String');
StopFreq = get(handles.editStopFrequency,'String');
StartFreq2 = 2*2.87e9-str2double(StopFreq);
StopFreq2 = 2*2.87e9-str2double(StartFreq);
set(handles.editStartFrequency2,'String',sprintf('%.4g',StartFreq2));
set(handles.editStopFrequency2,'String',sprintf('%.4g',StopFreq2));

% --- Executes on button press in checkboxRightsideSweep.
function checkboxRightsideSweep_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxRightsideSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxRightsideSweep



function editStartFrequency2_Callback(hObject, eventdata, handles)
% hObject    handle to editStartFrequency2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartFrequency2 as text
%        str2double(get(hObject,'String')) returns contents of editStartFrequency2 as a double


% --- Executes during object creation, after setting all properties.
function editStartFrequency2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartFrequency2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStopFrequency2_Callback(hObject, eventdata, handles)
% hObject    handle to editStopFrequency2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStopFrequency2 as text
%        str2double(get(hObject,'String')) returns contents of editStopFrequency2 as a double


% --- Executes during object creation, after setting all properties.
function editStopFrequency2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStopFrequency2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over updateFreButton.
function updateFreButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to updateFreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
