
function [handles] = CCNY_ImageAcquire_InitScript(handles)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP NI              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%


        % configure NIDAQ Driver Instance
        LibraryName = 'nidaqmx';
        LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
        HeaderFilePath = 'D:\Matlab software and codes\wittelsbach control software 75 + phase\config\NIDAQmx.h';
        ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
        %%
        % add Counter Line
        ni.addCounterInLine('Dev1/ctr0','/Dev1/PFI0',1);

        % add Clock Line
        ni.addClockLine('Dev1/ctr1','/Dev1/PFI13');

        % add AO lines
        ni.addAOLine('Dev1/ao0',0);
        ni.addAOLine('Dev1/ao1',0);

        % Write the AO
        ni.WriteAnalogOutAllLines;


        % send to the handles structure
        handles.NI = ni;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP ImageAcqusition HANDLES             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % hookup the NI to the IA
        handles.ImageAcquisition.interfaceNIDAQ = handles.NI;
        handles.ImageAcquisition.interfacePiezo = PIControl();
        handles.ImageAcquisition.interfacePiezo.initialize();
        
        handles.ImageAcquisition.ZController = 'Piezo';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP CounterAcquisition %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init Counter
handles.Counter = CounterAcquisition();
handles.Counter.interfaceNIDAQ = handles.NI;
handles.Counter.DwellTime = 0.005;
handles.Counter.NumberOfSamples = 25;
handles.Counter.LoopsUntilTimeOut = 10000;
handles.Counter.CounterInLine = 1;
handles.Counter.CounterOutLine = 1;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP Tracking                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% PULSE GENERATOR %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the pulse generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        LibraryFile = 'C:\SpinCore\SpinAPI\lib\spinapi.dll';
        HeaderFile = 'C:\SpinCore\SpinAPI\include\spinapi.h';
        LibraryName = 'pb';
        PG = SpinCorePulseGenerator2();
        
        PG.Initialize(LibraryFile,HeaderFile,LibraryName);

        % set PG clock rate to 1MHz
        % for SpinCore, clock rate is in units of MHZ
        PG.setClockRate(4e8);
        
        % init the pg
        PG.init();
 
%%%%% CONFIGURE TRACKER %%%%%
Tracker = TrackerCCNY();
Tracker.hCounterAcquisition = handles.Counter;
Tracker.hwLaserController = PG;
Tracker.hImageAcquisition = handles.ImageAcquisition;
Tracker.InitialStepSize = [0.002,0.002,1];
Tracker.StepReductionFactor = [.5,.5,0.5];
Tracker.MinimumStepSize = [0.0002,0.0002,0.05];
Tracker.TrackingThreshold = [1500];
Tracker.MaxIterations = [15];
Tracker.LaserControlLine = 1; % AOM is line 1 
Tracker.InitialPosition = handles.ImageAcquisition.CursorPosition;
Tracker.MaxCursorPosition = [5,5,100];
Tracker.MinCursorPosition = [-5,-5,0];

handles.Tracker = Tracker;



