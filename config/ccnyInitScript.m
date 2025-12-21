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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the signal generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.SignalGenerator = RohdeSchwarzSignalGenerator('tcpip','134.74.27.145',5025);
%     %handles.SignalGenerator.reset();
% handles.SignalGenerator.setModulationOff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init AWG controller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %handles.TekAWGController = TekAWGController('tcpip','169.254.90.56',4000);    
% handles.TekAWGController = TekAWGController('tcpip','134.74.27.123',4000); % before 062723 tcpip 134.74.27.103
% handles.TekAWGController.reset();
% handles.TekAWGController.sendstr('SOUR1:ROSC:SOUR EXT');
% handles.TekAWGController.sendstr('INSTRUMENT:COUPLE:SOURCE ALL');
% handles.TekAWGController.sendstr('TRIG:IMP 50ohm;:AWGCONTROL:RMODE TRIG');
% handles.TekAWGController.setSourceFrequency(1.0e9);
% % set marker voltage high/low
% handles.TekAWGController.setmarker(1,1,0,2.4);
% handles.TekAWGController.setmarker(1,2,0,2.4);
% handles.TekAWGController.setmarker(2,1,0,2.4);
% handles.TekAWGController.setmarker(2,2,0,2.4);
% % set the amplitude and offset
% handles.TekAWGController.setSourceAmplitudeandOffset(1,1,0);
% % delete the sequences
% handles.TekAWGController.sendstr(sprintf('WLIST:WAVEFORM:DELETE ALL'));

%%% init the Tabor proteus

% Communication Parameters
connStr = '134.74.27.16'; % your IP here
paranoia_level = 1; % 0, 1 or 2

% Create Administrator
inst = TEProteusInst(connStr, paranoia_level);
fprintf('\n');

res = inst.Connect();
% assert (res == true);

% Identify instrument using the standard IEEE-488.2 Command
idnstr = 'P9484D';
fprintf('\nConnected to: %s\n', idnstr);
inst.SendCmd('*CLS');
inst.SendCmd('*RST');
inst.Disconnect();    
handles.TEProteusInst = inst;
handles.SignalGenerator = inst;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the MW amplitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup the microwave amplifier

handles.MicrowaveAmp = instrfind('Type', 'visa-serial', 'RsrcName', 'ASRL5::INSTR', 'Tag', '');
% Create the VISA-Serial object if it does not exist
% otherwise use the object that was found.
if isempty(handles.MicrowaveAmp)
    handles.MicrowaveAmp = visa('NI', 'ASRL5::INSTR');
else
    fclose(handles.MicrowaveAmp);
    handles.MicrowaveAmp = handles.MicrowaveAmp(1);
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
        LibraryName = 'nidaqmx';
        LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
        HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
% 
%         %%
% 
        handles.Counter = NICounter(LibraryName,LibraryFilePath,HeaderFilePath);

        %%

        handles.Counter.hwHandle.addCounterInLine('Dev1/ctr0','/Dev1/PFI0',1);
        % add Counter Line
        handles.Counter.hwHandle.addCounterInLine('Dev1/ctr1','/Dev1/PFI13',2);  

        % add Clock Line
        handles.Counter.hwHandle.addClockLine('Dev1/ctr1','/Dev1/PFI13');
        % add Clock Line
        handles.Counter.hwHandle.addClockLine('Ext','/Dev1/PFI0');
        
        handles.Counter.CounterInLine = 2;
        handles.Counter.CounterClockLine = 2;
        
        % change the readtime to 1s;
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
addpath([pwd,'\','Sequences\']);

% add in hack for spin noise measurements
handles.options.spinNoiseAvg = 0; % turn on spin noise averaging;
handles.options.SpinNoiseDataFolder = 'D:\Data\Will\Spin Noise';
