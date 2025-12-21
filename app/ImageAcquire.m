 function varargout = ImageAcquire(varargin)
% 
% ImageAcquire.m script for ImageAcquire.fig
%
% jhodges@mit.edu
% 7 July 2009
%
% NOTE: This script implements gui callbacks directly within the script.
% In the future, it will be best to define a set of "wrapper functions" for
% doing this programmatically.
%
%
%
% IMAGEACQUIRE M-file for ImageAcquire.fig
%      IMAGEACQUIRE, by itself, creates a new IMAGEACQUIRE or raises the
%      existing
%      singleton*.
%
%      H = IMAGEACQUIRE returns the handle to a new IMAGEACQUIRE or the handle to
%      the existing singleton*.
%
%      IMAGEACQUIRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEACQUIRE.M with the given input arguments.
%
%      IMAGEACQUIRE('Property','Value',...) creates a new IMAGEACQUIRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageAcquire_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageAcquire_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageAcquire

% Last Modified by GUIDE v2.5 22-Nov-2024 17:48:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageAcquire_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageAcquire_OutputFcn, ...
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


% --- Executes just before ImageAcquire is made visible.
function ImageAcquire_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageAcquire (see VARARGIN)

% Choose default command line output for ImageAcquire
handles.output = hObject;

% check to make sure all preferences are set
CheckPrefs();

% Update handles structure with some classes we'll need.

% First the ConfocalScan class with some default values
handles.ConfocalScan = ConfocalScan();
handles.ConfocalScan.MinValues = [-2 -2 0];
handles.ConfocalScan.MaxValues = [2 2 0];
handles.ConfocalScan.NumPoints = [100 100 1];
handles.ConfocalScan.OffsetValues = [0,0,0];

% initialize an empty string for the controlLinesController function.
% this can be reassigned in the init script.
handles.controlLinesController = '';

% create an image acquisition object
handles.ImageAcquisition = ImageAcquisition();
% added by kang, creat an Traker object
handles.Tracker = TrackerCCNY();
% init devices
handles = InitDevices(handles);

%Setup some stuff with the current position
axes(handles.imageAxes);
handles.xcrosshair = NaN;
handles.ycrosshair = NaN;


set(handles.text_curPosZ,'String','Z (um)');
handles.ImageAcquisition.CurrentPosition(3) =  handles.ImageAcquisition.interfacePiezo.GetCurrentPosition();

set(handles.cursorZ,'String',sprintf('%0.4f',handles.ImageAcquisition.CurrentPosition(3)));
handles.ImageAcquisition.CursorPosition = handles.ImageAcquisition.CurrentPosition;
set(handles.TrackThresh, 'string',sprintf('%d',handles.Tracker.TrackingThreshold))
% get the offsets for the image acquisition from system preferences
handles.ImageAcquisition.OffsetValues = getpref('nv','OffsetValues');

% init Events
handles.ImageAcquireEvent = ImageAcquireEvent();

% init Events
InitEvents(hObject,handles);

% init Icons
InitIcons(hObject,handles);

% load scans
notify(handles.ImageAcquireEvent,'SavedScanChange');

% ??? Why do we need to do this instead of just guidata(hObject, handles);
gobj = findall(0,'Name','ImageAcquire');
guidata(gobj,handles);

% UIWAIT makes ImageAcquire wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageAcquire_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonSetupScan.
function buttonSetupScan_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSetupScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureScan(handles.ConfocalScan);


% --- Executes on button press in buttonScan.
function buttonScan_Callback(hObject, eventdata, handles)
% hObject    handle to buttonScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hookup the scan
try
    handles.NI.ClearAllTasks();
end
handles.ImageAcquisition.CurrentScan = handles.ConfocalScan;

bSxy = get(handles.CheckboxXY,'Value');
bSz = get(handles.CheckboxZ,'Value');

if bSxy && ~bSz
    handles.ConfocalScan.bEnable = [1 1 0];
    handles.ImageAcquisition.CurrentScan.DwellTime = str2double(get(handles.DwellXY,'String'));
elseif ~bSxy && bSz
    handles.ConfocalScan.bEnable = [0 0 1];
    handles.ImageAcquisition.CurrentScan.DwellTime = str2double(get(handles.DwellZ,'String'));
elseif bSxy && bSz
    handles.ConfocalScan.bEnable = [1 1 1];
end

PerformScan(hObject,eventdata,handles);


% copy images from IA to handle
handles.ConfocalImages = handles.ImageAcquisition.ConfocalImages;
%gobj = findall(0,'Name','ImageAcquire');
guidata(hObject,handles);

%check the scan continuously button
bSC = get(handles.cbScanContinuous,'Value');

while bSC
    PerformScan(hObject,eventdata,handles);
    bSC = get(handles.cbScanContinuous,'Value');
    % copy images from IA to handle
    handles.ConfocalImages = handles.ImageAcquisition.ConfocalImages;
    %gobj = findall(0,'Name','ImageAcquire');
    guidata(hObject,handles);
end

% check for autosave
if strcmp(get(handles.menuAutoSave,'checked'),'on')
    SaveScan(hObject, eventdata, handles);
end

% Helper function to update the confocal image
function [] = updateImage(handles,src,eventdata)

        Vx = src.CurrentScanVxVec;
        Vy = src.CurrentScanVyVec;
        I = src.UnpackImage();
        % ??? Usually it's slow to redo the plot, axis, colormap command and faster to just
        % update the data.  Is there a way to do this with 2D plots by
        % setting the CData?
        hI = imagesc(Vx,Vy(end:-1:1),I,'Parent',handles.imageAxes);
        axis(handles.imageAxes,'square');
        colormap(handles.imageAxes,jet);
        hCb = colorbar('peer',handles.imageAxes);
         

function [] = updateImage1D(handles,src,eventdata)
        bE = handles.ImageAcquisition.CurrentScan.bEnable;
        if bE(1)
             V = src.CurrentScanVxVec;
        elseif bE(2)
             V = src.CurrentScanVyVec;
        else
             V = src.CurrentScanVzVec;
        end

        % ??? Similarly here do we just want to update the data
        l = length(src.ImageRawData);
        plot(V(1:l),src.ImageRawData,'b.-','Parent',handles.imageAxes);
        drawnow();

            

% --- Executes on button press in buttonStop.
function buttonStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ImageAcquisition.ClearScan2D();
handles.scanStopped = 1;

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over buttonStop.
function buttonStop_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuResetNI_Callback(hObject, eventdata, handles)
% hObject    handle to menuResetNI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NI.ResetDevice();
warndlg('NI Device Reset');


% --- Executes during object creation, after setting all properties.
function tablePosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tablePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
hObject.setData([0 0 0]);


% --- Executes during object creation, after setting all properties.
function cursorX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cursorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function cursorY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cursorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function cursorZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cursorZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cursorX_Callback(hObject, eventdata, handles)
% hObject    handle to cursorX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cursorX as text
%        str2double(get(hObject,'String')) returns contents of cursorX as a double

function cursorY_Callback(hObject, eventdata, handles)
% hObject    handle to cursorY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cursorY as text
%        str2double(get(hObject,'String')) returns contents of cursorY as a double

function cursorZ_Callback(hObject, eventdata, handles)
% hObject    handle to cursorZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cursorZ as text
%        str2double(get(hObject,'String')) returns contents of cursorZ as a double

% --- Executes on button press in buttonSetCursor.
function buttonSetCursor_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSetCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% fixate to the current position
newCursorPosition = arrayfun(@(x) str2double(get(x,'String')),[handles.cursorX,handles.cursorY,handles.cursorZ]);

%Disable the button 
set(hObject,'Enable','off');

if length(newCursorPosition) ~= 3,
    errordlg('Could not set cursor');
else
    % update the cursor position
    handles.ImageAcquisition.CursorPosition = newCursorPosition;
    handles.ImageAcquisition.SetCursor();
end


% --- Executes on key press with focus on cursorX and none of its controls.
function cursorX_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to cursorX (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
set(handles.buttonSetCursor,'Enable','on');


% --- Executes on key press with focus on cursorY and none of its controls.
function cursorY_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to cursorY (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
set(handles.buttonSetCursor,'Enable','on');


% --- Executes on key press with focus on cursorZ and none of its controls.
function cursorZ_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to cursorZ (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
set(handles.buttonSetCursor,'Enable','on');


% --------------------------------------------------------------------
function menuSetOffset_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'X Offset (V)','Y Offset (V)','Z Offset (mm)'};
dlg_title = 'Offset Value Preferences';
num_lines = 1;
oldOV = getpref('nv','OffsetValues');
def = {num2str(oldOV(1)),num2str(oldOV(2)),num2str(oldOV(3))};
answer = inputdlg(prompt,dlg_title,num_lines,def);

OV = cellfun(@str2num,answer);

if length(OV) == 3
    
    % save preferences
    setpref('nv','OffsetValues',OV);
    
    % update current IA object
    handles.ImageAcquisition.OffsetValues = OV;
end

function updateScanTable(src,eventdata,handles)
    S = src;
    
    data = {S.MinValues(1),S.MaxValues(1),S.NumPoints(1),logical(S.bEnable(1));...
        S.MinValues(2),S.MaxValues(2),S.NumPoints(2),logical(S.bEnable(2));...
        S.MinValues(3),S.MaxValues(3),S.NumPoints(3),logical(S.bEnable(3));};
        
    set(handles.tableScan,'data',data);

function InitEvents(hObject,handles)
    addlistener(handles.ConfocalScan,'ScanStateChange',@(src,event)updateScanTable(src,event,handles));
    
    addlistener(handles.ImageAcquireEvent,'SavedScanChange',@(src,event)updateScanList(src,event,handles));
    
    addlistener(handles.ImageAcquireEvent,'SelectedScanChange',@(src,event,handles)updateImageList());
    
    addlistener(handles.ImageAcquisition,'UpdateCursorPosition',@(src,event)updateCursorPosition(src,event,handles));
    
    addlistener(handles.Tracker, 'TargetListUpdated',@(src,event)updateTargetList(src,event,handles));


% --- Executes during object creation, after setting all properties.
function tableScan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tableScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'ColumnFormat',{'numeric','numeric','numeric','logical'});

function PerformScan(hObject,eventdata,handles)

% check to see if Z position is homed
if isfield(handles.ImageAcquisition,'interfaceAPTMotor')
    if ~handles.ImageAcquisition.interfaceAPTMotor.isHomed
        [answer] = questdlg('The Z position is not homed. Move home before first scan?','Home Motor','Yes','No','No. Stop Asking','Yes');
        
        switch answer
            case 'Yes'
                pause(.1); % give some time to close the question dialog
                SetStatus(handles,'Homing Stepper Motor...');
                pause(.1);
                handles.ImageAcquisition.interfaceAPTMotor.moveHome();
                SetStatus(handles,'Stepper Motor Homed.');
                
                % after you home, Set the cursor back to the last value
                handles.ImageAcquisition.SetCursor();
            case 'No. Stop Asking'
               handles.ImageAcquisition.interfaceAPTMotor.isHomed = 1;
        end
    end
end

% clear out the images and perform the scan
handles.ImageAcquisition.ConfocalImages = ConfocalImage();

% First, decide the dimension of the scan using the logical array bEnable
% Convert to base 10 and switch
switch sum(handles.ConfocalScan.bEnable .* [4 2 1])
    case 6 %X and Y are enabled
        SetStatus(handles,'Performing 2D Scan.... ');
        PerformScanXY(handles);        
    case 1 %only Z is enabled
        PerformScanZ(handles);
    case {2, 4} %either X or Y is enabled
        PerformScan1DXY(hObject,eventdata,handles);
    case 7 % all are enabled
        PerformScan3D(hObject,eventdata,handles);
    otherwise
        error('Unable to handle current scan setup');
end

        
% copy the images into a gui variable
handles.ConfocalImages = handles.ImageAcquisition.ConfocalImages;
% update guidata
   gobj = findall(0,'Name','ImageAcquire');
   guidata(gobj,handles);
   
updateImageList(hObject,eventdata);

SetStatus(handles,'Scan Complete.');

function updateImageList(hObject,eventdata)

% get the most recent handles
gobj = findall(0,'Name','ImageAcquire');
handles = guidata(gobj);
   
% Make a cell array of strings for the Image list
names = {'No Images Available'};
if isfield(handles,'ConfocalImages')
     for k=1:length(handles.ConfocalImages)
%     for k=1:10%modified by kang to limit the number in the list
        names{k} = ['Image ',num2str(k)];
    end
end

% load images into the selector and set it to the last image
set(handles.popupImage,'String',names);
set(handles.popupImage,'Value',k);

if isfield(handles,'ConfocalImages'),
    DisplayImage([],[],handles,k);
end

function PerformScan3D(hObject,eventdata,handles)
    
    % 3D Scan is simply a succession of 2D scans, with incremented Z values
    
    % first clear the image axes
    cla(handles.imageAxes);
 
    % setup the Z scan
    handles.ImageAcquisition.SetScanZ();
    
    % loop over the z dimension
    dimZ = handles.ImageAcquisition.CurrentScan.NumPoints(3);
    for k=1:dimZ
        % Move the Z direction
        handles.ImageAcquisition.IncrementScanZ();
        
        %Do the 2D scan
        SetStatus(handles,['Performing Scan ',num2str(k),'/',num2str(dimZ)]);
        PerformScanXY(handles);

        %This is a bit of a hack but everytime PerformScanXY is called it
        %calls InitVarforScan which clears the Z scan info
        handles.ImageAcquisition.SetScanZ();
        handles.ImageAcquisition.ZCounter = k;
    end



function PerformScanZ(handles)
    cla(handles.imageAxes);

    handles.ImageAcquisition.SetScanZ();
    % setup the counters
    handles.ImageAcquisition.SetPulseTrain();
    handles.ImageAcquisition.SetCounter();
    
    % setup the data structures
    handles.ImageAcquisition.CounterRawData = [];
            % minimize the acquistion threshold
            
    handles.ImageAcquisition.ImageRawData = [];
    
    delete(handles.ImageAcquisition.updateCounterListenerHandle);
    
    handles.ImageAcquisition.updateCounterListenerHandle = addlistener(handles.ImageAcquisition,'UpdateCounterData',...
        @(src,evnt)updateImage1D(handles,src,evnt));
    
    handles.ImageAcquisition.StartScan1DZ();
    
    handles.ImageAcquisition.ClearScan1DZ();
    
    % remove the listener
    delete(handles.ImageAcquisition.updateCounterListenerHandle);
    
    % record the image
    handles.ImageAcquisition.StoreConfocalImage();
    
    
function PerformScanXY(handles)


% clear out variables for the scan
handles.ImageAcquisition.InitVarForScan();

% setup the pulse train, counters and 2D scan, based on Scan Parameters
handles.ImageAcquisition.SetPulseTrain();
handles.ImageAcquisition.SetCounter();
handles.ImageAcquisition.SetScan2D();

% start the scan
handles.ImageAcquisition.StartScan2D();

% add a listener?
hListener = addlistener(handles.ImageAcquisition,'UpdateCounterData',...
            @(src,eventdata)updateImage(handles,src,eventdata));
        
a = handles.NI.IsTaskDone('Counter');
while ~a
    
    handles.ImageAcquisition.StreamCounterSamples();
    a = handles.NI.IsTaskDone('Counter');
    drawnow();
end
% after the task finishes, clear out the last of the data

handles.ImageAcquisition.StreamCounterSamples(1);

handles.ImageAcquisition.ClearScan2D();
handles.ImageAcquisition.ZeroScan2D();

% record the image
handles.ImageAcquisition.StoreConfocalImage();

% remove the listener
delete(hListener)


function PerformScan1DXY(hObject,eventdata,handles)

% setup the pulse train, counters and 2D scan, based on Scan Parameters
handles.ImageAcquisition.SetPulseTrain();
handles.ImageAcquisition.SetCounter();

%initialize variables
handles.ImageAcquisition.InitVarForScan();

handles.ImageAcquisition.SetScan1DXY();

% start the scan
handles.ImageAcquisition.StartScan2D();

% add a listener?
hListener = addlistener(handles.ImageAcquisition,'UpdateCounterData',...
            @(src,eventdata)updateImage1D(handles,src,eventdata));
        
a = handles.NI.IsTaskDone('Counter');
while ~a
    handles.ImageAcquisition.StreamCounterSamples(1);
    a = handles.NI.IsTaskDone('Counter');
    drawnow();
end
% after the task finishes, clear out the last of the data

handles.ImageAcquisition.StreamCounterSamples(1);

handles.ImageAcquisition.ClearScan2D();
handles.ImageAcquisition.ZeroScan2D();

% record the image
handles.ImageAcquisition.StoreConfocalImage();

% remove the listener
delete(hListener)

% --- Executes on button press in close_pushbutton.
function close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% clean up function

% clear all NI tasks
handles.NI.ClearAllTasks();
handles.ImageAcquisition.interfacePiezo.destroy();
hVCA = findall(0,'Name','Counter');
if hVCA
    close(hVCA);
end

hTrace = findall(0,'Name','Counter Trace');
if hTrace
    close(hTrace);
end


hCursorControl = findall(0,'Name','Cursor Control');
if hCursorControl
    close(hCursorControl);
end
delete(gcf);


% --------------------------------------------------------------------
function menuDIO_Callback(hObject, eventdata, handles)
% hObject    handle to menuDIO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NIDAQ();

%Helpfer function to update the status line. 
function [] = SetStatus(handles,msg)

set(handles.textStatus,'String',msg);


% --- Executes on selection change in popupScan.
function popupScan_Callback(hObject, eventdata, handles)
% hObject    handle to popupScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupScan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupScan

contents = get(hObject,'String');
selectedScan = contents{get(hObject,'Value')};

LoadImagesFromScan(hObject,eventdata,handles);
notify(handles.ImageAcquireEvent,'SelectedScanChange');



% --- Executes during object creation, after setting all properties.
function popupScan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupImage.
function popupImage_Callback(hObject, eventdata, handles)
% hObject    handle to popupImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupImage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupImage
index = get(hObject,'Value');

DisplayImage(hObject,eventdata,handles,index);

% --- Executes during object creation, after setting all properties.
function popupImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DisplayImage(hObject,eventdata,handles,index)

%axes(handles.imageAxes);
%cla(handles.imageAxes);
cImage = handles.ConfocalImages(index);

% Decide what dimension of image we have
if size(cImage.ImageData,1) > 1
    imagesc(cImage.DomainX,cImage.RangeY(end:-1:1),cImage.ImageData,'Parent',handles.imageAxes);
    axis(handles.imageAxes,'square');
    colormap(handles.imageAxes,jet);
    colorbar('EastOutside','peer',handles.imageAxes);
else
    %Assume only axis is enabled
    curaxis = find(cImage.ScanData.bEnable);
    axisRange = linspace(cImage.ScanData.MinValues(curaxis),cImage.ScanData.MaxValues(curaxis),cImage.ScanData.NumPoints(curaxis));
    plot(axisRange,cImage.ImageData,'-b.','Parent',handles.imageAxes);
end

function DrawCrossHairsFromUpdate(src,evnt)

%Load the most recent handles data
gobj = findall(0,'Name','ImageAcquire');
handles = guidata(gobj);

%Try and get handles to the current lines
lh1 = handles.xcrosshair;
lh2 = handles.ycrosshair;

%If they don't exist then create them
if ~ishandle(lh1)
   lh1 = line([0 0],[0 0],[0 0],'Parent',handles.imageAxes);
   handles.xcrosshair = lh1;
   gobj = findall(0,'Name','ImageAcquire');
   guidata(gobj,handles);
end

if ~ishandle(lh2)
   lh2 = line([0 0],[0 0],[0 0],'Parent',handles.imageAxes);
   handles.ycrosshair = lh2;
   gobj = findall(0,'Name','ImageAcquire');
   guidata(gobj,handles);
end

% get the current limits of the axes1
XLimits = get(handles.imageAxes,'XLim');
YLimits = get(handles.imageAxes,'YLim');

%Get the current position and draw lines along x and y
xP = handles.ImageAcquisition.CursorPosition(1);
yP = handles.ImageAcquisition.CursorPosition(2);

if xP <= max(XLimits) && xP >= min(XLimits)
    if yP <= max(YLimits) && yP >= min(YLimits)
        set(lh1,'XData',[XLimits(1),XLimits(2)],'YData',[yP yP]);
        set(lh2,'XData',[xP xP],'YData',[YLimits(1),YLimits(2)]);
    end
end

function [] = SetCursorFromAxes(src,evnt,handles)

CP = get(handles.imageAxes,'CurrentPoint');

handles.ImageAcquisition.CursorPosition(1) = CP(1,1);
handles.ImageAcquisition.CursorPosition(2) = CP(1,2);
handles.ImageAcquisition.CursorPosition(3) = handles.ImageAcquisition.interfacePiezo.GetCurrentPosition();
% handles.ImageAcquisition.SetCursor();
 handles.ImageAcquisition.SetCursor2D();



set(handles.cursorX,'String',sprintf('%0.3f',handles.ImageAcquisition.CursorPosition(1)));
set(handles.cursorY,'String',sprintf('%0.3f',handles.ImageAcquisition.CursorPosition(2)));
set(handles.cursorZ,'String',sprintf('%0.3f',handles.ImageAcquisition.CursorPosition(3)));

%DrawCrosshairs(src,evnt);

function [] = updateCursorPosition(src,evnt,handles)
set(handles.cursorX,'String',sprintf('%0.3f',handles.ImageAcquisition.CursorPosition(1)));
set(handles.cursorY,'String',sprintf('%0.3f',handles.ImageAcquisition.CursorPosition(2)));
set(handles.cursorZ,'String',sprintf('%0.4f',handles.ImageAcquisition.CursorPosition(3)));
DrawCrossHairsFromUpdate(src,evnt);

% --------------------------------------------------------------------
function toggletoolCursorSet_OffCallback(hObject, eventdata, handles)
% hObject    handle to toggletoolCursorSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.imageAxes,'ButtonDownFcn','');

set(handles.imageAxes,'ButtonDownFcn','');
% also need to set the image as well
C = get(handles.imageAxes,'Children');
if C
    set(C,'ButtonDownFcn','');
end


% --------------------------------------------------------------------
function toggletoolCursorSet_OnCallback(hObject, eventdata, handles)
% hObject    handle to toggletoolCursorSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.imageAxes,'ButtonDownFcn',@(src,evt)SetCursorFromAxes(src,evt,handles));
% also need to set the image as well
C = get(handles.imageAxes,'Children');
set(C,'ButtonDownFcn',@(src,evt)SetCursorFromAxes(src,evt,handles));



% --------------------------------------------------------------------
function toggletoolCursorSet_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to toggletoolCursorSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuCPS_Callback(hObject, eventdata, handles)
% hObject    handle to menuCPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)\

% determine if window already open
hVCA = findall(0,'Name','Counter');
% if hVCA
%     hTrace = findall(0,'Name','Counter Trace');
%     if hTrace
%         figure(hTrace);
%     end
%     figure(hVCA);
% else
    ViewCounterAcquisition(handles.Counter);
%end

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
% hObject    handle to menuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuEditImage_Callback(hObject, eventdata, handles)
% hObject    handle to menuEditImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hF = figure;
copyobj(handles.imageAxes,hF);
A = get(hF,'Children');
P = get(A,'OuterPosition');
set(A,'OuterPosition',[.2 .2 P(3) P(4)]);

% --------------------------------------------------------------------
function SaveScan(hObject,eventdata,handles)

    fp = getpref('nv','SavedImageDirectory');

    fn = ['Image_',datestr(now,'yyyy-mm-dd_HHMMSS')];
    fullFN = fullfile(fp,fn);

    Scan = handles.ConfocalImages;
    
    if ~isempty(Scan)
        save(fullFN,'Scan');
    else
        alertdlg('No Images found for current scan');
    end
    notify(handles.ImageAcquireEvent,'SavedScanChange');
    


% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
% hObject    handle to menuSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveScan(hObject,eventdata,handles)

% --------------------------------------------------------------------
function menuAutoSave_Callback(hObject, eventdata, handles)
% hObject    handle to menuAutoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% toggle the state of the AutoSave check box
switch get(hObject,'checked');
    case 'on'
        set(hObject,'checked','off');
    case 'off'
        set(hObject,'checked','on');
end
    
function updateScanList(hObject,eventdata,handles)

%Load the .mat files and sort by date
files = dir([getpref('nv','SavedImageDirectory') '/*.mat']);

%Load the names (flipped to get the dates right) into a cell array and add 'Current Scan' to the top of the
%list
fn = flipud(arrayfun(@(x) x.name,files,'UniformOutput',false));
fn = [{'Current Scan'} fn{:}];

%Set the popup menu
set(handles.popupScan,'String',fn);

%Update the handles object
gobj = findall(0,'Name','ImageAcquire');
guidata(gobj,handles);

function updateTargetList(hObject,eventdata,handles)

    try
        targets = length(handles.Tracker.TargetList(:,1));
    catch error
        targets = 0;
    end
    

    if((get(handles.popupTargetList,'Value') - 1)  > targets)
        set(handles.popupTargetList,'Value',1);
    end
    targetCount = num2cell(handles.Tracker.TargetList(:,4));
    targetCount = ['Select Target'; targetCount];
    %Set the popup menu
    set(handles.popupTargetList,'String',targetCount);

    %Update the handles object
    gobj = findall(0,'Name','ImageAcquire');
    guidata(gobj,handles);

   
function LoadImagesFromScan(hObject,eventdata,handles)

scans = get(handles.popupScan,'String');
selectedScan = scans{get(hObject,'Value')};

% Hints: contents = get(hObject,'String') returns popupScan contents as
% cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupScan

if strcmp(selectedScan,'Current Scan')
    % display current scan images
    handles.ConfocalImages = handles.ImageAcquisition.ConfocalImages;
else
    % load up images from saved file
    
    fp = getpref('nv','SavedImageDirectory');
    SavedScan = load(fullfile(fp,selectedScan));
    handles.ConfocalImages = SavedScan.Scan;
end

gobj = findall(0,'Name','ImageAcquire');
guidata(gobj,handles);
    


% --------------------------------------------------------------------
function menuExportImage_Callback(hObject, eventdata, handles)
% hObject    handle to menuExportImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


fp = getpref('nv','SavedImageDirectory');
[fn,fp] = uiputfile({'*.jpg','*.jpeg'},'Save Image...',fullfile(fp,'ExportedImages'));

hF = figure('Visible','off');
copyobj(handles.imageAxes,hF);
colorbar();
colormap(jet);
hAx = get(hF,'Children');
%set(hAx,'OuterPosition',[0 0 1 1],'ActivePositionProperty','outerposition');
saveas(hF,fullfile(fp,fn));
close(hF);


% --- Executes on button press in buttonNavigate.
function buttonNavigate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNavigate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NavigateUI(handles.ImageAcquisition);


% --------------------------------------------------------------------
function menuPopoutImage_Callback(hObject, eventdata, handles)
% hObject    handle to menuPopoutImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hF = figure();
copyobj(handles.imageAxes,hF);
colorbar();
colormap(jet);

function CheckPrefs()

% see if prefs of type 'nv' are set
NV = getpref('nv');

if isempty(NV)
    
    % ask for offset values
   prompt={'Offset X','Offset Y','Offset Z'};
   name='Set NV Preferences: OffsetValues';
   numlines=1;
   defaultanswer={'0','0','0'};
   answer=inputdlg(prompt,name,numlines,defaultanswer);
   setpref('nv','OffsetValues',[str2double(answer{1}),str2double(answer{2}),str2double(answer{3})]);
   
   a = uigetdir([],'Choose Default Saved Image Directory');
   setpref('nv','SavedImageDirectory',a);
   
end

if ~isfield(NV,'OffsetValues')
    
    % ask for offset values
   prompt={'Offset X','Offset Y','Offset Z'};
   name='Set NV Preferences: OffsetValues';
   numlines=1;
   defaultanswer={'0','0','0'};
   answer=inputdlg(prompt,name,numlines,defaultanswer);
   setpref('nv','OffsetValues',[str2double(answer{1}),str2double(answer{2}),str2double(answer{3})]);
end

if ~isfield(NV,'SavedImageDirectory')
       a = uigetdir([],'Choose Default Saved Image Directory');
   setpref('nv','SavedImageDirectory',a);
   
end


% --------------------------------------------------------------------
function toolSetToAxes_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to toolSetToAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
XL = get(handles.imageAxes,'XLim');
YL = get(handles.imageAxes,'YLim');

handles.ConfocalScan.MaxValues(1) = max(XL);
handles.ConfocalScan.MaxValues(2) = max(YL);
handles.ConfocalScan.MinValues(1) = min(XL);
handles.ConfocalScan.MinValues(2) = min(YL);

notify(handles.ConfocalScan,'ScanStateChange');

% --------------------------------------------------------------------
function menuSetImgDir_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetImgDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%d = getpref('nv','SavedImageDirectory');

%a = uigetdir(d,'Choose Default Saved Image Directory');
%setpref('nv','SavedImageDirectory',a);
a = 'D:\Matlab software and codes\Image directory'; %Changed by Al
setpref('nv','SavedImageDirectory',a);  %Changed by Al

% --- Executes on button press in cbScanContinuous.
function cbScanContinuous_Callback(hObject, eventdata, handles)
% hObject    handle to cbScanContinuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbScanContinuous

function handles = InitDevices(handles)

if ispref('nv','ImageAcquireInitScript')
    script = getpref('nv','ImageAcquireInitScript');
    addpath('./config');
    handles = feval(script(1:end-2),handles);
    SetStatus(handles,sprintf('Init Script (%s) Run',script));
    rmpath('./config');
else
    SetStatus(handles,'Please run init script.');
end


% --------------------------------------------------------------------
function menuSetInitScript_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetInitScript (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ask user to select init script
W = what('config');
[S,OK] = listdlg('PromptString','Select an initialization script','SelectionMode','single','ListString',W.m);
if OK
    handles.initScript = W.m{S};

    % ask to save as default
    button = questdlg('Save Init Script as Default?','Default Init Script','Yes','No','Yes');
    switch button
        case 'Yes'
            setpref('nv','ImageAcquireInitScript',handles.initScript);
    end

    % evaluate the script
    addpath('./config');
    [hObject,handles] = feval(handles.initScript(1:end-2),hObject,handles);
    rmpath('./config');
    SetStatus(handles,sprintf('Init Script (%s) Run',handles.initScript));
    guidata(hObject,handles);
end

function [] = InitIcons(hObject,handles)

[cdata,map] = imread('icons/clock_48.png','png');
handles.icons.counter = cdata(1:2:end,1:2:end,:);
set(handles.uipushtoolCounter,'CData',handles.icons.counter);

[cdata,map] = imread('icons/compass.jpg','jpeg');
handles.icons.nav = cdata;
set(handles.uipushtoolNavigate,'CData',handles.icons.nav);

% --------------------------------------------------------------------
function uipushtoolCounter_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtoolCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

menuCPS_Callback(hObject, eventdata, handles);
gobj = findall(0,'Name','ImageAcquire');
guidata(gobj,handles);


% --------------------------------------------------------------------
function uipushtoolNavigate_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtoolNavigate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NavigateUI(handles.ImageAcquisition);


% --------------------------------------------------------------------
function uipushtoolTrack_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtoolTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% if Tracker defined in the config
if isfield(handles,'Tracker')

    TrackingViewer(handles.Tracker);
    handles.Tracker.trackCenter([0,0,0]);
    %Close the window so we don't accumulate listeners
    close(findobj(0,'name','TrackingViewer'));

end


% --------------------------------------------------------------------
function pushtoolControlLines_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushtoolControlLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval(handles.controlLinesController);


% --------------------------------------------------------------------
% function menu_ZStageController_Callback(hObject, eventdata, handles)
% % hObject    handle to menu_ZStageController (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% %Set the flag
% handles.ImageAcquisition.ZController = questdlg('Which Z Stage Controller','Z Stage Controller','Motor','Piezo','Motor');
% 
% %Switch the units and current position
% switch(handles.ImageAcquisition.ZController)
%     case 'Motor'
%         set(handles.text_curPosZ,'String','Z (mm)');
%         handles.ImageAcquisition.CurrentPosition(3) =  handles.ImageAcquisition.interfaceAPTMotor.getPosition();
%     case 'Piezo'
%         set(handles.text_curPosZ,'String','Z (um)');
%         handles.ImageAcquisition.CurrentPosition(3) =  handles.ImageAcquisition.interfaceAPTPiezo.getPosition();
% end
% set(handles.cursorZ,'String',sprintf('%0.4f',handles.ImageAcquisition.CurrentPosition(3)));
% 
% handles.ImageAcquisition.CursorPosition = handles.ImageAcquisition.CurrentPosition;

% --------------------------------------------------------------------
function menu_ZStageMaxTravel_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ZStageMaxTravel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Look for the MaxTravel Preference
if(isfield(getpref('nv'),'ZMaxTravel'))
    curMaxTravel = {num2str(getpref('nv','ZMaxTravel'))};
else
    curMaxTravel = {''};
end

answer = inputdlg({'Enter Maximum Z Travel:'},'Set Maximum Z Stage Travel',1,curMaxTravel);

if(~isempty(answer))
    setpref('nv','ZMaxTravel',str2double(answer{1}));
end

handles.ImageAcquisition.interfaceAPTMotor.maxTravel = getpref('nv','ZMaxTravel');


% --------------------------------------------------------------------
function menu_ZStageController_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ZStageController (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupTargetList.
function popupTargetList_Callback(hObject, eventdata, handles)
% hObject    handle to popupTargetList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupTargetList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupTargetList
notify(handles.Tracker, 'TargetListUpdated');


% --- Executes during object creation, after setting all properties.
function popupTargetList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupTargetList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonAddTarget.
function buttonAddTarget_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    
     name = handles.Tracker.TargetList(end,4)+1;
%    name = numel(handles.Tracker.TargetList(:,1));
%    name = str2int(handles.Tracker.TargetList(name,4))+1; % by kang

catch ME
    if (strcmp(ME.identifier,'MATLAB:badsubscript'))
        name = 1;
    end
end
handles.Tracker.addTarget(name,handles.ImageAcquisition.CursorPosition(1:3));


% --- Executes on button press in buttonRemoveTarget.
function buttonRemoveTarget_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.Tracker.removeTarget(get(handles.popupTargetList,'Value')); %by kang
handles.Tracker.removeTarget(get(handles.popupTargetList,'Value')-1);


% --- Executes on button press in buttonTrackTarget.
function buttonTrackTarget_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTrackTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
targetNumber = get(handles.popupTargetList,'Value')-1;
TrackingViewer(handles.Tracker);
handles.Tracker.trackTarget(targetNumber);
close(findobj(0,'name','TrackingViewer'));
    


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.ImageAcquisition.interfacePiezo.destroy();
delete(hObject);


% --- Executes on button press in buttonGoToTarget.
function buttonGoToTarget_Callback(hObject, eventdata, handles)
% hObject    handle to buttonGoToTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
targetNumber = get(handles.popupTargetList,'Value')-1;
handles.Tracker.goToTarget(targetNumber);


% --- Executes on button press in buttonClearTargets.
function buttonClearTargets_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClearTargets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Tracker.clearTargets();
% handles.Tracker.TargetList = [];
% notify(handles.Tracker, 'TargetListUpdated');



% --- Executes on button press in buttonAdjustTargets.
function buttonAdjustTargets_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAdjustTargets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
adjustResponse = questdlg('This action will shift the coordinates for all targets based on your current target selection and current cursor position. Are you sure you want to do this?','Warning','Yes','No','No');
switch adjustResponse
    case 'No'
    case 'Yes'
        targetNumber = get(handles.popupTargetList,'Value')-1;
        handles.Tracker.adjustTargets(targetNumber);
          
end



function editColorMin_Callback(hObject, eventdata, handles)
% hObject    handle to editColorMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editColorMin as text
%        str2double(get(hObject,'String')) returns contents of editColorMin as a double


% --- Executes during object creation, after setting all properties.
function editColorMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editColorMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editColorMax_Callback(hObject, eventdata, handles)
% hObject    handle to editColorMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editColorMin as text
%        str2double(get(hObject,'String')) returns contents of editColorMin as a double


% --- Executes during object creation, after setting all properties.
function editColorMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editColorMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonRescale.
function pushbuttonRescale_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
min = get(handles.editColorMin,'String');
max = get(handles.editColorMax,'String');
min = str2num(min);
max = str2num(max);
set(handles.imageAxes,'CLim',[min,max]);



function editLowPLThresh_Callback(hObject, eventdata, handles)
% hObject    handle to editLowPLThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLowPLThresh as text
%        str2double(get(hObject,'String')) returns contents of editLowPLThresh as a double


% --- Executes during object creation, after setting all properties.
function editLowPLThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLowPLThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFilterSize_Callback(hObject, eventdata, handles)
% hObject    handle to editFilterSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilterSize as text
%        str2double(get(hObject,'String')) returns contents of editFilterSize as a double


% --- Executes during object creation, after setting all properties.
function editFilterSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilterSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushFindDefects.
function pushFindDefects_Callback(hObject, eventdata, handles)
% hObject    handle to pushFindDefects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get image data and flip it to agree with plot in console
scanImage = handles.ImageAcquisition.ConfocalImages.ImageData;
scanImage = flipud(scanImage);
scanImage = wiener2(scanImage);
scanImage = medfilt2(scanImage);

%get user input and prepare for image processing
lowerThresh = str2num(get(handles.editLowPLThresh, 'String'));
filterSize = str2num(get(handles.editFilterSize, 'String'));
filter = ones(filterSize);
filterSize = (filterSize-1)/2 +1;
filter(filterSize,filterSize) = 0;

%zero the image data that is below the threshold to make peak finding
%easier
scanImage(scanImage < lowerThresh) = 0;
NVPositions = scanImage > imdilate(scanImage,filter);

%Gather the indices
[NVYCoord,NVXCoord] = find(NVPositions);
NVXCoord = handles.ImageAcquisition.CurrentScanVxVec(NVXCoord)';
NVYCoord = handles.ImageAcquisition.CurrentScanVyVec(NVYCoord)';
NVZCoord = handles.ImageAcquisition.CursorPosition(3);
NVZCoord = repmat(NVZCoord,length(NVXCoord),1);

NVCoords = [NVXCoord,NVYCoord,NVZCoord];
for NV = 1:length(NVXCoord)
    handles.Tracker.addTarget(NV,NVCoords(NV,:));
end


% --- Executes on button press in CheckboxXY.
function CheckboxXY_Callback(hObject, eventdata, handles)
% hObject    handle to CheckboxXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckboxXY


% --- Executes during object creation, after setting all properties.
function CheckboxXY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CheckboxXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in CheckboxZ.
function CheckboxZ_Callback(hObject, eventdata, handles)
% hObject    handle to CheckboxZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckboxZ



function DwellXY_Callback(hObject, eventdata, handles)
% hObject    handle to DwellXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DwellXY as text
%        str2double(get(hObject,'String')) returns contents of DwellXY as a double


% --- Executes during object creation, after setting all properties.
function DwellXY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DwellXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DwellZ_Callback(hObject, eventdata, handles)
% hObject    handle to DwellZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DwellZ as text
%        str2double(get(hObject,'String')) returns contents of DwellZ as a double


% --- Executes during object creation, after setting all properties.
function DwellZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DwellZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function CheckboxZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CheckboxZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function TrackThresh_Callback(hObject, eventdata, handles)
% hObject    handle to TrackThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrackThresh as text
%        str2double(get(hObject,'String')) returns contents of TrackThresh as a double


% --- Executes during object creation, after setting all properties.
function TrackThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrackThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on TrackThresh and none of its controls.
function TrackThresh_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to TrackThresh (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% set(handles.Tracker.TrackingThreshold,'string', sprintf('%d',newTrackThresh));


% --- Executes on button press in TrackThreshSet.
function TrackThreshSet_Callback(hObject, eventdata, handles)
% hObject    handle to TrackThreshSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newTrackThresh = str2double(get(handles.TrackThresh,'String'));
handles.Tracker.TrackingThreshold = newTrackThresh;


% --- Executes on button press in pushbuttonLaser.
function pushbuttonLaser_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLaser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbuttonLaser
LaserState = get(hObject,'Value');
if LaserState
   handles.Tracker.hwLaserController.init();
   handles.Tracker.laserOn;
   handles.Tracker.hwLaserController.close();

   set(hObject,'Value',1);
   set(hObject,'String','Laser On');
   set(hObject,'BackgroundColor','Green');

else
   handles.Tracker.hwLaserController.init();
   handles.Tracker.laserOff;
   handles.Tracker.hwLaserController.close();
   set(hObject,'Value',0);
   set(hObject,'String','Laser Off');
   set(hObject,'BackgroundColor','white');

end
    guidata(hObject,handles);
