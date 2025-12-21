function varargout = PulseSequencer(varargin)
% PULSESEQUENCER M-file for PulseSequencer.fig
%      PULSESEQUENCER, by itself, creates a new PULSESEQUENCER or raises the existing
%      singleton*.
%
%      H = PULSESEQUENCER returns the handle to a new PULSESEQUENCER or the handle to
%      the existing singleton*.
%
%      PULSESEQUENCER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PULSESEQUENCER.M with the given input arguments.
%
%      PULSESEQUENCER('Property','Value',...) creates a new PULSESEQUENCER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditSequence_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PulseSequencer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PulseSequencer

% Last Modified by GUIDE v2.5 27-Jun-2024 18:18:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PulseSequencer_OpeningFcn, ...
                   'gui_OutputFcn',  @PulseSequencer_OutputFcn, ...
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


% --- Executes just before PulseSequencer is made visible.
function PulseSequencer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PulseSequencer (see VARARGIN)

% Choose default command line output for PulseSequencer
handles.output = hObject;

% if called with input argument, then set is, otherwise, create a new one
if nargin > 3,
    handles.PSeq = varargin{1};
else
    handles.PSeq = PulseSequence();
end

handles.backupPSeq = handles.PSeq.clone();

% Update handles structure
guidata(hObject, handles);


% InitEvets
addlistener(handles.PSeq,'PulseSeqeunceChangedState',@(src,evnt)PulseSequencerFunctions('EventPSChangeState',src,evnt,hObject));

% UIWAIT makes PulseSequencer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

PulseSequencerFunctions('Init',hObject, eventdata, handles);

% --- Outputs from this function are returned to the command line.
function varargout = PulseSequencer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
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


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editT_Callback(hObject, eventdata, handles)
% hObject    handle to editT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editT as text
%        str2double(get(hObject,'String')) returns contents of editT as a double
PulseSequencerFunctions('UpdateRiseInput',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDT_Callback(hObject, eventdata, handles)
% hObject    handle to editDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDT as text
%        str2double(get(hObject,'String')) returns contents of editDT as a double
PulseSequencerFunctions('UpdateRiseInput',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editDT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON1_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON1 as text
%        str2double(get(hObject,'String')) returns contents of DelayON1 as a double
EditgEditSEQ('DelayON',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DelayON1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF1_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF1 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF1 as a double
EditgEditSEQ('DelayOFF',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DelayOFF1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBN2.
function PBN2_Callback(hObject, eventdata, handles)
% hObject    handle to PBN2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBN2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBN2
EditgEditSEQ('PBN2',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PBN2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBN2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rise2.
function Rise2_Callback(hObject, eventdata, handles)
% hObject    handle to Rise2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rise2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rise2


% --- Executes during object creation, after setting all properties.
function Rise2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rise2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeON2_Callback(hObject, eventdata, handles)
% hObject    handle to TimeON2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeON2 as text
%        str2double(get(hObject,'String')) returns contents of TimeON2 as a double
EditgEditSEQ('TimeON2',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TimeON2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeON2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DT2_Callback(hObject, eventdata, handles)
% hObject    handle to DT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DT2 as text
%        str2double(get(hObject,'String')) returns contents of DT2 as a double
EditgEditSEQ('DT2',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DT2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON2_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON2 as text
%        str2double(get(hObject,'String')) returns contents of DelayON2 as a double


% --- Executes during object creation, after setting all properties.
function DelayON2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF2_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF2 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF2 as a double


% --- Executes during object creation, after setting all properties.
function DelayOFF2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBN3.
function PBN3_Callback(hObject, eventdata, handles)
% hObject    handle to PBN3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBN3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBN3
EditgEditSEQ('PBN3',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PBN3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBN3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RISE3.
function RISE3_Callback(hObject, eventdata, handles)
% hObject    handle to RISE3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RISE3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RISE3


% --- Executes during object creation, after setting all properties.
function RISE3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RISE3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeON3_Callback(hObject, eventdata, handles)
% hObject    handle to TimeON3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeON3 as text
%        str2double(get(hObject,'String')) returns contents of TimeON3 as a double
EditgEditSEQ('TimeON3',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TimeON3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeON3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DT3_Callback(hObject, eventdata, handles)
% hObject    handle to DT3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DT3 as text
%        str2double(get(hObject,'String')) returns contents of DT3 as a double
EditgEditSEQ('DT3',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DT3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON3_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON3 as text
%        str2double(get(hObject,'String')) returns contents of DelayON3 as a double


% --- Executes during object creation, after setting all properties.
function DelayON3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF3_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF3 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF3 as a double


% --- Executes during object creation, after setting all properties.
function DelayOFF3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBN4.
function PBN4_Callback(hObject, eventdata, handles)
% hObject    handle to PBN4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBN4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBN4
EditgEditSEQ('PBN4',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PBN4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBN4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RISE4.
function RISE4_Callback(hObject, eventdata, handles)
% hObject    handle to RISE4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RISE4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RISE4


% --- Executes during object creation, after setting all properties.
function RISE4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RISE4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeON4_Callback(hObject, eventdata, handles)
% hObject    handle to TimeON4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeON4 as text
%        str2double(get(hObject,'String')) returns contents of TimeON4 as a double
EditgEditSEQ('TimeON4',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TimeON4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeON4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DT4_Callback(hObject, eventdata, handles)
% hObject    handle to DT4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DT4 as text
%        str2double(get(hObject,'String')) returns contents of DT4 as a double
EditgEditSEQ('DT4',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DT4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON4_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON4 as text
%        str2double(get(hObject,'String')) returns contents of DelayON4 as a double


% --- Executes during object creation, after setting all properties.
function DelayON4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF4_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF4 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF4 as a double


% --- Executes during object creation, after setting all properties.
function DelayOFF4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBN5.
function PBN5_Callback(hObject, eventdata, handles)
% hObject    handle to PBN5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBN5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBN5
EditgEditSEQ('PBN5',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PBN5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBN5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RISE5.
function RISE5_Callback(hObject, eventdata, handles)
% hObject    handle to RISE5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RISE5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RISE5


% --- Executes during object creation, after setting all properties.
function RISE5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RISE5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeON5_Callback(hObject, eventdata, handles)
% hObject    handle to TimeON5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeON5 as text
%        str2double(get(hObject,'String')) returns contents of TimeON5 as a double
EditgEditSEQ('TimeON5',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TimeON5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeON5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DT5_Callback(hObject, eventdata, handles)
% hObject    handle to DT5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DT5 as text
%        str2double(get(hObject,'String')) returns contents of DT5 as a double
EditgEditSEQ('DT5',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DT5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON5_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON5 as text
%        str2double(get(hObject,'String')) returns contents of DelayON5 as a double


% --- Executes during object creation, after setting all properties.
function DelayON5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF5_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF5 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF5 as a double


% --- Executes during object creation, after setting all properties.
function DelayOFF5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBN6.
function PBN6_Callback(hObject, eventdata, handles)
% hObject    handle to PBN6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBN6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBN6
EditgEditSEQ('PBN6',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PBN6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBN6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RISE6.
function RISE6_Callback(hObject, eventdata, handles)
% hObject    handle to RISE6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RISE6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RISE6


% --- Executes during object creation, after setting all properties.
function RISE6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RISE6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeON6_Callback(hObject, eventdata, handles)
% hObject    handle to TimeON6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeON6 as text
%        str2double(get(hObject,'String')) returns contents of TimeON6 as a double
EditgEditSEQ('TimeON6',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TimeON6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeON6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DT6_Callback(hObject, eventdata, handles)
% hObject    handle to DT6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DT6 as text
%        str2double(get(hObject,'String')) returns contents of DT6 as a double
EditgEditSEQ('DT6',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DT6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON6_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON6 as text
%        str2double(get(hObject,'String')) returns contents of DelayON6 as a double


% --- Executes during object creation, after setting all properties.
function DelayON6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF6_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF6 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF6 as a double


% --- Executes during object creation, after setting all properties.
function DelayOFF6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBN7.
function PBN7_Callback(hObject, eventdata, handles)
% hObject    handle to PBN7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBN7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBN7
EditgEditSEQ('PBN7',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PBN7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBN7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RISE7.
function RISE7_Callback(hObject, eventdata, handles)
% hObject    handle to RISE7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RISE7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RISE7


% --- Executes during object creation, after setting all properties.
function RISE7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RISE7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeON7_Callback(hObject, eventdata, handles)
% hObject    handle to TimeON7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeON7 as text
%        str2double(get(hObject,'String')) returns contents of TimeON7 as a double
EditgEditSEQ('TimeON7',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TimeON7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeON7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DT7_Callback(hObject, eventdata, handles)
% hObject    handle to DT7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DT7 as text
%        str2double(get(hObject,'String')) returns contents of DT7 as a double
EditgEditSEQ('DT7',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DT7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON7_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON7 as text
%        str2double(get(hObject,'String')) returns contents of DelayON7 as a double


% --- Executes during object creation, after setting all properties.
function DelayON7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF7_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF7 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF7 as a double


% --- Executes during object creation, after setting all properties.
function DelayOFF7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBN8.
function PBN8_Callback(hObject, eventdata, handles)
% hObject    handle to PBN8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBN8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBN8
EditgEditSEQ('PBN8',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PBN8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBN8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RISE8.
function RISE8_Callback(hObject, eventdata, handles)
% hObject    handle to RISE8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RISE8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RISE8


% --- Executes during object creation, after setting all properties.
function RISE8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RISE8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeON8_Callback(hObject, eventdata, handles)
% hObject    handle to TimeON8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeON8 as text
%        str2double(get(hObject,'String')) returns contents of TimeON8 as a double
EditgEditSEQ('TimeON8',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TimeON8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeON8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DT8_Callback(hObject, eventdata, handles)
% hObject    handle to DT8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DT8 as text
%        str2double(get(hObject,'String')) returns contents of DT8 as a double
EditgEditSEQ('DT8',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DT8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON8_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON8 as text
%        str2double(get(hObject,'String')) returns contents of DelayON8 as a double


% --- Executes during object creation, after setting all properties.
function DelayON8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF8_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF8 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF8 as a double


% --- Executes during object creation, after setting all properties.
function DelayOFF8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBN9.
function PBN9_Callback(hObject, eventdata, handles)
% hObject    handle to PBN9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBN9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBN9
EditgEditSEQ('PBN9',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PBN9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBN9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RISE9.
function RISE9_Callback(hObject, eventdata, handles)
% hObject    handle to RISE9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RISE9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RISE9


% --- Executes during object creation, after setting all properties.
function RISE9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RISE9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeON9_Callback(hObject, eventdata, handles)
% hObject    handle to TimeON9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeON9 as text
%        str2double(get(hObject,'String')) returns contents of TimeON9 as a double
EditgEditSEQ('TimeON9',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TimeON9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeON9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DT9_Callback(hObject, eventdata, handles)
% hObject    handle to DT9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DT9 as text
%        str2double(get(hObject,'String')) returns contents of DT9 as a double
EditgEditSEQ('DT9',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DT9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayON9_Callback(hObject, eventdata, handles)
% hObject    handle to DelayON9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayON9 as text
%        str2double(get(hObject,'String')) returns contents of DelayON9 as a double


% --- Executes during object creation, after setting all properties.
function DelayON9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayON9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DelayOFF9_Callback(hObject, eventdata, handles)
% hObject    handle to DelayOFF9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DelayOFF9 as text
%        str2double(get(hObject,'String')) returns contents of DelayOFF9 as a double


% --- Executes during object creation, after setting all properties.
function DelayOFF9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayOFF9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RISE2.
function RISE2_Callback(hObject, eventdata, handles)
% hObject    handle to RISE2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RISE2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RISE2


% --- Executes during object creation, after setting all properties.
function RISE2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RISE2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DONE.
function DONE_Callback(hObject, eventdata, handles)
% hObject    handle to DONE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;

% --- Executes on button press in SaveSeqAs.
function SaveSeqAs_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSeqAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in Refresh.
function Refresh_Callback(hObject, eventdata, handles)
% hObject    handle to Refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('DrawSequence',hObject, eventdata, handles);

% --- Executes on button press in EditOpenSeq.
function EditOpenSeq_Callback(hObject, eventdata, handles)
% hObject    handle to EditOpenSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditSequenceFunctionPool('OpenAddSequence',hObject, eventdata, handles);

% --- Executes on selection change in popupmenu21.
function popupmenu21_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu21 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu21


% --- Executes during object creation, after setting all properties.
function popupmenu21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SubPBN1.
function SubPBN1_Callback(hObject, eventdata, handles)
% hObject    handle to SubPBN1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SubPBN1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SubPBN1


% --- Executes during object creation, after setting all properties.
function SubPBN1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubPBN1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu23.
function popupmenu23_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu23 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu23


% --- Executes during object creation, after setting all properties.
function popupmenu23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu24.
function popupmenu24_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu24 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu24


% --- Executes during object creation, after setting all properties.
function popupmenu24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu25.
function popupmenu25_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu25 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu25


% --- Executes during object creation, after setting all properties.
function popupmenu25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu26.
function popupmenu26_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu26 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu26


% --- Executes during object creation, after setting all properties.
function popupmenu26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu27.
function popupmenu27_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu27 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu27


% --- Executes during object creation, after setting all properties.
function popupmenu27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu28.
function popupmenu28_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu28 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu28


% --- Executes during object creation, after setting all properties.
function popupmenu28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu29.
function popupmenu29_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu29 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu29


% --- Executes during object creation, after setting all properties.
function popupmenu29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu30.
function popupmenu30_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu30 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu30


% --- Executes during object creation, after setting all properties.
function popupmenu30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu31.
function popupmenu31_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu31 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu31


% --- Executes during object creation, after setting all properties.
function popupmenu31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu32.
function popupmenu32_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu32 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu32


% --- Executes during object creation, after setting all properties.
function popupmenu32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu33.
function popupmenu33_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu33 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu33


% --- Executes during object creation, after setting all properties.
function popupmenu33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu34.
function popupmenu34_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu34 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu34


% --- Executes during object creation, after setting all properties.
function popupmenu34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu35.
function popupmenu35_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu35 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu35


% --- Executes during object creation, after setting all properties.
function popupmenu35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu36.
function popupmenu36_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu36 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu36


% --- Executes during object creation, after setting all properties.
function popupmenu36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu37.
function popupmenu37_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu37 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu37


% --- Executes during object creation, after setting all properties.
function popupmenu37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddSubSeq.
function AddSubSeq_Callback(hObject, eventdata, handles)
% hObject    handle to AddSubSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditSequenceFunctionPool('AddSubSeq',hObject, eventdata, handles);


function NTimes_Callback(hObject, eventdata, handles)
% hObject    handle to NTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NTimes as text
%        str2double(get(hObject,'String')) returns contents of NTimes as a double


% --- Executes during object creation, after setting all properties.
function NTimes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Type.
function Type_Callback(hObject, eventdata, handles)
% hObject    handle to Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Type


% --- Executes during object creation, after setting all properties.
function Type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit48_Callback(hObject, eventdata, handles)
% hObject    handle to edit48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit48 as text
%        str2double(get(hObject,'String')) returns contents of edit48 as a double


% --- Executes during object creation, after setting all properties.
function edit48_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editType_Callback(hObject, eventdata, handles)
% hObject    handle to editType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editType as text
%        str2double(get(hObject,'String')) returns contents of editType as a double
PulseSequencerFunctions('UpdateRiseInput',hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit39_Callback(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit39 as text
%        str2double(get(hObject,'String')) returns contents of edit39 as a double


% --- Executes during object creation, after setting all properties.
function edit39_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit40_Callback(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit40 as text
%        str2double(get(hObject,'String')) returns contents of edit40 as a double


% --- Executes during object creation, after setting all properties.
function edit40_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit41_Callback(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit41 as text
%        str2double(get(hObject,'String')) returns contents of edit41 as a double


% --- Executes during object creation, after setting all properties.
function edit41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit42_Callback(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit42 as text
%        str2double(get(hObject,'String')) returns contents of edit42 as a double


% --- Executes during object creation, after setting all properties.
function edit42_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit43_Callback(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit43 as text
%        str2double(get(hObject,'String')) returns contents of edit43 as a double


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit44_Callback(hObject, eventdata, handles)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit44 as text
%        str2double(get(hObject,'String')) returns contents of edit44 as a double


% --- Executes during object creation, after setting all properties.
function edit44_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit45_Callback(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit45 as text
%        str2double(get(hObject,'String')) returns contents of edit45 as a double


% --- Executes during object creation, after setting all properties.
function edit45_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit46 as text
%        str2double(get(hObject,'String')) returns contents of edit46 as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveSeq.
function SaveSeq_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    SaveSequence('SaveFile');

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.PSeq.copy(handles.backupPSeq);

close;

% --- Executes on selection change in Rise3.
function Rise3_Callback(hObject, eventdata, handles)
% hObject    handle to Rise3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rise3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rise3


% --- Executes during object creation, after setting all properties.
function Rise3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rise3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rise4.
function Rise4_Callback(hObject, eventdata, handles)
% hObject    handle to Rise4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rise4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rise4


% --- Executes during object creation, after setting all properties.
function Rise4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rise4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rise5.
function Rise5_Callback(hObject, eventdata, handles)
% hObject    handle to Rise5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rise5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rise5


% --- Executes during object creation, after setting all properties.
function Rise5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rise5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rise6.
function Rise6_Callback(hObject, eventdata, handles)
% hObject    handle to Rise6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rise6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rise6


% --- Executes during object creation, after setting all properties.
function Rise6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rise6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rise7.
function Rise7_Callback(hObject, eventdata, handles)
% hObject    handle to Rise7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rise7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rise7


% --- Executes during object creation, after setting all properties.
function Rise7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rise7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rise8.
function Rise8_Callback(hObject, eventdata, handles)
% hObject    handle to Rise8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rise8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rise8


% --- Executes during object creation, after setting all properties.
function Rise8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rise8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rise9.
function Rise9_Callback(hObject, eventdata, handles)
% hObject    handle to Rise9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Rise9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rise9


% --- Executes during object creation, after setting all properties.
function Rise9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rise9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DelPBN1.
function DelPBN1_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN',hObject, eventdata, handles)

% --- Executes on button press in DelPBN2.
function DelPBN2_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN2',hObject, eventdata, handles)


% --- Executes on button press in DelPBN3.
function DelPBN3_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN3',hObject, eventdata, handles)


% --- Executes on button press in DelPBN4.
function DelPBN4_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN4',hObject, eventdata, handles)


% --- Executes on button press in DelPBN5.
function DelPBN5_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN5',hObject, eventdata, handles)


% --- Executes on button press in DelPBN6.
function DelPBN6_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN6',hObject, eventdata, handles)


% --- Executes on button press in DelPBN7.
function DelPBN7_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN7',hObject, eventdata, handles)


% --- Executes on button press in DelPBN8.
function DelPBN8_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN8',hObject, eventdata, handles)


% --- Executes on button press in DelPBN9.
function DelPBN9_Callback(hObject, eventdata, handles)
% hObject    handle to DelPBN9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('DeletePBN9',hObject, eventdata, handles)


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Rise1_Callback(hObject, eventdata, handles)
% hObject    handle to Rise1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rise1 as text
%        str2double(get(hObject,'String')) returns contents of Rise1 as a double
PulseSequencerFunctions('UpdateSelectedRise',hObject, eventdata, handles)




% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DelRiseN1.
function DelRiseN1_Callback(hObject, eventdata, handles)
% hObject    handle to DelRiseN1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('DeleteRise',hObject, eventdata, handles)


% --- Executes on button press in AddRiseN2.
function AddRiseN2_Callback(hObject, eventdata, handles)
% hObject    handle to AddRiseN2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddRiseN3.
function AddRiseN3_Callback(hObject, eventdata, handles)
% hObject    handle to AddRiseN3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DelRiseN4.
function DelRiseN4_Callback(hObject, eventdata, handles)
% hObject    handle to DelRiseN4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddRiseN5.
function AddRiseN5_Callback(hObject, eventdata, handles)
% hObject    handle to AddRiseN5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddRiseN6.
function AddRiseN6_Callback(hObject, eventdata, handles)
% hObject    handle to AddRiseN6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddRiseN8.
function AddRiseN8_Callback(hObject, eventdata, handles)
% hObject    handle to AddRiseN8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddRiseN9.
function AddRiseN9_Callback(hObject, eventdata, handles)
% hObject    handle to AddRiseN9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in AddRiseN4.
function AddRiseN4_Callback(hObject, eventdata, handles)
% hObject    handle to AddRiseN4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on selection change in popupHWChannel.
function popupHWChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popupHWChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupHWChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupHWChannel
PulseSequencerFunctions('SetHWChannelPopup',hObject, eventdata, handles)




function Type2_Callback(hObject, eventdata, handles)
% hObject    handle to Type2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Type2 as text
%        str2double(get(hObject,'String')) returns contents of Type2 as a double
EditgEditSEQ('Type2',hObject, eventdata, handles)





function Type3_Callback(hObject, eventdata, handles)
% hObject    handle to Type3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Type3 as text
%        str2double(get(hObject,'String')) returns contents of Type3 as a double
EditgEditSEQ('Type3',hObject, eventdata, handles)





function Type4_Callback(hObject, eventdata, handles)
% hObject    handle to Type4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Type4 as text
%        str2double(get(hObject,'String')) returns contents of Type4 as a double
EditgEditSEQ('Type4',hObject, eventdata, handles)





function Type5_Callback(hObject, eventdata, handles)
% hObject    handle to Type5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Type5 as text
%        str2double(get(hObject,'String')) returns contents of Type5 as a double
EditgEditSEQ('Type5',hObject, eventdata, handles)





function Type6_Callback(hObject, eventdata, handles)
% hObject    handle to Type6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Type6 as text
%        str2double(get(hObject,'String')) returns contents of Type6 as a double
EditgEditSEQ('Type6',hObject, eventdata, handles)





function Type7_Callback(hObject, eventdata, handles)
% hObject    handle to Type7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Type7 as text
%        str2double(get(hObject,'String')) returns contents of Type7 as a double
EditgEditSEQ('Type7',hObject, eventdata, handles)





function Type8_Callback(hObject, eventdata, handles)
% hObject    handle to Type8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Type8 as text
%        str2double(get(hObject,'String')) returns contents of Type8 as a double
EditgEditSEQ('Type8',hObject, eventdata, handles)





function Type9_Callback(hObject, eventdata, handles)
% hObject    handle to Type9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Type9 as text
%        str2double(get(hObject,'String')) returns contents of Type9 as a double
EditgEditSEQ('Type9',hObject, eventdata, handles)




% --- Executes on button press in ShowType.
function ShowType_Callback(hObject, eventdata, handles)
% hObject    handle to ShowType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ZoomLeft.
function ZoomLeft_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ZoomEditSEQ('Left',hObject, eventdata, handles);

% --- Executes on button press in ZoomRight.
function ZoomRight_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ZoomEditSEQ('Right',hObject, eventdata, handles);


% --- Executes on selection change in popupChannel.
function popupChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel
PulseSequencerFunctions('UpdateSelectedChannelPopup',hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in AddRiseN1.
function AddRiseN1_Callback(hObject, eventdata, handles)
% hObject    handle to AddRiseN1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('AddRise',hObject, eventdata, handles)




% --- Executes on button press in ShowTimes.
function ShowTimes_Callback(hObject, eventdata, handles)
% hObject    handle to ShowTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowTimes
EditSEQRedraw('ShowTimes',hObject, eventdata, handles);

% --- Executes on button press in cbShift.
function cbShift_Callback(hObject, eventdata, handles)
% hObject    handle to cbShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShift


% --- Executes on button press in ShiftAll.
function ShiftAll_Callback(hObject, eventdata, handles)
% hObject    handle to ShiftAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShiftAll


% --- Executes on button press in ZoomOut.
function ZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ZoomEditSEQ('ZoomOut',hObject, eventdata, handles);



% --- Executes on button press in bZoom.
function bZoom_Callback(hObject, eventdata, handles)
% hObject    handle to bZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bZoom




% --- Executes on button press in ShowTypes.
function ShowTypes_Callback(hObject, eventdata, handles)
% hObject    handle to ShowTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowTypes
EditSEQRedraw('ShowTypes',hObject, eventdata, handles);




% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%RefreshEditSeqForm('ButtonDown',hObject, eventdata, handles)



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ZoomRight.
function ZoomRight_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ZoomRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in buttonPlot.
function buttonPlot_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% get the axes object with the plot
hSeq = get(handles.axes1,'Children');
% create a new figure
hFig = figure;
hAxes = axes;
copyobj(hSeq,hAxes);



% --- Executes on button press in buttonAddChannel.
function buttonAddChannel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditSequenceFunctions('AddChannel',hObject, eventdata, handles)




% --- Executes on button press in pbDelChannel.
function pbDelChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pbDelChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('DeleteChannel',hObject, eventdata, handles)




% --- Executes on key press with focus on editDT and none of its controls.
function editDT_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editDT (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, cbshift) pressed
% handles    structure with handles and user data (see GUIDATA)



function editPhase_Callback(hObject, eventdata, handles)
% hObject    handle to editPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPhase as text
%        str2double(get(hObject,'String')) returns contents of editPhase as a double
%
% update the Phase
PulseSequencerFunctions('UpdateRiseInput',hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editPhase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in cbPhases.
function cbPhases_Callback(hObject, eventdata, handles)
% hObject    handle to cbPhases (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbPhases


% --- Executes during object creation, after setting all properties.
function AddSequenceFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddSequenceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in ReplaceSequence.
function ReplaceSequence_Callback(hObject, eventdata, handles)
% hObject    handle to ReplaceSequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditSequenceFunctionPool('ReplaceSequence',hObject, eventdata, handles);








% --- Executes during object creation, after setting all properties.
function ReplaceSequence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReplaceSequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in bDeletePulse.
function bDeletePulse_Callback(hObject, eventdata, handles)
% hObject    handle to bDeletePulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bDeletePulse


% --- Executes on button press in bDeleteSelectedPulses.
function bDeleteSelectedPulses_Callback(hObject, eventdata, handles)
% hObject    handle to bDeleteSelectedPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bDeleteSelectedPulses
EditSequenceFunctionPool('DeleteSelectedPulses',hObject, eventdata, handles);




function DTPulses_Callback(hObject, eventdata, handles)
% hObject    handle to DTPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DTPulses as text
%        str2double(get(hObject,'String')) returns contents of DTPulses as a double


% --- Executes during object creation, after setting all properties.
function DTPulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DTPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PBNPulses.
function PBNPulses_Callback(hObject, eventdata, handles)
% hObject    handle to PBNPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PBNPulses contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PBNPulses


% --- Executes during object creation, after setting all properties.
function PBNPulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBNPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ApplyPulses.
function ApplyPulses_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditgEditSEQ('ApplyPulses',hObject, eventdata, handles)





function TypePulses_Callback(hObject, eventdata, handles)
% hObject    handle to TypePulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TypePulses as text
%        str2double(get(hObject,'String')) returns contents of TypePulses as a double


% --- Executes during object creation, after setting all properties.
function TypePulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TypePulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bTypePulses.
function bTypePulses_Callback(hObject, eventdata, handles)
% hObject    handle to bTypePulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bTypePulses


% --- Executes on button press in checkPan.
function checkPan_Callback(hObject, eventdata, handles)
% hObject    handle to checkPan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkPan
if get(hObject,'Value'),
    pan(handles.axes1,'on');
else,
    pan(handles.axes1,'off');
end




% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuNew_Callback(hObject, eventdata, handles)
% hObject    handle to menuNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('New',hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuLoad_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('Load',hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
% hObject    handle to menuSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('Save',hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuSaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('SaveAs',hObject, eventdata, handles);





function editAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to editAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hints: get(hObject,'String') returns contents of editAmplitude as text
%        str2double(get(hObject,'String')) returns contents of editAmplitude as a double
PulseSequencerFunctions('UpdateRiseInput',hObject, eventdata, handles)

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


% --------------------------------------------------------------------
function menuPopout_Callback(hObject, eventdata, handles)
% hObject    handle to menuPopout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function menuHWChannels_Callback(hObject, eventdata, handles)
% hObject    handle to menuHWChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuPlot_Callback(hObject, eventdata, handles)
% hObject    handle to menuPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuDelays_Callback(hObject, eventdata, handles)
% hObject    handle to menuDelays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureDelays(handles.PSeq);



% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function menuDebug_Callback(hObject, eventdata, handles)
% hObject    handle to menuDebug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('debug');



% --------------------------------------------------------------------
function uipushtool4_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigurePulseSweeps(handles.PSeq);

function SetStatus(handles,statusText)
set(handles.textStatus,'String',statusText);





% --------------------------------------------------------------------
function menuSetSeqDir_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetSeqDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ispref('nv','SavedSequenceDirectory'),
    d = getpref('nv','SavedSequenceDirectory');
else
    d = pwd;
end

a = uigetdir(d,'Choose Default Saved Sequence Directory');
setpref('nv','SavedSequenceDirectory',a);





% --- Executes on button press in pbAddGroup.
function pbAddGroup_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('AddGroup',hObject,eventdata,handles);

% --- Executes on button press in pbDelGroup.
function pbDelGroup_Callback(hObject, eventdata, handles)
% hObject    handle to pbDelGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupGroups.
function popupGroups_Callback(hObject, eventdata, handles)
% hObject    handle to popupGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupGroups contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupGroups
PulseSequencerFunctions('UpdateSelectedGroupPopup',hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupGroups_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupStartEvent.
function popupStartEvent_Callback(hObject, eventdata, handles)
% hObject    handle to popupStartEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupStartEvent contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupStartEvent
PulseSequencerFunctions('UpdateGroupInput',hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function popupStartEvent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupStartEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupEndEvent.
function popupEndEvent_Callback(hObject, eventdata, handles)
% hObject    handle to popupEndEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupEndEvent contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupEndEvent
PulseSequencerFunctions('UpdateGroupInput',hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function popupEndEvent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupEndEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLoop_Callback(hObject, eventdata, handles)
% hObject    handle to editLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLoop as text
%        str2double(get(hObject,'String')) returns contents of editLoop as a double
PulseSequencerFunctions('UpdateGroupInput',hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editLoop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function editGroupName_Callback(hObject, eventdata, handles)
% hObject    handle to editGroupName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGroupName as text
%        str2double(get(hObject,'String')) returns contents of editGroupName as a double
PulseSequencerFunctions('UpdateGroupInput',hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editGroupName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGroupName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu44.
function popupmenu44_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu44 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu44


% --- Executes during object creation, after setting all properties.
function popupmenu44_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu45.
function popupmenu45_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu45 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu45


% --- Executes during object creation, after setting all properties.
function popupmenu45_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu46.
function popupmenu46_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu46 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu46


% --- Executes during object creation, after setting all properties.
function popupmenu46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function sliderSweeps_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSweeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
PulseSequencerFunctions('SliderPlay',hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function sliderSweeps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSweeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pbPlaySweep.
function pbPlaySweep_Callback(hObject, eventdata, handles)
% hObject    handle to pbPlaySweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencerFunctions('PlaySweep',hObject, eventdata, handles);



% --- Executes on button press in pushbutton51.
function pushbutton51_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton52.
function pushbutton52_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editSweepMulti_Callback(hObject, eventdata, handles)
% hObject    handle to editSweepMulti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSweepMulti as text
%        str2double(get(hObject,'String')) returns contents of editSweepMulti as a double
PulseSequencerFunctions('UpdateRiseInput',hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editSweepMulti_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSweepMulti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
