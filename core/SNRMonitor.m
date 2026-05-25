classdef SNRMonitor < handle
    properties
        hFig
        hEnable
        hRecalculate
        hMode
        hSignalMethod
        hNoiseMethod
        hSmoothWindow
        hTimeWindow
        hTargetEnable
        hTargetSNR
        hAvgText
        hSNRText
        hSignalText
        hNoiseText
        hTraceAxes
        hSNRAxes
        hNoiseAxes
        hSignalAxes
        hLayoutControls = gobjects(0)
        ControlLayout = struct('handle',{},'row',{},'position',{})
        SignalWindow = []
        ReferenceWindow = []
        StopFcn = []
        AutoStopTriggered = false
        TraceHistory
        History
        FirstAvg = []
        FirstNoise = []
        FirstSNR = []
    end

    methods
        function obj = SNRMonitor()
            obj.reset();
            obj.buildFigure();
        end

        function show(obj)
            if obj.isOpen()
                set(obj.hFig,'Visible','on');
                figure(obj.hFig);
            else
                obj.buildFigure();
            end
        end

        function tf = isEnabled(obj)
            tf = obj.isOpen() && get(obj.hEnable,'Value') == 1;
        end

        function reset(obj)
            obj.History = struct('avg',[],'snr',[],'signal',[],'noise',[], ...
                'noiseRef',[],'snrRef',[]);
            obj.TraceHistory = struct('x',{{}},'y',{{}},'avg',[], ...
                'expType',{{}},'modeName',{{}});
            obj.FirstAvg = [];
            obj.FirstNoise = [];
            obj.FirstSNR = [];
            obj.AutoStopTriggered = false;
            if obj.isOpen()
                cla(obj.hTraceAxes);
                cla(obj.hSNRAxes);
                cla(obj.hNoiseAxes);
                cla(obj.hSignalAxes);
                obj.updateReadouts(NaN,NaN,NaN,NaN);
            end
        end

        function update(obj,x,y,avgIndex,expType,modeName)
            if ~obj.isEnabled()
                return;
            end
            obj.ensureTraceHistory();

            x = x(:);
            y = y(:);
            valid = isfinite(x) & isfinite(y);
            x = x(valid);
            y = y(valid);
            if numel(y) < 3
                return;
            end

            obj.storeTrace(x,y,avgIndex,expType,modeName);
            metric = obj.appendMetricFromTrace(x,y,avgIndex,expType,modeName);
            if isempty(metric)
                return;
            end
            obj.updateReferenceCurves();

            obj.drawTrace(x,y,metric);
            obj.drawHistory();
            obj.updateReadouts(avgIndex,metric.snr,metric.signal,metric.noise);
            obj.checkTargetSNR(metric.snr,avgIndex);
            drawnow limitrate;
        end

        function recalculate(obj)
            obj.ensureTraceHistory();
            obj.clearMetricHistory();
            lastMetric = [];
            lastTrace = [];
            for idx = 1:numel(obj.TraceHistory.avg)
                x = obj.TraceHistory.x{idx};
                y = obj.TraceHistory.y{idx};
                avgIndex = obj.TraceHistory.avg(idx);
                expType = obj.TraceHistory.expType{idx};
                modeName = obj.TraceHistory.modeName{idx};
                metric = obj.appendMetricFromTrace(x,y,avgIndex,expType,modeName);
                if ~isempty(metric)
                    lastMetric = metric;
                    lastTrace = struct('x',x,'y',y,'avgIndex',avgIndex);
                end
            end
            obj.updateReferenceCurves();

            if ~isempty(lastMetric)
                obj.drawTrace(lastTrace.x,lastTrace.y,lastMetric);
                obj.drawHistory();
                obj.updateReadouts(lastTrace.avgIndex,lastMetric.snr,lastMetric.signal,lastMetric.noise);
                drawnow limitrate;
            else
                obj.updateReadouts(NaN,NaN,NaN,NaN);
                cla(obj.hSNRAxes);
                cla(obj.hNoiseAxes);
                cla(obj.hSignalAxes);
            end
        end

        function pickSignalWindow(obj)
            obj.pickWindow('SignalWindow');
        end

        function pickReferenceWindow(obj)
            obj.pickWindow('ReferenceWindow');
        end
    end

    methods (Access = private)
        function buildFigure(obj)
            obj.hFig = figure('Visible','on','Position',[80,80,900,620], ...
                'MenuBar','none','Toolbar','figure','Name','SNR Monitor', ...
                'NumberTitle','off','CloseRequestFcn',@(h,e)set(h,'Visible','off'), ...
                'Resize','on');

            obj.hEnable = uicontrol(obj.hFig,'Style','checkbox','String','Enable', ...
                'Value',1,'Position',[12,586,70,22]);
            uicontrol(obj.hFig,'Style','pushbutton','String','Reset', ...
                'Position',[85,586,58,22],'Callback',@(h,e)obj.reset());
            uicontrol(obj.hFig,'Style','pushbutton','String','Save', ...
                'Position',[148,586,58,22],'Callback',@(h,e)obj.saveHistory());
            obj.hRecalculate = uicontrol(obj.hFig,'Style','pushbutton','String','Recalculate', ...
                'Position',[211,586,82,22],'Callback',@(h,e)obj.recalculate());

            uicontrol(obj.hFig,'Style','text','String','Mode', ...
                'HorizontalAlignment','left','Position',[310,588,40,16]);
            obj.hMode = uicontrol(obj.hFig,'Style','popupmenu', ...
                'String',{'Auto','Rabi','Ramsey','Hahn echo','ODMR', ...
                'XY6/sensing','Exp decay','Sin damp','Lorentz', ...
                'Smooth residual','Custom'}, ...
                'Position',[348,586,125,22]);

            obj.hAvgText = uicontrol(obj.hFig,'Style','text','String','Avg: --', ...
                'HorizontalAlignment','left','Position',[485,588,75,16]);
            obj.hSNRText = uicontrol(obj.hFig,'Style','text','String','SNR: --', ...
                'HorizontalAlignment','left','Position',[560,588,95,16]);
            obj.hSignalText = uicontrol(obj.hFig,'Style','text','String','Signal: --', ...
                'HorizontalAlignment','left','Position',[655,588,110,16], ...
                'ForegroundColor',[0.85,0.325,0.098],'FontWeight','bold');
            obj.hNoiseText = uicontrol(obj.hFig,'Style','text','String','Noise: --', ...
                'HorizontalAlignment','left','Position',[765,588,105,16]);

            uicontrol(obj.hFig,'Style','text','String','Signal', ...
                'HorizontalAlignment','left','Position',[12,554,55,16]);
            obj.hSignalMethod = uicontrol(obj.hFig,'Style','popupmenu', ...
                'String',{'Auto','Peak-valley','Signal-reference'}, ...
                'Position',[68,552,125,22]);
            uicontrol(obj.hFig,'Style','pushbutton','String','Pick signal', ...
                'Position',[198,552,85,22],'Callback',@(h,e)obj.pickSignalWindow());

            uicontrol(obj.hFig,'Style','text','String','Noise', ...
                'HorizontalAlignment','left','Position',[305,554,45,16]);
            obj.hNoiseMethod = uicontrol(obj.hFig,'Style','popupmenu', ...
                'String',{'Auto','Residual','Reference window','Time stability'}, ...
                'Position',[350,552,135,22]);
            uicontrol(obj.hFig,'Style','pushbutton','String','Pick ref', ...
                'Position',[490,552,70,22],'Callback',@(h,e)obj.pickReferenceWindow());

            uicontrol(obj.hFig,'Style','text','String','Smooth', ...
                'HorizontalAlignment','left','Position',[582,554,52,16]);
            obj.hSmoothWindow = uicontrol(obj.hFig,'Style','edit','String','5', ...
                'Position',[632,552,40,22]);
            uicontrol(obj.hFig,'Style','text','String','Time W', ...
                'HorizontalAlignment','left','Position',[690,554,52,16]);
            obj.hTimeWindow = uicontrol(obj.hFig,'Style','edit','String','8', ...
                'Position',[742,552,40,22]);
            obj.hTargetEnable = uicontrol(obj.hFig,'Style','checkbox','String','Auto stop', ...
                'Value',0,'Position',[790,552,72,22]);
            obj.hTargetSNR = uicontrol(obj.hFig,'Style','edit','String','10', ...
                'Position',[860,552,35,22]);

            obj.hTraceAxes = axes('Parent',obj.hFig,'Units','pixels','Position',[60,330,790,195]);
            obj.hSNRAxes = axes('Parent',obj.hFig,'Units','pixels','Position',[60,180,370,105]);
            obj.hNoiseAxes = axes('Parent',obj.hFig,'Units','pixels','Position',[480,180,370,105]);
            obj.hSignalAxes = axes('Parent',obj.hFig,'Units','pixels','Position',[60,45,790,90]);

            title(obj.hTraceAxes,'Current trace');
            title(obj.hSNRAxes,'SNR vs average');
            title(obj.hNoiseAxes,'Noise vs average');
            title(obj.hSignalAxes,'Signal vs average');
            obj.captureControlLayout();
            obj.layoutFigure();
            set(obj.hFig,'SizeChangedFcn',@(h,e)obj.layoutFigure());
            obj.updateReadouts(NaN,NaN,NaN,NaN);
        end

        function captureControlLayout(obj)
            controls = findall(obj.hFig,'Type','uicontrol');
            obj.hLayoutControls = controls(:);
            obj.ControlLayout = struct('handle',{},'row',{},'position',{});
            for idx = 1:numel(obj.hLayoutControls)
                pos = get(obj.hLayoutControls(idx),'Position');
                if pos(2) >= 570
                    row = 1;
                else
                    row = 2;
                end
                obj.ControlLayout(end+1) = struct( ...
                    'handle',obj.hLayoutControls(idx), ...
                    'row',row, ...
                    'position',pos);
            end
        end

        function layoutFigure(obj)
            if ~obj.isOpen()
                return;
            end

            figPos = get(obj.hFig,'Position');
            width = max(figPos(3),520);
            height = max(figPos(4),360);

            if figPos(3) ~= width || figPos(4) ~= height
                set(obj.hFig,'Position',[figPos(1),figPos(2),width,height]);
            end

            topRowY = height - 34;
            secondRowY = height - 68;
            for idx = 1:numel(obj.ControlLayout)
                if ~ishandle(obj.ControlLayout(idx).handle)
                    continue;
                end
                pos = obj.ControlLayout(idx).position;
                if obj.ControlLayout(idx).row == 1
                    pos(2) = topRowY;
                else
                    pos(2) = secondRowY;
                end
                set(obj.ControlLayout(idx).handle,'Position',pos);
            end

            marginLeft = 60;
            marginRight = 50;
            marginBottom = 45;
            gap = 45;
            plotTop = height - 95;
            plotWidth = max(width - marginLeft - marginRight,200);
            plotHeight = max(plotTop - marginBottom,230);

            signalHeight = max(70,round(plotHeight * 0.18));
            smallHeight = max(85,round(plotHeight * 0.25));
            traceHeight = max(120,plotHeight - signalHeight - smallHeight - 2 * gap);

            signalY = marginBottom;
            smallY = signalY + signalHeight + gap;
            traceY = smallY + smallHeight + gap;
            smallWidth = max((plotWidth - 50) / 2,120);

            set(obj.hTraceAxes,'Units','pixels','Position',[marginLeft,traceY,plotWidth,traceHeight]);
            set(obj.hSNRAxes,'Units','pixels','Position',[marginLeft,smallY,smallWidth,smallHeight]);
            set(obj.hNoiseAxes,'Units','pixels','Position',[marginLeft + smallWidth + 50,smallY,smallWidth,smallHeight]);
            set(obj.hSignalAxes,'Units','pixels','Position',[marginLeft,signalY,plotWidth,signalHeight]);
        end

        function tf = isOpen(obj)
            tf = ~isempty(obj.hFig) && ishandle(obj.hFig);
        end

        function storeTrace(obj,x,y,avgIndex,expType,modeName)
            obj.ensureTraceHistory();
            existingIdx = find(obj.TraceHistory.avg == avgIndex,1,'last');
            if isempty(existingIdx)
                existingIdx = numel(obj.TraceHistory.avg) + 1;
            end

            obj.TraceHistory.x{existingIdx} = x;
            obj.TraceHistory.y{existingIdx} = y;
            obj.TraceHistory.avg(existingIdx,1) = avgIndex;
            obj.TraceHistory.expType{existingIdx,1} = expType;
            obj.TraceHistory.modeName{existingIdx,1} = modeName;
        end

        function clearMetricHistory(obj)
            obj.History = struct('avg',[],'snr',[],'signal',[],'noise',[], ...
                'noiseRef',[],'snrRef',[]);
            obj.FirstAvg = [];
            obj.FirstNoise = [];
            obj.FirstSNR = [];
        end

        function ensureTraceHistory(obj)
            if isempty(obj.TraceHistory) || ~isstruct(obj.TraceHistory) || ...
                    ~isfield(obj.TraceHistory,'avg') || ~isfield(obj.TraceHistory,'x') || ...
                    ~isfield(obj.TraceHistory,'y') || ~isfield(obj.TraceHistory,'expType') || ...
                    ~isfield(obj.TraceHistory,'modeName')
                obj.TraceHistory = struct('x',{{}},'y',{{}},'avg',[], ...
                    'expType',{{}},'modeName',{{}});
            end
        end

        function metric = appendMetricFromTrace(obj,x,y,avgIndex,expType,modeName)
            metric = obj.computeMetric(x,y,expType,modeName);
            if ~isfinite(metric.signal)
                metric = [];
                return;
            end

            if isfinite(metric.noise) && metric.noise > 0
                metric.snr = abs(metric.signal) / metric.noise;
            else
                metric.snr = NaN;
            end

            if isempty(obj.FirstNoise) && isfinite(metric.noise) && metric.noise > 0
                obj.FirstAvg = max(avgIndex,1);
                obj.FirstNoise = metric.noise;
                obj.FirstSNR = metric.snr;
            end

            noiseRef = NaN;
            snrRef = NaN;
            if ~isempty(obj.FirstNoise) && avgIndex > 0
                noiseRef = obj.FirstNoise * sqrt(obj.FirstAvg / avgIndex);
                snrRef = obj.FirstSNR * sqrt(avgIndex / obj.FirstAvg);
            end

            obj.History.avg(end+1,1) = avgIndex;
            obj.History.snr(end+1,1) = metric.snr;
            obj.History.signal(end+1,1) = metric.signal;
            obj.History.noise(end+1,1) = metric.noise;
            obj.History.noiseRef(end+1,1) = noiseRef;
            obj.History.snrRef(end+1,1) = snrRef;
        end

        function updateReferenceCurves(obj)
            avg = obj.History.avg;
            noise = obj.History.noise;
            signal = obj.History.signal;
            obj.History.noiseRef = NaN(size(avg));
            obj.History.snrRef = NaN(size(avg));

            firstNoiseIdx = find(isfinite(noise) & noise > 0 & isfinite(avg) & avg > 0,1,'first');
            latestSignalIdx = find(isfinite(signal),1,'last');
            if isempty(firstNoiseIdx) || isempty(latestSignalIdx)
                return;
            end

            anchorAvg = avg(firstNoiseIdx);
            anchorNoise = noise(firstNoiseIdx);
            latestSignal = abs(signal(latestSignalIdx));
            obj.History.noiseRef = anchorNoise .* sqrt(anchorAvg ./ avg);
            obj.History.snrRef = latestSignal ./ obj.History.noiseRef;
        end

        function metric = computeMetric(obj,x,y,expType,modeName)
            metric = struct('signal',NaN,'noise',NaN,'fit',[],'residual',[], ...
                'signalWindow',obj.SignalWindow,'referenceWindow',obj.ReferenceWindow);

            mode = SNRMonitor.selectedPopup(obj.hMode);
            if strcmp(mode,'Auto')
                if strcmpi(expType,'Rabi')
                    mode = 'Rabi';
                elseif ~isempty(strfind(lower(expType),'ramsey')) || ...
                        ~isempty(strfind(lower(modeName),'ramsey'))
                    mode = 'Ramsey';
                elseif ~isempty(strfind(lower(expType),'hahn')) || ...
                        ~isempty(strfind(lower(expType),'echo')) || ...
                        ~isempty(strfind(lower(modeName),'hahn')) || ...
                        ~isempty(strfind(lower(modeName),'echo'))
                    mode = 'Hahn echo';
                elseif ~isempty(strfind(lower(modeName),'sweep'))
                    mode = 'ODMR';
                else
                    mode = 'Custom';
                end
            end

            fitMode = SNRMonitor.fitModeForMonitorMode(mode);
            signalMethod = SNRMonitor.selectedPopup(obj.hSignalMethod);
            noiseMethod = SNRMonitor.selectedPopup(obj.hNoiseMethod);
            if strcmp(signalMethod,'Auto')
                if strcmp(mode,'Rabi') || strcmp(mode,'Ramsey') || ...
                        strcmp(mode,'Smooth residual')
                    signalMethod = 'Peak-valley';
                else
                    signalMethod = 'Signal-reference';
                end
            end
            if strcmp(noiseMethod,'Auto')
                if ~isempty(fitMode)
                    noiseMethod = 'Residual';
                elseif strcmp(mode,'ODMR') && ~isempty(obj.ReferenceWindow)
                    noiseMethod = 'Reference window';
                else
                    noiseMethod = 'Residual';
                end
            end

            if strcmp(noiseMethod,'Residual') && ~isempty(fitMode)
                fitMetric = SNRMonitor.fitTraceModel(x,y,fitMode);
                if ~isempty(fitMetric)
                    metric.signal = fitMetric.signal;
                    metric.fit = fitMetric.fit;
                    metric.residual = y - metric.fit;
                    metric.noise = SNRMonitor.rmsNoise(metric.residual);
                    return;
                end
            end

            metric.signal = obj.computeSignal(y,signalMethod);
            switch noiseMethod
                case 'Reference window'
                    metric.noise = obj.referenceNoise(x,y);
                case 'Time stability'
                    metric.noise = obj.timeStabilityNoise(metric.signal);
                otherwise
                    smoothWindow = SNRMonitor.readPositiveInteger(obj.hSmoothWindow,5);
                    metric.fit = SNRMonitor.movingMean(y,smoothWindow);
                    metric.residual = y - metric.fit;
                    metric.noise = SNRMonitor.robustMad(metric.residual);
            end
        end

        function signal = computeSignal(obj,y,signalMethod)
            if strcmp(signalMethod,'Signal-reference') && ~isempty(obj.SignalWindow) && ~isempty(obj.ReferenceWindow)
                sig = SNRMonitor.windowValues(y,obj.SignalWindow);
                ref = SNRMonitor.windowValues(y,obj.ReferenceWindow);
                signal = mean(sig) - mean(ref);
                return;
            end

            if ~isempty(obj.SignalWindow) && ~isempty(obj.ReferenceWindow)
                sig = SNRMonitor.windowValues(y,obj.SignalWindow);
                ref = SNRMonitor.windowValues(y,obj.ReferenceWindow);
                signal = mean(sig) - mean(ref);
                return;
            end

            signal = SNRMonitor.percentile(y,90) - SNRMonitor.percentile(y,10);
        end

        function noise = referenceNoise(obj,x,y)
            if isempty(obj.ReferenceWindow)
                noise = NaN;
                return;
            end
            idx = SNRMonitor.windowIndices(numel(y),obj.ReferenceWindow);
            if numel(idx) < 3
                noise = NaN;
                return;
            end
            xr = x(idx);
            yr = y(idx);
            if numel(idx) >= 4
                p = polyfit(xr,yr,1);
                residual = yr - polyval(p,xr);
            else
                residual = yr - mean(yr);
            end
            noise = SNRMonitor.robustMad(residual);
        end

        function noise = timeStabilityNoise(obj,signal)
            timeWindow = SNRMonitor.readPositiveInteger(obj.hTimeWindow,8);
            previous = obj.History.signal;
            values = [previous; signal];
            if numel(values) < 3
                noise = NaN;
                return;
            end
            startIdx = max(1,numel(values)-timeWindow+1);
            recent = values(startIdx:end);
            noise = std(recent);
        end

        function drawTrace(obj,x,y,metric)
            cla(obj.hTraceAxes);
            plot(obj.hTraceAxes,x,y,'.-','Color',[0,0.447,0.741]);
            hold(obj.hTraceAxes,'on');
            if ~isempty(metric.fit)
                plot(obj.hTraceAxes,x,metric.fit,'-','Color',[0.15,0.15,0.15]);
            end
            obj.drawWindow(obj.hTraceAxes,x,y,obj.SignalWindow,[0.85,0.325,0.098]);
            obj.drawWindow(obj.hTraceAxes,x,y,obj.ReferenceWindow,[0.466,0.674,0.188]);
            hold(obj.hTraceAxes,'off');
            title(obj.hTraceAxes,'Current trace');
            xlabel(obj.hTraceAxes,'Sweep value');
            ylabel(obj.hTraceAxes,'Processed signal');
        end

        function drawWindow(obj,ax,x,y,window,color)
            if isempty(window)
                return;
            end
            idx = SNRMonitor.windowIndices(numel(y),window);
            if isempty(idx)
                return;
            end
            plot(ax,x(idx),y(idx),'.-','LineWidth',1.5,'Color',color);
        end

        function drawHistory(obj)
            avg = obj.History.avg;
            if isempty(avg)
                return;
            end

            cla(obj.hSNRAxes);
            plot(obj.hSNRAxes,avg,obj.History.snr,'b.-');
            hold(obj.hSNRAxes,'on');
            plot(obj.hSNRAxes,avg,obj.History.snrRef,'k--');
            latestIdx = find(isfinite(obj.History.snr),1,'last');
            if ~isempty(latestIdx)
                latestAvg = avg(latestIdx);
                latestSNR = obj.History.snr(latestIdx);
                plot(obj.hSNRAxes,latestAvg,latestSNR,'o', ...
                    'Color',[0.85,0.325,0.098], ...
                    'MarkerFaceColor',[0.85,0.325,0.098], ...
                    'MarkerSize',5);
                text(obj.hSNRAxes,latestAvg,latestSNR, ...
                    ['  ',SNRMonitor.formatValue(latestSNR)], ...
                    'Color',[0.85,0.325,0.098], ...
                    'FontWeight','bold', ...
                    'VerticalAlignment','bottom');
            end
            hold(obj.hSNRAxes,'off');
            xlabel(obj.hSNRAxes,'Average');
            ylabel(obj.hSNRAxes,'SNR');
            legend(obj.hSNRAxes,{'Actual','latest sig ref'},'Location','northwest');

            cla(obj.hNoiseAxes);
            plot(obj.hNoiseAxes,avg,obj.History.noise,'r.-');
            hold(obj.hNoiseAxes,'on');
            plot(obj.hNoiseAxes,avg,obj.History.noiseRef,'k--');
            hold(obj.hNoiseAxes,'off');
            xlabel(obj.hNoiseAxes,'Average');
            ylabel(obj.hNoiseAxes,'Noise');
            legend(obj.hNoiseAxes,{'Actual','1/sqrt(N) ref'},'Location','northwest');

            cla(obj.hSignalAxes);
            plot(obj.hSignalAxes,avg,obj.History.signal,'.-','Color',[0.466,0.674,0.188]);
            xlabel(obj.hSignalAxes,'Average');
            ylabel(obj.hSignalAxes,'Signal');
        end

        function updateReadouts(obj,avgIndex,snr,signal,noise)
            set(obj.hAvgText,'String',sprintf('Avg: %s',SNRMonitor.formatValue(avgIndex)));
            set(obj.hSNRText,'String',sprintf('SNR: %s',SNRMonitor.formatValue(snr)));
            set(obj.hSignalText,'String',sprintf('Signal: %s',SNRMonitor.formatValue(signal)));
            set(obj.hNoiseText,'String',sprintf('Noise: %s',SNRMonitor.formatValue(noise)));
        end

        function checkTargetSNR(obj,snr,avgIndex)
            if isempty(obj.hTargetEnable) || ~ishandle(obj.hTargetEnable) || ...
                    get(obj.hTargetEnable,'Value') == 0 || obj.AutoStopTriggered
                return;
            end
            target = str2double(get(obj.hTargetSNR,'String'));
            if isnan(target) || ~isfinite(target) || target <= 0 || ~isfinite(snr)
                return;
            end
            if snr >= target
                obj.AutoStopTriggered = true;
                if ~isempty(obj.StopFcn)
                    obj.StopFcn(snr,target,avgIndex);
                end
            end
        end

        function pickWindow(obj,propertyName)
            if ~obj.isOpen()
                return;
            end
            figure(obj.hFig);
            axes(obj.hTraceAxes);
            try
                pts = ginput(2);
            catch
                return;
            end
            if size(pts,1) < 2
                return;
            end
            lines = findobj(obj.hTraceAxes,'Type','line');
            if isempty(lines)
                return;
            end
            xData = get(lines(end),'XData');
            if isempty(xData)
                return;
            end
            x1 = min(pts(:,1));
            x2 = max(pts(:,1));
            idx = find(xData >= x1 & xData <= x2);
            if isempty(idx)
                [~,idx1] = min(abs(xData - x1));
                [~,idx2] = min(abs(xData - x2));
                idx = min(idx1,idx2):max(idx1,idx2);
            end
            obj.(propertyName) = [min(idx),max(idx)];
        end

        function saveHistory(obj)
            if isempty(obj.History.avg)
                return;
            end
            [fn,fp] = uiputfile('*.mat','Save SNR monitor history', ...
                ['SNRMonitor_',datestr(now,'yyyymmdd_HHMMSS'),'.mat']);
            if isequal(fn,0)
                return;
            end
            History = obj.History;
            TraceHistory = obj.TraceHistory;
            SignalWindow = obj.SignalWindow;
            ReferenceWindow = obj.ReferenceWindow;
            save(fullfile(fp,fn),'History','TraceHistory','SignalWindow','ReferenceWindow');
        end
    end

    methods (Static, Access = private)
        function s = selectedPopup(h)
            strings = get(h,'String');
            s = strings{get(h,'Value')};
        end

        function n = readPositiveInteger(h,defaultValue)
            n = str2double(get(h,'String'));
            if isnan(n) || ~isfinite(n) || n < 1
                n = defaultValue;
            end
            n = round(n);
        end

        function values = windowValues(y,window)
            idx = SNRMonitor.windowIndices(numel(y),window);
            values = y(idx);
        end

        function idx = windowIndices(n,window)
            if isempty(window)
                idx = [];
                return;
            end
            startIdx = max(1,min(n,round(window(1))));
            stopIdx = max(1,min(n,round(window(2))));
            idx = min(startIdx,stopIdx):max(startIdx,stopIdx);
        end

        function yfit = movingMean(y,window)
            window = max(1,min(window,numel(y)));
            half = floor(window/2);
            yfit = NaN(size(y));
            for ii = 1:numel(y)
                idx1 = max(1,ii-half);
                idx2 = min(numel(y),ii+half);
                yfit(ii) = mean(y(idx1:idx2));
            end
        end

        function noise = robustMad(values)
            values = values(isfinite(values));
            if numel(values) < 2
                noise = NaN;
                return;
            end
            med = median(values);
            noise = 1.4826 * median(abs(values - med));
            if noise <= 0
                noise = std(values);
            end
        end

        function noise = rmsNoise(values)
            values = values(isfinite(values));
            if numel(values) < 2
                noise = NaN;
                return;
            end
            noise = sqrt(mean(values(:).^2));
        end

        function fitMode = fitModeForMonitorMode(mode)
            fitMode = '';
            switch lower(strrep(mode,' ',''))
                case {'rabi','sindamp'}
                    fitMode = 'sindamp';
                case {'hahnecho','expdecay'}
                    fitMode = 'expdecay';
                case {'odmr','lorentz','lorenz'}
                    fitMode = 'lorentz';
            end
        end

        function metric = fitTraceModel(x,y,fitMode)
            metric = [];
            x = x(:);
            y = y(:);
            valid = isfinite(x) & isfinite(y);
            x = x(valid);
            y = y(valid);
            xSpan = max(x) - min(x);
            ySpan = max(y) - min(y);
            if numel(y) < 6 || xSpan == 0 || ySpan == 0
                return;
            end

            xs = (x - min(x)) ./ xSpan;
            switch fitMode
                case 'expdecay'
                    metric = SNRMonitor.fitExpDecay(xs,y);
                case 'sindamp'
                    metric = SNRMonitor.fitSinDamp(xs,y);
                case 'lorentz'
                    metric = SNRMonitor.fitLorentz(xs,y);
            end
        end

        function metric = fitExpDecay(x,y)
            tailCount = max(3,round(numel(y) * 0.2));
            c0 = median(y(end-tailCount+1:end));
            a0 = y(1) - c0;
            if abs(a0) < eps
                a0 = max(y) - min(y);
            end
            tau0 = 0.35;
            p0 = [c0,a0,log(tau0)];
            objective = @(p) sum((y - SNRMonitor.expDecayModel(p,x)).^2);
            p = SNRMonitor.safeFminsearch(objective,p0);
            yfit = SNRMonitor.expDecayModel(p,x);
            metric = struct('fit',yfit,'signal',abs(p(2)));
        end

        function yfit = expDecayModel(p,x)
            tau = max(exp(p(3)),1e-6);
            yfit = p(1) + p(2) .* exp(-x ./ tau);
        end

        function metric = fitSinDamp(x,y)
            c0 = mean(y);
            a0 = 0.5 * (max(y) - min(y));
            freq0 = SNRMonitor.estimateCycles(x,y - c0);
            phi0 = 0;
            tau0 = 1.2;
            p0 = [c0,a0,log(freq0),phi0,log(tau0)];
            objective = @(p) sum((y - SNRMonitor.sinDampModel(p,x)).^2);
            p = SNRMonitor.safeFminsearch(objective,p0);
            yfit = SNRMonitor.sinDampModel(p,x);
            metric = struct('fit',yfit,'signal',abs(p(2)));
        end

        function yfit = sinDampModel(p,x)
            cycles = min(max(exp(p(3)),0.05),30);
            tau = max(exp(p(5)),1e-6);
            yfit = p(1) + p(2) .* cos(2*pi*cycles*x + p(4)) .* exp(-x ./ tau);
        end

        function cycles = estimateCycles(x,y)
            y = y(:) - mean(y(:));
            n = numel(y);
            if n < 8
                cycles = 2;
                return;
            end
            spectrum = abs(fft(y));
            half = 2:floor(n/2);
            if isempty(half)
                cycles = 2;
                return;
            end
            [~,localIdx] = max(spectrum(half));
            bin = half(localIdx) - 1;
            cycles = max(bin / max(max(x) - min(x),eps),0.5);
            cycles = min(cycles,10);
        end

        function metric = fitLorentz(x,y)
            xs = x - mean(x);
            yMed = median(y);
            [yMin,minIdx] = min(y);
            [yMax,maxIdx] = max(y);
            if abs(yMin - yMed) >= abs(yMax - yMed)
                a0 = yMin - yMed;
                x0 = xs(minIdx);
            else
                a0 = yMax - yMed;
                x0 = xs(maxIdx);
            end
            gamma0 = 0.08;
            p0 = [yMed,0,a0,x0,log(gamma0)];
            objective = @(p) sum((y - SNRMonitor.lorentzModel(p,xs)).^2);
            p = SNRMonitor.safeFminsearch(objective,p0);
            yfit = SNRMonitor.lorentzModel(p,xs);
            metric = struct('fit',yfit,'signal',abs(p(3)));
        end

        function yfit = lorentzModel(p,x)
            gamma = max(exp(p(5)),1e-6);
            yfit = p(1) + p(2).*x + p(3) ./ (1 + ((x - p(4)) ./ gamma).^2);
        end

        function p = safeFminsearch(objective,p0)
            opts = optimset('Display','off','MaxIter',600,'MaxFunEvals',2500);
            try
                p = fminsearch(objective,p0,opts);
            catch
                p = p0;
            end
        end

        function p = percentile(values,percent)
            values = sort(values(isfinite(values)));
            if isempty(values)
                p = NaN;
                return;
            end
            if numel(values) == 1
                p = values(1);
                return;
            end
            pos = 1 + (percent/100) * (numel(values)-1);
            lo = floor(pos);
            hi = ceil(pos);
            if lo == hi
                p = values(lo);
            else
                p = values(lo) + (values(hi)-values(lo)) * (pos-lo);
            end
        end

        function s = formatValue(v)
            if ~isfinite(v)
                s = '--';
            elseif abs(v) >= 1000 || abs(v) < 0.001
                s = sprintf('%.3g',v);
            else
                s = sprintf('%.4g',v);
            end
        end
    end
end
