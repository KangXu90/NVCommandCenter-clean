function DrawSequence(SEQ, hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Written by Jeronimo Maze, July 2007 %%%%%%%%%%%%%%%%%%
%%%%%%%%%% Harvard University, Cambridge, USA  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global tmin tmax ScaleT bShowTimes bShowTypes;

if isempty(bShowTypes)
    bShowTypes = false;
end
if isempty(bShowTimes)
    bShowTimes = false;
end


Color = {'g','r','b','k','m','c','y','g','r','b','k','m','c','y'};

if numel(SEQ.CHN)== 0 cla(handles.axes1); return; end

for ichn = 1 :numel(SEQ.CHN)
    atmin(ichn) = min(SEQ.CHN(ichn).T);
    atmax(ichn) = max(SEQ.CHN(ichn).T + SEQ.CHN(ichn).DT);
end
tmin = min(atmin);
tmax = max(atmax);

[ScaleT ScaleStr] = GetScale(tmax);

ymin = -0.5;
ymax = (size(SEQ.CHN,2) -1)*1.5 + 1 + 0.5;

cla(handles.axes1);
for ichn = size(SEQ.CHN,2):-1:1
    PlotCHN(handles,SEQ,ichn,Color, tmin,tmax,ScaleT,ScaleStr);
end

xlim(ScaleT*[tmin tmax]);
ylim([ymin ymax]);

function PlotCHN(handles,SEQ,ichn,Color,tmin,tmax,ScaleT, ScaleStr)
global bShowTimes bShowTypes;

yLow = (ichn -1)*1.5;
yHigh = (ichn -1)*1.5 + 1;
s = 0:1/99:1;
one = ones(size(s));
t0 = tmin;
hold(handles.axes1,'on');
xlim(handles.axes1,'auto');
for irise = 1:SEQ.CHN(ichn).NRise %PLOT each rise
    t1 = SEQ.CHN(ichn).T(irise);
    dt = SEQ.CHN(ichn).DT(irise);
    t2 = t1 + dt;
    xL = t0 + (t1-t0)*s;
    yL = yLow*one;
    xLH = t1*one;
    yLH = yLow + (yHigh - yLow)*s;
    xH = t1 + (t2-t1)*s;
    yH = yHigh*one;
    xHL = t2*one;
    yHL = yHigh + (yLow - yHigh)*s;
    plot(handles.axes1,ScaleT*[xL xLH xH xHL],[yL yLH yH yHL],Color{ichn});
    t0 = t2;
    if bShowTimes
        text(ScaleT*xLH,(yL+yH)/2,...
            [' (' NiceNotation(xHL(1)-xLH(1)) ', ' NiceNotation(xLH(1)) ')'],'FontSize',8,'Parent',handles.axes1);
    end
    if bShowTypes
        text(ScaleT*xLH,yH+0.2, SEQ.CHN(ichn).Type(irise),'FontSize',8,'Parent',handles.axes1);
    end
end
xL = t2 + (tmax-t2)*s;
yL = yLow*one;
plot(handles.axes1,ScaleT*xL,yL,Color{ichn});
hold(handles.axes1,'off');
text(ScaleT*(tmin+0.01*(tmax-tmin)),yLow+0.5,sprintf('PB%.0f',SEQ.CHN(ichn).PBN),'Color',Color{ichn},'Parent',handles.axes1);
xlabel(ScaleStr)


function [ScaleT, ScaleStr] = GetScale(tmax)
if tmax > 0 & tmax <= 100e-12
    ScaleT = 1e12;
    ScaleStr = 'ps';
elseif tmax > 100e-12 & tmax <= 100e-9
    ScaleT = 1e9;
    ScaleStr = 'ns';
elseif tmax > 100e-9 & tmax <= 100e-6
    ScaleT = 1e6;
    ScaleStr = '{\mu}s';
elseif tmax > 100e-6 & tmax <= 100e-3
    ScaleT = 1e3;
    ScaleStr = 'ms';
elseif tmax > 100e-3 & tmax <= 100
    ScaleT = 1;
    ScaleStr = 's';
end

