
function [hObject,handles] = myInitScript(hObject,handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the signal generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handles.SignalGenerator = AgilentSignalGenerator('tcpip','172.16.1.184',7777);
    %handles.SignalGenerator.reset();
    handles.SignalGenerator.setModulationOff();
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the pulse generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        LibraryName = 'pb';
        LibraryFile = 'C:\SpinCore\SpinAPI\dll\spinapi.dll';
        HeaderFile = 'C:\SpinCore\SpinAPI\dll\spinapi.h';

        handles.PulseGenerator = SpinCorePulseGenerator();
        handles.PulseGenerator.Initialize(LibraryFile,HeaderFile,LibraryName);
        
        % set PG clock rate to 1MHz
        handles.PulseGenerator.setClockRate(300e6);

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

        handles.Counter.hwHandle.addCounterInLine('Dev2/ctr0','/Dev2/PFI0');
        % add Counter Line
        handles.Counter.hwHandle.addCounterInLine('Dev2/ctr1','/Dev2/PFI7');  

        % add Clock Line
        handles.Counter.hwHandle.addClockLine('Dev2/ctr1','/Dev2/PFI7');
        % add Clock Line
        handles.Counter.hwHandle.addClockLine('Ext','/Dev2/PFI0');
        
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init tracker
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.Tracker = TrackerMIT();
handles.Tracker.hCounterAcquisition = handles.TrackCounter;
handles.Tracker.hwLaserController = handles.PulseGenerator;
handles.Tracker.LaserControlLine = 2;

         

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% configure the tracking algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
            colormap(handles.axesConfocal,'bone');
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

%%% HW Lines
handles.HWLineFunction = 'TekLines';
