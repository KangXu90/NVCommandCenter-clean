function varargout = TrackingViewer(varargin)
% TRACKINGVIEWER M-file for TrackingViewer.fig
%      TRACKINGVIEWER, by itself, creates a new TRACKINGVIEWER or raises the existing
%      singleton*.
%
%      H = TRACKINGVIEWER returns the handle to a new TRACKINGVIEWER or the handle to
%      the existing singleton*.
%
%      TRACKINGVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKINGVIEWER.M with the given input arguments.
%
%      TRACKINGVIEWER('Property','Value',...) creates a new TRACKINGVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrackingViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TrackingViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrackingViewer

% Last Modified by GUIDE v2.5 13-Nov-2009 17:43:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrackingViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @TrackingViewer_OutputFcn, ...
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


% --- Executes just before TrackingViewer is made visible.
function TrackingViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrackingViewer (see VARARGIN)

% Choose default command line output for TrackingViewer
handles.output = hObject;
handles.statusString = {''};  
handles.hTracker = varargin{1};

[hObject,handles] = InitEvents(hObject,handles);
set(handles.figure1,'DeleteFcn',@(src,eventdata)cleanupTrackingViewer(src));
% Update handles structure
guidata(hObject, handles);
%
% center on the screen
%pixels
set( handles.figure1, ...
    'Units', 'pixels' );

%get your display size
screenSize = get(0, 'ScreenSize');

%calculate the center of the display
position = get( handles.figure1, ...
    'Position' );
position(1) = screenSize(3)-position(3);
position(2) = 0;

%center the window
set( handles.figure1, ...
    'Position', position );
% UIWAIT makes TrackingViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TrackingViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
notify(handles.hTracker,'TrackerAbort');

function updateStatus(handles,newString)
    if ~isViewerHandleValid(handles,'textStatus')
        return;
    end
    hObject = findall(0,'Name','TrackingViewer');
    if isempty(hObject) || ~ishandle(hObject(1))
        return;
    end
    hObject = hObject(1);
    handles = guidata(hObject);
    handles.statusString{end+1} = newString;
    maxStatusLines = 100;
    if numel(handles.statusString) > maxStatusLines
        handles.statusString = handles.statusString(end-maxStatusLines+1:end);
    end
    if ~isViewerHandleValid(handles,'textStatus')
        return;
    end
    set(handles.textStatus,'String',handles.statusString);
    hObject = findall(0,'Name','TrackingViewer');
    if isempty(hObject) || ~ishandle(hObject(1))
        return;
    end
    hObject = hObject(1);
    guidata(hObject,handles);

function plotNNCounts(handles,eData)
    if ~isViewerHandleValid(handles,'axes1')
        return;
    end
    bar(handles.axes1,eData.NewData);
    drawnow limitrate;
    
function updateStepSize(handles,eventdata)
    String = sprintf('Step Size Reduced: [%d,%d,%d]',eventdata.NewData(1),eventdata.NewData(2),eventdata.NewData(3));
    updateStatus(handles,String);
        
function updatePosition(handles,eventdata)
    String = sprintf('New Position: [%d,%d,%d]',eventdata.NewData(1),eventdata.NewData(2),eventdata.NewData(3));
    updateStatus(handles,String);

function tf = isViewerHandleValid(handles,fieldName)
    tf = isfield(handles,fieldName) && ishandle(handles.(fieldName));
    
function [hObject,handles] = InitEvents(hObject,handles)

deleteTrackerViewerListeners(handles.hTracker);
handles.listeners.counts = addlistener(handles.hTracker,'TrackerCountsUpdated',@(src,eventdata)plotNNCounts(handles,eventdata));
handles.listeners.step = addlistener(handles.hTracker,'StepSizeReduced',@(src,eventdata)updateStepSize(handles,eventdata));
handles.listeners.position = addlistener(handles.hTracker,'PositionUpdated',@(src,eventdata)updatePosition(handles,eventdata));
setTrackerViewerListeners(handles.hTracker,handles.listeners);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cleanupTrackingViewer(hObject);
    
% Hint: delete(hObject) closes the figure
delete(hObject);

function cleanupTrackingViewer(hObject)
    try
        handles = guidata(hObject);
    catch
        handles = struct();
    end
    if isfield(handles,'listeners')
        deleteListenerStruct(handles.listeners);
        handles.listeners = [];
    end
    if isfield(handles,'hTracker')
        deleteTrackerViewerListeners(handles.hTracker);
    end
    try
        if ishandle(hObject)
            guidata(hObject,handles);
        end
    catch
    end

function setTrackerViewerListeners(hTracker,listeners)
    try
        setappdata(0,'TrackingViewerListeners',listeners);
    catch
    end
    try
        if ~isempty(hTracker) && isvalid(hTracker) && isprop(hTracker,'TrackingViewerListeners')
            hTracker.TrackingViewerListeners = listeners;
        end
    catch
    end

function deleteTrackerViewerListeners(hTracker)
    try
        if isappdata(0,'TrackingViewerListeners')
            deleteListenerStruct(getappdata(0,'TrackingViewerListeners'));
            rmappdata(0,'TrackingViewerListeners');
        end
    catch
    end
    try
        if ~isempty(hTracker) && isvalid(hTracker) && isprop(hTracker,'TrackingViewerListeners')
            deleteListenerStruct(hTracker.TrackingViewerListeners);
            hTracker.TrackingViewerListeners = [];
        end
    catch
    end

function deleteListenerStruct(listeners)
    if isempty(listeners)
        return;
    end
    if isstruct(listeners)
        names = fieldnames(listeners);
        for k = 1:numel(names)
            deleteListenerHandle(listeners.(names{k}));
        end
    else
        deleteListenerHandle(listeners);
    end

function deleteListenerHandle(listenerHandle)
    try
        if ~isempty(listenerHandle)
            validMask = isvalid(listenerHandle);
            delete(listenerHandle(validMask));
        end
    catch
    end
