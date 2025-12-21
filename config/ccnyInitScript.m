function [handles] = ccnyInitScript(handles)

%% LOOK FOR ImageAcquire
apps = getappdata(0);
fN = fieldnames(apps);
for k=1:numel(fN),
    if ishandle(getfield(apps,fN{k})),
        try
            name = get(getfield(apps,fN{k}),'Name');
        catch ME
            name = 'failed';
        end
        if strcmp('ImageAcquire',name),
            hFig = getfield(apps,fN{k});
            IAHandles = guidata(hFig);
            handles.hImageAcquisition = IAHandles.ImageAcquisition;
            C = get(IAHandles.imageAxes,'Children');
            copyobj(C,handles.axesConfocal);
            colormap(handles.axesConfocal,'jet');
            colorbar('peer',handles.axesConfocal);
            axis(handles.axesConfocal,'square');
            handles.Tracker = IAHandles.Tracker;
            handles.PulseGenerator = IAHandles.Tracker.hwLaserController;
            break;
        end
    end
end

if isfield(handles,'hImageAcquisition'),
    set(handles.textCurPosX,'String',sprintf('X = %.4f',handles.hImageAcquisition.CursorPosition(1)));
    set(handles.textCurPosY,'String',sprintf('Y = %.4f',handles.hImageAcquisition.CursorPosition(2)));
    set(handles.textCurPosZ,'String',sprintf('Z = %.4f',handles.hImageAcquisition.CursorPosition(3)));
end


% ---- Tabor Proteus init (optional) ----
cfg = site_ccny();  % 如果你在脚本开头已经有这一句，这里不用重复

if isfield(cfg,'tabor') && isfield(cfg.tabor,'enable') && cfg.tabor.enable
    try
        connStr = cfg.tabor.connStr;
        paranoia_level = cfg.tabor.paranoia_level;

        inst = TEProteusInst(connStr, paranoia_level);

        res = inst.Connect();
        % if you want to enforce connection success:
        % assert(res == true);

        % Optional instrument init commands
        if isfield(cfg.tabor,'do_clear') && cfg.tabor.do_clear
            inst.SendCmd('*CLS');
        end
        if isfield(cfg.tabor,'do_reset') && cfg.tabor.do_reset
            inst.SendCmd('*RST');
        end

        % Optional: store handle(s)
        handles.TEProteusInst = inst;

        if isfield(cfg.tabor,'expose_as_signal_generator') && cfg.tabor.expose_as_signal_generator
            handles.SignalGenerator = inst;
        end

        % Optional: expected ID logging (your original code hard-coded idnstr)
        if isfield(cfg.tabor,'idn_expected') && ~isempty(cfg.tabor.idn_expected)
            fprintf('Connected to Proteus (expected ID): %s\n', cfg.tabor.idn_expected);
        else
            fprintf('Connected to Proteus at %s\n', connStr);
        end

        % IMPORTANT:
        % Do NOT disconnect if you intend to use the handle later.
        % If you just want to test connection at startup, then disconnect here.
        %
        % If your workflow needs the instrument active during experiment,
        % keep it connected and provide a cleanup on app close instead.
        %
        % inst.Disconnect();

    catch ME
        warning('[ccnyInitScript] Proteus init failed: %s', ME.message);
        % Optionally: ensure handle exists and is empty
        handles.TEProteusInst = [];
    end
end

% ---- Microwave Amplifier init (VISA-Serial) ----
% cfg = site_ccny();  % 如果脚本开头已有 cfg，这里不用重复

if isfield(cfg,'mwAmp') && isfield(cfg.mwAmp,'enable') && cfg.mwAmp.enable
    try
        vendor = cfg.mwAmp.vendor;
        rsrc   = cfg.mwAmp.rsrc;

        ampObj = instrfind('Type','visa-serial','RsrcName',rsrc,'Tag','');

        if isempty(ampObj)
            ampObj = visa(vendor, rsrc);
        else
            if isfield(cfg.mwAmp,'closeExisting') && cfg.mwAmp.closeExisting
                try fclose(ampObj); catch, end
            end
            ampObj = ampObj(1);
        end

        % Apply serial parameters
        if isprop(ampObj,'BaudRate'),  ampObj.BaudRate  = cfg.mwAmp.baudRate; end
        if isprop(ampObj,'DataBits'),  ampObj.DataBits  = cfg.mwAmp.dataBits; end
        if isprop(ampObj,'StopBits'),  ampObj.StopBits  = cfg.mwAmp.stopBits; end
        if isprop(ampObj,'Parity'),    ampObj.Parity    = cfg.mwAmp.parity; end
        if isprop(ampObj,'Terminator'),ampObj.Terminator= cfg.mwAmp.terminator; end
        if isprop(ampObj,'Timeout'),   ampObj.Timeout   = cfg.mwAmp.timeout; end

        % Open connection
        % if strcmpi(ampObj.Status,'closed')
        %     fopen(ampObj);
        % end

        handles.MicrowaveAmp = ampObj;
        fprintf('MicrowaveAmp connected: %s (%s)\n', rsrc, vendor);

    catch ME
        warning('[ccnyInitScript] MicrowaveAmp init failed: %s', ME.message);
        handles.MicrowaveAmp = [];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the pulse generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         LibraryFile = 'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.dll';
%         HeaderFile = 'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.h';
%         LibraryName = 'pb';
%         handles.PulseGenerator = SpinCorePulseGenerator2();
%
%         handles.PulseGenerator.Initialize(LibraryFile,HeaderFile,LibraryName);
%
%         % set PG clock rate to 1MHz
%         % for SpinCore, clock rate is in units of MHZ
%         handles.PulseGenerator.setClockRate(4e8);
% LibraryFilePath = 'C:\SpinCore\SpinAPI\lib\spinapi64.dll';
% HeaderFilePath = 'C:\SpinCore\SpinAPI\include\spinapi.h';
% HeaderFilePath2 = 'C:\SpinCore\SpinAPI\include\pulseblaster.h';
% LibraryName = 'pb';
% PG = SpinCorePulseGenerator2();
%
% PG.Initialize(LibraryFilePath,HeaderFilePath,HeaderFilePath2,LibraryName);

% set PG clock rate to 1MHz
% for SpinCore, clock rate is in units of MHZ
% PG.setClockRate(4e8);

% init the pg
% PG.init();
%  handles.PulseGenerator = PG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init a fast counter for pulsing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % configure NIDAQ Driver Instance
cfg = site_ccny();
handles.options.cfg = cfg;  % (可选) 存起来，方便别处复用

handles.Counter = NICounter(cfg.ni.libraryName, cfg.ni.dll, cfg.ni.header);

handles.Counter.hwHandle.addCounterInLine(cfg.ni.counter.ctr0, cfg.ni.counter.pfi0, 1);
handles.Counter.hwHandle.addCounterInLine(cfg.ni.counter.ctr1, cfg.ni.counter.pfi13, 2);

handles.Counter.hwHandle.addClockLine(cfg.ni.clock.internal, cfg.ni.clock.pfi13);
handles.Counter.hwHandle.addClockLine(cfg.ni.clock.externalName, cfg.ni.clock.externalPFI);

handles.Counter.CounterInLine = 2;
handles.Counter.CounterClockLine = 2;
handles.Counter.hwHandle.ReadTimeout = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init a counter for tracking (same hardware, different software object)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         handles.TrackCounter = CounterAcquisition();
%         handles.TrackCounter.interfaceNIDAQ = handles.Counter.hwHandle;
%         handles.TrackCounter.DwellTime = 0.005;
%         handles.TrackCounter.NumberOfSamples = 100;
%         handles.TrackCounter.LoopsUntilTimeOut = 100;
%         handles.TrackCounter.CounterInLine = 1;
%         handles.TrackCounter.CounterOutLine = 1;



%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% configure the tracking algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PG = handles.PulseGenerator;
%
% %%%%% CONFIGURE TRACKER %%%%%
% Tracker = TrackerCCNY();
% Tracker.hCounterAcquisition = handles.TrackCounter;
% handles.Tracker.hwLaserController = PG;
% Tracker.hImageAcquisition = handles.hImageAcquisition;
% Tracker.InitialStepSize = [0.005,0.005];
% Tracker.StepReductionFactor = [.5,.5];
% Tracker.MinimumStepSize = [0.0005,0.0005];
% Tracker.TrackingThreshold = [1500];
% Tracker.MaxIterations = [10];
% handles.Tracker.LaserControlLine = 1; % AOM is line 1
% Tracker.InitialPosition = handles.hImageAcquisition.CursorPosition;
% Tracker.MaxCursorPosition = [5,5];
% Tracker.MinCursorPosition = [-5,-5];
%
% handles.Tracker = Tracker;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Configure B Field Stage Controllers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the Serial Number
SNX = 27250249; % put in the serial number of the hardware
SNY = 27250244;
SNZ = 27250912;
%
fpos    = get(0,'DefaultFigurePosition'); % figure default position
fpos(3) = 650; % figure window size;Width
fpos(4) = 450; % Height

%creat B field Control GUIs and handles  (magnet? Commented Daniela)
%  BXFig = figure('Position', fpos,'Menu','None','Name','X-Axis');
%  handles.BControlX = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], BXFig);
%  BYFig = figure('Position', fpos,'Menu','None','Name','Y-Axis');
%  handles.BControlY = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], BYFig);
%  BZFig = figure('Position', fpos,'Menu','None','Name','Z-Axis');
%  handles.BControlZ = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], BZFig);
%
%% Initialize
% Start Control (commented by Daniela for magnets)
% handles.BControlX.StartCtrl;
% handles.BControlY.StartCtrl;
% handles.BControlZ.StartCtrl;
% %
% set(handles.BControlX,'HWSerialNum', SNX);
% set(handles.BControlY,'HWSerialNum', SNY);
% set(handles.BControlZ,'HWSerialNum', SNZ);
% %
% % % Indentify the device
% handles.BControlX.Identify;
% handles.BControlY.Identify;
% handles.BControlZ.Identify;
%
% pause(5); % waiting for the GUI to load up;
% %% Controlling the Hardware
% handles.BControlX.MoveHome(0,0); % Home the stage. First 0 is the channel ID (channel 1)
% handles.BControlY.MoveHome(0,0);
% handles.BControlZ.MoveHome(0,0);
% %Contraint parameters
handles.BControlMax = 25;
handles.BControlMin = -1;
handles.BControlJogSize = .1;

%%
% fix the path
% addpath([pwd,'\','Sequences\']);

% add in hack for spin noise measurements
handles.options.spinNoiseAvg = 0; % turn on spin noise averaging;
handles.options.SpinNoiseDataFolder = 'D:\Data\Will\Spin Noise';
