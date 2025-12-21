function [hObject,handles] = MIT_ImageAcquire_InitScript(hObject,handles)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP NI              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % configure NIDAQ Driver Instance
        LibraryName = 'nidaqmx';
        LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
        HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
        ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
        
        % add Counter Line
        ni.addCounterInLine('Dev2/ctr0','/Dev2/PFI0');

        % add Clock Line
        ni.addClockLine('Dev2/ctr1','/Dev2/PFI7');

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

        hAPT = AptController();

        try,
            hAPT.Initialize();
        catch ME
                h=warndlg({['Error:',ME.identifier],'Could not initialize ThorLabs APT Controller.'},'Warning!','modal');
                waitfor(h);
                delete(hAPT);   
                hAPT = [];
        end

        handles.APT = hAPT;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP ImageAcqusition HANDLES             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % hookup the NI to the IA
        handles.ImageAcquisition.interfaceNIDAQ = handles.NI;
        handles.ImageAcquisition.interfaceAPT = handles.APT;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP CounterAcquisition %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init Counter
handles.Counter = CounterAcquisition();
handles.Counter.interfaceNIDAQ = handles.NI;
handles.Counter.DwellTime = 0.005;
handles.Counter.NumberOfSamples = 100;
handles.Counter.LoopsUntilTimeOut = 100;
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
Tracker.InitialStepSize = [0.005,0.005,.002];
Tracker.StepReductionFactor = [.5,.5,.5];
Tracker.MinimumStepSize = [0.0005,0.0005,0.0001];
Tracker.TrackingThreshold = [1500];
Tracker.MaxIterations = [10];
Tracker.LaserControlLine = 2;
Tracker.InitialPosition = handles.ImageAcquisition.CursorPosition;
Tracker.MaxCursorPosition = [0.5,0.5,2.0];
Tracker.MinCursorPosition = [-0.5,-0.5,0];

handles.Tracker = Tracker;

% set control lines controller
handles.controlLinesController = 'TekLines';