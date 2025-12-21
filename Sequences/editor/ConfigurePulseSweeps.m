function varargout = ConfigurePulseSweeps(varargin)
% CONFIGUREPULSESWEEPS M-file for ConfigurePulseSweeps.fig
%      CONFIGUREPULSESWEEPS, by itself, creates a new CONFIGUREPULSESWEEPS or raises the existing
%      singleton*.
%
%      H = CONFIGUREPULSESWEEPS returns the handle to a new CONFIGUREPULSESWEEPS or the handle to
%      the existing singleton*.
%
%      CONFIGUREPULSESWEEPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGUREPULSESWEEPS.M with the given input arguments.
%
%      CONFIGUREPULSESWEEPS('Property','Value',...) creates a new CONFIGUREPULSESWEEPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ConfigurePulseSweeps_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ConfigurePulseSweeps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ConfigurePulseSweeps

% Last Modified by GUIDE v2.5 08-Dec-2021 12:29:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConfigurePulseSweeps_OpeningFcn, ...
                   'gui_OutputFcn',  @ConfigurePulseSweeps_OutputFcn, ...
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


% --- Executes just before ConfigurePulseSweeps is made visible.
function ConfigurePulseSweeps_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConfigurePulseSweeps (see VARARGIN)

% Choose default command line output for ConfigurePulseSweeps
handles.output = hObject;

if nargin > 1,
    handles.PSeqOriginal = varargin{1};
end
% work on the cloned version and change it back at the last minute
handles.PSeq = varargin{1}.clone();

addlistener(handles.PSeq,'PulseSeqeunceChangedState',@(src,evnt)Init(hObject,handles));
Init(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ConfigurePulseSweeps wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ConfigurePulseSweeps_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupChannel.
function popupChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel
UpdateSweeps(hObject,handles)

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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupType.
function popupType_Callback(hObject, eventdata, handles)
% hObject    handle to popupType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupType
UpdateSweeps(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
hObject.String{5} = 'TimeExp';
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbRise.
function rbRise_Callback(hObject, eventdata, handles)
% hObject    handle to rbRise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbRise


% --- Executes on button press in rbType.
function rbType_Callback(hObject, eventdata, handles)
% hObject    handle to rbType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbType


% --- Executes on button press in pbAdd.
function pbAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pbAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PSeq.addSweep();


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
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



function editPoints_Callback(hObject, eventdata, handles)
% hObject    handle to editPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPoints as text
%        str2double(get(hObject,'String')) returns contents of editPoints as a double
UpdateSweeps(hObject,handles)

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



function editStart_Callback(hObject, eventdata, handles)
% hObject    handle to editStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStart as text
%        str2double(get(hObject,'String')) returns contents of editStart as a double
UpdateSweeps(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStop_Callback(hObject, eventdata, handles)
% hObject    handle to editStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStop as text
%        str2double(get(hObject,'String')) returns contents of editStop as a double
UpdateSweeps(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxSweeps.
function listboxSweeps_Callback(hObject, eventdata, handles)
% hObject    handle to listboxSweeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxSweeps contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxSweeps
 UpdateSweepGUI(hObject,handles)

% --- Executes during object creation, after setting all properties.
function listboxSweeps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxSweeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupShifts.
function popupShifts_Callback(hObject, eventdata, handles)
% hObject    handle to popupShifts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupShifts contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupShifts
UpdateSweeps(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupShifts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupShifts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupClass.
function popupClass_Callback(hObject, eventdata, handles)
% hObject    handle to popupClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupClass contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupClass
UpdateSweeps(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupClass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbRemove.
function pbRemove_Callback(hObject, eventdata, handles)
% hObject    handle to pbRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
swp = get(handles.listboxSweeps,'Value');
str = get(handles.listboxSweeps,'String');
if swp >= 1 && numel(str) > 0,
    handles.PSeq.deleteSweep(swp);
    Init(hObject,handles);
end

function Init(hObject,handles)
s = {};
for k=1:numel(handles.PSeq.Sweeps),
    s{k} = sprintf('Sweep %d',k);
    set(handles.listboxSweeps,'String',s);
end
set(handles.listboxSweeps,'String',s);
set(handles.listboxSweeps,'Value',1);

% fill up channels popup
for k=1:numel(handles.PSeq.Channels),
    s{k} = sprintf('Channel %d:HW Channel %d',k,handles.PSeq.Channels(k).HWChannel);
    set(handles.popupChannel,'String',s);
end
UpdateSweepGUI(hObject,handles)


function UpdateSweepGUI(hObject,handles)

% get the string of sweeps in the listbox
s = get(handles.listboxSweeps,'String');

% if there are any sweeps, get the selected index
if length(s),
    selected = get(handles.listboxSweeps,'Value');
else
	return;
end

% set the local gui variables to the Sweeps PulseSequence array @ the
% selected index
Channel =  handles.PSeq.Sweeps(selected).Channels;
Class = handles.PSeq.Sweeps(selected).SweepClass;
Type = handles.PSeq.Sweeps(selected).SweepType;
Rises = handles.PSeq.Sweeps(selected).SweepRises;
StartValue = handles.PSeq.Sweeps(selected).StartValue;
StopValue = handles.PSeq.Sweeps(selected).StopValue;
Points =  handles.PSeq.Sweeps(selected).SweepPoints;
Shifts = handles.PSeq.Sweeps(selected).SweepShifts;
Add  = handles.PSeq.Sweeps(selected).SweepAdd;

if Channel,
    set(handles.popupChannel,'Visible','on');
    set(handles.popupChannel,'Value',Channel);
elseif numel(handles.PSeq.Channels) < 1,
    set(handles.popupChannel,'Visible','off');
else
    set(handles.popupChannel,'Visible','on');
    set(handles.popupChannel,'Value',1);
end

if isempty(Type),
    Type = '';
end
switch Type
    case 'Time'
        set(handles.popupType,'Value',1);       
    case 'Duration'
        set(handles.popupType,'Value',2);
    case 'Amplitude'
        set(handles.popupType,'Value',3);
    case 'Phase'
        set(handles.popupType,'Value',4);
    case 'TimeExp'
        set(handles.popupType,'Value',5);
    case 'Frequency'
        set(handles.popupType,'Value',6);
        %         set(handles.text1,'String','dt');
    otherwise
        set(handles.popupType,'Value',1);
end


        set(handles.text1,'String','Start Value [s]');
        set(handles.text2,'String','Stop Value [s]');
        set(handles.text3,'String','Number of Points');          


% switch Type
%     case 'TimeExp'
%         set(handles.text1,'String','Initial dt [s]');
%         set(handles.text2,'String','Points in a block');
%         set(handles.text3,'String','Number of blocks');        
%     otherwise
%         set(handles.text1,'String','Start Value [s]');
%         set(handles.text2,'String','Stop Value [s]');
%         set(handles.text3,'String','Number of Points');          
% end
% the possible classes are stored in the default gui popup properties
s = get(handles.popupClass,'String');
if Class
    F = strfind(s,Class);
    for k=1:length(F)
        if ~isempty(F{k})
            set(handles.popupClass,'Value',k);
            break;
        end
    end
else
    Class = '';
end

if StartValue
    set(handles.editStart,'String',sprintf('%3.8g',StartValue));
else
    set(handles.editStart,'String',0);
end

if StopValue
    set(handles.editStop,'String',sprintf('%3.8g',StopValue));
else
    set(handles.editStop,'String',0);
end


if Points
    set(handles.editPoints,'String',num2str(Points));
else
    set(handles.editPoints,'String',0);
end

switch Class,
    case 'Rise'
        C = get(handles.popupChannel,'Value');
        if C
            S = handles.PSeq.Channels(C).NumberOfRises;
            s = '';
            for k=1:S
                s{k} = sprintf('%d',k);
            end
            set(handles.popupRise,'String',s);
            
            if Rises
                if isnumeric(Rises),
                    set(handles.popupRise,'Value',Rises);
                else
                    set(handles.popupRise,'Value',1);
                end
            end
        else
            set(handles.popupRise,'String','');
        end
    case 'Type'
        C = get(handles.popupChannel,'Value');
        if C
            S = unique(handles.PSeq.Channels(C).RiseTypes);
            set(handles.popupRise,'String',S);
            
            % set the value to the one chosen for the sweep
            for k = 1:numel(S)
                if strcmp(S{k},Rises)
                    set(handles.popupRise,'Value',k);
                end
            end
        else
            set(handles.popupRise,'String','');
        end
end

if Add
    set(handles.cbAdd,'Value',1);
else
    set(handles.cbAdd,'Value',0);
end

% add 1 since shifts are indexed at 0
if isempty(Shifts)
    Shifts = 1;
end
set(handles.popupShifts,'Value',Shifts+1);

function UpdateSweeps(hObject,handles)


Class = get(handles.popupClass,'String');
Class = Class{get(handles.popupClass,'Value')};

Channel = get(handles.popupChannel,'Value');

Type = get(handles.popupType,'String');
Type = Type{get(handles.popupType,'Value')};

Rise = get(handles.popupRise,'String');
if ~isempty(Rise),
    Rise = Rise{get(handles.popupRise,'Value')};
end

% if integer, set to integer type
if  ~strcmp(Rise,'Counter') && ~isempty(str2num(Rise)) 
    Rise = str2num(Rise);
end

StartValue = get(handles.editStart,'String');
StopValue = get(handles.editStop,'String');
Points =  str2num(get(handles.editPoints,'String'));
Shifts = get(handles.popupShifts,'Value');

% Shifts are index starting at 0
Shifts = Shifts - 1;


% handle other notational input
StartValue = PulseSequencerFunctions('ParseInput',StartValue);
StopValue = PulseSequencerFunctions('ParseInput',StopValue);

if get(handles.cbAdd,'Value'),
    Add = 1;
else
    Add = 0;
end

swp = get(handles.listboxSweeps,'Value');


handles.PSeq.Sweeps(swp).setSweepParams(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add);

% --- Executes on button press in pbSave.
function pbSave_Callback(hObject, eventdata, handles)
% hObject    handle to pbSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PSeqOriginal.Sweeps = handles.PSeq.Sweeps;

% blank an empty array
if numel(handles.PSeqOriginal.Sweeps) == 0
    handles.PSeqOriginal.Sweeps = [];
end
close(handles.figure1);


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on button press in cbAdd.
function cbAdd_Callback(hObject, eventdata, handles)
% hObject    handle to cbAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of cbAdd
UpdateSweeps(hObject,handles)

% --- Executes on selection change in popupRise.
function popupRise_Callback(hObject, eventdata, handles)
% hObject    handle to popupRise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupRise contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupRise
UpdateSweeps(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupRise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupRise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
