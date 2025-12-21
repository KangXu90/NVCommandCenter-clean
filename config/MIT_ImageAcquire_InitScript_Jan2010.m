function handles = MIT_ImageAcquire_InitScript_Jan2010(handles)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP NI              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% configure NIDAQ Driver Instance
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);


% add Clock Line
ni.addClockLine('Dev2/ctr1','/Dev2/PFI7');

% add Counter Line
ni.addCounterInLine('Dev2/ctr0','/Dev2/PFI0',1);


% add AO lines
ni.addAOLine('Dev2/ao0',0);
ni.addAOLine('Dev2/ao1',0);

% Write the AO
ni.WriteAnalogOutAllLines;

% send to the handles structure
handles.NI = ni;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP APT             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%First setup the server
APTServer = APTobj();
APTServer.initialize('MG17SYSTEM.MG17SystemCtrl.1',[],1001)

%Now the motor controller
interfaceAPTMotor = APTMotorController();
interfaceAPTMotor.initialize('MGMOTOR.MGMotorCtrl.1',40819122,1002)

%Now the strain gauge
APTSG = APTStrainGauge();
APTSG.initialize('MGPIEZO.MGPiezoCtrl.1',84824566,1003)

%Now the piezo driver
APTPiezoD = APTPiezoDriver();
APTPiezoD.strainGauge = APTSG;
APTPiezoD.initialize('MGPIEZO.MGPiezoCtrl.1',81824608,1004)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP ImageAcqusition HANDLES             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hookup the NI to the IA
handles.ImageAcquisition.interfaceNIDAQ = handles.NI;
handles.ImageAcquisition.interfaceAPTMotor = interfaceAPTMotor;
handles.ImageAcquisition.interfaceAPTPiezo = APTPiezoD;

%Default to the Motor controller
handles.ImageAcquisition.ZController = 'Motor';
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP CounterAcquisition %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init Counter
handles.Counter = CounterAcquisition();
handles.Counter.interfaceNIDAQ = handles.NI;
handles.Counter.DwellTime = 0.005;
handles.Counter.NumberOfSamples = 20;
handles.Counter.LoopsUntilTimeOut = 1000;
handles.Counter.CounterInLine = 1;
handles.Counter.CounterOutLine = 1;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP Tracking                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% PULSE GENERATOR %%%%%%%%%%%
PG = TekPulseGenerator('tcpip','172.16.1.183',4000);
PG.setClockRate(10e6);
PG.init();


%%%%% CONFIGURE TRACKER %%%%%
Tracker = TrackerMIT();
Tracker.hCounterAcquisition = handles.Counter;
Tracker.hwLaserController = PG;
Tracker.hImageAcquisition = handles.ImageAcquisition;
Tracker.InitialStepSize = [0.002,0.002,0.5];
Tracker.StepReductionFactor = [.5,.5,.5];
Tracker.MinimumStepSize = [0.0002,0.0002,0.02];
Tracker.TrackingThreshold = [1500];
Tracker.MaxIterations = [10];
Tracker.LaserControlLine = 14;
Tracker.InitialPosition = handles.ImageAcquisition.CursorPosition;
Tracker.MaxCursorPosition = [0.5,0.5,20];
Tracker.MinCursorPosition = [-0.5,-0.5,0];
Tracker.ZCorrection = [-0.01013 0.02713];

handles.Tracker = Tracker;

% set control lines controller
handles.controlLinesController = 'TekLines';