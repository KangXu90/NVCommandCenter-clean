
function [handles] = CCNY_ImageAcquire_InitScript(handles)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP NI (used for XY scanning (Galvo) and APD count read)%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% configure NIDAQ Driver Instance
cfg = site_ccny();

ni = NIDAQ_Driver(cfg.ni.libraryName, cfg.ni.dll, cfg.ni.header);

% Counter + clock
ni.addCounterInLine(cfg.ni.counter.ctr0, cfg.ni.counter.pfi0, 1);
ni.addClockLine(cfg.ni.clock.internal, cfg.ni.clock.pfi13);

% Galvo AO
ni.addAOLine(cfg.ni.ao.x, 0);
ni.addAOLine(cfg.ni.ao.y, 0);




% Write the AO
ni.WriteAnalogOutAllLines;


% send to the handles structure
handles.NI = ni;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP PI (Used for Z control)            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PI = PIControl(cfg.pi.alias,cfg.pi.dll,cfg.pi.h);

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
handles.Counter.NumberOfSamples = 5; % small number could fater the speed of tracking
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

% LibraryFilePath = 'C:\SpinCore\SpinAPI\lib\spinapi64.dll';
% HeaderFilePath = 'C:\SpinCore\SpinAPI\include\spinapi.h';
% HeaderFilePath2 = 'C:\SpinCore\SpinAPI\include\pulseblaster.h';
% LibraryName = 'pb';
PG = SpinCorePulseGenerator2();

PG.Initialize(cfg.spincore.dll,cfg.spincore.header_spinapi,...
    cfg.spincore.header_pulseblaster,cfg.spincore.libraryName);

% set PG clock rate to 1MHz
% for SpinCore, clock rate is in units of MHZ
PG.setClockRate(4e8);

% init the pg
PG.init();

%%%%% CONFIGURE TRACKER %%%%%
Tracker = TrackerCCNY();
Tracker.hCounterAcquisition = handles.Counter;
Tracker.hwLaserController = PG;
Tracker.hwLaserState = 0;
Tracker.hImageAcquisition = handles.ImageAcquisition;
Tracker.InitialStepSize = [0.01,0.01,1];
Tracker.StepReductionFactor = [.5,.5,0.5];
Tracker.MinimumStepSize = [0.001,0.001,0.001];
 Tracker.TrackingThreshold = 20000;
Tracker.MaxIterations = 10;
Tracker.LaserControlLine = 1; % AOM is line 1
Tracker.InitialPosition = handles.ImageAcquisition.CursorPosition;
Tracker.MaxCursorPosition = [2,2,100];
Tracker.MinCursorPosition = [-2,-2,0];

handles.Tracker = Tracker;



