function [varargout] = GalvoControlFunctions(varargin)

    hObject = varargin{2};
    eventdata = varargin{3};
    handles = varargin{4};
    
    switch varargin{1}
        case 'Initialize'
            [varargout{1}] = Initialize(hObject,eventdata,handles);
        case 'SliderUpdate'
            [varargout{1}] = SliderUpdate(hObject,eventdata,handles);
        case 'EditUpdate'
             [varargout{1}] = EditUpdate(hObject,eventdata,handles);
    end
end

function [handles] = Initialize(hObject,eventdata,handles)

    % configure the libs
    LibraryName = 'nidaqmx';
    LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
    HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

    % instantiate the driver
    ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
    
    % add analog out lines
    ni = ni.addAOLine('Dev2/ao0',0.000); % default 0.000V
    ni = ni.addAOLine('Dev2/ao1',0.000); % default 0.000V
    
    % update the A0 voltages
    ni.WriteAnalogOutAllLines;
    
    % set the max and min values of sliders to those of the NI card
    set(handles.sliderX,'Min',ni.AnalogOutMinVoltage,'Max',ni.AnalogOutMaxVoltage);
    set(handles.sliderY,'Min',ni.AnalogOutMinVoltage,'Max',ni.AnalogOutMaxVoltage);
    
    % update the X and Y edit boxes
    set(handles.editX,'String',sprintf('%1.3f',ni.AnalogOutVoltages(1)));
    set(handles.editY,'String',sprintf('%1.3f',ni.AnalogOutVoltages(2)));
    
    handles.ni = ni;
end

function [handles] = SliderUpdate(hObject,eventdata,handles)

    % get the current slider positions
    sX = get(handles.sliderX,'Value');
    sY = get(handles.sliderY,'Value');
    
    % update the ni values
    handles.ni.AnalogOutVoltages(1) = sX;
    handles.ni.AnalogOutVoltages(2) = sY;
    
    % update the X and Y edit boxes
    set(handles.editX,'String',sprintf('%1.3f',handles.ni.AnalogOutVoltages(1)));
    set(handles.editY,'String',sprintf('%1.3f',handles.ni.AnalogOutVoltages(2)));   
   
    % update the A0 voltages
    handles.ni.WriteAnalogOutAllLines;
end

function [handles] = EditUpdate(hObject,eventdata,handles)

    % get the current slider positions
    sX = get(handles.editX,'String');
    sY = get(handles.editY,'String');
    sX = str2double(sX);
    sY = str2double(sY);
    
    % error check to see if within allowed values
    if sX > handles.ni.AnalogOutMaxVoltage | sX < handles.ni.AnalogOutMinVoltage,
        errordlg('X value out of range');
        sX = handles.ni.AnalogOutVoltages(1);

    end
    
  if sY > handles.ni.AnalogOutMaxVoltage | sY < handles.ni.AnalogOutMinVoltage,
        errordlg('Y value out of range');
        sY = handles.ni.AnalogOutVoltages(2);

    end
    % update the ni values
    handles.ni.AnalogOutVoltages(1) = sX;
    handles.ni.AnalogOutVoltages(2) = sY;
    
    % update the X and Y edit boxes
    set(handles.sliderX,'Value',handles.ni.AnalogOutVoltages(1));
    set(handles.sliderY,'Value',handles.ni.AnalogOutVoltages(2));   
   
    % update the A0 voltages
    handles.ni.WriteAnalogOutAllLines;
    
    % format the edit boxes
    set(handles.editX,'String',sprintf('%1.3f',sX));
    set(handles.editY,'String',sprintf('%1.3f',sY));
end
    