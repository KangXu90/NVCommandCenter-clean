function varargout = NVCommandCenter(varargin)
% NVCOMMANDCENTER M-file for NVCommandCenter.fig
%      NVCOMMANDCENTER, by itself, creates a new NVCOMMANDCENTER or raises the existing
%      singleton*.
%
%      H = NVCOMMANDCENTER returns the handle to a new NVCOMMANDCENTER or the handle to
%      the existing singleton*.
%
%      NVCOMMANDCENTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NVCOMMANDCENTER.M with the given input arguments.
%
%      NVCOMMANDCENTER('Property','Value',...) creates a new
%      NVCOMMANDCENTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NVCommandCenter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NVCommandCenter_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NVCommandCenter

% Last Modified by GUIDE v2.5 02-Sep-2024 19:55:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NVCommandCenter_OpeningFcn, ...
    'gui_OutputFcn',  @NVCommandCenter_OutputFcn, ...
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


% --- Executes just before NVCommandCenter is made visible.
function NVCommandCenter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NVCommandCenter (see VARARGIN)

addpath(fullfile(pwd,'Sequences'));

% Choose default command line output for NVCommandCenter
handles.output = hObject;

if ~isfield(handles,'PulseSequence')
    handles.PulseSequence = PulseSequence();
end
if ~isfield(handles,'InitPulseSequence')
    handles.InitPulseSequence = PulseSequence();
end


% init any default values to the handles structure
handles = InitDefaults(handles);

%
InitEvents(hObject,handles);

%
handles = InitDevices(handles);

InitGUI(hObject,handles);
handles = InitConfigMenu(hObject,handles);
handles = InitAnalysisMenu(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NVCommandCenter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NVCommandCenter_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonStart.
function buttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

RunExperiment(hObject,eventdata,handles);

% --- Executes on button press in buttonStop.
function buttonStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
abortRun(hObject, eventdata, handles);

% --- Executes on selection change in popupMode.
function popupMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupMode

contents = get(hObject,'String');
val =contents{get(hObject,'Value')};
set(handles.editSequenceSamples,'Enable','on');


% --- Executes during object creation, after setting all properties.
function popupMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbTrackEnable.
function cbTrackEnable_Callback(hObject, eventdata, handles)
% hObject    handle to cbTrackEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbTrackEnable


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
function menuConfigSG_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigSG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigTaborProteus(handles.SignalGenerator);


% --------------------------------------------------------------------
function menuConfigPG_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigPG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Set ClockRate for Pulse Generator'},...
    sprintf('Set Properties for Pulse Generator: %s',class(handles.PulseGenerator)),...
    1,...
    {sprintf('%.1e',handles.PulseGenerator.ClockRate)});
if ~isempty(answer),
    CR = str2double(answer{1});
    handles.PulseGenerator.ClockRate = CR;

    % update the GUI
    InitGUI(hObject,handles);
end

% --------------------------------------------------------------------
function menuConfigCounter_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbEditPS.
function pbEditPS_Callback(hObject, eventdata, handles)
% hObject    handle to pbEditPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencer(handles.PulseSequence);
InitEvents(hObject,handles);
updatePulseSequence(handles.PulseSequence,[],handles);


function editAverages_Callback(hObject, eventdata, handles)
% hObject    handle to editAverages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAverages as text
%        str2double(get(hObject,'String')) returns contents of editAverages as a double


function Averages = readAverages(handles, previousAverages)
Averages = str2double(get(handles.editAverages,'String'));
if isnan(Averages) || ~isfinite(Averages) || Averages < 1
    Averages = previousAverages;
    return;
end
Averages = floor(Averages);


% --- Executes during object creation, after setting all properties.
function editAverages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAverages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RunExperiment(hObject,eventdata,handles)
% reset specials
handles.specialData = [];
handles.specialVec = [];
handles.Bcal = 1;
handles.TimeVector = [];
handles.SNRTraceHistory = InitSNRTraceHistory();

SetStatus(handles,'Experiment Started...');
% remove any left over listeners
% delete the listener
if isfield(handles,'hListener')
    delete(handles.hListener);
end
if isfield(handles,'hListener2')
    delete(handles.hListener2);
end
if isfield(handles,'hListener3')
    delete(handles.hListener3);
end

% Set the Signal SG
SG =  handles.SignalGenerator;
% Set the Pulse Generator
PG = handles.PulseGenerator;
PG.init();

%Set up AWG
AWG = handles.TEProteusInst;
AWG.Connect();
% AWG.SendCmd(':TRAC:ZERO:ALL');
AWG.SendCmd(':TRAC:DEL:ALL');


% set the MW amplifier from low power but keep off
MAMP = handles.MicrowaveAmp;
try
fopen(MAMP);
catch
end
fprintf(MAMP,'POWER:ON');
fclose(MAMP);


% Set up the Counter changes
myCounter = handles.Counter;
myCounter.AvgIndex = 0;
myCounter.RawData = [];
myCounter.ProcessedData = [];
myCounter.AveragedData = [];
handles.CurrentAverage = 0;
% myCounter.init();


% Clear the average and current scan axes
% cla(handles.axesRawData);
cla(handles.axesAvgData);
cla(handles.axesAvgData2);

cla(handles.axesProcessData);
cla(handles.axesProcessData2);



% if Tracking Enabled, get reference counts

if get(handles.cbTrackEnable,'Value'), % if tracking turned on...

    % turn laser on
    handles.Tracker.laserOn();
    % get some ref counts
    ReferenceCounts = handles.Tracker.GetCountsCurPos;
    set(handles.textTrackRefCounts,'String',ReferenceCounts);
    % turn the laser off
    handles.Tracker.laserOff();

end

% look over the number of averages
Averages = readAverages(handles,1);
Samples = str2double(get(handles.editSequenceSamples,'String'));

promodeselec = get(handles.pnlProcessMode,'SelectedObject');
promode = get(promodeselec,'Tag');

switch promode
    case 'buttonRabiMode'
        ProDataPlotMode = 'UpdateCounterProcData_Rabi';
    case 'buttonT2Mode'
        ProDataPlotMode = 'UpdateCounterProcData_T2';
end


s = get(handles.popupMode,'String');
Mode = s{get(handles.popupMode,'Value')};
handles.note = Mode;


%%%% VERY UGLY HACK
%%%% REMOVE THIS AS SOON AS YOU UNDERSTAND HOW TO SAVE SUBCLASSED OBJECTS
switch Mode
    case 'Pulsed'

        %==================
        %general config
        if str2double(SG.Frequency1)>2e9
            sr_baseband = 1.125e9;                 % 你的基带采样率（与IQM插值、FREQ:RAST匹配）
        else
            sr_baseband = 1e9;
        end

        samplerate = num2str(8 * sr_baseband, '%.0e');                 % 你的基带采样率（与IQM插值、FREQ:RAST匹配）




        % ===============================
        % (原逻辑) 计算sweep/计数器等
        % ===============================
        inds = handles.PulseSequence.getSweepIndexMax();

        % 统计 Counter gate 数
        cnts = strfind([handles.PulseSequence.Channels(:).RiseTypes],'Counter');
        CounterGates = sum([cnts{:}]);

        % 初始化计数器=
        myCounter.NSamples       = Samples;
        myCounter.DataDims       = inds;
        myCounter.NAverages      = Averages;
        myCounter.NCounterGates  = CounterGates;
        myCounter.MaxCounts      = 100;
        myCounter.init();

        % 解析当前 sweep 的脉冲序列（保持你的接口）

        handles.PulseSequence.SweepIndex = 1;
        [BinarySequence,tempSequence,AWGPSeq, AWGPSeqI, AWGPSeqQ,TimeVector] = ProcessPulseSequence( ...
            handles.PulseSequence, 400e6, 'Instruction', sr_baseband);

        % 画图（保持原逻辑）
        PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,tempSequence);

        % used for plot
        handles.TimeVector = TimeVector;

        % 监听器（保持原逻辑）
        handles.hListener  = addlistener(myCounter,'UpdateCounterData', ...
            @(src,eventdata)updateSingleDataPlot(handles,src,eventdata)); % currently not used

        promodeselec = get(handles.pnlProcessMode,'SelectedObject');
        promode      = get(promodeselec,'Tag');

        % Set expType on Counter for pulsed processing
        switch promode
            case 'buttonRabiMode'
                myCounter.expType = 'Rabi';
            case 'buttonT2Mode'
                myCounter.expType = 'T2';
            otherwise
                myCounter.expType = '';
        end

        % Pulse mode: use DataProcessor to update Counter.AveragedData / ProcessedData
        handles.DataProcessor = DataProcessor(myCounter);

        % Pre-create plot handles for incremental (inds) update (set-mode)
        x = handles.TimeVector;
        yInit = NaN(length(x), myCounter.NCounterGates);
        handles.hAvgLines = plot(x, yInit, '.-','Parent',handles.axesAvgData);
        handles.axesAvgData2.Visible = 'on';
        handles.axesAvgData2.XAxisLocation = 'top';
        handles.axesAvgData2.XDir = 'reverse';
        handles.axesAvgData2.YAxisLocation = 'right';
        handles.axesAvgData2.Color = 'none';

        % Processed axis (contrast)
        if strcmp(myCounter.expType,'Rabi')
            SWP = handles.PulseSequence.Sweeps(1);
            xProc = linspace(SWP.StartValue, SWP.StopValue, SWP.SweepPoints)';
        else
            xProc = handles.TimeVector;
        end
        yProcInit = NaN(length(xProc), myCounter.NCounterGates);
        handles.hProcLines = plot(xProc, yProcInit, '.-','Parent',handles.axesProcessData);
        set(handles.hProcLines, 'Color', [0, 0.447, 0.741]); % 深蓝

        handles.axesProcessData2.Visible = 'on';
        handles.axesProcessData2.XAxisLocation = 'top';
        handles.axesProcessData2.XDir = 'reverse';
        handles.axesProcessData2.YAxisLocation = 'right';
        handles.axesProcessData2.Color = 'none';
        % Listeners on DataProcessor (events carry inds + expType)
        handles.hListener2 = addlistener(handles.DataProcessor,'UpdateCounterProcData', ...
            @(src,eventdata)updateAvgDataPlotPulsed(handles,myCounter,eventdata));

        switch myCounter.expType
            case 'Rabi'
                handles.hListener3 = addlistener(handles.DataProcessor,'UpdateCounterProcData_Rabi', ...
                    @(src,eventdata)updateAvgDataPlotPulsedRabi(handles,myCounter,eventdata));
            case 'T2'
                handles.hListener3 = addlistener(handles.DataProcessor,'UpdateCounterProcData_T2', ...
                    @(src,eventdata)updateAvgDataPlotPulsedT2(handles,myCounter,eventdata));
        end

        guidata(hObject,handles);

        % 如需保存spin-noise，保持原逻辑
        if handles.options.spinNoiseAvg
            M  = zeros(myCounter.NSamples,1);
            fn = ['SpinNoise',datestr(now,'yyyymmdd-HHMMSS')];
            fp = handles.options.SpinNoiseDataFolder;
            handles.spinNoiseFilePath = fullfile(fp,fn);
            save(handles.spinNoiseFilePath,'M'); clear('M');
        end

        % ======================================================
        % 【优化1】AWG 一次性初始化（不要在循环里反复配置）
        % ======================================================
        AWG.Connect();
        for ch = 1
            AWG.Channel = ch; AWG.selectChannel();
            AWG.SendCmd(':TRAC:DEL:ALL');
            AWG.SendCmd(':IQM ONE');       % 例：DUC ONE（1.25Gsps），与设备设置保持一致
            AWG.SendCmd(':INIT:CONT OFF');
            AWG.SendCmd(':TRIG:SEL TRG1');
            AWG.SendCmd(':TRIG:LEV 0.5');
            AWG.SendCmd(':TRIG:SOUR:ENAB TRG1');
            AWG.SendCmd(':TRIG:STATE ON');
            AWG.SendCmd(':SOUR:FUNC:MODE:SEGM 1');
            AWG.SendCmd(':FREQ:RAST', samplerate); % 与 sr_baseband * 插值 一致
            % AWG.SendCmd(':SOUR:VOLT 0.8'); % 【优化3】把幅度交给硬件，避免后续整体缩放
            AWG.setRFOn();

            % 【优化6】启用 Marker1 输出（一次性设置）
        end

        handles.PulseSequence.SweepIndex = 1;

    case 'Pulsed/f-sweep'

          ConfigVoltageForRange = true;

          % ConfigVoltageForRange = false;
        % general config
        %default samplerate for pulse-ODMR
        if  ConfigVoltageForRange 
        sr_baseband = 1.125e9;
        AmpGain = 10; % percent
        voltage_below3GHz = 0.1;
        voltage_above3GHz = 0.4;

        fopen(MAMP);
        cmd = ['LEVEL:GAIN', num2str(AmpGain)];
        fprintf(MAMP, [cmd, '\n']);  % 发送命令
        fclose(MAMP);
        samplerate = 8*sr_baseband;

        else
        % % for DD sequence sweep deturning offset
        sr_baseband = 1.0e9;  
        % sr_baseband = 1.125e9;
        samplerate = 8*sr_baseband;
        end


        % -------- 1) 组频点（支持两个区间拼接）--------
        f1 = []; f2 = [];
        if AWG.SweepZoneState1
            f1 = linspace(AWG.SweepStart1, AWG.SweepStop1, AWG.SweepPoints1);
        end
        if AWG.SweepZoneState2
            f2 = linspace(AWG.SweepStart2, AWG.SweepStop2, AWG.SweepPoints2);
        end
        Frequency = [f1, f2];
        handles.specialVec = Frequency(:);
        handles.PulseSequence.Sweeps.SweepPoints = numel(Frequency);
        inds = handles.PulseSequence.Sweeps.SweepPoints;

        % -------- 2) 计数器初始化（保持你原有参数）--------
        cnts = strfind([handles.PulseSequence.Channels(:).RiseTypes], 'Counter');
        CounterGates = sum([cnts{:}]);
        myCounter.NSamples       = Samples;
        myCounter.DataDims       = inds;
        myCounter.NAverages      = Averages;
        myCounter.NCounterGates  = CounterGates;
        myCounter.MaxCounts      = 10000;
        myCounter.init();

        % 监听（Pulsed/f-sweep：使用 DataProcessor 做处理 + set-mode 增量更新）
        handles.hListener  = addlistener(myCounter,'UpdateCounterData', @(src,ev)updateSingleDataPlot(handles,src,ev));

        promodeselec = get(handles.pnlProcessMode,'SelectedObject');
        promode      = get(promodeselec,'Tag');

        % Set expType on Counter for pulsed processing
        switch promode
            case 'buttonRabiMode'
                myCounter.expType = 'Rabi';
            case 'buttonT2Mode'
                myCounter.expType = 'T2';
            otherwise
                myCounter.expType = '';
        end

        % DataProcessor for Pulsed/f-sweep
        handles.DataProcessor = DataProcessor(myCounter);

        % -------- 2.1) 预创建 f-sweep 的曲线句柄（set-mode：只更新 inds 点）--------
        cla(handles.axesAvgData);
        cla(handles.axesAvgData2);
        cla(handles.axesProcessData);
        cla(handles.axesProcessData2);

        nG = myCounter.NCounterGates;

        if handles.TEProteusInst.SweepZoneState1 && ~handles.TEProteusInst.SweepZoneState2
            handles.axesAvgData2.Visible = 'off';
            handles.axesProcessData2.Visible = 'off';
            x1 = handles.specialVec(1:handles.TEProteusInst.SweepPoints1);
            yInit = NaN(numel(x1), nG);

            handles.hAvgLinesFS1 = plot(x1, yInit, '.-','Parent',handles.axesAvgData);
            handles.hAvgLinesFS2 = [];

            handles.hProcLinesFS1 = plot(x1, yInit, '.-','Parent',handles.axesProcessData);
            set(handles.hProcLinesFS1, 'Color', [0, 0.447, 0.741]); % 深蓝

            handles.hProcLinesFS2 = [];

        elseif handles.TEProteusInst.SweepZoneState2 && ~handles.TEProteusInst.SweepZoneState1
            handles.axesAvgData.Visible = 'off';
            handles.axesProcessData.Visible = 'off';

            x2 = handles.specialVec(1:handles.TEProteusInst.SweepPoints2);
            yInit = NaN(numel(x2), nG);

            handles.axesAvgData2.XAxisLocation = 'top';
            handles.axesAvgData2.XDir = 'reverse';
            handles.axesAvgData2.YAxisLocation = 'right';
            handles.hAvgLinesFS2 = plot(x2, yInit, '.-','Parent',handles.axesAvgData2);
            handles.hAvgLinesFS1 = [];

            handles.axesProcessData2.XAxisLocation = 'top';
            handles.axesProcessData2.XDir = 'reverse';
            handles.axesProcessData2.YAxisLocation = 'right';
            handles.hProcLinesFS2 = plot(x2, yInit, '.-','Parent',handles.axesProcessData2);
            handles.hProcLinesFS1 = [];

        else
            % first prepare the average data, which contains ref and sig
            % for each point
            x1 = handles.specialVec(1:handles.TEProteusInst.SweepPoints1);
            x2 = handles.specialVec(end-handles.TEProteusInst.SweepPoints2+1:end);
            yInit1 = NaN(numel(x1), nG);
            yInit2 = NaN(numel(x2), nG);

            handles.hAvgLinesFS1 = plot(x1, yInit1, '.-','Parent',handles.axesAvgData);
            set(handles.hAvgLinesFS1(1), 'Color', [0, 0.447, 0.741]); % 深蓝
            set(handles.hAvgLinesFS1(2), 'Color', [0.301, 0.745, 0.933]); % 浅蓝

            handles.hAvgLinesFS2 = plot(x2, yInit2, '.-','Parent',handles.axesAvgData2);
            set(handles.hAvgLinesFS2(1), 'Color', [0.85, 0.325, 0.098]); % 深红
            set(handles.hAvgLinesFS2(2), 'Color', [0.929, 0.694, 0.125]); % 橙黄

            handles.axesAvgData2.XAxisLocation = 'top';
            handles.axesAvgData2.XDir = 'reverse';
            handles.axesAvgData2.YAxisLocation = 'right';
            handles.axesAvgData2.Color = 'none';
            handles.axesAvgData2.Box = 'off';
            handles.axesAvgData2.XLim = [min(x2) max(x2)];

            %then prepare the process data lines, which only has 1 data for each point
            handles.axesProcessData.Box = 'off';
            handles.hProcLinesFS1 = plot(x1, yInit1(:,1), '.-','Parent',handles.axesProcessData);
            set(handles.hProcLinesFS1, 'Color', [0, 0.447, 0.741]); % 深蓝

            handles.hProcLinesFS2 = plot(x2, yInit2(:,1), '.-','Parent',handles.axesProcessData2);
            set(handles.hProcLinesFS2, 'Color', [0.85, 0.325, 0.098]); % 深红
            handles.axesProcessData2.XAxisLocation = 'top';
            handles.axesProcessData2.XDir = 'reverse';
            handles.axesProcessData2.YAxisLocation = 'right';
            handles.axesProcessData2.Color = 'none';
            handles.axesProcessData2.Box = 'off';
            handles.axesProcessData2.XLim = [min(x2) max(x2)];
        end

        % -------- 2.2) 监听 DataProcessor（事件携带 inds + expType）--------
        handles.hListener2 = addlistener(handles.DataProcessor,'UpdateCounterProcData', ...
            @(src,eventdata)updateAvgDataPlotPulsed(handles,myCounter,eventdata));

        switch myCounter.expType
            case 'Rabi'
                handles.hListener3 = addlistener(handles.DataProcessor,'UpdateCounterProcData_Rabi', ...
                    @(src,eventdata)updateAvgDataPlotPulsedRabi(handles,myCounter,eventdata));
            case 'T2'
                handles.hListener3 = addlistener(handles.DataProcessor,'UpdateCounterProcData_T2', ...
                    @(src,eventdata)updateAvgDataPlotPulsedT2(handles,myCounter,eventdata));
        end

        guidata(hObject,handles);
        % 自旋噪声原始数据（如需）
        if handles.options.spinNoiseAvg
            M  = zeros(myCounter.NSamples,1);
            fn = ['SpinNoise',datestr(now,'yyyymmdd-HHMMSS')];
            fp = handles.options.SpinNoiseDataFolder;
            handles.spinNoiseFilePath = fullfile(fp,fn);
            save(handles.spinNoiseFilePath,'M'); clear M;
        end

        % 解析当前 sweep 的脉冲序列（保持你的接口）
        handles.PulseSequence.SweepIndex = 1;
        [BinarySequence,tempSequence,AWGPSeq,AWGPSeqI, AWGPSeqQ] = ProcessPulseSequence( ...
            handles.PulseSequence, 400e6, 'Instruction', sr_baseband);


        % ======================================================
        AWGconfig.ChannelsToUse = 1;
        % AWGconfig.ChannelsToUse = [1,2];

        for chIdx = AWGconfig.ChannelsToUse
            I_wave =  AWGPSeqI(chIdx,:);
            Q_wave =  AWGPSeqQ(chIdx,:);
            % --- 【优化3】仅归一化，不再整体乘最后一次幅度 ---
            [AWGI, AWGQ] = AWG.NormalIq(I_wave', Q_wave',1);  % 别再整体缩放
            % w = max(Amp)*AWG.Interleave(AWGI, AWGQ);             % 单精度足够
            w = AWG.Interleave(AWGI, AWGQ);             % 单精度足够
            % 粒度对齐
            outLen = max(ceil(numel(w)/AWG.Granularity)*AWG.Granularity, 5120);
            if numel(w) < outLen
                w(outLen) = single(0);
            end
            % --- 【优化4】转为 int16 以匹配16-bit DAC ---
            % w_i16 = int16(32767 * w);

            % 下发波形到段1（保持你的API）
            SendWfmToProteus(AWG, chIdx, 1, w, 16);

            % -------- 4) 一次性 AWG 通道与触发设置 --------
            % 选择段并确保RF ON（初始化里已做，一般不必重复）
            AWG.SendCmd(sprintf('INST:CHAN %d', chIdx));
            AWG.SendCmd(':IQM ONE');
            AWG.SendCmd(':INIT:CONT OFF');
            AWG.SendCmd(':TRIG:SEL TRG1');
            AWG.SendCmd(':TRIG:LEV 0.5');
            AWG.SendCmd(':TRIG:SOUR:ENAB TRG1');
            AWG.SendCmd(':TRIG:STATE ON');
            AWG.SendCmd(':SOUR:FUNC:MODE:SEGM 1');
            AWG.SendCmd(':FREQ:RAST %d',samplerate);   % 你的设备栈（保持一致）
            % AWG.SendCmd(':SOUR:VOLT 0.2');% Config Voltage from AWG
            AWG.setRFOn;
        end

        % -------- 5) 脉冲发生器序列一次性下发 --------
        PG.sendSequence(BinarySequence, Samples, 0);
    case 'Pulsed/N-sweep',
        % setup the data structures
        % Assume that this sort of experiment has a 1D pulse sweep and a
        % single frequency sweep
        
        % get # of sweeps and # of points
        %      inds = str2num(get(handles.editPointsF,'String'));
        
        % number of Tau
        
        %{ kang 202/12/29 Variables for Pulsed/N-sweep
        startN = 4;
        stopN = 804;
        pointsN = 201;
        a = 90;
        b = 180;
        c = 270;
        d = 0;


        p = 50e-9;
        XY = 16;
        Tau = 50e-9;
        %} Variables for Pulsed/N-sweep ended
        
        Ntaus = linspace(startN,stopN,pointsN);
        handles.specialVec = Ntaus; 
        inds = pointsN;
        Np = startN;
        
        %{kang 2022/12/28 for different Ntau, Counter number would not
        %change, so there is no need to change here
        
        % get total number of counter gates
        if XY == 2;
            Q = generatePulseSequence_kang(p/2,p,XY*Np,[a,c], [0,a],0,1);
        end
        if XY == 8
            Q = generatePulseSequence_kang(p/2,p,XY*Np,[0,0], [0,a,0,a,a,0,a,0],0,1,0,1.0);
        end
        if XY == 16 % DSL-4
            Q = generatePulseSequence_WAHUHA_kang(p/2,p,Np,[90,90],[180,270,90,0,180,90,270,0,0,90,270,180,0,270,90,180],0,1,0,1.0);
        end

        handles.PulseSequence = Q;
        PulseVector = Ntaus;



            %==================
        %general config
        if str2double(SG.Frequency1)>2e9
            sr_baseband = 1.125e9;                 % 你的基带采样率（与IQM插值、FREQ:RAST匹配）
        else
            sr_baseband = 1e9;
        end

        samplerate = num2str(8 * sr_baseband, '%.0e');                 % 你的基带采样率（与IQM插值、FREQ:RAST匹配）




        % ===============================
        % (原逻辑) 计算sweep/计数器等
        % ===============================
        % inds = handles.PulseSequence.getSweepIndexMax();

        % 统计 Counter gate 数
        cnts = strfind([handles.PulseSequence.Channels(:).RiseTypes],'Counter');
        CounterGates = sum([cnts{:}]);

        % 初始化计数器=
        myCounter.NSamples       = Samples;
        myCounter.DataDims       = inds;
        myCounter.NAverages      = Averages;
        myCounter.NCounterGates  = CounterGates;
        myCounter.MaxCounts      = 100;
        myCounter.init();

        % 解析当前 sweep 的脉冲序列（保持你的接口）

        handles.PulseSequence.SweepIndex = 1;
        [BinarySequence,tempSequence,AWGPSeq, AWGPSeqI, AWGPSeqQ,TimeVector] = ProcessPulseSequence( ...
            handles.PulseSequence, 400e6, 'Instruction', sr_baseband);

        % 画图（保持原逻辑）
        PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,tempSequence);

        % used for plot
        handles.TimeVector = PulseVector;

        % 监听器（保持原逻辑）
        handles.hListener  = addlistener(myCounter,'UpdateCounterData', ...
            @(src,eventdata)updateSingleDataPlot(handles,src,eventdata)); % currently not used

        promodeselec = get(handles.pnlProcessMode,'SelectedObject');
        promode      = get(promodeselec,'Tag');

        % Set expType on Counter for pulsed processing
        switch promode
            case 'buttonRabiMode'
                myCounter.expType = 'Rabi';
            case 'buttonT2Mode'
                myCounter.expType = 'T2';
            otherwise
                myCounter.expType = '';
        end

        % Pulse mode: use DataProcessor to update Counter.AveragedData / ProcessedData
        handles.DataProcessor = DataProcessor(myCounter);

        % Pre-create plot handles for incremental (inds) update (set-mode)
        x = handles.TimeVector;
        yInit = NaN(length(x), myCounter.NCounterGates);
        handles.hAvgLines = plot(x, yInit, '.-','Parent',handles.axesAvgData);
        handles.axesAvgData2.Visible = 'on';
        handles.axesAvgData2.XAxisLocation = 'top';
        handles.axesAvgData2.XDir = 'reverse';
        handles.axesAvgData2.YAxisLocation = 'right';
        handles.axesAvgData2.Color = 'none';

        % Processed axis (contrast)
        if strcmp(myCounter.expType,'Rabi')
            SWP = handles.PulseSequence.Sweeps(1);
            xProc = linspace(SWP.StartValue, SWP.StopValue, SWP.SweepPoints)';
        else
            xProc = handles.TimeVector;
        end
        yProcInit = NaN(length(xProc), myCounter.NCounterGates);
        handles.hProcLines = plot(xProc, yProcInit, '.-','Parent',handles.axesProcessData);
        set(handles.hProcLines, 'Color', [0, 0.447, 0.741]); % 深蓝

        handles.axesProcessData2.Visible = 'on';
        handles.axesProcessData2.XAxisLocation = 'top';
        handles.axesProcessData2.XDir = 'reverse';
        handles.axesProcessData2.YAxisLocation = 'right';
        handles.axesProcessData2.Color = 'none';
        % Listeners on DataProcessor (events carry inds + expType)
        handles.hListener2 = addlistener(handles.DataProcessor,'UpdateCounterProcData', ...
            @(src,eventdata)updateAvgDataPlotNPulsed(handles,myCounter,eventdata));

        switch myCounter.expType
            case 'Rabi'
                handles.hListener3 = addlistener(handles.DataProcessor,'UpdateCounterProcData_Rabi', ...
                    @(src,eventdata)updateAvgDataPlotPulsedRabi(handles,myCounter,eventdata));
            case 'T2'
                handles.hListener3 = addlistener(handles.DataProcessor,'UpdateCounterProcData_T2', ...
                    @(src,eventdata)updateAvgDataPlotPulsedT2(handles,myCounter,eventdata));
        end

        guidata(hObject,handles);

        % 如需保存spin-noise，保持原逻辑
        if handles.options.spinNoiseAvg
            M  = zeros(myCounter.NSamples,1);
            fn = ['SpinNoise',datestr(now,'yyyymmdd-HHMMSS')];
            fp = handles.options.SpinNoiseDataFolder;
            handles.spinNoiseFilePath = fullfile(fp,fn);
            save(handles.spinNoiseFilePath,'M'); clear('M');
        end

        % ======================================================
        % 【优化1】AWG 一次性初始化（不要在循环里反复配置）
        % ======================================================
        AWG.Connect();
        for ch = 1
            AWG.Channel = ch; AWG.selectChannel();
            AWG.SendCmd(':TRAC:DEL:ALL');
            AWG.SendCmd(':IQM ONE');       % 例：DUC ONE（1.25Gsps），与设备设置保持一致
            AWG.SendCmd(':INIT:CONT OFF');
            AWG.SendCmd(':TRIG:SEL TRG1');
            AWG.SendCmd(':TRIG:LEV 0.5');
            AWG.SendCmd(':TRIG:SOUR:ENAB TRG1');
            AWG.SendCmd(':TRIG:STATE ON');
            AWG.SendCmd(':SOUR:FUNC:MODE:SEGM 1');
            AWG.SendCmd(':FREQ:RAST', samplerate); % 与 sr_baseband * 插值 一致
            % AWG.SendCmd(':SOUR:VOLT 0.8'); % 【优化3】把幅度交给硬件，避免后续整体缩放
            AWG.setRFOn();

            % 【优化6】启用 Marker1 输出（一次性设置）
        end

      

end %switch
refPoint = [0,0,0];
k = 1;
while true
    drawnow limitrate
    Averages = readAverages(handles,Averages);
    myCounter.NAverages = Averages;
    if k>Averages
        break;
    end

    tic
    if myCounter.hasAborted
        %         myCounter.hasAborted = 0;
        break;
    end

    % % if tracking enabled
    % if get(handles.cbTrackEnable,'Value'), % if tracking turned on...
    %
    %     %Do the tracking if we need to
    %     Thresh = str2double(get(handles.editTrackThreshold,'String'));
    %     %If we are belowt the threshold then initiate a tracking session
    %     measuretargets = mod(k-1,Thresh)+1;
    %
    %     TrackingViewer(handles.Tracker);
    %     handles.Tracker.trackTarget( measuretargets);
    %     handles.Tracker.adjustTargets(measuretargets);
    %     close(findobj(0,'name','TrackingViewer'));
    % end

    %
    Thresh = str2double(get(handles.editTrackThreshold,'String'));
    if get(handles.cbTrackEnable,'Value'), % if tracking turned on...

        if mod(k-1,Thresh) == 0,
            TrackingViewer(handles.Tracker);
            handles.Tracker.trackCenter(refPoint);
            close(findobj(0,'name','TrackingViewer'));
            set(handles.textLastTrackPos,'String',datestr(now,'yyyy-mm-dd HH:MM:SS'));
        end
    end

    if strcmp(Mode,'CW'),
        % Parse Pulse Sequence For CW Experiment
        [BinarySequence,temp,AWGPSeq] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate,'Instruction');

        HWChannels = [handles.PulseSequence.getHardwareChannels]';
        % Load Pulse Sequence and set loops to # of sweeps
        PG.sendSequence(BinarySequence,NumberCWPoints,0);
    end
    % if strcmp(Mode,'Pulsed'),
    %     handles.PulseSequence.SweepIndex = 1;
    % end
    if strcmp(Mode,'Pulsed/f-sweep'),
        handles.PulseSequence.SweepIndex = 1;
        [BinarySequence,temp,AWGPSeq, AWGPSeqI, AWGPSeqQ] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate,'Instruction',samplerate);
        % HWChannels = [handles.PulseSequence.getHardwareChannels]';
        % update the sequence plot
        PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,tempSequence);
        % Load Pulse Sequence and set loops to # of sweeps
        PG.sendSequence(BinarySequence,Samples,0);
    end
    if strcmp(Mode,'Sync Read'),
        handles.PulseSequence.SweepIndex = 1;
        %             [InitBinarySequence] = ProcessPulseSequence(handles.InitPulseSequence,PG.ClockRate,'Instruction');
        %
        %             [BinarySequence,temp,AWGPSeq] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate,'Instruction');

        HWChannels = [handles.PulseSequence.getHardwareChannels]';
        % Load Pulse Sequence and set loops to # of sweeps
        PG.sendSequence(BinarySequence,Samples,InitBinarySequenceMW);
    end


    % update text
    set(handles.textAvg,'String',sprintf('(%d/%d)',k,Averages));

    switch Mode,

        case 'Pulsed',

            % turn on SG RF
            AWG.Connect();

            % reset sweeps
            handles.PulseSequence.SweepIndex = 1;
            while handles.PulseSequence.getSweepIndex > 0

                if myCounter.hasAborted
                    %                     myCounter.hasAborted = 0;
                    break;
                end

                % see if we are tracking per sweep point
                if get(handles.cbTrackEnable,'Value') && get(handles.popupTrackFreq,'Value') == 2,
                    Thresh = str2double(get(handles.editTrackThreshold,'String'));
                    % get counts
                    handles.Tracker.laserOn();
                    Counts = handles.Tracker.GetCountsCurPos;
                    handles.Tracker.laserOff();

                    set(handles.textTrackCounts,'String',Counts);

                    if Counts < Thresh*ReferenceCounts,
                        TrackingViewer(handles.Tracker);
                        handles.Tracker.trackCenter(refPoint);

                        close(findobj(0,'name','TrackingViewer'));
                        set(handles.textLastTrackPos,'String',datestr(now,'yyyy-mm-dd HH:MM:SS'));
                    end
                end

                % 解析当前 sweep 的脉冲序列（保持你的接口）
                [BinarySequence,tempSequence,AWGPSeq,AWGPSeqI,AWGPSeqQ,TimeVector] = ProcessPulseSequence( ...
                    handles.PulseSequence, 400e6, 'Instruction', sr_baseband);

                % 画图（保持原逻辑）
                PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,tempSequence);

                % 下发门控序列到脉冲发生器（保持原逻辑）
                % HWChannels = [handles.PulseSequence.getHardwareChannels]';
                PG.sendSequence(BinarySequence, Samples, 0);
                % used for plot
                handles.TimeVector = TimeVector;

                AWGconfig.ChannelsToUse = 1;
                % AWGconfig.ChannelsToUse = [1,2];


                for chIdx = AWGconfig.ChannelsToUse

                    I_wave =  AWGPSeqI(chIdx,:);
                    Q_wave =  AWGPSeqQ(chIdx,:);

                    % --- 【优化3】仅归一化，不再整体乘最后一次幅度 ---

                    [AWGI, AWGQ] = AWG.NormalIq(I_wave', Q_wave',1);  % if normal to max power
                    % w = max(Amp)*AWG.Interleave(AWGI, AWGQ);             % 单精度足够
                    w = AWG.Interleave(AWGI, AWGQ);             % 单精度足够

                    % 粒度对齐
                    outLen = max(ceil(numel(w)/AWG.Granularity)*AWG.Granularity, 5120);
                    if numel(w) < outLen
                        w(outLen) = single(0);
                    end

                    % --- 【优化4】转为 int16 以匹配16-bit DAC ---
                    % w_i16 = int16(32767 * w);

                    % 下发波形到段1（保持你的API）

                    SendWfmToProteus(AWG, chIdx, 1, w, 16); %%% sometimes the AWG could not receive the...
                                                              % file and make the measurement stop during long time measurement
 
                    % 选择段并确保RF ON（初始化里已做，一般不必重复）
                    AWG.SendCmd('INST:CHAN d%', chIdx); AWG.SendCmd(':SOUR:FUNC:MODE:SEGM 1');

                end
                %Setup the rawdata array
                myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                myCounter.RawDataIndex = 0;

                % arm the counter
                myCounter.arm();
                PG.start();
                while ~myCounter.isFinished()
                    myCounter.streamCounts();
                end
                try
                    % Pull once more to drain the tail, in case isFinished is true
                    % but the FIFO isn't empty yet.
                    % solved the point swap problem
                    myCounter.streamCounts();
                catch
                end
                PG.stop();
                if myCounter.isFinished()
                    %Get the last counts
                    % myCounter.streamCounts();
                    myCounter.AvgIndex = k;
                    if handles.options.spinNoiseAvg,
                        myCounter.saveRawDataPulsed(handles.PulseSequence.getSweepIndex,k,handles.spinNoiseFilePath);
                    end
                    % Pulse-mode processing moved to DataProcessor (NICounter stops at streamCounts)
                    if ~strcmp(handles.note, 'Pulsed/f-sweep')
                        handles.DataProcessor.processRawDataPulsed(handles.PulseSequence.getSweepIndex);
                        switch myCounter.expType
                            case 'Rabi'
                                handles.DataProcessor.processRawDataPulsed_Rabi(handles.PulseSequence.getSweepIndex);
                            case 'T2'
                                handles.DataProcessor.processRawDataPulsed_T2(handles.PulseSequence.getSweepIndex);
                        end
                    else
                        % Keep legacy processing path for Pulsed/f-sweep (unchanged)
                        % Pulsed processing moved to DataProcessor (NICounter stops at streamCounts)
                        handles.DataProcessor.processRawDataPulsed(handles.PulseSequence.getSweepIndex);
                        switch myCounter.expType
                            case 'Rabi'
                                handles.DataProcessor.processRawDataPulsed_Rabi(handles.PulseSequence.getSweepIndex);
                            case 'T2'
                                handles.DataProcessor.processRawDataPulsed_T2(handles.PulseSequence.getSweepIndex);
                        end
                    end


                    myCounter.disarm();
                    handles.PulseSequence.incrementSweepIndex();
                    %AWG.sendstr('SEQUENCE:JUMP:IMMEDIATE 1');
                    %                     disp('test');
                else
                    disp('Counter Dropped a Pulse. Repeating');
                    SetStatus(handles,'Repeating Sweep.');
                    myCounter.disarm();
                    myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                end

            end

        case 'Pulsed/f-sweep'
            % 显式 for 循环更清晰（也可以保留 getSweepIndex 的 while）
            for sIdx = 1:numel(Frequency)
                handles.PulseSequence.SweepIndex = sIdx;
                if myCounter.hasAborted, break; end
                % -------- 6) 仅更新载波频率并等待落地（建议用设备的 DUC/NCO 设频命令）--------
                % 把下面的 SCPI 替换成你 setFrequencyandPhase() 内部对频率的那条命令
                AWG.Frequency1 = Frequency(sIdx);
                AWG.setFrequencyandPhase();
                if ConfigVoltageForRange
                    if AWG.Frequency1>3e9
                        AWG.SendCmd(':SOUR:VOLT %d',voltage_above3GHz);
                    else
                        AWG.SendCmd(':SOUR:VOLT %d',voltage_below3GHz); %fsweep power
                    end
                end

                AWG.SendQuery('*OPC?');   % 等设置完成；或用 *WAI

                % 若需要按点 tracking（保留你原逻辑）
                if get(handles.cbTrackEnable,'Value') && get(handles.popupTrackFreq,'Value') == 2
                    Thresh = str2double(get(handles.editTrackThreshold,'String'));
                    handles.Tracker.laserOn();
                    Counts = handles.Tracker.GetCountsCurPos;
                    handles.Tracker.laserOff();
                    set(handles.textTrackCounts,'String',Counts);
                    if exist('ReferenceCounts','var') && Counts < Thresh*ReferenceCounts
                        TrackingViewer(handles.Tracker);
                        handles.Tracker.trackCenter([0,0,0]);
                        close(findobj(0,'name','TrackingViewer'));
                        set(handles.textLastTrackPos,'String',datestr(now,'yyyy-mm-dd HH:MM:SS'));
                    end
                end

                % -------- 7) 可选：改频后的“首点丢弃”（去瞬态）--------
                % 预热触发一次但不入平均；如你在序列里已有 settle 延时，可删掉这段
                % myCounter.disarm();
                % myCounter.RawDataIndex = 0;
                % myCounter.arm();
                % PG.start();
                % while ~myCounter.isFinished()
                %     myCounter.streamCounts();
                %     drawnow limitrate
                % end
                % PG.stop(); myCounter.disarm();

                % -------- 正式采集 --------
                myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                myCounter.RawDataIndex = 0;

                % arm the counter
                myCounter.arm();
                PG.start();
                while ~myCounter.isFinished()
                    myCounter.streamCounts();
                end
                try
                    % Pull once more to drain the tail, in case isFinished is true
                    % but the FIFO isn't empty yet.
                    % solved the point swap problem
                    myCounter.streamCounts();
                catch
                end
                PG.stop();

                if myCounter.isFinished()
                    myCounter.streamCounts();
                    myCounter.AvgIndex = k;
                    if handles.options.spinNoiseAvg
                        myCounter.saveRawDataPulsed(handles.PulseSequence.getSweepIndex, k, handles.spinNoiseFilePath);
                    end
                    % Pulsed processing moved to DataProcessor (NICounter stops at streamCounts)
                    handles.DataProcessor.processRawDataPulsed(handles.PulseSequence.getSweepIndex);
                    switch myCounter.expType
                        case 'Rabi'
                            handles.DataProcessor.processRawDataPulsed_Rabi(handles.PulseSequence.getSweepIndex);
                        case 'T2'
                            handles.DataProcessor.processRawDataPulsed_T2(handles.PulseSequence.getSweepIndex);
                    end
                    myCounter.disarm();
                    % 若仍想兼容 while 版本，这里可以 increment：
                    % handles.PulseSequence.incrementSweepIndex();
                else
                    disp('Counter Dropped a Pulse. Repeating');
                    SetStatus(handles, 'Repeating Sweep.');
                    myCounter.disarm();
                    myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                    % 本点重来（按需）
                end
            end % for sIdx

            % handles.specialData(:,:,handles.PulseSequence.getSweepIndex) = myCounter.AveragedData;
            % end freq sweep loop

             case 'Pulsed/N-sweep',
            
            
            
            
            for qq = 1:length(Ntaus), % loop over the frequencies
                
                % turn on SG RF
                Np = Ntaus(qq);
                if XY == 2;
                    Q = generatePulseSequence_kang(p/2,p,XY*Np,[0,d], [a,c],0,1);
                end
                if XY == 8
                    Q = generatePulseSequence_kang(p/2,p,XY*Np,[0,0], [0,a,0,a,a,0,a,0],0,1,0,1.0);
                end
                if XY == 16 % DSL-4
                    Q = generatePulseSequence_WAHUHA_kang(p/2,p,Np,[90,90],[180,270,90,0,180,90,270,0,0,90,270,180,0,270,90,180],0,1,0,1.0);
                end
                handles.PulseSequence = Q;
                handles.PulseSequence.Sweeps.StartValue = 0;
                handles.PulseSequence.Sweeps.StopValue = 0;
                handles.PulseSequence.Sweeps.SweepPoints = 1;
                
                
                % do all the normal things of a pulsed experiment, but before
                % doing that, change the frequency of the carrier
                
                   % reset sweeps
            handles.PulseSequence.SweepIndex = 1;
            while handles.PulseSequence.getSweepIndex > 0

                if myCounter.hasAborted
                    %                     myCounter.hasAborted = 0;
                    break;
                end

                % see if we are tracking per sweep point
                if get(handles.cbTrackEnable,'Value') && get(handles.popupTrackFreq,'Value') == 2,
                    Thresh = str2double(get(handles.editTrackThreshold,'String'));
                    % get counts
                    handles.Tracker.laserOn();
                    Counts = handles.Tracker.GetCountsCurPos;
                    handles.Tracker.laserOff();

                    set(handles.textTrackCounts,'String',Counts);

                    if Counts < Thresh*ReferenceCounts,
                        TrackingViewer(handles.Tracker);
                        handles.Tracker.trackCenter(refPoint);

                        close(findobj(0,'name','TrackingViewer'));
                        set(handles.textLastTrackPos,'String',datestr(now,'yyyy-mm-dd HH:MM:SS'));
                    end
                end

                % 解析当前 sweep 的脉冲序列（保持你的接口）
                [BinarySequence,tempSequence,AWGPSeq,AWGPSeqI,AWGPSeqQ,TimeVector] = ProcessPulseSequence( ...
                    handles.PulseSequence, 400e6, 'Instruction', sr_baseband);

                % 画图（保持原逻辑）
                PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,tempSequence);

                % 下发门控序列到脉冲发生器（保持原逻辑）
                % HWChannels = [handles.PulseSequence.getHardwareChannels]';
                PG.sendSequence(BinarySequence, Samples, 0);
                % used for plot
                % handles.TimeVector = TimeVector;
                % handles.TimeVector = Ntaus; 


                AWGconfig.ChannelsToUse = 1;
                % AWGconfig.ChannelsToUse = [1,2];


                for chIdx = AWGconfig.ChannelsToUse

                    I_wave =  AWGPSeqI(chIdx,:);
                    Q_wave =  AWGPSeqQ(chIdx,:);

                    % --- 【优化3】仅归一化，不再整体乘最后一次幅度 ---

                    [AWGI, AWGQ] = AWG.NormalIq(I_wave', Q_wave',1);  % if normal to max power
                    % w = max(Amp)*AWG.Interleave(AWGI, AWGQ);             % 单精度足够
                    w = AWG.Interleave(AWGI, AWGQ);             % 单精度足够

                    % 粒度对齐
                    outLen = max(ceil(numel(w)/AWG.Granularity)*AWG.Granularity, 5120);
                    if numel(w) < outLen
                        w(outLen) = single(0);
                    end

                    % --- 【优化4】转为 int16 以匹配16-bit DAC ---
                    % w_i16 = int16(32767 * w);

                    % 下发波形到段1（保持你的API）

                    SendWfmToProteus(AWG, chIdx, 1, w, 16);

                    % 选择段并确保RF ON（初始化里已做，一般不必重复）
                    AWG.SendCmd('INST:CHAN d%', chIdx); AWG.SendCmd(':SOUR:FUNC:MODE:SEGM 1');

                end
                %Setup the rawdata array
                myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                myCounter.RawDataIndex = 0;

                % arm the counter
                myCounter.arm();
                PG.start();
                while ~myCounter.isFinished()
                    myCounter.streamCounts();
                end
                try
                    % Pull once more to drain the tail, in case isFinished is true
                    % but the FIFO isn't empty yet.
                    % solved the point swap problem
                    myCounter.streamCounts();
                catch
                end
                    PG.stop();
                    pause(.2);
                    if myCounter.isFinished()
                        %Get the last counts
                        myCounter.streamCounts();
                        myCounter.AvgIndex = k;
                        if handles.options.spinNoiseAvg,
                            myCounter.saveRawDataPulsed(handles.PulseSequence.getSweepIndex,k,handles.spinNoiseFilePath);
                        end
                        % Pulse-mode processing moved to DataProcessor (NICounter stops at streamCounts)
                        
                        handles.DataProcessor.processRawDataPulsed(qq);
                        switch myCounter.expType
                            case 'Rabi'
                                handles.DataProcessor.processRawDataPulsed_Rabi(qq);
                            case 'T2'
                                handles.DataProcessor.processRawDataPulsed_T2(qq);
                        end

                        myCounter.disarm();
                        handles.PulseSequence.incrementSweepIndex();
                    else
                        disp('Counter Dropped a Pulse. Repeating');
                        SetStatus(handles,'Repeating Sweep.');
                        myCounter.disarm();
                        myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                    end
                    %pause(.5);
                end % end pulse sweep loop
                
                handles.specialData(:,:,qq) = myCounter.AveragedData;
            end % end Ntau sweep loop

    end %Switch on Pulse/CW

    handles = MergeRuntimeAnalysisHandles(hObject,handles);
    handles.CurrentAverage = k;
    handles = recordSNRTraceHistory(handles,myCounter,Mode,k);
    guidata(hObject,handles);
    updateSNRMonitor(handles,myCounter,Mode,k);
    k = k+1;


    %     SG.open();
    %     SG.setRFOff();
    %     SG.close();
end % end averages


PG.stop();
PG.init();
AWG.Connect();
AWG.SendCmd('INST:CHAN 1');
AWG.setRFOff;
AWG.setRFOff;
% AWG.setRFOff();
AWG.Disconnect();
% clean up at the end of the experiment
myCounter.close();

if strcmp(Mode,'Sync Read')
    p = polyfit(1./sqrt((1:Averages)*Npts*tauSR)',handles.Allan,1);
    senseFit = polyval(p,1./sqrt((1:Averages)*Npts*tauSR));
    handles.hRawDataPlot = plot(1./sqrt((1:Averages)*Npts*tauSR)',[handles.Allan,senseFit'],'.-','Parent',handles.axesRawData);
    drawnow();
    disp(p(1))
    Allan = [1./sqrt((1:Averages)*Npts*tauSR)',handles.Allan];
    fn = ['Exp_',datestr(now,'yyyymmdd_HH-MM-SS')];
    save(fn,'Allan');
end
% delete the listeners
if isfield(handles,'hListener')
    delete(handles.hListener);
end

if isfield(handles,'hListener2')
    delete(handles.hListener2);
end

if isfield(handles,'hListener3')
    delete(handles.hListener3);
end
if myCounter.hasAborted
    SetStatus(handles,'Experiment Aborted.');
else
    SetStatus(handles,'Experiment Complete.');
end
guidata(hObject,handles); % update handles object

function updateSNRMonitor(handles,src,Mode,avgIndex)
try
    currentHandles = guidata(handles.figure1);
    if isfield(currentHandles,'SNRMonitor')
        monitor = currentHandles.SNRMonitor;
    elseif isfield(handles,'SNRMonitor')
        monitor = handles.SNRMonitor;
    else
        return;
    end

    if isempty(monitor) || ~isvalid(monitor) || ~monitor.isEnabled()
        return;
    end

    syncSNRMonitorTraceHistory(currentHandles,monitor);
    [x,y] = buildSNRTrace(currentHandles,src,Mode);
    if isempty(x) || isempty(y)
        return;
    end
    monitor.update(x,y,avgIndex,src.expType,Mode);
catch err
    disp(['SNR monitor update skipped: ',err.message]);
end

function handles = MergeRuntimeAnalysisHandles(hObject,handles)
try
    latestHandles = guidata(hObject);
    if isfield(latestHandles,'SNRMonitor')
        handles.SNRMonitor = latestHandles.SNRMonitor;
    end
    if isfield(latestHandles,'options') && isfield(latestHandles.options,'snrMonitorEnabled')
        handles.options.snrMonitorEnabled = latestHandles.options.snrMonitorEnabled;
    end
catch
end

function stopNVFromTargetSNR(hFigure,snr,target,avgIndex)
try
    handles = guidata(hFigure);
    if ~isfield(handles,'Counter') || isempty(handles.Counter) || handles.Counter.hasAborted
        return;
    end
    abortRun(hFigure,[],handles);
    try
        autosaveButton_Callback(hFigure,[],guidata(hFigure));
        handles = guidata(hFigure);
        SetStatus(handles,sprintf('Target SNR reached: %.3g >= %.3g at avg %d. Experiment stopped and saved.',snr,target,avgIndex));
    catch saveErr
        SetStatus(handles,sprintf('Target SNR reached: %.3g >= %.3g at avg %d. Experiment stopped, save failed.',snr,target,avgIndex));
        disp(['Target SNR autosave skipped: ',saveErr.message]);
    end
catch err
    disp(['Target SNR stop skipped: ',err.message]);
end

function history = InitSNRTraceHistory()
history = struct('x',{{}},'y',{{}},'avg',[], ...
    'expType',{{}},'modeName',{{}});

function handles = recordSNRTraceHistory(handles,src,Mode,avgIndex)
if ~isfield(handles,'SNRTraceHistory') || isempty(handles.SNRTraceHistory)
    handles.SNRTraceHistory = InitSNRTraceHistory();
end

[x,y] = buildSNRTrace(handles,src,Mode);
if isempty(x) || isempty(y)
    return;
end

existingIdx = find(handles.SNRTraceHistory.avg == avgIndex,1,'last');
if isempty(existingIdx)
    existingIdx = numel(handles.SNRTraceHistory.avg) + 1;
end
handles.SNRTraceHistory.x{existingIdx} = x;
handles.SNRTraceHistory.y{existingIdx} = y;
handles.SNRTraceHistory.avg(existingIdx,1) = avgIndex;
handles.SNRTraceHistory.expType{existingIdx,1} = src.expType;
handles.SNRTraceHistory.modeName{existingIdx,1} = Mode;

function syncSNRMonitorTraceHistory(handles,monitor)
if ~isfield(handles,'SNRTraceHistory') || isempty(handles.SNRTraceHistory) || ...
        ~isstruct(handles.SNRTraceHistory) || ~isfield(handles.SNRTraceHistory,'avg')
    return;
end
if isempty(monitor.TraceHistory) || ~isstruct(monitor.TraceHistory) || ~isfield(monitor.TraceHistory,'avg')
    monitor.TraceHistory = InitSNRTraceHistory();
end
if isNewSNRTraceHistory(handles.SNRTraceHistory,monitor.TraceHistory)
    monitor.reset();
end
if numel(handles.SNRTraceHistory.avg) <= numel(monitor.TraceHistory.avg)
    return;
end
monitor.TraceHistory = handles.SNRTraceHistory;

function tf = isNewSNRTraceHistory(currentHistory,monitorHistory)
tf = false;
if isempty(currentHistory.avg) || isempty(monitorHistory.avg)
    return;
end
currentIdx = numel(currentHistory.avg);
monitorIdx = numel(monitorHistory.avg);
currentX = currentHistory.x{currentIdx};
monitorX = monitorHistory.x{monitorIdx};
if isempty(currentX) || isempty(monitorX)
    return;
end
if currentHistory.avg(currentIdx) < monitorHistory.avg(monitorIdx)
    tf = true;
    return;
end
if numel(currentX) ~= numel(monitorX)
    tf = true;
    return;
end
if ~sameSNRTraceAxis(currentX,monitorX)
    tf = true;
    return;
end
if ~sameSNRTraceLabel(currentHistory.expType,currentIdx,monitorHistory.expType,monitorIdx) || ...
        ~sameSNRTraceLabel(currentHistory.modeName,currentIdx,monitorHistory.modeName,monitorIdx)
    tf = true;
end

function tf = sameSNRTraceAxis(x1,x2)
x1 = x1(:);
x2 = x2(:);
if numel(x1) ~= numel(x2)
    tf = false;
    return;
end
scale = max([1;abs(x1);abs(x2)]);
tol = 1e-9 * scale;
tf = abs(x1(1)-x2(1)) <= tol && abs(x1(end)-x2(end)) <= tol;

function tf = sameSNRTraceLabel(labels1,idx1,labels2,idx2)
tf = true;
try
    label1 = labels1{idx1};
    label2 = labels2{idx2};
    tf = strcmp(label1,label2);
catch
end

function Mode = getCurrentAcquisitionMode(handles)
if isfield(handles,'note') && ~isempty(handles.note)
    Mode = handles.note;
    return;
end
try
    s = get(handles.popupMode,'String');
    Mode = s{get(handles.popupMode,'Value')};
catch
    Mode = '';
end

function [x,y] = buildSNRTrace(handles,src,Mode)
x = [];
y = [];
if isempty(src.ProcessedData)
    return;
end

data = src.ProcessedData;
if size(data,2) > 1
    data = data(:,1);
end
y = data(:);
validY = isfinite(y);
if nnz(validY) < 3
    x = [];
    y = [];
    return;
end

if strcmp(Mode,'Pulsed/f-sweep') && isfield(handles,'specialVec') && numel(handles.specialVec) == numel(y)
    x = handles.specialVec(:);
elseif strcmp(src.expType,'Rabi') && isfield(handles,'PulseSequence') && ~isempty(handles.PulseSequence.Sweeps)
    SWP = handles.PulseSequence.Sweeps(1);
    x = linspace(SWP.StartValue,SWP.StopValue,numel(y))';
elseif isfield(handles,'TimeVector') && numel(handles.TimeVector) == numel(y)
    x = handles.TimeVector(:);
else
    x = (1:numel(y))';
end

function updateSingleDataPlot(handles,src,eventdata)
% set(handles.hRawDataPlot,'YData',src.RawData);
% %plot(src.RawData,'b-','Parent',handles.axesRawData);
% drawnow();

function updateAvgDataPlot(handles,src,eventdata)

x = linspace(handles.SignalGenerator.SweepStart,handles.SignalGenerator.SweepStop,handles.SignalGenerator.SweepPoints);
data = src.AveragedData(2:end);
%ODMRFit = polyfit(x(2:end)',data,2);
%ODMRFit = polyval(ODMRFit,x(2:end)');
%data = data - ODMRFit;
data = (max(data)-data)./max(data);
plot(x(2:end),data,'b.-','Parent',handles.axesAvgData);
xlabel(handles.axesAvgData,'Freq');
drawnow();


function updateAvgDataPlotPulsed(handles,src,eventdata)
if strcmp(handles.note, 'Pulsed/f-sweep')
    % f-sweep: set-mode incremental update using inds (preferred)
    if nargin >= 3 && ~isempty(eventdata) && isprop(eventdata,'inds')
        inds = eventdata.inds;
    else
        inds = [];
    end

    if ~isempty(inds) && (isfield(handles,'hAvgLinesFS1') || isfield(handles,'hAvgLinesFS2'))
        p1 = handles.TEProteusInst.SweepPoints1;
        if handles.TEProteusInst.SweepZoneState1 && ~handles.TEProteusInst.SweepZoneState2
            local = inds;
            for jj = 1:numel(handles.hAvgLinesFS1)
                y = get(handles.hAvgLinesFS1(jj),'YData');
                y(local) = src.AveragedData(inds,jj);
                set(handles.hAvgLinesFS1(jj),'YData',y);
            end
            drawnow(); return;
        elseif handles.TEProteusInst.SweepZoneState2 && ~handles.TEProteusInst.SweepZoneState1
            local = inds;
            for jj = 1:numel(handles.hAvgLinesFS2)
                y = get(handles.hAvgLinesFS2(jj),'YData');
                y(local) = src.AveragedData(inds,jj);
                set(handles.hAvgLinesFS2(jj),'YData',y);
            end
            drawnow(); return;
        else
            if inds <= p1
                local = inds;
                for jj = 1:numel(handles.hAvgLinesFS1)
                    y = get(handles.hAvgLinesFS1(jj),'YData');
                    y(local) = src.AveragedData(inds,jj);
                    set(handles.hAvgLinesFS1(jj),'YData',y);
                end
            else
                local = inds - p1;
                for jj = 1:numel(handles.hAvgLinesFS2)
                    y = get(handles.hAvgLinesFS2(jj),'YData');
                    y(local) = src.AveragedData(inds,jj);
                    set(handles.hAvgLinesFS2(jj),'YData',y);
                end
            end
            drawnow(); return;
        end
    end

    if handles.TEProteusInst.SweepZoneState1&&~handles.TEProteusInst.SweepZoneState2
        Frequency1  = handles.specialVec(1:handles.TEProteusInst.SweepPoints1);
        data1 = src.AveragedData(1:handles.TEProteusInst.SweepPoints1,:);
        handles.axesAvgData2.XAxisLocation = 'top';
        handles.axesAvgData2.XDir = 'reverse';
        handles.axesAvgData2.YAxisLocation = 'right';
        handles.axesAvgData2.Color = 'none';
        plot(Frequency1,data1,'.-','Parent',handles.axesAvgData);
    end
    if handles.TEProteusInst.SweepZoneState2&&~handles.TEProteusInst.SweepZoneState1
        Frequency2  = handles.specialVec(1:handles.TEProteusInst.SweepPoints2);
        data2 = src.AveragedData(1:handles.TEProteusInst.SweepPoints2,:);
        plot(Frequency2,data2,'.-','Parent',handles.axesAvgData2);
        handles.axesAvgData2.XAxisLocation = 'top';
        handles.axesAvgData2.XDir = 'reverse';
        handles.axesAvgData2.YAxisLocation = 'right';
        handles.axesAvgData2.Color = 'none';
    end
    if handles.TEProteusInst.SweepZoneState1&&handles.TEProteusInst.SweepZoneState2
        Frequency1  = handles.specialVec(1:handles.TEProteusInst.SweepPoints1);
        data1 = src.AveragedData(1:handles.TEProteusInst.SweepPoints1,:);
        plot(Frequency1,data1,'b.-','Parent',handles.axesAvgData);
        Frequency2  = handles.specialVec(end-handles.TEProteusInst.SweepPoints2+1:end);
        data2 = src.AveragedData(end-handles.TEProteusInst.SweepPoints2+1:end,:);
        plot(Frequency2,data2,'r.-','Parent',handles.axesAvgData2);
        handles.axesAvgData2.XAxisLocation = 'top';
        handles.axesAvgData2.XDir = 'reverse';
        handles.axesAvgData2.YAxisLocation = 'right';
        handles.axesAvgData2.Color = 'none';
    end
else
    % Pulse mode: incremental update (set-mode) using inds from eventdata
    if nargin >= 3 && ~isempty(eventdata) && isprop(eventdata,'inds')
        inds = eventdata.inds;
    else
        inds = [];
    end

    % Update AveragedData lines (axesAvgData)
    if isfield(handles,'hAvgLines') && ~isempty(inds)
        for jj = 1:numel(handles.hAvgLines)
            y = get(handles.hAvgLines(jj),'YData');
            y(inds) = src.AveragedData(inds,jj);
            set(handles.hAvgLines(jj),'YData',y);
        end
    end

    % Update ProcessedData lines (axesProcessData) if handles exist
    if isfield(handles,'hProcLines') && ~isempty(inds)
        for jj = 1:numel(handles.hProcLines)
            y = get(handles.hProcLines(jj),'YData');
            y(inds) = src.ProcessedData(inds,jj);
            set(handles.hProcLines(jj),'YData',y);
        end
    end
end


drawnow();

function updateAvgDataPlotPulsedT2(handles,src,eventdata)


% f-sweep T2: set-mode incremental update using inds (preferred)
if strcmp(handles.note, 'Pulsed/f-sweep')
    if nargin >= 3 && ~isempty(eventdata) && isprop(eventdata,'inds')
        inds = eventdata.inds;
    else
        inds = [];
    end

    if ~isempty(inds) && (isfield(handles,'hProcLinesFS1') || isfield(handles,'hProcLinesFS2'))
        p1 = handles.TEProteusInst.SweepPoints1;
        if handles.TEProteusInst.SweepZoneState1 && ~handles.TEProteusInst.SweepZoneState2
            local = inds;
            for jj = 1:numel(handles.hProcLinesFS1)
                y = get(handles.hProcLinesFS1(jj),'YData');
                y(local) = src.ProcessedData(inds,jj);
                set(handles.hProcLinesFS1(jj),'YData',y);
            end
            drawnow(); return;
        elseif handles.TEProteusInst.SweepZoneState2 && ~handles.TEProteusInst.SweepZoneState1
            local = inds;
            for jj = 1:numel(handles.hProcLinesFS2)
                y = get(handles.hProcLinesFS2(jj),'YData');
                y(local) = src.ProcessedData(inds,jj);
                set(handles.hProcLinesFS2(jj),'YData',y);
            end
            drawnow(); return;
        else
            if inds <= p1
                local = inds;
                for jj = 1:numel(handles.hProcLinesFS1)
                    y = get(handles.hProcLinesFS1(jj),'YData');
                    y(local) = src.ProcessedData(inds,jj);
                    set(handles.hProcLinesFS1(jj),'YData',y);
                end
            else
                local = inds - p1;
                for jj = 1:numel(handles.hProcLinesFS2)
                    y = get(handles.hProcLinesFS2(jj),'YData');
                    y(local) = src.ProcessedData(inds,jj);
                    set(handles.hProcLinesFS2(jj),'YData',y);
                end
            end
            drawnow(); return;
        end
    end
end

if numel(handles.PulseSequence.Sweeps) == 1,
    % SWP = handles.PulseSequence.Sweeps(1);
    % SWPpts = SWP.SweepPoints;
    % data = src.ProcessedData;
    % x = linspace(SWP.StartValue,SWP.StopValue,SWPpts)';
    % plot(x,data,'.-','Parent',handles.axesProcessData);
    % SWP = handles.PulseSequence.Sweeps(1);
    % SWPpts = SWP.SweepPoints;
    % set-mode incremental update using inds from eventdata (pulse mode)
    if nargin >= 3 && ~isempty(eventdata) && isprop(eventdata,'inds')
        inds = eventdata.inds;
    else
        inds = [];
    end

    if isfield(handles,'hProcLines') && ~isempty(inds)
        for jj = 1:numel(handles.hProcLines)
            y = get(handles.hProcLines(jj),'YData');
            y(inds) = src.ProcessedData(inds,jj);
            set(handles.hProcLines(jj),'YData',y);
        end
    else
        x = handles.TimeVector;
        data = src.ProcessedData;
        plot(x,data,'.-','Parent',handles.axesProcessData);
    end
    handles.axesProcessData2.XAxisLocation = 'top';
    handles.axesProcessData2.XDir = 'reverse';
    handles.axesProcessData2.YAxisLocation = 'right';
    handles.axesProcessData2.Color = 'none';
end

drawnow();



function updateAvgDataPlotPulsedRabi(handles,src,eventdata)
if strcmp(handles.note, 'Pulsed/f-sweep')
    % f-sweep Rabi: set-mode incremental update using inds (preferred)
    if nargin >= 3 && ~isempty(eventdata) && isprop(eventdata,'inds')
        inds = eventdata.inds;
    else
        inds = [];
    end

    if ~isempty(inds) && (isfield(handles,'hProcLinesFS1') || isfield(handles,'hProcLinesFS2'))
        p1 = handles.TEProteusInst.SweepPoints1;
        if handles.TEProteusInst.SweepZoneState1 && ~handles.TEProteusInst.SweepZoneState2
            local = inds;
            for jj = 1:numel(handles.hProcLinesFS1)
                y = get(handles.hProcLinesFS1(jj),'YData');
                y(local) = src.ProcessedData(inds,jj);
                set(handles.hProcLinesFS1(jj),'YData',y);
            end
            drawnow(); return;
        elseif handles.TEProteusInst.SweepZoneState2 && ~handles.TEProteusInst.SweepZoneState1
            local = inds;
            for jj = 1:numel(handles.hProcLinesFS2)
                y = get(handles.hProcLinesFS2(jj),'YData');
                y(local) = src.ProcessedData(inds,jj);
                set(handles.hProcLinesFS2(jj),'YData',y);
            end
            drawnow(); return;
        else
            if inds <= p1
                local = inds;
                for jj = 1:numel(handles.hProcLinesFS1)
                    y = get(handles.hProcLinesFS1(jj),'YData');
                    y(local) = src.ProcessedData(inds,jj);
                    set(handles.hProcLinesFS1(jj),'YData',y);
                end
            else
                local = inds - p1;
                for jj = 1:numel(handles.hProcLinesFS2)
                    y = get(handles.hProcLinesFS2(jj),'YData');
                    y(local) = src.ProcessedData(inds,jj);
                    set(handles.hProcLinesFS2(jj),'YData',y);
                end
            end
            drawnow(); return;
        end
    end

    if handles.TEProteusInst.SweepZoneState1&&~handles.TEProteusInst.SweepZoneState2
        Frequency1  = handles.specialVec(1:handles.TEProteusInst.SweepPoints1);
        data1 = src.ProcessedData(1:handles.TEProteusInst.SweepPoints1);
        handles.axesProcessData2.XAxisLocation = 'top';
        handles.axesProcessData2.XDir = 'reverse';
        handles.axesProcessData2.YAxisLocation = 'right';
        handles.axesProcessData2.Color = 'none';
        plot(Frequency1,data1,'b.-','Parent',handles.axesProcessData);
    end
    if handles.TEProteusInst.SweepZoneState2&&~handles.TEProteusInst.SweepZoneState1
        Frequency2  = handles.specialVec(1:handles.TEProteusInst.SweepPoints2);
        data2 = src.ProcessedData(1:handles.TEProteusInst.SweepPoints2);
        plot(Frequency2,data2,'r.-','Parent',handles.axesProcessData2);
        handles.axesProcessData2.XAxisLocation = 'top';
        handles.axesProcessData2.XDir = 'reverse';
        handles.axesProcessData2.YAxisLocation = 'right';
        handles.axesProcessData2.Color = 'none';
    end
    if handles.TEProteusInst.SweepZoneState1&&handles.TEProteusInst.SweepZoneState2
        Frequency1  = handles.specialVec(1:handles.TEProteusInst.SweepPoints1);
        data1 = src.ProcessedData(1:handles.TEProteusInst.SweepPoints1);
        plot(Frequency1,data1,'b.-','Parent',handles.axesProcessData);
        Frequency2  = handles.specialVec(end-handles.TEProteusInst.SweepPoints2+1:end);
        data2 = src.ProcessedData(end-handles.TEProteusInst.SweepPoints2+1:end);
        plot(Frequency2,data2,'r.-','Parent',handles.axesProcessData2);
        handles.axesProcessData2.XAxisLocation = 'top';
        handles.axesProcessData2.XDir = 'reverse';
        % handles.axesProcessData2.XLim = [Frequency2(end) Frequency2(1)];
        handles.axesProcessData2.YAxisLocation = 'right';
        handles.axesProcessData2.Color = 'none';
    end

else
    % Pulse mode: incremental update (set-mode) using inds from eventdata
    if nargin >= 3 && ~isempty(eventdata) && isprop(eventdata,'inds')
        inds = eventdata.inds;
    else
        inds = [];
    end

    % Update processed lines if present
    if isfield(handles,'hProcLines') && ~isempty(inds)
        for jj = 1:numel(handles.hProcLines)
            y = get(handles.hProcLines(jj),'YData');
            y(inds) = src.ProcessedData(inds,jj);
            set(handles.hProcLines(jj),'YData',y);
        end
    else
        % Fallback (no precreated handles): do full plot
        data = src.ProcessedData;
        SWP = handles.PulseSequence.Sweeps(1);
        SWPpts = SWP.SweepPoints;
        x = linspace(SWP.StartValue,SWP.StopValue,SWPpts)';
        plot(x,data,'.-','Parent',handles.axesProcessData);
    end
end


drawnow();

% function updateAvgDataPlotPulsedRabi(handles, src, eventdata)
%     % 1. 获取当前更新的索引
%     if nargin >= 3 && isprop(eventdata, 'inds')
%         inds = eventdata.inds;
%     else
%         return; % 如果没有索引，说明没必要增量更新
%     end
%
%     p1 = handles.TEProteusInst.SweepPoints1;
%
%     % 2. 核心逻辑：判断更新哪一个图层
%     % 逻辑：inds <= p1 属于第一段，inds > p1 属于第二段
%     if all(inds <= p1)
%         % 更新第一段 (axesProcessData)
%         updateLineData(handles.hProcLinesFS1, inds, src.ProcessedData(inds, :));
%     else
%         % 更新第二段 (axesProcessData2)
%         % 注意：这里需要减去偏移量 p1 以匹配 x2 的坐标
%         localInds = inds - p1;
%         updateLineData(handles.hProcLinesFS2, localInds, src.ProcessedData(inds, :));
%     end
%
%     drawnow limitrate; % 使用 limitrate 提高高频刷新时的流畅度
%
%
% function updateLineData(hLines, inds, newData)
%     % 封装更新逻辑，避免冗余代码
%     for jj = 1:numel(hLines)
%         y = get(hLines(jj), 'YData');
%         y(inds) = newData(:, jj);
%         set(hLines(jj), 'YData', y);
%     end



function updateAvgDataPlotSyncRead(handles,src,eventdata)

%ColorOrder = [ [0,0,0];[0,0,1];[1,0,0];[0,1,0]];
%set(handles.axesAvgData,'ColorOrder',ColorOrder,'NextPlot','replacechildren');
if numel(handles.PulseSequence.Sweeps) == 1,
    tau = handles.PulseSequence.Sweeps.StartValue;

    Npulse = str2num(get(handles.textSeqName,'String'));
    tauSR = handles.PulseSequence.GetMaxRiseTime()+2*Npulse*2*tau;
    Npts = src.NSamples;
    load(handles.spinNoiseFilePath);
    data = M;
    junkPoints = 1;
    DC = mean(data);
    data = data- DC;
    fftData = abs(fft(data));
    fftData = fftshift(fftData);
    t = linspace(0,Npts*tauSR,Npts);
    f = linspace(0,1/(2*(t(2)-t(1))),Npts/2+1);
    plot(f,fftData(ceil(end/2):end)*handles.Bcal,'.-','Parent',handles.axesAvgData);
    if numel(f) == 1
        return;
    end
    plot(t,data,'.-','Parent',handles.axesProcessData);
    [sig,sigPos] = findpeaks(fftData,'Threshold',4*std(fftData));
    fftData(sigPos) = std(fftData);
    set(handles.textSequenceName, 'String', sprintf('%d',std(fftData)*handles.Bcal));
    plot(1:src.NAverages,handles.Allan,'b-','Parent',handles.axesRawData);
else
    plot(src.AveragedData,'.-','Parent',handles.axesAvgData);
end
drawnow();

function updateAvgDataPlotFPulsed(handles,src,eventdata)

%ColorOrder = [ [0,0,0];[0,0,1];[1,0,0];[0,1,0]];
%set(handles.axesAvgData,'ColorOrder',ColorOrder,'NextPlot','replacechildren');
data = src.AveragedData;
% Contrastdata = data(:,2)./data(:,1);
Contrastdata = data(:,2)./data(:,1);
if numel(handles.PulseSequence.Sweeps) == 1,
    x = handles.specialVec;
    plot(x,data,'.-','Parent',handles.axesAvgData);
    plot(x,Contrastdata,'.-','Parent',handles.axesProcessData);

else
    plot(src.AveragedData,'.-','Parent',handles.axesAvgData);
end

drawnow();
function updateAvgDataPlotNPulsed(handles,src,eventdata)

%ColorOrder = [ [0,0,0];[0,0,1];[1,0,0];[0,1,0]];
%set(handles.axesAvgData,'ColorOrder',ColorOrder,'NextPlot','replacechildren');
data = src.AveragedData;
data = (data(:,1) - data(:,2))./data(:,2);
if numel(handles.PulseSequence.Sweeps) == 1,
    x = handles.TimeVector;
    plot(x,src.AveragedData,'.-','Parent',handles.axesAvgData);
else
    plot(src.AveragedData,'.-','Parent',handles.axesAvgData);
end

drawnow();

% --- Executes on button press in buttonIA.
function buttonIA_Callback(hObject, eventdata, handles)
% hObject    handle to buttonIA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

apps = getappdata(0);
fN = fieldnames(apps);
for k=1:numel(fN),
    if sum(ishandle(getfield(apps,fN{k}))) && isa(getfield(apps,fN{k}),'double'),
        name = get(getfield(apps,fN{k}),'Name');
        if strcmp('ImageAcquire',name),
            hFig = getfield(apps,fN{k});
            figure(hFig);
        end
    end


end

% --------------------------------------------------------------------
function menuSetDevices_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetDevices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ask user to select init script
W = what('config');
[S,OK] = listdlg('PromptString','Select an initialization script','SelectionMode','single','ListString',[W.m]);
if OK,
    handles.initScript = W.m{S};

    % ask to save as default
    button = questdlg('Save Init Script as Default?','Default Init Script','Yes','No','Yes');
    switch button,
        case 'Yes'
            setpref('nv','CCInitScript',handles.initScript);
    end

    % evaluate the script
    addpath(fullfile(pwd,'config'));
    [hObject,handles] = feval(handles.initScript(1:end-2),hObject,handles);
    SetStatus(handles,sprintf('Init Script (%s) Run',handles.initScript));
    guidata(hObject,handles);
    % rmpath(fullfile(pwd,'config'));
end

% --------------------------------------------------------------------
function menuBField_Callback(hObject, eventdata, handles)
% hObject    handle to menuBField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function InitEvents(hObject,handles)

if isfield(handles,'nvccEvents'),
    delete(handles.nvccEvents);
end
handles.nvccEvents = addlistener(handles.PulseSequence,'PulseSeqeunceChangedState',@(src,event)updatePulseSequence(src,event,handles));




function handles = updatePulseSequence(src,event,handles)

try
    currentHandles = guidata(handles.figure1);
    if isstruct(currentHandles)
        handles = currentHandles;
    end
catch
end
handles.PulseSequence = src;
PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,src);
set(handles.textSeqName,'String',src.SequenceName);
handles = UpdateAutoFilename(handles);


% --- Executes on button press in pbLoadPS.
function pbLoadPS_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[PSeq,fn,fp] = PulseSequencerFunctions('LoadExternal');
if fn,
    %feval(class(handles.PulseSequence),PSeq); % if handles.PulseSequnce is a different class than PSeq, due to saving between version, cast to correct class
    %     handles.PulseSequence.copy(PSeq);% commeten by Kang,replaced with
    %     direct =
    handles.PulseSequence = PSeq;

    InitEvents(hObject,handles);
    handles = updatePulseSequence(handles.PulseSequence,[],handles);
    guidata(hObject,handles);
end


function SetStatus(handles,statusText)
set(handles.textStatus,'String',statusText);

function handles = InitDevices(handles)

if ispref('nv','CCInitScript'),
    script = getpref('nv','CCInitScript');
    addpath('./config');
    handles = feval(script(1:end-2),handles);
    SetStatus(handles,sprintf('Init Script (%s) Run',script));
    % rmpath('./config');
else
    SetStatus(handles,'Please run init script.');
end



% --------------------------------------------------------------------
function uitoggletool1_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacursormode on;


% --------------------------------------------------------------------
function uitoggletool1_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacursormode off;


% --------------------------------------------------------------------
function [fn,Exp] = menuSave_Callback(hObject, eventdata, handles)
% hObject    handle to menuSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = UpdateAutoFilename(handles);
guidata(hObject,handles);
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker,handles.popupMode.Value);
Exp.Notes = handles.note;
Exp.SpecialData = handles.specialData;
Exp.SpecialVec = handles.specialVec;
Exp.TimeVector = handles.TimeVector;

[fn]= SaveExp(Exp,handles);


function [fn] = SaveExp(Exp,handles)

if ispref('nv','DefaultExpSavePath');
    fp = getpref('nv','DefaultExpSavePath');
else
    fp = '';
end

fn = BuildSaveFilename(handles);
[fn,fp] = uiputfile('*.mat',fullfile(fp,fn));
if ~isequal(fn,0)
    fn = BuildSaveFilenameFromName(handles,fn);
    fn = fullfile(fp,fn);
    fn = BuildUniqueFilename(fn);
    save(fn,'Exp');
end

function handles = InitConfigMenu(hObject,handles)
existingMenu = findall(handles.figure1,'Tag','menuNVConfiguration');
if ~isempty(existingMenu)
    handles.menuNVConfiguration = existingMenu(1);
    return;
end
handles.menuNVConfiguration = uimenu(handles.figure1,'Label','Configuration','Tag','menuNVConfiguration');
uimenu(handles.menuNVConfiguration,'Label','Save Configuration...','Tag','menuSaveNVConfiguration',...
    'Callback',@(hObject,eventdata)menuSaveConfig_Callback(hObject,eventdata,guidata(hObject)));
uimenu(handles.menuNVConfiguration,'Label','Load Configuration...','Tag','menuLoadNVConfiguration',...
    'Callback',@(hObject,eventdata)menuLoadConfig_Callback(hObject,eventdata,guidata(hObject)));

function handles = InitAnalysisMenu(hObject,handles)
existingMenu = findall(handles.figure1,'Tag','menuNVAnalysis');
if ~isempty(existingMenu)
    handles.menuNVAnalysis = existingMenu(1);
    return;
end
handles.menuNVAnalysis = uimenu(handles.figure1,'Label','Analysis','Tag','menuNVAnalysis');
handles.menuSNRMonitor = uimenu(handles.menuNVAnalysis,'Label','SNR Monitor','Tag','menuSNRMonitor',...
    'Callback',@(hObject,eventdata)menuSNRMonitor_Callback(hObject,eventdata,guidata(hObject)));

function menuSNRMonitor_Callback(hObject,eventdata,handles)
if ~isfield(handles,'SNRMonitor') || isempty(handles.SNRMonitor) || ~isvalid(handles.SNRMonitor)
    handles.SNRMonitor = SNRMonitor();
else
    handles.SNRMonitor.show();
end
handles.SNRMonitor.StopFcn = @(snr,target,avgIndex)stopNVFromTargetSNR(handles.figure1,snr,target,avgIndex);
syncSNRMonitorTraceHistory(handles,handles.SNRMonitor);
handles.SNRMonitor.recalculate();
handles.options.snrMonitorEnabled = 1;
guidata(hObject,handles);

function menuSaveConfig_Callback(hObject,eventdata,handles)
Config = BuildNVConfiguration(handles);
defaultPath = GetConfigDefaultPath();
defaultName = ['NVCommandCenterConfig_',datestr(now,'yyyymmdd_HH-MM-SS'),'.mat'];
[fn,fp] = uiputfile('*.mat','Save NVCommandCenter Configuration',fullfile(defaultPath,defaultName));
if isequal(fn,0)
    return;
end
setpref('nv','DefaultConfigSavePath',fp);
fn = BuildUniqueFilename(fullfile(fp,fn));
save(fn,'Config');
SetStatus(handles,sprintf('Configuration saved: %s',fn));

function menuLoadConfig_Callback(hObject,eventdata,handles)
defaultPath = GetConfigDefaultPath();
[fn,fp] = uigetfile('*.mat','Load NVCommandCenter Configuration',defaultPath);
if isequal(fn,0)
    return;
end
data = load(fullfile(fp,fn));
if ~isfield(data,'Config')
    errordlg('Selected file does not contain a Config variable.','Load Configuration');
    return;
end
setpref('nv','DefaultConfigSavePath',fp);
handles = ApplyNVConfiguration(handles,data.Config);
InitEvents(handles.figure1,handles);
handles = updatePulseSequence(handles.PulseSequence,[],handles);
InitGUI(handles.figure1,handles);
handles = UpdateAutoFilename(handles);
guidata(handles.figure1,handles);
SetStatus(handles,sprintf('Configuration loaded: %s',fullfile(fp,fn)));

function defaultPath = GetConfigDefaultPath()
if ispref('nv','DefaultConfigSavePath')
    defaultPath = getpref('nv','DefaultConfigSavePath');
else
    defaultPath = pwd;
end

function Config = BuildNVConfiguration(handles)
Config.Version = 1;
Config.Created = datestr(now);
Config.GUI = CaptureGUIControls(handles);
Config.PulseSequence = handles.PulseSequence;
Config.InitPulseSequence = handles.InitPulseSequence;
Config.SignalGenerator = CaptureObjectProperties(handles,'SignalGenerator',SignalGeneratorConfigFields());
Config.Tabor = CaptureObjectProperties(handles,'TEProteusInst',TaborConfigFields());

function handles = ApplyNVConfiguration(handles,Config)
if isfield(Config,'PulseSequence')
    handles.PulseSequence = Config.PulseSequence;
end
if isfield(Config,'InitPulseSequence')
    handles.InitPulseSequence = Config.InitPulseSequence;
end
if isfield(Config,'GUI')
    handles = ApplyGUIControls(handles,Config.GUI);
end
if isfield(Config,'SignalGenerator')
    handles = ApplyObjectProperties(handles,'SignalGenerator',Config.SignalGenerator);
end
if isfield(Config,'Tabor')
    handles = ApplyObjectProperties(handles,'TEProteusInst',Config.Tabor);
end

function GUI = CaptureGUIControls(handles)
controlNames = GUIConfigControlNames();
GUI = struct();
for k = 1:numel(controlNames)
    name = controlNames{k};
    if isfield(handles,name) && ishandle(handles.(name))
        try
            GUI.(name).String = get(handles.(name),'String');
        catch
        end
        try
            GUI.(name).Value = get(handles.(name),'Value');
        catch
        end
    end
end
if isfield(handles,'popupmenuTempelate') && ishandle(handles.popupmenuTempelate)
    strings = get(handles.popupmenuTempelate,'String');
    value = get(handles.popupmenuTempelate,'Value');
    if ischar(strings)
        strings = cellstr(strings);
    end
    if ~isempty(strings) && value <= numel(strings)
        GUI.popupmenuTempelate.SelectedString = strings{value};
    end
end

function handles = ApplyGUIControls(handles,GUI)
controlNames = fieldnames(GUI);
for k = 1:numel(controlNames)
    name = controlNames{k};
    if ~isfield(handles,name) || ~ishandle(handles.(name))
        continue;
    end
    if isfield(GUI.(name),'String') && ~strcmp(name,'popupmenuTempelate')
        try
            set(handles.(name),'String',GUI.(name).String);
        catch
        end
    end
    if isfield(GUI.(name),'Value')
        try
            set(handles.(name),'Value',GUI.(name).Value);
        catch
        end
    end
end
if isfield(handles,'popupmenuTempelate') && ishandle(handles.popupmenuTempelate)
    RefreshOriginTemplatePopup(handles.popupmenuTempelate,handles);
    if isfield(GUI,'popupmenuTempelate') && isfield(GUI.popupmenuTempelate,'SelectedString')
        strings = get(handles.popupmenuTempelate,'String');
        if ischar(strings)
            strings = cellstr(strings);
        end
        selectedIndex = find(strcmp(strings,GUI.popupmenuTempelate.SelectedString),1);
        if ~isempty(selectedIndex)
            set(handles.popupmenuTempelate,'Value',selectedIndex);
        end
    end
end

function fields = GUIConfigControlNames()
fields = {'popupMode','editSequenceSamples','editAverages','cbTrackEnable',...
    'popupTrackFreq','editTrackThreshold','filenameEdit','prenameEdit',...
    'filepathEdit','plotinOriginCheckbox','popupmenuTempelate','textPiPulse'};

function data = CaptureObjectProperties(handles,objectName,fields)
data = struct();
if ~isfield(handles,objectName)
    return;
end
obj = handles.(objectName);
for k = 1:numel(fields)
    fieldName = fields{k};
    value = GetObjectProperty(obj,fieldName,[]);
    if ~isempty(value) || IsObjectProperty(obj,fieldName)
        data.(fieldName) = value;
    end
end

function handles = ApplyObjectProperties(handles,objectName,data)
if ~isfield(handles,objectName)
    return;
end
fields = fieldnames(data);
for k = 1:numel(fields)
    SetObjectProperty(handles.(objectName),fields{k},data.(fields{k}));
end

function fields = SignalGeneratorConfigFields()
fields = {'Frequency','Frequency1','Frequency2','Amplitude','Amplitude1','Amplitude2',...
    'SweepStart','SweepStop','SweepPoints','SweepStart1','SweepStop1','SweepPoints1',...
    'SweepStart2','SweepStop2','SweepPoints2'};

function fields = TaborConfigFields()
fields = {'Channel','Frequency1','Phase1','Apply6dB1','Frequency2','Phase2','Apply6dB2',...
    'DACmode','NCOmode','Interpolation','SamplingRate','Amplitude',...
    'SweepStart1','SweepStop1','SweepPoints1','SweepStart2','SweepStop2','SweepPoints2',...
    'SweepZoneState1','SweepZoneState2','SweepChannel','RFState','QueryString'};


function abortRun(hObject,eventdata,handles)
% stop SG output
handles.TEProteusInst.Connect();
handles.TEProteusInst.setRFOff();
handles.TEProteusInst.Disconnect();
%stop Counter
handles.Counter.abort();
% stop PG
handles.PulseGenerator.init();
% % stop AWG ouptput
% handles.TekAWGController.open();
% handles.TekAWGController.stop();
% handles.TekAWGController.setSourceOutput(1,0);
% handles.TekAWGController.setSourceOutput(2,0);
% handles.TekAWGController.close();
SetStatus(handles,'Experiment Aborted.');
% guidata(hObject,handles);

% SetStatus(handles,'Experiment Aborted.');



function editSequenceSamples_Callback(hObject, eventdata, handles)
% hObject    handle to editSequenceSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSequenceSamples as text
%        str2double(get(hObject,'String')) returns contents of editSequenceSamples as a double


% --- Executes during object creation, after setting all properties.
function editSequenceSamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSequenceSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuDebug_Callback(hObject, eventdata, handles)
% hObject    handle to menuDebug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('debug');


% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuHWLines_Callback(hObject, eventdata, handles)
% hObject    handle to menuHWLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'HWLineFunction')
    feval(handles.HWLineFunction);
end


% --- Executes on button press in pbTestRun.
function pbTestRun_Callback(hObject, eventdata, handles)
% hObject    handle to pbTestRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = get(hObject,'String');
PG = handles.PulseGenerator;

handles.PulseSequence.SweepIndex = 1;

if strfind(s,'Test');
    set(hObject,'String','Stop Run');

    PG.init();

    Samples = str2double(get(handles.editSequenceSamples,'String'));

    [BinarySequence,tempSequence,AWGPSeq] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate, 'Instruction');

    % update the sequence plot
    PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,handles.PulseSequence);


    % get HW Channels
    HWChannels = [handles.PulseSequence.getHardwareChannels]';

    PG.sendSequence(BinarySequence,HWChannels,Samples,0);
    PG.start();
elseif strfind(s,'Stop')
    set(hObject,'String','Test Run');
    PG.stop();
end
%PG.close();



function editNotes_Callback(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNotes as text
%        str2double(get(hObject,'String')) returns contents of editNotes as a double


% --- Executes during object creation, after setting all properties.
function editNotes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on editNotes and none of its controls.
function editNotes_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbNoteErase.
function cbNoteErase_Callback(hObject, eventdata, handles)
% hObject    handle to cbNoteErase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbNoteErase



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to textClockRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textClockRate as text
%        str2double(get(hObject,'String')) returns contents of textClockRate as a double


% --- Executes during object creation, after setting all properties.
function textClockRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textClockRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [] = InitGUI(hObject,handles);

if isfield(handles,'PulseGenerator'),
    % display the clock rate in MHz
    % clock rate in Pulsegenerator always given in Hz.
    set(handles.textClockRate,'String',sprintf('%.3f MHz',handles.PulseGenerator.ClockRate/1e6));
end

RefreshOriginTemplatePopup(handles.popupmenuTempelate,handles);
try
    set(handles.popupmenuTempelate,'ButtonDownFcn',@(hObject,eventdata)RefreshOriginTemplatePopup(hObject,guidata(hObject)));
catch
end

% % load in the code snipets
% W = what('snippets');
% if ~isempty(W.m),
%     set(handles.popupCodeSnipet,'String',W.m);
% end

% check for spin noise enabled
if handles.options.spinNoiseAvg,
    set(handles.menuSpinNoise,'checked','on');
end


% --- Executes on selection change in popupTrackFreq.
function popupTrackFreq_Callback(hObject, eventdata, handles)
% hObject    handle to popupTrackFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupTrackFreq contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupTrackFreq


% --- Executes during object creation, after setting all properties.
function popupTrackFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupTrackFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = InitDefaults(handles)

% define spin noise options as false
handles.options.spinNoiseAvg = 0;
handles.options.snrMonitorEnabled = 0;
handles.SNRMonitor = [];
handles.specialData = [];
handles.specialVec = [];


% --------------------------------------------------------------------
function menuSpinNoise_Callback(hObject, eventdata, handles)
% hObject    handle to menuSpinNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.options.spinNoiseAvg == 0;
    handles.options.spinNoiseAvg = 1;
    set(handles.menuSpinNoise,'checked','on');
else
    handles.options.spinNoiseAvg = 0;
    set(handles.menuSpinNoise,'checked','off');
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function axesConfocal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesConfocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesConfocal



function editStartF_Callback(hObject, eventdata, handles)
% hObject    handle to editStartF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartF as text
%        str2double(get(hObject,'String')) returns contents of editStartF as a double


% --- Executes during object creation, after setting all properties.
function editStartF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStopF_Callback(hObject, eventdata, handles)
% hObject    handle to editStopF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStopF as text
%        str2double(get(hObject,'String')) returns contents of editStopF as a double


% --- Executes during object creation, after setting all properties.
function editStopF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStopF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPointsF_Callback(hObject, eventdata, handles)
% hObject    handle to editPointsF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPointsF as text
%        str2double(get(hObject,'String')) returns contents of editPointsF as a double


% --- Executes during object creation, after setting all properties.
function editPointsF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPointsF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuConfigAWG_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigAWG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axesRawData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesRawData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesRawData
function axesAvgData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesRawData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesAvgData

function axesProcessData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesRawData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesProcessData


% --- Executes on button press in buttonConfigureScript.
function buttonConfigureScript_Callback(hObject, eventdata, handles)
% hObject    handle to buttonConfigureScript (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('This button doesn''t do anything for now','oops');


% --- Executes on button press in buttonRunScript.
function buttonRunScript_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRunScript (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Tracker.MaxIterations = [30];
lorentz = 'a*(b/(4*(x-c)^2+b^2)) + d';
decCosine = 'a*cos(pi/c*x)+d';
PG = handles.PulseGenerator;


%     getSensitivity(PG,hObject, eventdata, handles)
fp = uigetdir('D:\Data\Kang');
% Define the angles theta and phi in degrees
% thetaDeg = 18;
% phiDeg = 54.7;
%
% %define the center
% P0 = [5.84,12.5,14.7];
%
% %define the sweep range
% xrange = 0.5;
% yrange = 0.5;
%
% % xrange = xrange*round(sind(thetaDeg),2);
% % yrange = yrange*round(cosd(thetaDeg),2);
%
%
% thetaDeg = 180-thetaDeg;
% phiDeg = 54.7;
%
% % Convert the angles to radians
% theta = thetaDeg * pi / 180;
% phi = phiDeg * pi / 180;
%
%
% % Define the point on the line
% pointOnLine = [0, 0, 0];
%
% % Define the direction vector of the line
% lineDirection = [sin(theta)*sin(phi), cos(theta)*sin(phi), -cos(phi)];
%
% % Define the grid of points for the surface
% [x, y] = meshgrid(-xrange:0.15:xrange, -yrange:0.15:yrange);
%
% % Calculate the z-coordinates for each point on the surface, dot(A,B) = 0
% % to define the plane
% z = -(lineDirection(1)*(x-pointOnLine(1)) + lineDirection(2)*(y-pointOnLine(2)))/lineDirection(3) + pointOnLine(3);
%
% % Plot the surface
%
% x = x+ P0(1);
% y = y+ P0(2);
% z = z+ P0(3);
%
% % surf(x, y, z);
% % xlabel('x');
% % ylabel('y');
% % zlabel('z');
%
% BX = handles.BControlX;
% BY = handles.BControlY;
% BZ = handles.BControlZ;
%
%     for i=1:size(x,2)
%
%         for k = 1:size(x,1)
%
%             if ~(rem(i,2))
%                 l = size(x,1)-k+1;
%             else
%                 l = k;
%             end
%
%             BXValue = x(l,i);
%             BYValue = y(l,i);
%             BZValue = z(l,i);
%
%             BX.SetAbsMovePos(0,BXValue);%Set up the Valueing positions
%             BY.SetAbsMovePos(0,BYValue);
%             BZ.SetAbsMovePos(0,BZValue);
%
%
%             BX.MoveAbsolute(0,BXValue);%Move to the Valueing position
%             BY.MoveAbsolute(0,BYValue);
%             BZ.MoveAbsolute(0,BZValue);
%             %Run and save experiemnt
%             PG.init();
%             TrackingViewer(handles.Tracker);
%             handles.Tracker.trackCenter(0);
%             close(findobj(0,'name','TrackingViewer'));
%             PG.stop();
%             PG.close();
%             RunExperiment(hObject,eventdata,handles);
%             Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
%             Exp.SpecialData = [BX.GetPosition_Position(0),BY.GetPosition_Position(0),BZ.GetPosition_Position(0)];
%             Exp.SpecialVec = [];
%             fn = ['ODMR-',num2str(ceil(Exp.SpecialData(1)*1000)),'-',num2str(ceil(Exp.SpecialData(2)*1000)),'-',num2str(ceil(Exp.SpecialData(3)*1000))];
%             save(fullfile(fp,fn),'Exp');
%             pause(2);
%
%         end
%
%     end
%%%%%%%%%
%%%%%%%%%%%%



for j = 1:size(handles.Tracker.TargetList,1)

    popnum = handles.Tracker.TargetList(j,4);
    fpCurr = strcat(fp,['\NV-', num2str(popnum)]);
    mkdir(fpCurr);
    set(handles.textNVnumber, 'String', ['NV: ', num2str(popnum)]);
    scriptTrack(j,PG,handles);
    %     %%%%%START OF ESR%%%%%
    %      ESRFit = findFreq(j,fpCurr,PG,hObject, eventdata, handles);
    %      contrast = 1 - (ESRFit.d + ESRFit.a)/ESRFit.d;
    %       if(contrast < .05 )
    %          %handles.Tracker.removeTarget(j);
    %           continue;
    %       end


    %%%%%END OF ESR%%%%%

    %%%%START OF RABI%%%%%
    RabiFit = findPi(j,fpCurr,PG,hObject, eventdata, handles);
    % %      if(RabiFit.a1*2 < .1 )
    % % %         %handles.Tracker.removeTarget(j);
    % %          continue;
    % %      end
    %                     p = pi/RabiFit.b1;
    %                 p_2 = 17.3e-9;
    %                 p = 40e-9;
    getT2(j,p,fp,PG,hObject, eventdata, handles)
    dynamicDecoupling(j,p,8,1,0,1,fp,PG,hObject,eventdata,handles);
    % dynamicDecoupling(j,p,8,2,0,1,fp,PG,hObject,eventdata,handles);
    %  dynamicDecoupling(j,p,8,3,0,0,fp,PG,hObject,eventdata,handles);
    % dynamicDecoupling(j,p,8,4,0,1,fp,PG,hObject,eventdata,handles);
    %  dynamicDecoupling(j,p,8,5,19e-9,0,fp,PG,hObject,eventdata,handles);

    %      dynamicDecoupling(j,p,8,6,0,0,fp,PG,hObject,eventdata,handles);
    %         dynamicDecoupling(j,p,8,30,0,0,fp,PG,hObject,eventdata,handles);
    %          dynamicDecoupling(j,p,8,6,161.5e-9,0,fp,PG,hObject,eventdata,handles);
    %           dynamicDecoupling(j,p,8,17,0,0,fp,PG,hObject,eventdata,handles);
    %           dynamicDecoupling(j,p,8,22,0,0,fp,PG,hObject,eventdata,handles);

    %          dynamicDecoupling(j,p,8,1,161.5e-9,0,fp,PG,hObject,eventdata,handles);
    %          dynamicDecoupling(j,p,8,2,161.5e-9,0,fp,PG,hObject,eventdata,handles);
    %          dynamicDecoupling(j,p,8,3,161.5e-9,0,fp,PG,hObject,eventdata,handles);
    %          dynamicDecoupling(j,p,8,4,161.5e-9,0,fp,PG,hObject,eventdata,handles);
    %          dynamicDecoupling(j,p,8,5,161.5e-9,0,fp,PG,hObject,eventdata,handles);
    %          dynamicDecoupling(j,p,8,6,161.5e-9,0,fp,PG,hObject,eventdata,handles);

    %       dynamicDecoupling(j,p,8,3,161e-9,0,fp,PG,hObject,eventdata,handles);
    %       dynamicDecoupling(j,p,8,4,161e-9,0,fp,PG,hObject,eventdata,handles);
    %       dynamicDecoupling(j,p,8,8,130e-9,0,fp,PG,hObject,eventdata,handles);

    %         dynamicDecoupling(j,p,8,20,0,0,fp,PG,hObject,eventdata,handles);
    %        dynamicDecoupling(j,p,8,5,180e-9,0,fp,PG,hObject,eventdata,handles);
    %      dynamicDecoupling(j,p,8,30,0,1,fp,PG,hObject,eventdata,handles);
    %      dynamicDecoupling(j,p,8,40,0,1,fp,PG,hObject,eventdata,handles);

    %getCorrelation(j,p,fp,PG,hObject, eventdata, handles);
    %getT1(j,p,fp,PG,hObject, eventdata, handles);
    %end
    %getRamsey(j,fp,p,PG,hObject,eventdata,handles);
    %getT2(j,p,fp,PG,hObject, eventdata, handles);
    %getCorrelation(j,p,fp,PG,hObject,eventdata,handles);
    %dynamicDecoupling(j,p,16,,0,fp,PG,hObject,eventdata,handles);


    %     count = 0; % initialize the count to zero
    %     while true % loop indefinitely
    %         t = clock; % get the current time as a 6-element vector [year, month, day, hour, minute, second]
    %         if mod(t(5), 10) == 0 % check if the minute is a multiple of 10 and the second is zero
    %             findPulseODMRFreq(j,fp,PG,hObject, eventdata, handles); % do CWODMR
    %             disp(count); % display the count
    %         end
    %         pause(1); % wait for 1 second
    %     end
    %     %%%%%END OF XY8%%%%%
    %
    %     fpCurr = strcat(fpCurr,'\DD')
    %     mkdir(fpCurr);
    %     for scAvg = 1:20
    %         scriptTrack(j,PG,handles);
    %         mkdir(strcat(fpCurr,['\AVG- ', num2str(scAvg)]));
    %         ESRFit = findFreq(j,fpCurr,PG,hObject, eventdata, handles);
    %         RabiFit = findPi(j,fpCurr,PG,hObject, eventdata, handles);
    %         p = pi/RabiFit.b1;
    %         B = 397;
    %         Tdip = 1/(4.2576*B*1000)/2;
    %         TdipAdjusted = (Tdip - p)/2;
    %         dynamicDecoupling(j,p,20,10,TdipAdjusted,strcat(fpCurr,['\AVG- ', num2str(scAvg)]),PG,hObject,eventdata,handles);
    %         scriptTrack(j,PG,handles);
    %     end
    %REMEMBER TO CHANGE PHASE IN DD FUNCTION

end


%helper function that does tracking for the script.
function [] = scriptTrack(targetNumber,PG,handles)
PG.init();
TrackingViewer(handles.Tracker);
handles.Tracker.trackTarget(targetNumber);
close(findobj(0,'name','TrackingViewer'));
PG.stop();
PG.close();


function [RabiFit] = findPi(j,fp, PG,hObject, eventdata, handles)
%decCosine = 'a*cos(pi/c*x)+d';
%sin1 = 'a*sin(b*x+c)
set(handles.popupTrackFreq,'Value',1);
set(handles.textSequenceName, 'String', 'Sequence: Rabi');
set(handles.popupMode, 'Value', 2);
set(handles.editSequenceSamples,'String','100000');
set(handles.editAverages,'String','5');
set(handles.cbTrackEnable,'Value',1);
set(handles.editTrackThreshold,'String', '1');
set(handles.buttonRabiMode,'Value',1);

Q = load('D:\Matlab software and codes\Control software with AWG control(Work in progress)\Sequences\Jake''s Sequences\Pulsed\Rabi\rabi-1.0Amp.mat');%Load Rabi Pulse Sequence
handles.PulseSequence = Q.PSeq;
handles.SignalGenerator.Amplitude = 10;
handles.SignalGenerator.setAmplitude();%Set Power for Rabi
scriptTrack(j,PG,handles);
RunExperiment(hObject,eventdata,handles);
t = linspace(handles.PulseSequence.Sweeps.StartValue,handles.PulseSequence.Sweeps.StopValue,handles.PulseSequence.Sweeps.SweepPoints)';
data = handles.Counter.AveragedData(:,1)./handles.Counter.AveragedData(:,2);
dt = t(2)-t(1);
data = data - mean(data);
initialFit = [0,0,pi/2];
fA = abs(fft(data));
fA = fA(1:25);
f= linspace(0,1/(2*dt),ceil(51/2));
[n,m] = max(fA);
initialFit(2) =(f(m)*2*pi);
initialFit(1)= (max(data) - min(data))/2;
RabiFit = fit(t,data,'sin1', 'Start', initialFit);
fn = ['NV-', num2str(handles.Tracker.TargetList(j,4)), '-Rabi'];
fnextend = ['-t',num2str(handles.PulseSequence.Sweeps.StartValue*1e9),'nsto' ...
    ,num2str(handles.PulseSequence.Sweeps.StopValue*1e9),'ns-pts' ...
    ,num2str(handles.PulseSequence.Sweeps.SweepPoints),'-f', ...
    num2str((handles.SignalGenerator.Frequency+100e6)/1e6),'MHz-pi', ...
    num2str(pi/RabiFit.b1*1e9),'ns-contst',num2str(2*RabiFit.a1),'.mat'];
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = RabiFit;
Exp.SpecialVec = handles.specialVec;
save(fullfile(fp,[fn,fnextend]),'Exp');
set(handles.textPiPulse, 'String', ['Pi pulse: ' num2str(pi/RabiFit.b1)]);
plotfigure('Rabi',t,data,RabiFit,fn,fp,1,1,handles);
handles.Tracker.adjustTargets(j);
scriptTrack(j,PG,handles);
function [ESRFit] = findPulseODMRFreq(j,fp,PG,hObject, eventdata, handles)
lorentz = '2*a/pi*(b/(4*(x-c)^2+b^2)) + d';
set(handles.textSequenceName, 'String', 'Sequence: CWODMR');
set(handles.popupMode, 'Value', 3);
set(handles.cbTrackEnable,'Value',0);
set(handles.popupTrackFreq,'Value',1);
set(handles.editSequenceSamples,'String','50000');
set(handles.editAverages,'String','10');
set(handles.editTrackThreshold,'String', '5');
Q = load('D:\Matlab software and codes\Control software with AWG control(Work in progress)\Sequences\Jake''s Sequences\Pulsed\Rabi\PESR AWG amp control.mat');%Load Rabi Pulse Sequence
handles.PulseSequence = Q.PSeq;
handles.SignalGenerator.Amplitude = -25;
handles.SignalGenerator.setAmplitude();%Set Power for Rabi
scriptTrack(j,PG,handles);
RunExperiment(hObject,eventdata,handles);
data = handles.Counter.AveragedData(:,1)./handles.Counter.AveragedData(:,2);
startF = str2num(get(handles.editStartF,'String'));
stopF = str2num(get(handles.editStopF,'String'));
pointsF = str2num(get(handles.editPointsF,'String'));
t = linspace(startF,stopF,pointsF)';
dt = t(2)-t(1);
initialFit = [0,10e6,0,0];
initialFit(4) = mean(data);
initialFit(1) = (min(data) - max(data))*initialFit(2)*pi/2;
[n,m] = min(data);
initialFit(3) = t(m);
ESRFit = fit(t,data,lorentz, 'Start', initialFit);
%     set(handles.textFrequency, 'String', ['Frequency:', num2str(ESRFit.c)]);
freq = ESRFit.c;
handles.SignalGenerator.Frequency = freq - 100e6;
handles.SignalGenerator.setFrequency();
fn = ['NV-', num2str(handles.Tracker.TargetList(j,4)), '-ESR-',datestr(now,'yyyymmdd_HH-MM-SS'),'.mat'];
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = ESRFit;
Exp.SpecialVec = handles.specialVec;
save(fullfile(fp,fn),'Exp');
handles.Tracker.adjustTargets(j);
scriptTrack(j,PG,handles);

function [ESRFit] = findFreq(j,fp,PG,hObject, eventdata, handles)
%  lorentz = '2*a/pi*(b/(4*(x-c)^2+b^2)) + d';
set(handles.textSequenceName, 'String', 'Sequence: ESR');
set(handles.popupMode, 'Value', 3);
set(handles.cbTrackEnable,'Value',1);
set(handles.popupTrackFreq,'Value',1);
set(handles.editSequenceSamples,'String','50000');
set(handles.editAverages,'String','5');
set(handles.editTrackThreshold,'String', '1');
Q = load('D:\Matlab software and codes\Control software with AWG control(Work in progress)\Sequences\Jake''s Sequences\Pulsed\Rabi\PESR AWG amp control.mat');%Load Rabi Pulse Sequence
handles.PulseSequence = Q.PSeq;
handles.SignalGenerator.Amplitude = -25;
handles.SignalGenerator.setAmplitude();%Set Power for Rabi
scriptTrack(j,PG,handles);
RunExperiment(hObject,eventdata,handles);
data = (handles.Counter.AveragedData(:,1)-handles.Counter.AveragedData(:,2))./handles.Counter.AveragedData(:,2);
startF = str2num(get(handles.editStartF,'String'));
stopF = str2num(get(handles.editStopF,'String'));
pointsF = str2num(get(handles.editPointsF,'String'));
t = linspace(startF,stopF,pointsF)';
%t = t(2:101);
dt = t(2)-t(1);
%     initialFit = [0,10e6,0,0];
%     initialFit(4) = mean(data);
%     initialFit(1) = (min(data) - max(data))*initialFit(2)*pi/2;
%     [n,m] = min(data);
%     initialFit(3) = t(m);
[psor,lsor] = findpeaks(-data,t,'SortStr','descend');
if abs(lsor(1)-lsor(2))<2e6;
    lsor(2)=lsor(3);
end
peakloc1 = lsor(1);
peakloc2 = lsor(2);
ft = fittype( '2*a/pi*(b/(4*(x-c)^2+b^2)) + d+2*a1/pi*(b1/(4*(x-c1)^2+b1^2))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
initialFit = [0,0,1e6,1e6,0,0,0];
initialFit(7) = mean(data);
initialFit(1) = (min(data) - max(data))*initialFit(3)*pi/2;
initialFit(2) = (min(data) - max(data))*initialFit(4)*pi/2;
initialFit(5) = peakloc1;
initialFit(6) = peakloc2;
opts.Lower = [-1000000 -1000000 500000 500000 initialFit(5)-0.5e6 initialFit(6)-0.5e6 initialFit(7)-0.3];
opts.StartPoint = initialFit;
opts.Upper = [-100000 -100000 2000000 2000000 initialFit(5)+0.5e6 initialFit(6)+0.5e6 initialFit(7)+0.3];
ESRFit = fit(t,data,ft,opts);
%  ESRFit = fit(t,data,lorentz,'Start', initialFit);
ESRFitfre = (ESRFit.c+ESRFit.c1)/2;
contrast = 1 - (ESRFit.d + ESRFit.a)/ESRFit.d;
contrast1 = 1 - (ESRFit.d + ESRFit.a1)/ESRFit.d;
set(handles.textFrequency, 'String', ['Frequency:', num2str(ESRFitfre)]);
freq = ESRFitfre;
handles.SignalGenerator.Frequency = freq - 100e6;
handles.SignalGenerator.setFrequency();
fn = ['NV-', num2str(handles.Tracker.TargetList(j,4)),'-ESR'];
fnextend = ['-f',num2str(startF./1e6),'MHzto',num2str(stopF./1e6), ...
    'MHz-pts',num2str(pointsF),'-pow',num2str( handles.SignalGenerator.Amplitude),'db-pi',num2str(handles.PulseSequence.Sweeps.StartValue*1e9),'ns-cont',num2str(contrast/1e6),'.mat'];
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = ESRFit;
Exp.SpecialVec = handles.specialVec;
save(fullfile(fp,[fn,fnextend]),'Exp');
plotfigure('ESR',t,data,ESRFit,fn,fp,1,1,handles);
handles.Tracker.adjustTargets(j);
scriptTrack(j,PG,handles);

function [] = getT2(j,p,fp,PG,hObject, eventdata, handles)
a = 90;
b = 180;
%     B = (2870 - handles.SignalGenerator.Frequency/1e6)/2.8;
%     Tlarmor = 1/(1.0705*B*1000);
%     Tdip = Tlarmor/2;
%     TdipAdjusted = Tdip - p;
Q = generatePulseSequence_kang(p/2,p,1,[0,b], [a],0,1);

set(handles.textSequenceName, 'String', ['Sequence: T2']);
handles.PulseSequence = Q;
handles.PulseSequence.Sweeps.StartValue = 5e-9;
handles.PulseSequence.Sweeps.StopValue = 5e-6;
handles.PulseSequence.Sweeps.SweepPoints = 101;
set(handles.popupTrackFreq,'Value',1);
set(handles.editSequenceSamples,'String','10000');
set(handles.editAverages,'String','10');
set(handles.editTrackThreshold,'String', '1');
set(handles.buttonT2Mode,'Value',1);
%     scriptTrack(j,PG,handles);
RunExperiment(hObject,eventdata,handles);
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = handles.specialData;
Exp.SpecialVec = handles.specialVec;
fn = ['NV-' num2str(handles.Tracker.TargetList(j,4)),'-T2'];
fnextend = ['-t',num2str(handles.PulseSequence.Sweeps.StartValue*1e6),'usto',num2str(handles.PulseSequence.Sweeps.StopValue*1e6), ...
    'us-pts',num2str(handles.PulseSequence.Sweeps.SweepPoints),'-f',num2str((handles.SignalGenerator.Frequency+100e6)/1e6), ...
    'MHz-pi',num2str(p*1e9),'ns.mat'];
fn = [fn,fnextend];
save(fullfile(fp,fn),'Exp');
handles.Tracker.adjustTargets(j);
%     scriptTrack(j,PG,handles);

function []= dynamicDecoupling(j,p,XY,Np,corr,timeflag,fp,PG,hObject, eventdata, handles)
a = 90.0;
b = 180;
c = 270;
if XY == 16
    Q = generatePulseSequence_kang(p/2,p,XY*Np,[a,c], [0,a,0,a,a,0,a,0,b,c,b,c,c,b,c,b],corr,1);
    fn = ['NV-' num2str(handles.Tracker.TargetList(j,4)),'-XY-16x',num2str(Np)];
    set(handles.textSequenceName, 'String', ['Sequence: XY-16x', num2str(Np)]);
elseif XY == 8
    if ~corr
        Q = generatePulseSequence_kang(p/2,p,XY*Np,[0,0], [0,a,0,a,a,0,a,0],corr,1);
        fn = ['NV-' num2str(handles.Tracker.TargetList(j,4)),'-XY-8x',num2str(Np)];
        set(handles.textSequenceName, 'String', ['Sequence: XY-8x', num2str(Np)]);
    elseif corr %for  corr measurement
        Q = generatePulseSequence_kang(p/2,p,XY*Np,[0,90], [0,a,0,a,a,0,a,0],corr,1);
        fn = ['NV-' num2str(handles.Tracker.TargetList(j,4)),'-XYcorr-8x',num2str(Np)];
        set(handles.textSequenceName, 'String', ['Sequence: XYcorr-8x', num2str(Np)]);
    end
elseif XY == 20
    Q = generatePulseSequence_kang(p/2,p,XY*Np,[a,c], [30,0,90,0,30,120,90,180,90,120,30,0,90,0,30,120,90,180,90,120],corr,1);
    fn = ['NV-' num2str(handles.Tracker.TargetList(j,4)),'-KDD-',num2str(Np)];
    set(handles.textSequenceName, 'String', ['Sequence: KDD*', num2str(Np)]);
end
handles.PulseSequence = Q;

B = (2870 - (handles.SignalGenerator.Frequency+100e6)/1e6)/2.8;
Tdip = 1./(4.008*B*1000);
%      Tdip = 1000e-9;
TdipAdjusted = (Tdip/2 - p)/2;
start = TdipAdjusted - 35e-9;
stop = TdipAdjusted + 25e-9;
points = 31;

if corr %for corr sweeping
    handles.PulseSequence.Sweeps.StartValue = 5e-9;
    handles.PulseSequence.Sweeps.StopValue = 5e-6;
    handles.PulseSequence.Sweeps.SweepPoints = 51;
    set(handles.editAverages,'String','100');
elseif timeflag % for T2 sweeping
    handles.PulseSequence.Sweeps.StartValue = 5e-9;
    handles.PulseSequence.Sweeps.StopValue = 50e-9;
    handles.PulseSequence.Sweeps.SweepPoints = 51;
    set(handles.editAverages,'String','50');
elseif ~corr && ~timeflag  %for proton detectio
    handles.PulseSequence.Sweeps.StartValue = start;
    handles.PulseSequence.Sweeps.StopValue = stop;
    handles.PulseSequence.Sweeps.SweepPoints = points;
    set(handles.editAverages,'String','3000');

end

set(handles.popupTrackFreq,'Value',1);
set(handles.editSequenceSamples,'String','10000');
%   set(handles.editAverages,'String','1');
set(handles.editTrackThreshold,'String', '3');
set(handles.buttonT2Mode,'Value',1);
%     scriptTrack(j,PG,handles);
RunExperiment(hObject,eventdata,handles);
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = handles.specialData;
Exp.SpecialVec = handles.specialVec;
fnextend = ['-t',num2str(handles.PulseSequence.Sweeps.StartValue*1e9),'nsto',num2str(handles.PulseSequence.Sweeps.StopValue*1e9), ...
    'ns-pts',num2str(handles.PulseSequence.Sweeps.SweepPoints),'-f',num2str((handles.SignalGenerator.Frequency+100e6)/1e6), ...
    'MHz-pi',num2str(p*1e9),'ns.mat'];
fn = [fn,fnextend];
save(fullfile(fp,fn),'Exp');
handles.Tracker.adjustTargets(j);
scriptTrack(j,PG,handles);



function [] = getCorrelation(j,p,fp,PG,hObject, eventdata, handles)
a = 90.0;
b = 180.0;
B = (2870 - handles.SignalGenerator.Frequency/1e6+25)/2.8;
Tlarmor = 1/(1.0705*B*1000);
Tdip = Tlarmor/2;
TdipAdjusted = Tdip - p;
Q = generatePulseSequence(p/2,p,1,[a,0], [a],TdipAdjusted,1);
fn = ['NV-' num2str(handles.Tracker.TargetList(j,4)),'-Corr','.mat'];
set(handles.textSequenceName, 'String', ['Sequence: Correlation']);
handles.PulseSequence = Q;
handles.PulseSequence.Sweeps.StartValue = 50e-9;
handles.PulseSequence.Sweeps.StopValue = 100e-6;
handles.PulseSequence.Sweeps.SweepPoints = 201;
set(handles.popupTrackFreq,'Value',2);
set(handles.editSequenceSamples,'String','50000');
set(handles.editAverages,'String','1');
set(handles.editTrackThreshold,'String', '.925');
scriptTrack(j,PG,handles);
RunExperiment(hObject,eventdata,handles);
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = handles.specialData;
Exp.SpecialVec = handles.specialVec;
save(fullfile(fp,fn),'Exp');
handles.Tracker.adjustTargets(j);
scriptTrack(j,PG,handles);

function [] = getT1(j,p,fp,PG,hObject, eventdata, handles)
fn = ['NV-' num2str(handles.Tracker.TargetList(j,4)),'-T1','.mat'];
set(handles.textSequenceName, 'String', ['Sequence: T1']);
Q = load('D:\Matlab software and codes\Control software with AWG control(Work in progress)\Sequences\Jake''s Sequences\T1.mat');%Load Rabi Pulse Sequence
handles.PulseSequence = Q.PSeq;
handles.PulseSequence.Sweeps.StartValue = 50e-9;
handles.PulseSequence.Sweeps.StopValue = 300e-6;
handles.PulseSequence.Sweeps.SweepPoints = 11;
handles.PulseSequence.Channels(1,3).RiseDurations = p;
set(handles.popupTrackFreq,'Value',2);
set(handles.editSequenceSamples,'String','100000');
set(handles.editAverages,'String','2');
set(handles.editTrackThreshold,'String', '.95');
scriptTrack(j,PG,handles);
RunExperiment(hObject,eventdata,handles);
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = handles.specialData;
Exp.SpecialVec = handles.specialVec;
save(fullfile(fp,fn),'Exp');
handles.Tracker.adjustTargets(j);
scriptTrack(j,PG,handles);

function [] = getRamsey(j,fp,p, PG,hObject, eventdata, handles)
handles.SignalGenerator.Frequency = handles.SignalGenerator.Frequency - 6e6;
handles.SignalGenerator.setFrequency();
set(handles.popupTrackFreq,'Value',2);
set(handles.textSequenceName, 'String', 'Sequence: Ramsey');
set(handles.popupMode, 'Value', 2);
set(handles.editSequenceSamples,'String','100000');
set(handles.editAverages,'String','5');
set(handles.cbTrackEnable,'Value',1);
set(handles.editTrackThreshold,'String', '.95');
Q = load('D:\Matlab software and codes\Control software with AWG control(Work in progress)\Sequences\Jake''s Sequences\Pulsed\Ramsey.mat');%Load Rabi Pulse Sequence
handles.PulseSequence = Q.PSeq;
handles.PulseSequence.Channels(1,3).RiseTimes(1,2) = handles.PulseSequence.Channels(1,3).RiseTimes(1,1) + p/2;
handles.PulseSequence.Channels(1,3).RiseTimes(1,4) = handles.PulseSequence.Channels(1,3).RiseTimes(1,3) + p/2
handles.PulseSequence.Channels(1,3).RiseDurations = [p/2,p/2,p/2,p/2];
scriptTrack(j,PG,handles);
RunExperiment(hObject,eventdata,handles);
fn = ['NV-', num2str(handles.Tracker.TargetList(j,4)), '-Ramsey.mat'];
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = handles.specialData;
Exp.SpecialVec = handles.specialVec;
save(fullfile(fp,fn),'Exp');
handles.SignalGenerator.Frequency = handles.SignalGenerator.Frequency + 6e6;
handles.SignalGenerator.setFrequency();

function [] = getSensitivity(PG,hObject, eventdata, handles)
obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0699::0x0343::C011192::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('NI', 'USB0::0x0699::0x0343::C011192::0::INSTR');
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);
freq = 1.8010e6;
rot = 1.119e-10*freq/(20*8);
rot = rot/2;
rot = rot/3.1836e-006/.304;
fprintf(obj1, sprintf('SOURCE1:FREQUENCY %d',freq));
fprintf(obj1, sprintf('SOURCE1:BURST:NCYCLES %d',20*8/2));
NPts = 41;
voltage = linspace(20e-3,2000e-3,NPts)';
%voltage = [fliplr(voltage)*-1,voltage];
B =  1*voltage*1;
refPoint = [0,0,10.0631];
%samps = floor(logspace(3,6,21));
%for iter = 1:51
%   set(handles.editSequenceSamples,'String',num2str(samps(iter)));
senseData = nan(NPts,2);
for voltIndex = 1:NPts
    if mod(voltIndex-1,21) == 0
        PG.init();
        TrackingViewer(handles.Tracker);
        handles.Tracker.trackCenter(refPoint);
        close(findobj(0,'name','TrackingViewer'));
        PG.stop();
        PG.close();
    end

    fprintf(obj1, sprintf('SOURCE1:VOLTAGE:LEVEL:AMPLITUDE %d',abs(voltage(voltIndex))));
    RunExperiment(hObject,eventdata,handles);
    senseData(voltIndex,:) = handles.Counter.AveragedData;
    senseDataRef = (senseData(:,1) - senseData(:,2));
    plot(B,senseDataRef,'.-','Parent',handles.axesAvgData);
    drawnow();
end
shotNoise = mean(sqrt(senseData(:,1) + senseData(:,2)));
p = polyfit(B,senseDataRef,1);
senseFit = polyval(p,B);
plot(B,[senseDataRef,senseFit],'.-','Parent',handles.axesAvgData);
drawnow();
disp(shotNoise/p(1)*sqrt(handles.PulseSequence.GetMaxRiseTime()/2))
fn = ['Exp_',datestr(now,'yyyymmdd_HH-MM-SS')];
save(fn,'senseData');

function [] = performDEER(PG,hObject, eventdata, handles)
%check if comm channel is open, close it
openDevices = instrfind('Port','COM8');

if ~isempty(openDevices)
    fclose(openDevices);
    delete(openDevices);
end
%open new comm channel
RS2 = serial('COM8');
fopen(RS2);
avgNum = 100;
numFreqs = 61;
freqDEER = linspace( 1.18e+009-60e6,1.18e+009+60e6,numFreqs);
refPoint = [0,0,10.0631];
dataDEER = zeros(numFreqs,2);
dataDEERAvg = zeros(numFreqs,2);
for currAvg = 1:avgNum
    for currFreq = 1:numFreqs
        if mod(currFreq-1,51) == 0
            PG.init();

            TrackingViewer(handles.Tracker);
            handles.Tracker.trackCenter(refPoint);
            close(findobj(0,'name','TrackingViewer'));
            PG.stop();
            PG.close();
        end
        fprintf(RS2, ':OUTP:STAT ON');
        fprintf(RS2, sprintf(':SOUR:FREQ %d',freqDEER(currFreq)));
        set(handles.textSequenceName, 'String', sprintf('DEER Average %d',currAvg));
        RunExperiment(hObject,eventdata,handles);
        dataDEER(currFreq,:) = handles.Counter.AveragedData;
        dataDEERAvg(currFreq,:) = (dataDEERAvg(currFreq,:).*(currAvg-1) + dataDEER(currFreq,:))./currAvg;
        dataDEERRef = (dataDEERAvg(:,1) - dataDEERAvg(:,2));
        dataDEERRefPlot = dataDEERRef;
        dataDEERRefPlot(dataDEERRefPlot==0) = NaN;
        plot(freqDEER,dataDEERRefPlot,'.-','Parent',handles.axesAvgData);
        drawnow();
    end
end
fprintf(RS2, ':OUTP:STAT OFF');
fn = ['Exp_',datestr(now,'yyyymmdd_HH-MM-SS')];
save(fn,'dataDEERAvg');

fclose(RS2);
delete(RS2);

function [] = performMWSweep(PG,hObject, eventdata, handles)
%check if comm channel is open, close it
openDevices = instrfind('Port','COM8');

if ~isempty(openDevices)
    fclose(openDevices);
    delete(openDevices);
end
%open new comm channel
RS2 = serial('COM8');
fopen(RS2);
refPoint = [0,0,10.0631];
numFreqs = 11;
freqDEER = linspace( 9.2599e+008-25e6,9.2599e+008+25e6,numFreqs);
for currFreq = 1:numFreqs
    %if mod(currFreq-1,1) == 0
    PG.init();

    TrackingViewer(handles.Tracker);
    handles.Tracker.trackCenter(refPoint);
    close(findobj(0,'name','TrackingViewer'));
    PG.stop();
    PG.close();

    %end
    fprintf(RS2, ':OUTP:STAT ON');
    fprintf(RS2, sprintf(':SOUR:FREQ %d',freqDEER(currFreq)));
    RunExperiment(hObject,eventdata,handles);
end
fprintf(RS2, ':OUTP:STAT OFF');

fclose(RS2);
delete(RS2);

% --- Executes on button press in buttonInitLoad.
function buttonInitLoad_Callback(hObject, eventdata, handles)
% hObject    handle to buttonInitLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[PSeq,fn,fp] = PulseSequencerFunctions('LoadExternal');
if fn,
    %feval(class(handles.PulseSequence),PSeq); % if handles.PulseSequnce is a different class than PSeq, due to saving between version, cast to correct class
    handles.InitPulseSequence.copy(PSeq);
    InitEvents(hObject,handles);
    guidata(hObject,handles);
end


% --- Executes on button press in buttonInitEdit.
function buttonInitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonInitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencer(handles.InitPulseSequence);
InitEvents(hObject,handles);


% --- Executes during object creation, after setting all properties.
function axesPulseSequence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesPulseSequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesPulseSequence




% --- Executes during object creation, after setting all properties.
function pnlProcessMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pnlProcessMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function [RabiFit] = findSoftPi(j,fp, PG,hObject, eventdata, handles)
decCosine = 'a*cos(pi/c*x)+d';
set(handles.popupTrackFreq,'Value',1);
set(handles.textSequenceName, 'String', 'Sequence: Soft Rabi');
set(handles.popupMode, 'Value', 2);
set(handles.editSequenceSamples,'String','250000');
set(handles.editAverages,'String','4');
set(handles.cbTrackEnable,'Value',1);
set(handles.editTrackThreshold,'String', '2');
Q = load('D:\Matlab software and codes\Control software with AWG control(Work in progress)\Sequences\Jake''s Sequences\Pulsed\Rabi\Standard Rabi_Soft.mat');%Load Rabi Pulse Sequence
handles.PulseSequence = Q.PSeq;
handles.SignalGenerator.Amplitude = 0;
handles.SignalGenerator.setAmplitude();%Set Power for Rabi
scriptTrack(j,PG,handles);
softPi = 0;
rabiIterations = 0;
while ~softPi
    RunExperiment(hObject,eventdata,handles);
    data = handles.Counter.AveragedData(:,1)./handles.Counter.AveragedData(:,2);
    t = linspace(0,500e-9,1)';
    dt = t(2)-t(1);
    initialFit = [0,0,0];
    initialFit(3) = mean(data);
    A = data - initialFit(3);
    fA = fft(A);
    fA = fA(1:15);
    f= linspace(0,1/(2*dt),ceil(31/2));
    [n,m] = max(fA);
    initialFit(2) = 1/(f(m)*2);
    initialFit(1)= max(data) - initialFit(3);
    RabiFit = fit(t,data,decCosine, 'Start', initialFit);
    rabiIterations = rabiIterations + 1;
    if RabiFit.b1 < 400e-9
        handles.SignalGenerator.Amplitude = handles.SignalGenerator.Amplitude - 2;
        handles.SignalGenerator.setAmplitude();
    elseif rabifit.b1 > 600e-9
        handles.SignalGenerator.Amplitude = handles.SignalGenerator.Amplitude + 2;
        handles.SignalGenerator.setAmplitude();
    elseif rabiIteration >= 3
        break;
    else
        softPi = 1;
    end
end
fn = ['NV-', num2str(handles.Tracker.TargetList(j,4)), '-Rabi.mat'];
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.SpecialData = RabiFit;
Exp.SpecialVec = handles.specialVec;
save(fullfile(fp,fn),'Exp');
set(handles.textPiPulse, 'String', ['Pi pulse: ' num2str(RabiFit.b1)]);
handles.Tracker.adjustTargets(j);
scriptTrack(j,PG,handles);



% --- Executes when selected object is changed in pnlProcessMode.
function pnlProcessMode_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pnlProcessMode
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function buttonT2Mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonT2Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function buttonRabiMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonT2Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function buttonRabiMode_Callback(hObject, eventdata, handles)
% hObject    handle to buttonT2Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
% --- Excutes plot figure for script
function []= plotfigure(mode,x,yprocess,fitresult,fn,fp,rawFlag,processedFlag,handles)
switch mode
    case 'ESR'
        initialfn = fn;
        if rawFlag ==1
            fig = figure('Visible','off');
            plot(x,handles.Counter.AveragedData);
            xlabel('f (Hz)');
            ylabel('Signal');
            title(fn);
            fn = [initialfn,'-raw'];
            saveas(fig,fullfile(fp,fn),'jpg')
            close(fig)
        end
        if processedFlag == 1
            fig = figure('Visible','off');
            plot (fitresult,x,yprocess,'b-');
            fn = [initialfn,'-fitted'];
            xlabel('f (Hz)');
            ylabel('Signal');
            title(fn);
            ESRcontrast =fitresult.d - min ( fitresult(fitresult.c), fitresult(fitresult.c1));
            ESRfre = (fitresult.c+fitresult.c1)/2;
            ESRstring = {strcat('f1 = ',num2str(fitresult.c./1e6,'%.1f'),' MHz' ),...
                strcat('f2 = ',num2str(fitresult.c1./1e6,'%.1f'),' MHz' ),...
                strcat('fc = ',num2str(ESRfre./1e6,'%.1f'),' MHz' ),...
                strcat('contrast = ',num2str(ESRcontrast*100,'%2.2f%%')),...
            };
            dim = [0.4,0.7,0.2,0.2];
            annotation('textbox',dim,'String',ESRstring,'FitBoxToText','on');
            saveas(fig,fullfile(fp,fn),'jpg')
            close(fig)
        end

    case 'Rabi'
        initialfn = fn;
        if rawFlag ==1
            fig = figure('Visible','off');
            plot(x,handles.Counter.AveragedData);
            xlabel('t (Hz)');
            ylabel('Signal');
            title(fn);
            fn = [initialfn,'-raw'];
            saveas(fig,fullfile(fp,fn),'jpg')
            close(fig)
        end
        if processedFlag == 1
            fig = figure('Visible','off');
            plot (fitresult,x,yprocess,'b-.');
            fn = [initialfn,'-fitted'];
            xlabel('t (s)');
            ylabel('Signal');
            title(fn);
            Rabicontrast = 2*fitresult.a1;
            Rabipi = pi/fitresult.b1;
            Rabistring = {strcat('pi = ',num2str(Rabipi*1e9,'%.1f'),'ns'),...
                strcat('Contrast = ',num2str(Rabicontrast*100,'%2.2f%%')),...
            };
            dim = [0.2,0.7,0.2,0.2];
            annotation('textbox',dim,'String',Rabistring,'FitBoxToText','on');
            saveas(fig,fullfile(fp,fn),'jpg')
            close(fig)
        end

    case 'T2'
    case 'XY'
end


% --- Executes on button press in powerSweepEnable.
function powerSweepEnable_Callback(hObject, eventdata, handles)
% hObject    handle to powerSweepEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of powerSweepEnable


% --------------------------------------------------------------------
function menuConfigAMP_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigAMP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigAmplifier


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over autosaveButton.
function autosaveButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to autosaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on pushbutton20 and none of its controls.
function pushbutton20_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on menusaveButton and none of its controls.
function menusaveButton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to menusaveButton (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in matsaveButton.
function matsaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to matsaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuSave_Callback(hObject, eventdata, handles)

% --- Executes on button press in autosaveButton.
function autosaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to autosaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = UpdateAutoFilename(handles);
guidata(hObject,handles);
try
    prename = get(handles.prenameEdit,'string');
catch
    prename = [];
end
filename = get(handles.filenameEdit,'string');
filepath = get(handles.filepathEdit,'string');
if  isempty(filename)||isempty(filepath)
    fn = BuildSaveFilename(handles,['Exp_', datestr(now, 'yyyymmdd_HH-MM-SS')]);
    [fn, fp] = uiputfile('*.mat',fullfile(filepath, fn));
    if isequal(fn,0)
        return;
    end
    fn = BuildSaveFilenameFromName(handles,fn);
    fn = fullfile(fp, fn);
else
    fn = BuildSaveFilename(handles,filename,prename);
    fn = fullfile(filepath,fn);
end
fn = BuildUniqueFilename(fn,{'.xls'});
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence,handles.Tracker);
Exp.Notes = handles.note;
Exp.SpecialData = handles.specialData;
Exp.SpecialVec = handles.specialVec;
Exp.TimeVector = handles.TimeVector;

save(fn,'Exp');
%     [fn,Exp] = menuSave_Callback(hObject, eventdata, handles);
% Remove the .mat extension if it exists
if length(fn) >= 4 && strcmp(fn(end-3:end), '.mat')
    fn = fn(1:end-4);
end
exportXls([fn, '.xls'], Exp);

if get(handles.plotinOriginCheckbox, 'value')
    RefreshOriginTemplatePopup(handles.popupmenuTempelate,handles);
    s = get(handles.popupmenuTempelate,'String');
    Mode = s{get(handles.popupmenuTempelate,'Value')};
    CreatePlotInOrigin([fn, '.xls'],Mode)
end


%     fn = fullfile(fp, fn);
%     save([fn, '.mat'], 'Exp');
%     exportXls([fn, '.xls'], Exp);
%     if plotInOriginFlag
%         CreatePlotInOrigin([fn, '.xls'],'NV-correlation-Sindamp&FFT-xls.ogwu')
%     end


function handles = UpdateAutoFilename(handles)
if ~isfield(handles,'filenameEdit') || ~ishandle(handles.filenameEdit)
    return;
end
autoFilename = BuildExperimentFilenameCore(handles);
if isempty(autoFilename)
    return;
end
currentFilename = get(handles.filenameEdit,'String');
oldAutoFilename = '';
if isfield(handles,'AutoFilenamePart')
    oldAutoFilename = handles.AutoFilenamePart;
end
if isempty(oldAutoFilename)
    try
        userData = get(handles.filenameEdit,'UserData');
        if ischar(userData) || isstring(userData)
            oldAutoFilename = char(userData);
        end
    catch
    end
end
filename = MergeAutoFilenamePart(currentFilename,oldAutoFilename,autoFilename);
set(handles.filenameEdit,'String',filename);
try
    set(handles.filenameEdit,'UserData',autoFilename);
catch
end
handles.AutoFilenamePart = autoFilename;
try
    guidata(handles.figure1,handles);
catch
end

function filename = MergeAutoFilenamePart(currentFilename,oldAutoFilename,autoFilename)
if isempty(currentFilename)
    filename = autoFilename;
    return;
end
if ~isempty(oldAutoFilename)
    idx = strfind(currentFilename,oldAutoFilename);
    if ~isempty(idx)
        startIdx = idx(1);
        filename = [currentFilename(1:startIdx-1),autoFilename,currentFilename(startIdx+length(oldAutoFilename):end)];
        filename = regexprep(filename,'_+','_');
        filename = regexprep(filename,'^_','');
        filename = regexprep(filename,'_$','');
        return;
    end
end
if ~isempty(strfind(currentFilename,autoFilename))
    filename = currentFilename;
    return;
end
prefix = StripDetectedAutoFilenameTail(currentFilename);
if ~strcmp(prefix,currentFilename)
    filename = JoinFilenameParts(prefix,autoFilename);
    return;
end
if strcmp(currentFilename,autoFilename)
    filename = autoFilename;
else
    filename = JoinFilenameParts(currentFilename,autoFilename);
end

function filename = JoinFilenameParts(prefix,autoFilename)
if isempty(prefix)
    filename = autoFilename;
else
    filename = [prefix,'_',autoFilename];
end
filename = regexprep(filename,'_+','_');
filename = regexprep(filename,'^_','');
filename = regexprep(filename,'_$','');

function prefix = StripDetectedAutoFilenameTail(filename)
prefix = filename;
markers = regexp(filename,'_(?:f[^_]*|pi[^_]*|sweep[^_]*)','start');
if isempty(markers)
    return;
end
for k = numel(markers):-1:1
    candidate = filename(markers(k)+1:end);
    if IsAutoFilenameTail(candidate)
        beforeMarker = filename(1:markers(k)-1);
        prevUnderscore = find(beforeMarker == '_',1,'last');
        if isempty(prevUnderscore)
            prefix = '';
        else
            prefix = beforeMarker(1:prevUnderscore-1);
        end
        prefix = regexprep(prefix,'_+$','');
        return;
    end
end

function tf = IsAutoFilenameTail(candidate)
tf = false;
if ~isempty(regexp(candidate,'^f.*_pts[^_]*$','once'))
    tf = true;
elseif ~isempty(regexp(candidate,'^f.*_sweep.*_pts[^_]*$','once'))
    tf = true;
elseif ~isempty(regexp(candidate,'^pi.*_sweep.*_pts[^_]*$','once'))
    tf = true;
elseif ~isempty(regexp(candidate,'^sweep.*_pts[^_]*$','once'))
    tf = true;
end

function filename = BuildExperimentFilenameCore(handles)
sequenceName = GetSequenceName(handles);
sequenceName = SanitizeFilenamePart(sequenceName);
if isempty(sequenceName)
    sequenceName = 'Sequence';
end

if ~isempty(strfind(upper(sequenceName),'ODMR'))
    filename = [sequenceName,'_',BuildTaborSweepName(handles)];
elseif ~isempty(strfind(upper(sequenceName),'RABI'))
    filename = [sequenceName,'_',BuildTaborFrequencyName(handles),'_',BuildPulseSweepName(handles)];
else
    filename = [sequenceName,'_',BuildPiName(handles),'_',BuildPulseSweepName(handles)];
end
filename = regexprep(filename,'_+','_');
filename = regexprep(filename,'_$','');

function filename = BuildSaveFilename(handles,defaultName,prename)
if nargin < 2
    defaultName = '';
    try
        defaultName = get(handles.filenameEdit,'String');
    catch
    end
    if isempty(defaultName)
        defaultName = ['Exp_',datestr(now,'yyyymmdd_HH-MM-SS')];
    end
end
if nargin < 3
    prename = '';
    try
        prename = get(handles.prenameEdit,'String');
    catch
    end
end
baseName = defaultName;
if nargin < 2 || isempty(baseName)
    baseName = BuildExperimentFilenameCore(handles);
end
filename = BuildSaveFilenameFromName(handles,[prename,baseName]);

function filename = BuildSaveFilenameFromName(handles,filename)
[~,name,ext] = fileparts(filename);
if isempty(name)
    name = ['Exp_',datestr(now,'yyyymmdd_HH-MM-SS')];
end
name = regexprep(name,'_samp[^_]*_avg[^_]*$','');
samples = SanitizeFilenamePart(get(handles.editSequenceSamples,'String'));
averages = SanitizeFilenamePart(GetFilenameAverage(handles));
if isempty(samples)
    samples = 'Unknown';
end
if isempty(averages)
    averages = 'Unknown';
end
filename = [name,'_samp',samples,'_avg',averages];
if isempty(ext)
    ext = '.mat';
end
filename = [filename,ext];

function averages = GetFilenameAverage(handles)
averages = '';
if isfield(handles,'CurrentAverage') && isnumeric(handles.CurrentAverage) && ...
        isscalar(handles.CurrentAverage) && isfinite(handles.CurrentAverage) && ...
        handles.CurrentAverage > 0
    averages = sprintf('%d',floor(handles.CurrentAverage));
    return;
end
try
    if isfield(handles,'Counter') && ~isempty(handles.Counter) && ...
            isnumeric(handles.Counter.AvgIndex) && isscalar(handles.Counter.AvgIndex) && ...
            isfinite(handles.Counter.AvgIndex) && handles.Counter.AvgIndex > 0
        averages = sprintf('%d',floor(handles.Counter.AvgIndex));
        return;
    end
catch
end
averages = get(handles.editAverages,'String');

function filename = BuildUniqueFilename(filename,relatedExtensions)
if nargin < 2
    relatedExtensions = {};
end
if ischar(relatedExtensions)
    relatedExtensions = {relatedExtensions};
end
[folder,name,ext] = fileparts(filename);
if isempty(ext)
    ext = '.mat';
end
filename = fullfile(folder,[name,ext]);
index = 1;
while FileSetExists(filename,relatedExtensions)
    filename = fullfile(folder,sprintf('%s_%d%s',name,index,ext));
    index = index + 1;
end

function tf = FileSetExists(filename,relatedExtensions)
tf = exist(filename,'file') == 2;
if tf
    return;
end
[folder,name] = fileparts(filename);
for k = 1:numel(relatedExtensions)
    relatedFilename = fullfile(folder,[name,relatedExtensions{k}]);
    if exist(relatedFilename,'file') == 2
        tf = true;
        return;
    end
end

function sequenceName = GetSequenceName(handles)
sequenceName = '';
if isfield(handles,'PulseSequence') && isprop(handles.PulseSequence,'SequenceName')
    sequenceName = handles.PulseSequence.SequenceName;
end

function part = BuildTaborSweepName(handles)
parts = {};
if isfield(handles,'TEProteusInst')
    tabor = handles.TEProteusInst;
    if IsTruthy(GetObjectProperty(tabor,'SweepZoneState1',0))
        parts{end+1} = sprintf('f%s-to-%s_pts%s',FormatFrequency(GetObjectProperty(tabor,'SweepStart1',NaN)),FormatFrequency(GetObjectProperty(tabor,'SweepStop1',NaN)),FormatNumber(GetObjectProperty(tabor,'SweepPoints1',NaN)));
    end
    if IsTruthy(GetObjectProperty(tabor,'SweepZoneState2',0))
        parts{end+1} = sprintf('f%s-to-%s_pts%s',FormatFrequency(GetObjectProperty(tabor,'SweepStart2',NaN)),FormatFrequency(GetObjectProperty(tabor,'SweepStop2',NaN)),FormatNumber(GetObjectProperty(tabor,'SweepPoints2',NaN)));
    end
end
if isempty(parts)
    part = 'fSweep';
else
    part = parts{1};
    for k = 2:numel(parts)
        part = [part,'_',parts{k}];
    end
end

function part = BuildTaborFrequencyName(handles)
frequency = NaN;
if isfield(handles,'TEProteusInst')
    frequency = GetObjectProperty(handles.TEProteusInst,'Frequency1',NaN);
end
if isnan(ToDouble(frequency))
    part = 'fUnknown';
else
    part = ['f',FormatFrequency(frequency)];
end

function part = BuildPulseSweepName(handles)
if isfield(handles,'PulseSequence') && ~isempty(handles.PulseSequence.Sweeps)
    swp = handles.PulseSequence.Sweeps(1);
    part = sprintf('sweep%s-to-%s_pts%s',FormatSweepValue(swp.StartValue),FormatSweepValue(swp.StopValue),FormatNumber(swp.SweepPoints));
else
    part = 'sweep';
end

function part = BuildPiName(handles)
pulseLabel = '';
pulseValue = [];
[pulseLabel,pulseValue] = GetPulseNameFromSequence(handles);
if ~isempty(pulseLabel)
    if isempty(pulseValue) || isnan(pulseValue)
        part = pulseLabel;
    else
        part = [pulseLabel,FormatSweepValue(pulseValue)];
    end
    return;
end

piValue = [];
if isfield(handles,'textPiPulse') && ishandle(handles.textPiPulse)
    piText = get(handles.textPiPulse,'String');
    tokens = regexp(piText,'[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?','match');
    if ~isempty(tokens)
        piValue = str2double(tokens{1});
    end
end
if isempty(piValue) || isnan(piValue)
    part = 'pi';
else
    part = ['pi',FormatSweepValue(piValue)];
end

function [pulseLabel,pulseValue] = GetPulseNameFromSequence(handles)
pulseLabel = '';
pulseValue = [];
if ~isfield(handles,'PulseSequence') || isempty(handles.PulseSequence) || ...
        ~isprop(handles.PulseSequence,'Channels') || isempty(handles.PulseSequence.Channels)
    return;
end

pseq = handles.PulseSequence;
mwHWChannel = [];
try
    if isprop(pseq,'MWHWChannel') && ~isempty(pseq.MWHWChannel)
        mwHWChannel = pseq.MWHWChannel;
    end
catch
end
if isempty(mwHWChannel)
    mwHWChannel = GetDefaultMWHWChannel(pseq);
end

piDurations = [];
piHalfDurations = [];
mwDurations = [];
for channelIndex = 1:numel(pseq.Channels)
    ch = pseq.Channels(channelIndex);
    if ~isempty(mwHWChannel)
        try
            if ~isprop(ch,'HWChannel') || isempty(ch.HWChannel) || ch.HWChannel ~= mwHWChannel
                continue;
            end
        catch
            continue;
        end
    end
    if ~isprop(ch,'RiseDurations') || isempty(ch.RiseDurations)
        continue;
    end
    for riseIndex = 1:numel(ch.RiseDurations)
        duration = ToDouble(ch.RiseDurations(riseIndex));
        if isnan(duration) || duration <= 0
            continue;
        end
        riseType = GetRiseType(ch,riseIndex);
        if isempty(mwHWChannel) && IsNonMicrowaveRiseType(riseType)
            continue;
        end
        if IsPiHalfRiseType(riseType)
            piHalfDurations(end+1) = duration; %#ok<AGROW>
        elseif IsPiRiseType(riseType)
            piDurations(end+1) = duration; %#ok<AGROW>
        end
        mwDurations(end+1) = duration; %#ok<AGROW>
    end
end

if ~isempty(piDurations)
    pulseLabel = 'pi';
    pulseValue = max(piDurations);
elseif ~isempty(piHalfDurations)
    durationValues = UniqueRoundedValues(mwDurations);
    if numel(durationValues) > 1
        pulseLabel = 'pi';
        pulseValue = max(durationValues);
    else
        pulseLabel = 'piOver2';
        pulseValue = max(piHalfDurations);
    end
elseif ~isempty(mwDurations)
    durationValues = UniqueRoundedValues(mwDurations);
    if numel(durationValues) > 1
        pulseLabel = 'pi';
        pulseValue = max(durationValues);
    else
        pulseLabel = 'piOver2';
        pulseValue = durationValues(1);
    end
end

function riseType = GetRiseType(channel,riseIndex)
riseType = '';
try
    if isprop(channel,'RiseTypes') && numel(channel.RiseTypes) >= riseIndex
        riseType = lower(char(channel.RiseTypes{riseIndex}));
    end
catch
end

function mwHWChannel = GetDefaultMWHWChannel(pseq)
mwHWChannel = [];
try
    for channelIndex = 1:numel(pseq.Channels)
        ch = pseq.Channels(channelIndex);
        if isprop(ch,'HWChannel') && ~isempty(ch.HWChannel) && ch.HWChannel == 3
            mwHWChannel = 3;
            return;
        end
    end
catch
end

function tf = IsPiHalfRiseType(riseType)
tf = ~isempty(regexp(riseType,'pi\s*/?\s*2|pi[_-]?half|half[_-]?pi','once'));

function tf = IsPiRiseType(riseType)
tf = ~IsPiHalfRiseType(riseType) && ...
    ~isempty(regexp(riseType,'(^|[^a-z0-9])pi([^a-z0-9]|$)','once'));

function tf = IsNonMicrowaveRiseType(riseType)
tf = ~isempty(strfind(riseType,'counter')) || ...
    ~isempty(strfind(riseType,'init')) || ...
    ~isempty(strfind(riseType,'readout')) || ...
    ~isempty(strfind(riseType,'laser')) || ...
    strcmp(riseType,'rise') || ...
    ~isempty(strfind(riseType,'end'));

function values = UniqueRoundedValues(values)
values = values(isfinite(values) & values > 0);
if isempty(values)
    return;
end
scale = 1e12;
roundedValues = round(values * scale) / scale;
values = unique(roundedValues);

function out = FormatFrequency(value)
value = ToDouble(value);
if isnan(value)
    out = 'Unknown';
elseif abs(value) >= 1e9
    out = [FormatNumber(value/1e9),'GHz'];
elseif abs(value) >= 1e6
    out = [FormatNumber(value/1e6),'MHz'];
else
    out = [FormatNumber(value),'Hz'];
end

function out = FormatSweepValue(value)
value = ToDouble(value);
if isnan(value)
    out = 'Unknown';
elseif abs(value) > 0 && abs(value) < 1e-6
    out = [FormatNumber(value*1e9),'ns'];
elseif abs(value) >= 1e-6 && abs(value) < 1e-3
    out = [FormatNumber(value*1e6),'us'];
elseif abs(value) >= 1e-3 && abs(value) < 1
    out = [FormatNumber(value*1e3),'ms'];
else
    out = FormatNumber(value);
end

function out = FormatNumber(value)
value = ToDouble(value);
if isnan(value)
    out = 'Unknown';
elseif abs(value-round(value)) < 1e-9
    out = sprintf('%.0f',value);
else
    out = sprintf('%.4g',value);
end
out = strrep(out,'.','p');
out = strrep(out,'+','');

function value = ToDouble(value)
if ischar(value)
    value = str2double(value);
end

function tf = IsTruthy(value)
if ischar(value)
    tf = strcmpi(value,'on') || strcmpi(value,'true') || strcmp(value,'1');
else
    tf = logical(value);
end

function value = GetObjectProperty(obj,propName,defaultValue)
try
    value = obj.(propName);
catch
    value = defaultValue;
end

function tf = IsObjectProperty(obj,propName)
try
    tf = any(strcmp(properties(obj),propName));
catch
    tf = false;
end

function SetObjectProperty(obj,propName,value)
try
    obj.(propName) = value;
catch
end

function out = SanitizeFilenamePart(in)
if isempty(in)
    out = '';
    return;
end
if isnumeric(in)
    in = num2str(in);
end
out = regexprep(strtrim(in),'[^\w\-.]','_');

% --- Executes on button press in selectfolderButton.
function selectfolderButton_Callback(~, eventdata, handles)
% hObject    handle to selectfolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folderName = uigetdir;
% Check if the user selected a folder or canceled
if folderName ~= 0
    % Update the text box with the selected folder path
    set(handles.filepathEdit, 'String', folderName);
else
    % Display a message if the user canceled
    set(handles.filepathEdit, 'String', 'No folder selected');
end


function prenameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to prenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prenameEdit as text
%        str2double(get(hObject,'String')) returns contents of prenameEdit as a double


% --- Executes during object creation, after setting all properties.
function prenameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filenameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to filenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenameEdit as text
%        str2double(get(hObject,'String')) returns contents of filenameEdit as a double


% --- Executes during object creation, after setting all properties.
function filenameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filepathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to filepathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepathEdit as text
%        str2double(get(hObject,'String')) returns contents of filepathEdit as a double


% --- Executes during object creation, after setting all properties.
function filepathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filepathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotinOriginCheckbox.
function plotinOriginCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to plotinOriginCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotinOriginCheckbox


% --- Executes on key press with focus on selectfolderButton and none of its controls.
function selectfolderButton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to selectfolderButton (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% Open the file dialog to select a folder
folderName = uigetdir;
% Check if the user selected a folder or canceled
if folderName ~= 0
    % Update the text box with the selected folder path
    set(handles.filepathEdit, 'String', folderName);
else
    % Display a message if the user canceled
    set(handles.filepathEdit, 'String', 'No folder selected');
end

function exportXls(fn, Exp)
mode = Exp.Notes;
switch mode
    case'Pulsed'
        xdata = Exp.TimeVector;
    case'Pulsed/N-sweep'
        xdata = Exp.TimeVector';
    case 'Pulsed/f-sweep'
        xdata = transpose(linspace(Exp.SignalGenerator.SweepStart1,Exp.SignalGenerator.SweepStop1,Exp.SignalGenerator.SweepPoints1));
end

ydata = Exp.Counter.AveragedData;

% if size(ydata,2)==3
%     ycontrast = (ydata(:,2)-ydata(:,3))./(ydata(:,2)+ydata(:,3));
% else
%     ycontrast = ydata(:,2)./ydata(:,1);
% end

ycontrast = Exp.Counter.ProcessedData(:,1);

T = table(xdata, ydata,ycontrast);
% case'Pulsed/f-sweep';
%     startF = str2num(get(handles.editStartF,'String'));
%     stopF = str2num(get(handles.editStopF,'String'));
%     pointsF = str2num(get(handles.editPointsF,'String'));
%     xdata = transpose(linspace(startF,stopF,pointsF));

%     xdata = transpose(linspace(Exp.PulseSequence.Sweeps.StartValue,Exp.PulseSequence.Sweeps.StopValue,Exp.PulseSequence.Sweeps.SweepPoints));


writetable(T, fn, 'Sheet', 1);

frequency1value = fix(str2double(Exp.SignalGenerator.Frequency1));

signalgeneratordata = table(str2double(Exp.SignalGenerator.Amplitude),...
    frequency1value, ...
    Exp.SignalGenerator.SweepStart1, ...
    Exp.SignalGenerator.SweepStop1, ...
    Exp.SignalGenerator.SweepPoints1, ...
    'VariableNames', {'sweepfre', 'amplitude', 'sweepstart', 'sweepstop', 'sweeppoints'});

counterdata = table(Exp.Counter.NSamples, Exp.Counter.AvgIndex, ...
    'VariableNames', {'NSamples', 'AvgIndex'});

targetlist = [];
try
    targetlist = Exp.CurrentTracker.TargetList;
catch
end
targetlistTable = table();
if ~isempty(targetlist)
    if size(targetlist,2) < 4
        targetlist(:,end+1:4) = nan;
    end
    targetlistTable = array2table(targetlist(:,1:4), 'VariableNames', {'x', 'y', 'z', 'targetnumber'});
end

% List of all unique column names
allColumnNames = union(union(targetlistTable.Properties.VariableNames, counterdata.Properties.VariableNames), signalgeneratordata.Properties.VariableNames);

% Function to add missing columns to a table
addMissingColumns = @(T, columnNames) [T, array2table(nan(height(T), length(setdiff(columnNames, T.Properties.VariableNames))), 'VariableNames', setdiff(columnNames, T.Properties.VariableNames))];

% Add missing columns to each table
targetlistTable = addMissingColumns(targetlistTable, allColumnNames);
counterdata = addMissingColumns(counterdata, allColumnNames);
signalgeneratordata = addMissingColumns(signalgeneratordata, allColumnNames);

% Rearrange columns to match the same order
targetlistTable = targetlistTable(:, allColumnNames);
counterdata = counterdata(:, allColumnNames);
signalgeneratordata = signalgeneratordata(:, allColumnNames);

% Combine all tables vertically
combinedData = [targetlistTable; counterdata; signalgeneratordata];

% Write the combined table to an Excel file
writetable(combinedData, fn, 'Sheet', 2);

function CreatePlotInOrigin(fname,tempelateName)
% Obtain Origin COM Server object
% This will connect to an existing instance of Origin, or create a new one if none exist
originObj=actxserver('Origin.ApplicationSI');

% Make the Origin session visible
% originObj.Execute('doc -mc 1;');

% Load the tempelate
strPath = [OriginTemplateFolder(),filesep];
originObj.Load(strcat(strPath, tempelateName));

% % update the data file path
% originObj.Execute(strcat('wbook.dc.source$ =',fname));
% % import it
% originObj.Execute('wbook.dc.Import()');

loadoption = strcat('string fname$="',fname,'"',';');

originObj.Execute(loadoption);
originObj.Execute('impMSExcel options.Mode:=4 options.headers.MainHeaderLines:=1;');

% Set the context to the active workbook and trigger recalculation
labTalkScript = sprintf([
    'string workbookName$ = %H;'...
    'type -a "Active workbook short name: " + workbookName$;'...
    'win -o %s { ' ...
    '    int numSheets = page.nlayers; ' ...
    '    for (int i = 1; i <= numSheets; i++) { ' ...
    '        page.active = i; ' ...   % Activate each sheet
    '        layer -s i; ' ...
    '        recalculate; ' ...
    '        type -a "Recalculated worksheet: " + layer.name$; ' ...
    '    } ' ...
    '}'...
    ]);


% Execute the LabTalk script in Origin
originObj.Execute(labTalkScript);


% % Rescale the two layers in the graph and copy graph to clipboard
% originObj.Execute('page.active = 1; layer - a; page.active = 2; layer - a;');
% originObj.CopyPage('Graph1');

% relase the originobj
release(originObj);


% --- Executes on selection change in popupmenuTempelate.
function popupmenuTempelate_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTempelate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTempelate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTempelate

RefreshOriginTemplatePopup(hObject,handles);



% --- Executes during object creation, after setting all properties.
function popupmenuTempelate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTempelate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RefreshOriginTemplatePopup(hObject,handles)
if isempty(hObject) || ~ishandle(hObject)
    return;
end
folderPath = OriginTemplateFolder();
ogwuFiles = dir(fullfile(folderPath, '*.ogwu'));
fileNames = {ogwuFiles.name};
if isempty(fileNames)
    fileNames = {'No .ogwu templates found'};
end
oldSelection = '';
try
    oldStrings = get(hObject,'String');
    oldValue = get(hObject,'Value');
    if ischar(oldStrings)
        oldStrings = cellstr(oldStrings);
    end
    if ~isempty(oldStrings) && oldValue <= numel(oldStrings)
        oldSelection = oldStrings{oldValue};
    end
catch
end
newValue = 1;
if ~isempty(oldSelection)
    selectedIndex = find(strcmp(fileNames,oldSelection),1);
    if ~isempty(selectedIndex)
        newValue = selectedIndex;
    end
end
set(hObject,'String',fileNames,'Value',newValue);

function folderPath = OriginTemplateFolder()
folderPath = 'C:\Users\meriles\Documents\OriginLab\User Files\tempelateForNVcenter';
