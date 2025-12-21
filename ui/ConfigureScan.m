function varargout = ConfigureScan(varargin)
% CONFIGURESCAN M-file for ConfigureScan.fig
%      CONFIGURESCAN, by itself, creates a new CONFIGURESCAN or raises the existing
%      singleton*.
%
%      H = CONFIGURESCAN returns the handle to a new CONFIGURESCAN or the handle to
%      the existing singleton*.
%
%      CONFIGURESCAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGURESCAN.M with the given input arguments.
%
%      CONFIGURESCAN('Property','Value',...) creates a new CONFIGURESCAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ConfigureScan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ConfigureScan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ConfigureScan

% Last Modified by GUIDE v2.5 23-Sep-2009 19:41:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConfigureScan_OpeningFcn, ...
                   'gui_OutputFcn',  @ConfigureScan_OutputFcn, ...
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


% --- Executes just before ConfigureScan is made visible.
function ConfigureScan_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConfigureScan (see VARARGIN)

% Choose default command line output for ConfigureScan
handles.output = hObject;

if nargin > 3,
    handles.ConfocalScan = varargin{1};
else
    handles.ConfocalScan = ConfocalScan();
end
guidata(hObject, handles);

ConfigureScanFunctions('Initialize',hObject,eventdata,handles);

% UIWAIT makes ConfigureScan wait for user response (see UIRESUME)
%uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ConfigureScan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Return Confocal Scan to command line on close
%varargout{1} = handles.ConfocalScan;



function minX_Callback(hObject, eventdata, handles)
% hObject    handle to minX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minX as text
%        str2double(get(hObject,'String')) returns contents of minX as a double


% --- Executes during object creation, after setting all properties.
function minX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxX_Callback(hObject, eventdata, handles)
% hObject    handle to maxX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxX as text
%        str2double(get(hObject,'String')) returns contents of maxX as a double


% --- Executes during object creation, after setting all properties.
function maxX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pointsX_Callback(hObject, eventdata, handles)
% hObject    handle to pointsX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointsX as text
%        str2double(get(hObject,'String')) returns contents of pointsX as a double


% --- Executes during object creation, after setting all properties.
function pointsX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointsX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enableX.
function enableX_Callback(hObject, eventdata, handles)
% hObject    handle to enableX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enableX



function offsetX_Callback(hObject, eventdata, handles)
% hObject    handle to offsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of offsetX as text
%        str2double(get(hObject,'String')) returns contents of offsetX as a double


% --- Executes during object creation, after setting all properties.
function offsetX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minZ_Callback(hObject, eventdata, handles)
% hObject    handle to minZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minZ as text
%        str2double(get(hObject,'String')) returns contents of minZ as a double


% --- Executes during object creation, after setting all properties.
function minZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxZ_Callback(hObject, eventdata, handles)
% hObject    handle to maxZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxZ as text
%        str2double(get(hObject,'String')) returns contents of maxZ as a double


% --- Executes during object creation, after setting all properties.
function maxZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pointsZ_Callback(hObject, eventdata, handles)
% hObject    handle to pointsZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointsZ as text
%        str2double(get(hObject,'String')) returns contents of pointsZ as a double


% --- Executes during object creation, after setting all properties.
function pointsZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointsZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enableZ.
function enableZ_Callback(hObject, eventdata, handles)
% hObject    handle to enableZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enableZ



function offsetZ_Callback(hObject, eventdata, handles)
% hObject    handle to offsetZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of offsetZ as text
%        str2double(get(hObject,'String')) returns contents of offsetZ as a double


% --- Executes during object creation, after setting all properties.
function offsetZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offsetZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function offsetY_Callback(hObject, eventdata, handles)
% hObject    handle to offsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of offsetY as text
%        str2double(get(hObject,'String')) returns contents of offsetY as a double


% --- Executes during object creation, after setting all properties.
function offsetY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enableY.
function enableY_Callback(hObject, eventdata, handles)
% hObject    handle to enableY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enableY



function pointsY_Callback(hObject, eventdata, handles)
% hObject    handle to pointsY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointsY as text
%        str2double(get(hObject,'String')) returns contents of pointsY as a double


% --- Executes during object creation, after setting all properties.
function pointsY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointsY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxY_Callback(hObject, eventdata, handles)
% hObject    handle to maxY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxY as text
%        str2double(get(hObject,'String')) returns contents of maxY as a double


% --- Executes during object creation, after setting all properties.
function maxY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minY_Callback(hObject, eventdata, handles)
% hObject    handle to minY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minY as text
%        str2double(get(hObject,'String')) returns contents of minY as a double


% --- Executes during object creation, after setting all properties.
function minY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dwell_Callback(hObject, eventdata, handles)
% hObject    handle to dwell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dwell as text
%        str2double(get(hObject,'String')) returns contents of dwell as a double


% --- Executes during object creation, after setting all properties.
function dwell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dwell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ConfigureScanFunctions('Save',hObject,eventdata,handles);
handles.output = handles.ConfocalScan;
% notify of a state change
notify(handles.ConfocalScan,'ScanStateChange');
close();


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu2D_Callback(hObject, eventdata, handles)
% hObject    handle to menu2D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureScanFunctions('2D',hObject,eventdata,handles);

% --------------------------------------------------------------------
function menuZ_Callback(hObject, eventdata, handles)
% hObject    handle to menuZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureScanFunctions('Z',hObject,eventdata,handles);

