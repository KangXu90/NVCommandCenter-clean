function varargout = EditParams(varargin)
% EDITPARAMS M-file for EditParams.fig
%      EDITPARAMS, by itself, creates a new EDITPARAMS or raises the existing
%      singleton*.
%
%      H = EDITPARAMS returns the handle to a new EDITPARAMS or the handle to
%      the existing singleton*.
%
%      EDITPARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITPARAMS.M with the given input arguments.
%
%      EDITPARAMS('Property','Value',...) creates a new EDITPARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditParams_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditParams_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EditParams

% Last Modified by GUIDE v2.5 09-Mar-2010 14:49:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditParams_OpeningFcn, ...
                   'gui_OutputFcn',  @EditParams_OutputFcn, ...
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


% --- Executes just before EditParams is made visible.
function EditParams_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditParams (see VARARGIN)

% Choose default command line output for EditParams
handles.output = hObject;

% Populate and update all the fields based on the incoming expparams
handles.expparams = varargin{1};

%Grab a handle to the field controller
if(length(varargin)>1)
    handles.BFieldController = varargin{2};
else 
    handles.BFieldController = [];
end

%Setup the pulse shape popupmenu
%First populate it with 1..99
numbers1to99 = arrayfun(@(x)num2str(x),1:99,'UniformOutput',false);
set(handles.popupmenu_shapeNum,'String',numbers1to99);
%Now use the callback to fill in the rest
popupmenu_shapeNum_Callback(handles.popupmenu_shapeNum, [], handles)

%Now setup the predefined 
%Delays
set(handles.popupmenu_delays,'String',numbers1to99)
popupmenu_delays_Callback(handles.popupmenu_delays, [], handles)
%Pulses
set(handles.popupmenu_pulses,'String',numbers1to99)
popupmenu_pulses_Callback(handles.popupmenu_pulses, [], handles)
%Loops
set(handles.popupmenu_loops,'String',numbers1to99)
popupmenu_loops_Callback(handles.popupmenu_loops, [], handles)

%Setup the channels using the helper function
updateChannelInfoBox(handles);

%Setup the Sweeps box using the helper function
updateSweepInfoBox(handles)

%Update the Other boxes
set(handles.edit_numShots,'String',num2str(handles.expparams.numShots));
set(handles.edit_numAverages,'String',num2str(handles.expparams.numAverages));
set(handles.edit_AWGfreq,'String',num2str(handles.expparams.AWGfreq/1e6));
set(handles.edit_IFfreq,'String',num2str(handles.expparams.IFfreq/1e6));
set(handles.edit_counterChannel,'String',handles.expparams.counterChannel);

set(handles.edit_BFieldX,'String',num2str(handles.expparams.BField(1)));
set(handles.edit_BFieldY,'String',num2str(handles.expparams.BField(2)));
set(handles.edit_BFieldZ,'String',num2str(handles.expparams.BField(3)));

[pathstr, name, ext] = fileparts(handles.expparams.ppFile);
set(handles.text_ppFile,'String',sprintf('Pulse Program: %s%s',name,ext));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditParams wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EditParams_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu_shapeNum.
function popupmenu_shapeNum_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_shapeNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_shapeNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_shapeNum

%Load the shape
tmpShape = handles.expparams.sp(get(hObject,'Value'));

%Fill in the edit boxes
set(handles.edit_shapePower,'String',num2str(tmpShape.power))
set(handles.edit_shapeOffset,'String',sprintf('%.3e',tmpShape.offset));

%If there is a shape then plot it
cla(handles.axes_pulseAmp);
cla(handles.axes_pulsePhase);
if(isempty(tmpShape.pulse))
    %Print a warning
    axesLimits = get(handles.axes_pulseAmp,{'XLim','YLim'});
    text(0.1*diff(axesLimits{1})+axesLimits{1}(1),0.5*diff(axesLimits{2})+axesLimits{2}(1),'No pulse available.','Parent',handles.axes_pulseAmp)
else
    %Plot the shape
    plot(handles.axes_pulseAmp,tmpShape.pulse(:,1));
    plot(handles.axes_pulsePhase,tmpShape.pulse(:,2));
end
    

% --- Executes during object creation, after setting all properties.
function popupmenu_shapeNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_shapeNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_shapePower_Callback(hObject, eventdata, handles)
% hObject    handle to edit_shapePower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.sp(get(handles.popupmenu_shapeNum,'Value')).power = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_shapePower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_shapePower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_shapeOffset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_shapeOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.sp(get(handles.popupmenu_shapeNum,'Value')).offset = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_shapeOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_shapeOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_delays.
function popupmenu_delays_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_delays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Load the value and store it in the string
set(handles.edit_delays,'String',num2str(handles.expparams.defines.(sprintf('d%d',get(hObject,'Value'))).value));




% --- Executes during object creation, after setting all properties.
function popupmenu_delays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_delays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_pulses.
function popupmenu_pulses_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_pulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Load the value and store it in the string
set(handles.edit_pulses,'String',num2str(handles.expparams.defines.(sprintf('p%d',get(hObject,'Value'))).value));


% --- Executes during object creation, after setting all properties.
function popupmenu_pulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_pulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_loops.
function popupmenu_loops_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_loops (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Load the value and store it in the string
set(handles.edit_loops,'String',num2str(handles.expparams.defines.(sprintf('l%d',get(hObject,'Value'))).value));


% --- Executes during object creation, after setting all properties.
function popupmenu_loops_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_loops (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_delays_Callback(hObject, eventdata, handles)
% hObject    handle to edit_delays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.defines.(sprintf('d%d',get(handles.popupmenu_delays,'Value'))).value = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_delays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_delays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pulses_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.defines.(sprintf('p%d',get(handles.popupmenu_pulses,'Value'))).value = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_pulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_loops_Callback(hObject, eventdata, handles)
% hObject    handle to edit_loops (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.defines.(sprintf('l%d',get(handles.popupmenu_loops,'Value'))).value = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_loops_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_loops (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_channels.
function listbox_channels_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_channels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_channels


% --- Executes during object creation, after setting all properties.
function listbox_channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_addChannel.
function pushbutton_addChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Use the input dialog to get the parameters of the new channel
dlgAnswer = inputdlg({'Logical Name','Physical Name (space separate)','Type (quadrature,marker,analog)','Delay On','Delay Off'},'Enter Channel Parameters',1,{'','','','0','0'});

switch dlgAnswer{3}
    case {'marker','analog'}
        handles.expparams.addchannel(dlgAnswer{1},dlgAnswer{2},dlgAnswer{3},dlgAnswer{4},dlgAnswer{5})
    case 'quadrature'
        physicalChannels = textscan(dlgAnswer{2},'%s');
        handles.expparams.addchannel(dlgAnswer{1},physicalChannels{1},dlgAnswer{3},dlgAnswer{4},dlgAnswer{5})
    otherwise
        errordlg('Unknown Channel Type','Oops!')
end

%Use the helper function to update the listbox
updateChannelInfoBox(handles);

% --- Executes on button press in pushbutton_removeChannel.
function pushbutton_removeChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_removeChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Remove the channel
handles.expparams.channels(get(handles.listbox_channels,'Value')) = [];

%Use the helper function to update the listbox
updateChannelInfoBox(handles);


function edit_numShots_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numShots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.numShots = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_numShots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numShots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_numAverages_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numAverages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.numAverages = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_numAverages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numAverages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_AWGfreq_Callback(hObject, eventdata, handles)
% hObject    handle to edit_AWGfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.AWGfreq = 1e6*str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_AWGfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_AWGfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_IFfreq_Callback(hObject, eventdata, handles)
% hObject    handle to edit_IFfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.IFfreq = 1e6*str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_IFfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_IFfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_loadPulse.
function pushbutton_loadPulse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadPulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%First use the uigetfile
[shapeName,shapePath] = uigetfile([pwd '\*.shp'],'Select a Shape File:');

%Use the shape method to try and load the pulse
handles.expparams.sp(get(handles.popupmenu_shapeNum,'Value')).loadpulse(fullfile(shapePath,shapeName));


function updateChannelInfoBox(handles)

%Get the current value
curvalue = get(handles.listbox_channels,'Value');

channelsStr = cell(1,length(handles.expparams.channels));
for chct = 1:length(handles.expparams.channels)
    tmpChannel = handles.expparams.channels(chct); 
    switch tmpChannel.type
        case {'marker','analog'}
            channelsStr{chct} = sprintf('%-30s%-40s%-30s',tmpChannel.logicalName,tmpChannel.physicalName,tmpChannel.type);
        case 'quadrature'
            channelsStr{chct} = sprintf('%-20s%19s, %-19s%-20s',tmpChannel.logicalName,tmpChannel.physicalName{1},tmpChannel.physicalName{2},tmpChannel.type);
    end
end
%If we have channel info then set it
if(~isempty(handles.expparams.channels))
    set(handles.listbox_channels,'Value',min(curvalue,length(handles.expparams.channels)));
    set(handles.listbox_channels,'String',channelsStr);
else
    set(handles.listbox_channels,'Value',1,'String','Channel Info...');
end

% --- Executes on button press in pushbutton_choosePP.
function pushbutton_choosePP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_choosePP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Use the uiputfile to get the location
if ispref('nv','SavedSequenceDirectory'),
    ppPath = getpref('nv','SavedSequenceDirectory');
else
    ppPath = pwd;
end

%First use the uigetfile
[ppName,ppPath] = uigetfile([ppPath '\*.pp'],'Select a Pulse Program File:');

%Then set it
handles.expparams.ppFile = fullfile(ppPath,ppName);
set(handles.text_ppFile,'String',sprintf('Pulse Program: %s',ppName));

% --- Executes during object creation, after setting all properties.
function pushbutton_choosePP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_choosePP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in listbox_sweeps.
function listbox_sweeps_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_sweeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_sweeps contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_sweeps


% --- Executes during object creation, after setting all properties.
function listbox_sweeps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_sweeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_addSweep.
function pushbutton_addSweep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Use an input dialog to get the values
dlgAnswer = inputdlg({'Variable','Array (matlab syntax; leave blank to use fields below)','Start','Stop','Number of Points'},'Enter Sweep Parameters');

if(~isempty(dlgAnswer))
    
    if(isempty(dlgAnswer{2}))
        sweepArray = linspace(str2double(dlgAnswer{3}),str2double(dlgAnswer{4}),str2double(dlgAnswer{5}));
    else
        sweepArray = eval(dlgAnswer{2});
    end
    
    %If we already have sweeps, make sure that they are the same length
    if(~isempty(handles.expparams.sweeps))
        if(handles.expparams.sweeps(1).numPoints ~= length(sweepArray))
            errordlg('Your sweeps need to have the same number of points.','Oops!')
            return
        end
    end
    
    handles.expparams.sweeps(end+1).variable = dlgAnswer{1};
    handles.expparams.sweeps(end).sweepArray = sweepArray;
    handles.expparams.sweeps(end).numPoints = length(sweepArray);
    
    %Call the helper function to repopulate the listbox
    updateSweepInfoBox(handles);
    
end
function updateSweepInfoBox(handles)

%Get the current value
curvalue = get(handles.listbox_sweeps,'Value');

sweepsStr = cell(1,length(handles.expparams.sweeps));
for sweepct = 1:length(handles.expparams.sweeps)
    tmpSweep = handles.expparams.sweeps(sweepct); 
    sweepsStr{sweepct} = sprintf('%15s %15g %15g %15d',tmpSweep.variable,tmpSweep.sweepArray(1),tmpSweep.sweepArray(end),tmpSweep.numPoints);
end
%If we have sweep info then set it
if(~isempty(handles.expparams.sweeps))
    set(handles.listbox_sweeps,'Value',min(curvalue,length(handles.expparams.sweeps)));
    set(handles.listbox_sweeps,'String',sweepsStr);
else
    set(handles.listbox_sweeps,'Value',1,'String','Sweep Info...');
end


% --- Executes on button press in pushbutton_removeSweep.
function pushbutton_removeSweep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_removeSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Remove the channel
handles.expparams.sweeps(get(handles.listbox_channels,'Value')) = [];

%Use the helper function to update the listbox
updateSweepInfoBox(handles);



function edit_counterChannel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_counterChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expparams.counterChannel = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function edit_counterChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_counterChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_editPulseSequence.
function pushbutton_editPulseSequence_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_editPulseSequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

edit(handles.expparams.ppFile);


% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close();


% --- Executes on button press in pushbutton_setPulseSquare.
function pushbutton_setPulseSquare_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setPulseSquare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Use the shape method to try and set a square pulse
handles.expparams.sp(get(handles.popupmenu_shapeNum,'Value')).square(str2double(get(handles.edit_shapePower,'String')));

%Use the callback to update the plots
popupmenu_shapeNum_Callback(handles.popupmenu_shapeNum, [], handles)

% --- Executes on button press in pushbutton_setPulseGaussian.
function pushbutton_setPulseGaussian_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setPulseGaussian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Use an input dialog to get the values
dlgAnswer = inputdlg({'Number of Points','Cutoff'},'Enter Pulse Parameters');

%Use the shape method to try and set a square pulse
handles.expparams.sp(get(handles.popupmenu_shapeNum,'Value')).gaussian(str2double(get(handles.edit_shapePower,'String')),str2double(dlgAnswer{1}),str2double(dlgAnswer{2}));

%Use the callback to update the plots
popupmenu_shapeNum_Callback(handles.popupmenu_shapeNum, [], handles)


function edit_BFieldX_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BFieldX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BFieldX as text
%        str2double(get(hObject,'String')) returns contents of edit_BFieldX as a double

handles.expparams.BField(1) = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_BFieldX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BFieldX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_BFieldY_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BFieldY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BFieldY as text
%        str2double(get(hObject,'String')) returns contents of edit_BFieldY as a double
handles.expparams.BField(2) = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_BFieldY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BFieldY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_BFieldZ_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BFieldZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BFieldZ as text
%        str2double(get(hObject,'String')) returns contents of edit_BFieldZ as a double
handles.expparams.BField(3) = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_BFieldZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BFieldZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_setBField.
function pushbutton_setBField_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setBField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(~isempty(handles.BFieldController))
    handles.BFieldController.setField(handles.expparams.BField);
else
    errordlg('No Controller For B Field Found','Oops');
end

