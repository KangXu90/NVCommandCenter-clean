function [] = EditSequenceFunctions(varargin)

action = varargin{1};


switch action
    case 'Init'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        PSeq = handles.PSeq;
        Init(hObject,handles,PSeq);
    case 'DrawSequence'
        handles = varargin{4};
        PSeq = handles.PSeq;
        DrawSequence(handles.axes1,PSeq,[]);
        
    case 'AddChannel'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        handles.PSeq.addChannel();
        
    case 'EventPSChangeState'
        hObject = varargin{4};
        handles = guidata(hObject);
        PSeq = handles.PSeq;
        hAxes = handles.axes1;
        
        
        DrawSequence(handles.axes1,PSeq,[]);
        UpdateChannelsPopup(handles.popupChannel,PSeq);

end

function Init(hObject,handles,PSeq)


function DrawSequence(hAxes,PSeq,options)

    if isempty(options),
        options.showTypes = 0;
        options.showTimes = 0;
        options.verticalSpacing = 1.5;
        options.xRes = 100;
    end
    
    % if there are no channels to plot, return
    if numel(PSeq.Channels)== 0, cla(hAxes); return; end
    
    % use HSV colormap
    Colors = hsv(numel(PSeq.Channels));
    
    % Get Scaling
    [ScaleT, ScaleStr] = GetScale(PSeq.GetMaxRiseTime());
    
    tmin = PSeq.GetMinRiseTime();
    tmax = PSeq.GetMaxRiseTime();
    
    % scale the y-axis
    ymin = -0.5;
    ymax = options.verticalSpacing*numel(PSeq.Channels);
    
    % clear the axes before replotting
    cla(hAxes);
    
    % loop over all Pulse Channels
    for ichn = numel(PSeq.Channels):-1:1

            % set high and low line values for the channel
            yLow = (ichn -1)*options.verticalSpacing ;
            yHigh = (ichn -1)*options.verticalSpacing  + 1;
            
            % set horizontal spacing
            s = linspace(0,1,options.xRes);
            
            one = ones(size(s));
            t0 = tmin;
            hold(hAxes,'on');
            xlim(hAxes,'auto');

        % code from Jero's DrawSequence function
        yL = 0;
        for irise = 1:PSeq.Channels(ichn).NumberOfRises %PLOT each rise
            t1 = PSeq.Channels(ichn).RiseTimes(irise);
            dt = PSeq.Channels(ichn).RiseDurations(irise);
            t2 = t1 + dt;
            xL = t0 + (t1-t0)*s;
            yL = yLow*one;
            xLH = t1*one;
            yLH = yLow + (yHigh - yLow)*s;
            xH = t1 + (t2-t1)*s;
            yH = yHigh*one;
            xHL = t2*one;
            yHL = yHigh + (yLow - yHigh)*s;
            plot(hAxes,ScaleT*[xL xLH xH xHL],[yL yLH yH yHL],Colors(ichn,:));
            t0 = t2;
            if options.bShowTimes
                text(ScaleT*xLH,(yL+yH)/2,...
                    [' (' NiceNotation(xHL(1)-xLH(1)) ', ' NiceNotation(xLH(1)) ')'],'FontSize',8,'Parent',hAxes);
            end
            if bShowTypes
                text(ScaleT*xLH,yH+0.2, PSeq.Channels(ichn).RiseTypes(irise),'FontSize',8,'Parent',hAxes);
            end
        end
        
        if yL > 0, % conditional statement will only plot if there is something to plot
            xL = t2 + (tmax-t2)*s;
            yL = yLow*one;
            plot(hAxes,ScaleT*xL,yL,Colors(ichn,:));
            hold(hAxes,'off');
            text(ScaleT*(tmin+0.01*(tmax-tmin)),yLow+0.5,sprintf('HW Channel:%d',PSeqw.Channels(ichn).HWChannel),'Color',Colors(ichn,:),'Parent',hAxes);
            xlabel(ScaleStr);
        end
    end

    if abs(tmax - tmin) < 1e14,
        xlim(ScaleT*[tmin tmax]);
    end
    ylim([ymin ymax]);

    
function [] = UpdateChannelsPopup(hPop,PSeq)
    s = {'Channel N'};
    for k=1:numel(PSeq.Channels),
        s{k+1} = ['Channel ',num2str(k)];
    end
    set(hPop,'String',s);
    set(hPop,'Value',1);

    
    
function [ScaleT, ScaleStr] = GetScale(tmax)
if tmax >= 0 & tmax <= 100e-12
    ScaleT = 1e12;
    ScaleStr = 'ps';
elseif tmax > 100e-12 & tmax <= 100e-9
    ScaleT = 1e9;
    ScaleStr = 'ns';
elseif tmax > 100e-9 & tmax <= 100e-6
    ScaleT = 1e6;
    ScaleStr = 'us';
elseif tmax > 100e-6 & tmax <= 100e-3
    ScaleT = 1e3;
    ScaleStr = 'ms';
elseif tmax > 100e-3 & tmax <= 100
    ScaleT = 1;
    ScaleStr = 's';
end
    