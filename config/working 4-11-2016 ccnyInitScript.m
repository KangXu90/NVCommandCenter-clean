function [handles] = ccnyInitScript(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the signal generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handles.SignalGenerator = RohdeSchwarzSignalGenerator('tcpip','134.74.27.145',5025);
    %handles.SignalGenerator.reset();
    handles.SignalGenerator.setModulationOff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init AWG controller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handles.TekAWGController = TekAWGController('tcpip','134.74.27.26',4000);
    handles.TekAWGController.initialize();
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the pulse generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        LibraryFile = 'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.dll';
        HeaderFile = 'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.h';
        LibraryName = 'pb';
        handles.PulseGenerator = SpinCorePulseGenerator2();
        
        handles.PulseGenerator.Initialize(LibraryFile,HeaderFile,LibraryName);

        % set PG clock rate to 1MHz
        % for SpinCore, clock rate is in units of MHZ
        handles.PulseGenerator.setClockRate(4e8);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init a fast counter for pulsing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % configure NIDAQ Driver Instance
        LibraryName = 'nidaqmx';
        LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
        HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

        %%

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
        handles.TrackCounter = CounterAcquisition();
        handles.TrackCounter.interfaceNIDAQ = handles.Counter.hwHandle;
        handles.TrackCounter.DwellTime = 0.005;
        handles.TrackCounter.NumberOfSamples = 100;
        handles.TrackCounter.LoopsUntilTimeOut = 100;
        handles.TrackCounter.CounterInLine = 1;
        handles.TrackCounter.CounterOutLine = 1;


%% LOOK FOR ImageAcquire
apps = getappdata(0);
fN = fieldnames(apps);
for k=1:numel(fN),
    if ishandle(getfield(apps,fN{k})) && isa(getfield(apps,fN{k}),'double'),
        name = get(getfield(apps,fN{k}),'Name');
        if strcmp('ImageAcquire',name),
            hFig = getfield(apps,fN{k});
            IAHandles = guidata(hFig);
            handles.hImageAcquisition = IAHandles.ImageAcquisition;
            C = get(IAHandles.imageAxes,'Children');
            copyobj(C,handles.axesConfocal);
            colormap(handles.axesConfocal,'jet');
            colorbar('peer',handles.axesConfocal);
            axis(handles.axesConfocal,'square');
        end
    end
end

if isfield(handles,'hImageAcquisition'),
   set(handles.textCurPosX,'String',sprintf('X = %.4f',handles.hImageAcquisition.CursorPosition(1)));
  set(handles.textCurPosY,'String',sprintf('Y = %.4f',handles.hImageAcquisition.CursorPosition(2)));
 set(handles.textCurPosZ,'String',sprintf('Z = %.4f',handles.hImageAcquisition.CursorPosition(3)));

end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% configure the tracking algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PG = handles.PulseGenerator;

%%%%% CONFIGURE TRACKER %%%%%
Tracker = TrackerCCNY();
Tracker.hCounterAcquisition = handles.TrackCounter;
Tracker.hwLaserController = PG;
Tracker.hImageAcquisition = handles.hImageAcquisition;
Tracker.InitialStepSize = [0.005,0.005];
Tracker.StepReductionFactor = [.5,.5];
Tracker.MinimumStepSize = [0.0005,0.0005];
Tracker.TrackingThreshold = [1500];
Tracker.MaxIterations = [10];
Tracker.LaserControlLine = 1; % AOM is line 1
Tracker.InitialPosition = handles.hImageAcquisition.CursorPosition;
Tracker.MaxCursorPosition = [5,5];
Tracker.MinCursorPosition = [-5,-5];

handles.Tracker = Tracker;

%%
% fix the path
addpath([pwd,'\','Sequences\']);

% add in hack for spin noise measurements
handles.options.spinNoiseAvg = 1; % turn on spin noise averaging;
handles.options.SpinNoiseDataFolder = 'D:\Data\Will\Spin Noise';
