function varargout = NIDAQ(varargin)
% NIDAQ M-file for NIDAQ.fig
%      NIDAQ, by itself, creates a new NIDAQ or raises the existing
%      singleton*.
%
%      H = NIDAQ returns the handle to a new NIDAQ or the handle to
%      the existing singleton*.
%
%      NIDAQ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NIDAQ.M with the given input arguments.
%
%      NIDAQ('Property','Value',...) creates a new NIDAQ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NIDAQ_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NIDAQ_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NIDAQ

% Last Modified by GUIDE v2.5 04-Feb-2009 18:07:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NIDAQ_OpeningFcn, ...
                   'gui_OutputFcn',  @NIDAQ_OutputFcn, ...
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


% --- Executes just before NIDAQ is made visible.
function NIDAQ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NIDAQ (see VARARGIN)

% Choose default command line output for NIDAQ
handles.output = hObject;

handles.LibraryFile = 'C:\WINDOWS\system32\nicaiu.dll';
handles.HeaderFile = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
if  ~libisloaded('nidaqmx'),
    [pOk,warnings] = loadlibrary(handles.LibraryFile,handles.HeaderFile,'alias','nidaqmx');
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NIDAQ wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NIDAQ_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in p0l0.
function p0l0_Callback(hObject, eventdata, handles)
% hObject    handle to p0l0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l0


% --- Executes on button press in p0l1.
function p0l1_Callback(hObject, eventdata, handles)
% hObject    handle to p0l1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l1


% --- Executes on button press in p0l2.
function p0l2_Callback(hObject, eventdata, handles)
% hObject    handle to p0l2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l2


% --- Executes on button press in p0l3.
function p0l3_Callback(hObject, eventdata, handles)
% hObject    handle to p0l3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l3


% --- Executes on button press in p0l4.
function p0l4_Callback(hObject, eventdata, handles)
% hObject    handle to p0l4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l4


% --- Executes on button press in p0l5.
function p0l5_Callback(hObject, eventdata, handles)
% hObject    handle to p0l5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l5


% --- Executes on button press in p0l6.
function p0l6_Callback(hObject, eventdata, handles)
% hObject    handle to p0l6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l6


% --- Executes on button press in p0l7.
function p0l7_Callback(hObject, eventdata, handles)
% hObject    handle to p0l7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l7


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a(1) = get(handles.p0l0,'Value');
a(2) = get(handles.p0l1,'Value');
a(3) = get(handles.p0l2,'Value');
a(4) = get(handles.p0l3,'Value');
a(5) = get(handles.p0l4,'Value');
a(6) = get(handles.p0l5,'Value');
a(7) = get(handles.p0l6,'Value');
a(8) = get(handles.p0l7,'Value');

Device = {'Dev2/PFI0','Dev2/PFI1','Dev2/PFI2','Dev2/PFI3','Dev2/PFI4','Dev2/PFI5','Dev2/PFI6','Dev2/PFI7','Dev2/PFI8'};

for k=1:length(a),
    WriteDigitalLine(Device{k},a(k));
end

function WriteDigitalLine(Device,Value)
handles.daqmxTaskHandle = 1;
[a,b,handles.daqmxTaskHandle] = ...
    calllib('nidaqmx','DAQmxCreateTask','NIDAQTask',handles.daqmxTaskHandle);
[a,b,c] = calllib('nidaqmx','DAQmxCreateDOChan',handles.daqmxTaskHandle,Device,'MyDO',0);
[a] = calllib('nidaqmx','DAQmxStartTask',handles.daqmxTaskHandle);
[a,b,c,d] = calllib('nidaqmx','DAQmxWriteDigitalLines',handles.daqmxTaskHandle,1,1,10.0,0,Value,0,[]);

[a]=calllib('nidaqmx','DAQmxStopTask',handles.daqmxTaskHandle);
[a]=calllib('nidaqmx','DAQmxClearTask',handles.daqmxTaskHandle);