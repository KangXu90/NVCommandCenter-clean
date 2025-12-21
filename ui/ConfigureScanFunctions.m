function [varargout] = ConfigureScanFunctions(varargin)

task = varargin{1};
hObject = varargin{2};
eventdata = varargin{3};
handles = varargin{4};

switch task,
    case 'Initialize'
        scan = handles.ConfocalScan;
        
        set(handles.minX,'String',scan.MinValues(1));
        set(handles.minY,'String',scan.MinValues(2));
        set(handles.minZ,'String',scan.MinValues(3));

        set(handles.maxX,'String',scan.MaxValues(1));
        set(handles.maxY,'String',scan.MaxValues(2));
        set(handles.maxZ,'String',scan.MaxValues(3));
        
        set(handles.pointsX,'String',scan.NumPoints(1));
        set(handles.pointsY,'String',scan.NumPoints(2));
        set(handles.pointsZ,'String',scan.NumPoints(3));
        
        set(handles.offsetX,'String',scan.OffsetValues(1));
        set(handles.offsetY,'String',scan.OffsetValues(2));
        set(handles.offsetZ,'String',scan.OffsetValues(3));

        set(handles.dwell,'String',scan.DwellTime);
        
        set(handles.enableX,'Value',scan.bEnable(1));
        set(handles.enableY,'Value',scan.bEnable(2));
        set(handles.enableZ,'Value',scan.bEnable(3));
        
        varargout{1} = scan;
    case '2D'
       
        scan.MinValues = [-5 -5 0];
        scan.MaxValues = [5 5 0.1];
        scan.NumPoints = [100 100 100];
        scan.OffsetValues = [0 0 0];
        scan.DwellTime = 0.005;
        scan.bEnable = [1 1 0];
        
        set(handles.minX,'String',scan.MinValues(1));
        set(handles.minY,'String',scan.MinValues(2));
        set(handles.minZ,'String',scan.MinValues(3));

        set(handles.maxX,'String',scan.MaxValues(1));
        set(handles.maxY,'String',scan.MaxValues(2));
        set(handles.maxZ,'String',scan.MaxValues(3));
        
        set(handles.pointsX,'String',scan.NumPoints(1));
        set(handles.pointsY,'String',scan.NumPoints(2));
        set(handles.pointsZ,'String',scan.NumPoints(3));
        
        set(handles.offsetX,'String',scan.OffsetValues(1));
        set(handles.offsetY,'String',scan.OffsetValues(2));
        set(handles.offsetZ,'String',scan.OffsetValues(3));

        set(handles.dwell,'String',scan.DwellTime);
        
        set(handles.enableX,'Value',scan.bEnable(1));
        set(handles.enableY,'Value',scan.bEnable(2));
        set(handles.enableZ,'Value',scan.bEnable(3));
        
        varargout{1} = scan;
        
    case 'Z'
        
              scan.MinValues = [-5 -5 0];
        scan.MaxValues = [5 5 0.1];
        scan.NumPoints = [100 100 100];
        scan.OffsetValues = [0 0 0];
        scan.DwellTime = 0.01;
        scan.bEnable = [0 0 1];
        
        set(handles.minX,'String',scan.MinValues(1));
        set(handles.minY,'String',scan.MinValues(2));
        set(handles.minZ,'String',scan.MinValues(3));

        set(handles.maxX,'String',scan.MaxValues(1));
        set(handles.maxY,'String',scan.MaxValues(2));
        set(handles.maxZ,'String',scan.MaxValues(3));
        
        set(handles.pointsX,'String',scan.NumPoints(1));
        set(handles.pointsY,'String',scan.NumPoints(2));
        set(handles.pointsZ,'String',scan.NumPoints(3));
        
        set(handles.offsetX,'String',scan.OffsetValues(1));
        set(handles.offsetY,'String',scan.OffsetValues(2));
        set(handles.offsetZ,'String',scan.OffsetValues(3));

        set(handles.dwell,'String',scan.DwellTime);
        
        set(handles.enableX,'Value',scan.bEnable(1));
        set(handles.enableY,'Value',scan.bEnable(2));
        set(handles.enableZ,'Value',scan.bEnable(3));
        
        varargout{1} = scan;
    case 'Save'
                  
        MinVal(1) = str2num(get(handles.minX,'String'));
        MinVal(2) = str2num(get(handles.minY,'String'));
        MinVal(3) = str2num(get(handles.minZ,'String'));
        
        MaxVal(1) = str2num(get(handles.maxX,'String'));
        MaxVal(2) = str2num(get(handles.maxY,'String'));
        MaxVal(3) = str2num(get(handles.maxZ,'String'));
        
        NumPoints(1) = str2num(get(handles.pointsX,'String'));
        NumPoints(2) = str2num(get(handles.pointsY,'String'));
        NumPoints(3) = str2num(get(handles.pointsZ,'String'));
        
        Offset(1) = str2num(get(handles.offsetX,'String'));
        Offset(2) = str2num(get(handles.offsetY,'String'));
        Offset(3) = str2num(get(handles.offsetZ,'String'));
        
        DwellTime = str2num(get(handles.dwell,'String'));
        
        bEnable(1) = get(handles.enableX,'Value');
        bEnable(2) = get(handles.enableY,'Value');
        bEnable(3) = get(handles.enableZ,'Value');
     
        handles.ConfocalScan.MinValues = MinVal;
        handles.ConfocalScan.MaxValues = MaxVal;
        handles.ConfocalScan.NumPoints = NumPoints;
        handles.ConfocalScan.OffsetValues = Offset;
        handles.ConfocalScan.DwellTime = DwellTime;
        handles.ConfocalScan.bEnable = bEnable;
        
        guidata(hObject,handles);
end