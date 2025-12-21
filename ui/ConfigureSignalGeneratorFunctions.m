function ConfigureSignalGeneratorFunctions(varargin)

action = varargin{1};


switch action,
    
    case 'SetOutput',
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        SetOutput(hObject,eventdata,handles);
    case 'SetFrequencySweep',
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        SetFrequencySweep(hObject,eventdata,handles);
    case 'Query'
        hObject = varargin{2};
        handles = varargin{4};
        Query(hObject,handles);
    case 'Initialize',
        hObject = varargin{2};
        handles = varargin{3};
        Initialize(hObject,handles);
end
end

function [] = SetOutput(hObject,eventdata,handles)

% get all componets from the gui
% select the channel to edit
% ChannString = get(handles.popupmenuChannel, 'String');
Chann = get(handles.popupmenuChannel, 'Value');
Freq1 = get(handles.editFrequency1,'String');
Phase1 = get(handles.editPhase1,'String');
Apply6dB1 = get(handles.checkboxApply6dB1,'Value');
Freq2 = get(handles.editFrequency2,'String');
Phase2 = get(handles.editPhase2,'String');
Apply6dB2 = get(handles.checkboxApply6dB2,'Value');

% the NCO DAC parameter
NCOString = get(handles.popupmenuNCOmode, 'String');
NCOmode = NCOString{get(handles.popupmenuNCOmode, 'Value')};

DACString = get(handles.popupmenuDACmode, 'String');
DACmode = DACString{get(handles.popupmenuDACmode, 'Value')};

InterpolationString = get(handles.popupmenuInterpolation, 'String');
Interpolation = InterpolationString{get(handles.popupmenuInterpolation, 'Value')};

SamplingRate = get(handles.editSamplingRate,'String');

% the ampplifier parameter

Amp = get(handles.editAmplitude,'String');

if (get(handles.radiobuttonRFOn,'Value') == get(hObject,'Max'))
    RF = 1;
else
    RF = 0;
end

% set the handles object values
handles.hSignalGenerator.Channel = Chann;
handles.hSignalGenerator.Frequency1 = str2double(Freq1);
handles.hSignalGenerator.Phase1 = str2double(Phase1);
handles.hSignalGenerator.Apply6dB1 =Apply6dB1;
handles.hSignalGenerator.Frequency2 = str2double(Freq2);
handles.hSignalGenerator.Phase2 = str2double(Phase2);
handles.hSignalGenerator.Apply6dB2 = Apply6dB2;
% NCO and DAC
handles.hSignalGenerator.NCOmode = NCOmode;
handles.hSignalGenerator.DACmode = DACmode;
handles.hSignalGenerator.Interpolation = Interpolation;
handles.hSignalGenerator.SamplingRate = str2double(SamplingRate);

%Amplifier
handles.hSignalGenerator.Amplitude = str2double(Amp);
handles.hSignalGenerator.RFState = RF;

% call the set functions
handles.hSignalGenerator.Connect();
handles.hSignalGenerator.selectChannel();
handles.hSignalGenerator.setFrequencyandPhase();%set frequency and Phase of NCO1 and NCO2
handles.hSignalGenerator.setApply6dB();%
handles.hSignalGenerator.setDACmode();%'direct';'NCO';'DUC'
handles.hSignalGenerator.setNCOmode();%'single';'dual'
handles.hSignalGenerator.setInterpolation();
handles.hSignalGenerator.setSamplingRate();
handles.hSignalGenerator.setAmplitude();%set output voltage

if handles.hSignalGenerator.RFState,
    handles.hSignalGenerator.setRFOn();
else
    handles.hSignalGenerator.setRFOff();
end
handles.hSignalGenerator.Disconnect();
end %SetOutput


function [] = SetFrequencySweep(hObject,eventdata,handles)

% the sweeping paramter for ODMR
% SweepChannel = get(handels.popmenuSweepChannel,'value');
% SweepNCO = get(handels.popmenuSweepNCO,'Value');

% %select to sweep the lower transition or upper transition
SweepStart1 = get(handles.editSweepStart1,'String');
SweepStop1 = get(handles.editSweepStop1,'String');
SweepPoints1 = get(handles.editSweepPoints1,'String');
SweepZoneState1 = get(handles.checkboxSweepZoneState1,'Value');

SweepStart2 = get(handles.editSweepStart2,'String');
SweepStop2 = get(handles.editSweepStop2,'String');
SweepPoints2 = get(handles.editSweepPoints2,'String');
SweepZoneState2 = get(handles.checkboxSweepZoneState2,'Value');

%Frequency Sweep parameter
handles.hSignalGenerator.Connect();

handles.hSignalGenerator.SweepStart1 = str2double(SweepStart1);
handles.hSignalGenerator.SweepStop1 = str2double(SweepStop1);
handles.hSignalGenerator.SweepPoints1 = str2double(SweepPoints1);
handles.hSignalGenerator.SweepZoneState1 = SweepZoneState1;

handles.hSignalGenerator.SweepStart2 = str2double(SweepStart2);
handles.hSignalGenerator.SweepStop2 = str2double(SweepStop2);
handles.hSignalGenerator.SweepPoints2 = str2double(SweepPoints2);
handles.hSignalGenerator.SweepZoneState2 = SweepZoneState2;


% handles.hSignalGenerator.SweepMode = SweepMode;
% handles.hSignalGenerator.FrequencyMode = FrequencyMode;
% handles.hSignalGenerator.SweepTrigger = SweepTrigger;
% handles.hSignalGenerator.SweepDirection = SweepDirection;

handles.hSignalGenerator.Disconnect();
end %SetSweepFrequency

function [] = Initialize(hObject,handles)
% % call the set functions
handles.hSignalGenerator.Connect();
handles.hSignalGenerator.selectChannel();
handles.hSignalGenerator.getFrequencyandPhase();
handles.hSignalGenerator.getApply6dB();
handles.hSignalGenerator.getNCOmode();
handles.hSignalGenerator.getDACmode();
handles.hSignalGenerator.getInterpolation();
handles.hSignalGenerator.getSamplingRate();
handles.hSignalGenerator.getAmplitude();
handles.hSignalGenerator.getRFState();

% set all componets for the gui
set(handles.popupmenuChannel,'Value',handles.hSignalGenerator.Channel);
% Set the NCO frequency and phase and power
set(handles.editFrequency1,'String',sprintf('%.7g',str2double(handles.hSignalGenerator.Frequency1)));
set(handles.editPhase1,'String',sprintf('%.4g',str2double(handles.hSignalGenerator.Phase1)));
set(handles.checkboxApply6dB1,'Value',handles.hSignalGenerator.Apply6dB1);
set(handles.editFrequency2,'String',sprintf('%.7g',str2double(handles.hSignalGenerator.Frequency2)));
set(handles.editPhase2,'String',sprintf('%.4g',str2double(handles.hSignalGenerator.Phase2)));
set(handles.checkboxApply6dB2,'Value',handles.hSignalGenerator.Apply6dB2);
%set the NCO mode and DAC mode
setDropdownValue(handles.popupmenuNCOmode,handles.hSignalGenerator.NCOmode);
setDropdownValue(handles.popupmenuDACmode,handles.hSignalGenerator.DACmode);
setDropdownValue(handles.popupmenuInterpolation,handles.hSignalGenerator.Interpolation);
set(handles.editSamplingRate,'String',sprintf('%.7g',str2double(handles.hSignalGenerator.SamplingRate)));
% set the amplifier
set(handles.editAmplitude,'String',sprintf('%.4g',str2double(handles.hSignalGenerator.Amplitude)));
set(handles.radiobuttonRFOn,'Value', handles.hSignalGenerator.RFState);



%set the sweep config
set(handles.editSweepStart1,'String',sprintf('%.7g',handles.hSignalGenerator.SweepStart1));
set(handles.editSweepStop1,'String',sprintf('%.7g',handles.hSignalGenerator.SweepStop1));
set(handles.editSweepPoints1,'String',sprintf('%d',handles.hSignalGenerator.SweepPoints1));

set(handles.editSweepStart2,'String',sprintf('%.7g',handles.hSignalGenerator.SweepStart2));
set(handles.editSweepStop2,'String',sprintf('%.7g',handles.hSignalGenerator.SweepStop2));
set(handles.editSweepPoints2,'String',sprintf('%d',handles.hSignalGenerator.SweepPoints2));
set(handles.checkboxSweepZoneState1,'Value',handles.hSignalGenerator.SweepZoneState1);
set(handles.checkboxSweepZoneState2,'Value',handles.hSignalGenerator.SweepZoneState2);
% set(handles.radiobuttonLinkFrequency,'Value',handles.hSignalGenerator.LinkFrequency);

if  handles.hSignalGenerator.RFState > 0,
    set(handles.radiobuttonRFOn,'Value',get(handles.radiobuttonRFOn,'Max'));
else
    set(handles.radiobuttonRFOff,'Value',get(handles.radiobuttonRFOff,'Max'));
end

handles.hSignalGenerator.queryState();
set(handles.textQueryString,'String',handles.hSignalGenerator.QueryString);
handles.hSignalGenerator.Disconnect();

end

function Query(hObject,handles)
handles.hSignalGenerator.Connect();
handles.hSignalGenerator.selectChannel();
handles.hSignalGenerator.queryState();
set(handles.textQueryString,'String',handles.hSignalGenerator.QueryString);
handles.hSignalGenerator.Disconnect();

end

function setDropdownValue(popupmenuHandle, targetValue)
    %
    options = get(popupmenuHandle, 'String');
    
    % 
    [~, index] = ismember(targetValue, options);
    
    % 
    if index > 0
        set(popupmenuHandle, 'Value', index);
    else
        warning('The value %s is not a valid option in the dropdown menu.', targetValue);
    end
end
