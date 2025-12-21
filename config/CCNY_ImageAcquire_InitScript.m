
function [handles] = CCNY_ImageAcquire_InitScript(handles)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP NI (used for XY scanning (Galvo) and APD count read)%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % configure NIDAQ Driver Instance
        LibraryName = 'nidaqmx';
        LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
        HeaderFilePath = 'D:\Control software with AWG control (Kang) - confined liquid - Tabor\config\NIDAQmx.h';
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
%  SETUP PI (Used for Z control)            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        shrlib = 'E816_DLL_x64.dll';
        hfile = 'E816_DLL.h';
        LibAlias = 'E816';
        PI = PIControl(LibAlias,shrlib,hfile);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP ImageAcqusition HANDLES             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
       % hookup the NI to the IA, PI to IA
        handles.ImageAcquisition.interfaceNIDAQ = handles.NI;
        handles.ImageAcquisition.interfacePiezo = PI;    
        handles.ImageAcquisition.ZController = 'Piezo';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP CounterAcquisition %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init Counter
handles.Counter = CounterAcquisition();
handles.Counter.interfaceNIDAQ = handles.NI;
handles.Counter.DwellTime = 0.005;
handles.Counter.NumberOfSamples = 21;
handles.Counter.LoopsUntilTimeOut = 100000;
handles.Counter.CounterInLine = 1;
handles.Counter.CounterOutLine = 1;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP Tracking                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% PULSE GENERATOR %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the pulse generator (used for Tracking)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        LibraryFilePath = 'C:\SpinCore\SpinAPI\lib\spinapi64.dll';
        HeaderFilePath = 'C:\SpinCore\SpinAPI\include\spinapi.h';
        HeaderFilePath2 = 'C:\SpinCore\SpinAPI\include\pulseblaster.h';
        LibraryName = 'pb';
        PG = SpinCorePulseGenerator2();
        
        PG.Initialize(LibraryFilePath,HeaderFilePath,HeaderFilePath2,LibraryName);

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
Tracker.InitialStepSize = [0.01,0.01,1];
Tracker.StepReductionFactor = [.5,.5,0.5];
Tracker.MinimumStepSize = [0.001,0.001,0.001];
Tracker.TrackingThreshold = [2000];
Tracker.MaxIterations = [10];
Tracker.LaserControlLine = 1; % AOM is line 1 
Tracker.InitialPosition = handles.ImageAcquisition.CursorPosition;
Tracker.MaxCursorPosition = [2,2,100];
Tracker.MinCursorPosition = [-2,-2,0];

handles.Tracker = Tracker;



