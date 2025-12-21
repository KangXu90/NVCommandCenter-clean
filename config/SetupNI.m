function [niHandle] = SetupNI();

% quick and dirty tool for getting the NI up and running for imaging
%
% hopefully this won't exist for too long and a more elegant solution can
% be implemented

%%
% configure NIDAQ Driver Instance
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
%%
% add Counter Line
ni.addCounterInLine('Dev2/ctr0','/Dev2/PFI0');

% add Clock Line
ni.addClockLine('Dev2/ctr1','/Dev2/PFI7');

% add AO lines
ni.addAOLine('Dev2/ao0',0);
ni.addAOLine('Dev2/ao1',0);

% Write the AO
ni.WriteAnalogOutAllLines;

niHandle = ni;