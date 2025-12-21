function RefreshEditSeqForm(what,hObject, eventdata, handles, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Written by Jeronimo Maze, July 2007 %%%%%%%%%%%%%%%%%%
%%%%%%%%%% Harvard University, Cambridge, USA  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global gEditSEQ;

SEQ = gEditSEQ;

switch what
    case 'All'
        RefreshAll(SEQ, hObject, eventdata, handles, varargin);
    case 'CleanFormA'
        CleanFormA(hObject, eventdata, handles, varargin);
    case 'Channel'
        Channel(SEQ,hObject, eventdata, handles, varargin);
    case 'Rise'
        Rise(SEQ,hObject, eventdata, handles, varargin);
    case 'PBN'
        PBN(SEQ,hObject, eventdata, handles, varargin);
    case 'ButtonDown'
        ButtonDown(SEQ,hObject, eventdata, handles, varargin);
    otherwise
end


function ButtonDown(SEQ,hObject, eventdata, handles, varargin)
global gEditSEQ;

bZoom = get(handles.bZoom,'Value');
bDeleteSelectedPulses = get(handles.bDeleteSelectedPulses,'Value');
bDeletePulse = get(handles.bDeletePulse,'Value');

if bZoom
    ZoomEditSEQ('Mouse',hObject, eventdata, handles);
elseif bDeletePulse
	CP = get(handles.axes1,'CurrentPoint');
	x = CP(1,1);  
    y = CP(1,2);  
    chn = round((y-0.5)/1.5 + 1);
    Rise = GetRisefromX(SEQ,chn,x);
    gEditSEQ = DelRiseII(Rise,chn,SEQ,hObject, eventdata, handles);
    DrawSequence(gEditSEQ, hObject, eventdata, handles);
    
    set(handles.Channel,'Value',chn+1);
    FillUpPBN(chn, SEQ, hObject, eventdata, handles, varargin)
    FillUpRise(chn,Rise,SEQ, hObject, eventdata, handles, varargin);
    
elseif bDeleteSelectedPulses
	CP = get(handles.axes1,'CurrentPoint');
	x = CP(1,1);  
    y = CP(1,2);  
    T = x;
    chn = round((y-0.5)/1.5 + 1);
    gEditSEQ = DelFromT(T,chn,SEQ,hObject, eventdata, handles);
    DrawSequence(gEditSEQ, hObject, eventdata, handles);
    
    set(handles.Channel,'Value',chn+1);
    FillUpPBN(chn, SEQ, hObject, eventdata, handles, varargin)
    FillUpRise(chn,1,SEQ, hObject, eventdata, handles, varargin);
    
else
	CP = get(handles.axes1,'CurrentPoint');
	x = CP(1,1);  
    y = CP(1,2);  
    chn = round((y-0.5)/1.5 + 1);
    Rise = GetRisefromX(SEQ,chn,x);
    set(handles.Channel,'Value',chn+1);
    FillUpPBN(chn, SEQ, hObject, eventdata, handles, varargin)
    FillUpRise(chn,Rise,SEQ, hObject, eventdata, handles, varargin);
end

function Rise = GetRisefromX(SEQ,chn,x)
global ScaleT;
x = x/ScaleT;
Rise = 1;
minD = Inf;
for irise = 1:SEQ.CHN(chn).NRise
    D = min([abs(x - SEQ.CHN(chn).T(irise)) abs(x -  SEQ.CHN(chn).T(irise) - SEQ.CHN(chn).DT(irise))]);
    if D<minD
        Rise = irise;
        minD = D;
    end
end


function PBN(SEQ,hObject, eventdata, handles, varargin);
Rise = get(handles.Rise1,'Value')-1;
chn = get(handles.Channel,'Value')-1;
FillUpPBN(chn, SEQ, hObject, eventdata, handles, varargin)
FillUpRise(chn,Rise,SEQ, hObject, eventdata, handles, varargin);


function Rise(SEQ,hObject, eventdata, handles, varargin);
Rise = get(handles.Rise1,'Value')-1;
chn = get(handles.Channel,'Value')-1;
Rise
chn
SEQ.CHN(chn)
Rise
FillUpRise(chn,Rise,SEQ, hObject, eventdata, handles, varargin);

function Channel(SEQ,hObject, eventdata, handles, varargin)
chn = get(handles.Channel,'Value')-1;
FillUpPBN(chn,SEQ, hObject, eventdata, handles, varargin);


function CleanFormA(hObject, eventdata, handles, varargin)

set(handles.Channel,'String','Channel');
set(handles.PBN1,'Value',1);
set(handles.Rise1,'Value',1);
set(handles.TimeON1,'String','TimeON');
set(handles.DT1,'String','DT');
set(handles.Type1,'String','Type');
set(handles.DelayON1,'String','Edit Text');
set(handles.DelayOFF1,'String','Edit Text');
set(handles.risePhase,'String','Phase');



function RefreshAll(SEQ, hObject, eventdata, handles, varargin)

Nchn = numel(SEQ.CHN);
if Nchn < 1 return; end

StrL{1} = 'Channel N';
for i=2:Nchn+1
    StrL{i} = ['Channel ' num2str(i-1)];
end
set(handles.Channel,'String',StrL);
set(handles.Channel,'Value',2);

if Nchn>=1 FillUpPBN(1,SEQ, hObject, eventdata, handles, varargin); end

function FillUpRise(chn,Rise,SEQ, hObject, eventdata, handles, varargin)
if SEQ.CHN(chn).NRise>= Rise
    set(handles.TimeON1,'String',SEQ.CHN(chn).T(Rise));
    set(handles.DT1,'String',SEQ.CHN(chn).DT(Rise));
    set(handles.Type1,'String',SEQ.CHN(chn).Type(Rise));
    set(handles.risePhase,'String',SEQ.CHN(chn).Phase(Rise));
    set(handles.Rise1,'Value',Rise+1);
end

function FillUpPBN(which, SEQ, hObject, eventdata, handles, varargin)
%SEQ.CHN(which).PBN
set(handles.PBN1,'Value',SEQ.CHN(which).PBN+2);
if SEQ.CHN(which).NRise>= 1
    NRise = 1;
    StrList = cellstr(num2str([0:SEQ.CHN(which).NRise]'));
    StrList{1} ='RN';
    set(handles.Rise1,'String',StrList);
    set(handles.Rise1,'Value',NRise+1);
    set(handles.TimeON1,'String',SEQ.CHN(which).T(NRise));
    set(handles.DT1,'String',SEQ.CHN(which).DT(NRise));
    set(handles.risePhase,'String',SEQ.CHN(which).Phase(NRise));
    set(handles.Type1,'String',SEQ.CHN(which).Type(NRise));
end
set(handles.DelayON1,'String',SEQ.CHN(which).Delays(1));
set(handles.DelayOFF1,'String',SEQ.CHN(which).Delays(2));

function SEQ = DelFromT(T,chn,SEQ,hObject, eventdata, handles)
global tmin tmax;
global ScaleT;
disp('Hey')
T = T/ScaleT;

for ichn=1:numel(SEQ.CHN)
    iDel = find(SEQ.CHN(ichn).T>=T);
    SEQ.CHN(ichn).T(iDel) = [];
    SEQ.CHN(ichn).DT(iDel) = [];
    SEQ.CHN(ichn).Type(iDel) = [];
    SEQ.CHN(ichn).Phase(iDel) = [];
    SEQ.CHN(ichn).NRise = length(SEQ.CHN(ichn).T);
end
SEQ.CHN(1)
NRise = SEQ.CHN(chn).NRise;
StrList = cellstr(num2str([0:SEQ.CHN(chn).NRise]'));
StrList{1} ='RN';
set(handles.Rise1,'String',StrList);
set(handles.Rise1,'Value',1+1);

function SEQ = DelRiseII(Rise,chn,SEQ,hObject, eventdata, handles)
global tmin tmax;
SEQ.CHN(chn).T(Rise) = [];
SEQ.CHN(chn).DT(Rise) = [];
SEQ.CHN(chn).Type(Rise) = [];
SEQ.CHN(chn).Phase(Rise) = [];
SEQ.CHN(chn).NRise = SEQ.CHN(chn).NRise - 1;

NRise = SEQ.CHN(chn).NRise;
StrList = cellstr(num2str([0:SEQ.CHN(chn).NRise]'));
StrList{1} ='RN';
set(handles.Rise1,'String',StrList);
if Rise > NRise, Rise = NRise; end
set(handles.Rise1,'Value',Rise+1);

function Rise = GetRise(handles)
StrList = get(handles.Rise1,'String');
Value = get(handles.Rise1,'Value');
Rise =  str2num(StrList{Value});

