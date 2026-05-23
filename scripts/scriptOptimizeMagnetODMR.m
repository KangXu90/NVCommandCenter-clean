%% Optimize magnet position using the current NVCommandCenter ODMR setup
% Run this script from MATLAB after NVCommandCenter is open and configured
% for an ODMR measurement. The script connects the Thorlabs magnet motors,
% moves through the position grid below, runs the current NVCommandCenter
% experiment at each point, scores the ODMR trace, and saves a summary.

%% User settings
cfg.xList = 12.0:0.5:13;
cfg.yList = 10.5:0.5:11.5;
cfg.zList = NaN; % NaN disables Z movement and keeps the current Z position.

cfg.speed.X = 0.1;
cfg.speed.Y = 0.1;
cfg.speed.Z = 0.1;

cfg.settleSeconds = 1.0;
cfg.moveBackToBest = false;
cfg.outputFolder = fullfile(pwd,'data','magnet_odmr_optimization');
cfg.stopFile = fullfile(cfg.outputFolder,'STOP_MAGNET_ODMR.txt'); %是否有更好的stop方式，更简单，直接的

% Motor serial order follows the current magnetalignment app convention:
% detected device order is X, Z, Y.
cfg.motorAliases = {'X','Z','Y'};

%% Setup
% Because this file is a script, variables from a previous interrupted run
% can remain in the base workspace and keep motors connected. Clean them up
% before reconnecting.
try
    if exist('motorAcq','var')
        disconnectMagnetMotors(motorAcq);
        clear motorAcq;
    end
catch
end
try
    if exist('cleanupObj','var')
        clear cleanupObj;
    end
catch
end

if ~exist(cfg.outputFolder,'dir')
    mkdir(cfg.outputFolder);
end

hFig = findall(0,'Name','NVCommandCenter');
if isempty(hFig)
    error('NVCommandCenter is not open. Open and configure it before running this script.');
end
hFig = hFig(1);
handles = guidata(hFig); %这一个什么意思

motorAcq = connectMagnetMotors(cfg);
cleanupObj = onCleanup(@()disconnectMagnetMotors(motorAcq));
try
    setMagnetSpeeds(motorAcq,cfg.speed);

    positions = makePositionList(cfg.xList,cfg.yList,cfg.zList);
    numPositions = size(positions,1);
    results = initResults(numPositions);
    summaryCsv = fullfile(cfg.outputFolder,['magnet_odmr_summary_',datestr(now,'yyyymmdd_HH-MM-SS'),'.csv']);

    fprintf('Starting magnet ODMR optimization: %d positions\n',numPositions);
    fprintf('Output folder: %s\n',cfg.outputFolder);
    fprintf('Graceful stop: create this file to stop after the current point finishes:\n  %s\n',cfg.stopFile);

    %% Main loop
    for idx = 1:numPositions
        if exist(cfg.stopFile,'file')
            fprintf('Stop file detected before position %d. Exiting gracefully.\n',idx);
            break;
        end
        pos = positions(idx,:);
        fprintf('[%d/%d] Moving magnet to X=%.4f Y=%.4f Z=%s\n',idx,numPositions,pos(1),pos(2),formatPosition(pos(3)));
        moveMagnetTo(motorAcq,pos);
        pause(cfg.settleSeconds);

        handles = guidata(hFig);
        startNVExperiment(hFig,handles);
        handles = guidata(hFig);

        [x,y] = getODMRTrace(handles);
        metrics = scoreODMRTrace(x,y);

        results.PositionIndex(idx) = idx;
        results.X(idx) = pos(1);
        results.Y(idx) = pos(2);
        results.Z(idx) = pos(3);
        results.Baseline(idx) = metrics.baseline;
        results.DipHeight(idx) = metrics.height;
        results.Contrast(idx) = metrics.contrast;
        results.Linewidth(idx) = metrics.linewidth;
        results.Noise(idx) = metrics.noise;
        results.SNR(idx) = metrics.snr;
        results.Score(idx) = metrics.score;
        results.Center(idx) = metrics.center;
        results.FitR2(idx) = metrics.fitR2;
        results.RawX{idx} = vectorToCsvString(x);
        results.RawY{idx} = vectorToCsvString(y);

        pointBaseName = sprintf('magnet_odmr_%04d_X%.4f_Y%.4f_Z%s',idx,pos(1),pos(2),formatPosition(pos(3)));
        pointPngFile = fullfile(cfg.outputFolder,[pointBaseName,'.png']);
        results.PngFile{idx} = pointPngFile;
        saveODMRPointPlot(x,y,metrics,pos,idx,numPositions,pointPngFile);

        fprintf('  score=%.4g snr=%.4g contrast=%.4g linewidth=%.4g center=%.6g\n',...
            metrics.score,metrics.snr,metrics.contrast,metrics.linewidth,metrics.center);

        summaryTable = struct2table(results);
        writetable(summaryTable,summaryCsv);
    end

    summaryTable = struct2table(results);
    validScores = isfinite(summaryTable.Score);
    if any(validScores)
        validIndices = find(validScores);
        [~,bestLocalIdx] = max(summaryTable.Score(validScores));
        bestIdx = validIndices(bestLocalIdx);
        bestPosition = [summaryTable.X(bestIdx),summaryTable.Y(bestIdx),summaryTable.Z(bestIdx)];
    else
        bestIdx = NaN;
        bestPosition = [NaN,NaN,NaN];
    end

    writetable(summaryTable,summaryCsv);
    plotScoreSummary(summaryTable,cfg.outputFolder);

    if isfinite(bestIdx)
        fprintf('\nBest position: X=%.4f Y=%.4f Z=%s\n',bestPosition(1),bestPosition(2),formatPosition(bestPosition(3)));
        fprintf('Best score: %.4g\n',summaryTable.Score(bestIdx));
    else
        fprintf('\nNo completed points were available for scoring.\n');
    end
    fprintf('Saved summary:\n  %s\n',summaryCsv);

    if cfg.moveBackToBest && isfinite(bestIdx)
        fprintf('Moving back to best position...\n');
        moveMagnetTo(motorAcq,bestPosition);
    end
catch ME
    disconnectMagnetMotors(motorAcq);
    clear cleanupObj;
    rethrow(ME);
end

disconnectMagnetMotors(motorAcq);
clear cleanupObj motorAcq;

%% Local functions
function positions = makePositionList(xList,yList,zList)
if isempty(zList) || (numel(zList) == 1 && isnan(zList))
    zList = NaN;
end
[X,Y,Z] = ndgrid(xList,yList,zList);
positions = [X(:),Y(:),Z(:)];
end

function text = formatPosition(value)
if isnan(value)
    text = 'fixed';
else
    text = sprintf('%.4f',value);
end
end

function results = initResults(n)
results = struct();
results.PositionIndex = nan(n,1);
results.X = nan(n,1);
results.Y = nan(n,1);
results.Z = nan(n,1);
results.Baseline = nan(n,1);
results.DipHeight = nan(n,1);
results.Contrast = nan(n,1);
results.Linewidth = nan(n,1);
results.Noise = nan(n,1);
results.SNR = nan(n,1);
results.Score = nan(n,1);
results.Center = nan(n,1);
results.FitR2 = nan(n,1);
results.PngFile = cell(n,1);
results.RawX = cell(n,1);
results.RawY = cell(n,1);
end

function acq = connectMagnetMotors(cfg)
acq = ImageAcquisitionThorlabs();
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoCLI.dll');

import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.KCube.DCServoCLI.*

DeviceManagerCLI.BuildDeviceList();
serialNumbers = cell(ToArray(DeviceManagerCLI.GetDeviceList()));
if numel(serialNumbers) < 3
    error('Fewer than 3 Thorlabs motor serial numbers detected.');
end

try
    for k = 1:3
        axisName = cfg.motorAliases{k};
        sn = serialNumbers{k};
        motor = KCubeDCServo.CreateKCubeDCServo(sn);
        motor.Connect(sn);
        acq.Motors.(axisName) = motor;
        motor.WaitForSettingsInitialized(5000);
        motorConfig = motor.LoadMotorConfiguration(sn);
        motorConfig.DeviceSettingsName = 'MTS25-Z8';
        motorConfig.UpdateCurrentConfiguration();
        motor.SetSettings(motor.MotorDeviceSettings,true,false);
        motor.StartPolling(250);
    end
catch ME
    disconnectMagnetMotors(acq);
    rethrow(ME);
end
end

function disconnectMagnetMotors(acq)
axes = {'X','Y','Z'};
for k = 1:numel(axes)
    axisName = axes{k};
    try
        motor = acq.Motors.(axisName);
        if ~isempty(motor) && motor.IsConnected
            motor.StopPolling();
            motor.Disconnect();
        end
    catch
    end
end
end

function setMagnetSpeeds(acq,speed)
acq.setMotorSpeed('X',speed.X);
acq.setMotorSpeed('Y',speed.Y);
acq.setMotorSpeed('Z',speed.Z);
end

function moveMagnetTo(acq,pos)
axes = {'X','Y','Z'};
for k = 1:3
    if isnan(pos(k))
        continue;
    end
    motor = acq.Motors.(axes{k});
    if isempty(motor) || ~motor.IsConnected
        error('Motor %s is not connected.',axes{k});
    end
    motor.MoveTo(System.Decimal(pos(k)),60000);
end
end

function startNVExperiment(hFig,handles)
if isfield(handles,'buttonStart') && ishandle(handles.buttonStart)
    try
        figure(hFig); %这两句什么意思
        drawnow;
        startCallback = get(handles.buttonStart,'Callback');
        if isa(startCallback,'function_handle') %这三种情况什么意思
            startCallback(handles.buttonStart,[]);
        elseif iscell(startCallback)
            feval(startCallback{:},handles.buttonStart,[]);
        else
            NVCommandCenter('buttonStart_Callback',handles.buttonStart,[],guidata(handles.buttonStart));
        end
    catch ME
        close(findobj(0,'Name','TrackingViewer'));
        warning('Direct buttonStart callback failed: %s',ME.message);
        error('Unable to trigger NVCommandCenter experiment.');
    end
else
    error('Unable to trigger NVCommandCenter experiment. Start button handle was not found.');
end
drawnow;
statusText = getNVStatusText(guidata(hFig));
statusLower = lower(statusText);
if ~isempty(strfind(statusLower,'abort')) || ~isempty(strfind(statusLower,'error'))
    error('NVCommandCenter ended with status: %s',statusText);
end
end

function statusText = getNVStatusText(handles)
statusText = '';
try
    if isfield(handles,'textStatus') && ishandle(handles.textStatus)
        statusText = get(handles.textStatus,'String');
    end
catch
    statusText = '';
end
if iscell(statusText)
    statusText = strjoin(statusText,' ');
end
statusText = char(statusText);
end

function [x,y] = getODMRTrace(handles)
x = [];
if isfield(handles,'specialVec')
    x = handles.specialVec(:);
end

y = [];
if isfield(handles,'Counter') && ~isempty(handles.Counter.ProcessedData)
    y = handles.Counter.ProcessedData;
    if size(y,2) > 1
        y = y(:,1);
    end
    y = y(:);
end

if isempty(y)
    error('No processed ODMR data found in handles.Counter.ProcessedData after experiment.');
end
if isempty(x) || numel(x) ~= numel(y)
    x = (1:numel(y))';
end
end

function metrics = scoreODMRTrace(x,y)
x = x(:);
y = y(:);
valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);
[x,order] = sort(x);
y = y(order);

if numel(y) < 5
    error('ODMR trace has too few valid points.');
end

ys = smoothVector(y,5);
n = numel(ys);
sortedY = sort(ys);
lowCut = max(1,round(0.25*n));
highCut = min(n,round(0.90*n));
baselinePool = sortedY(lowCut:highCut);
baseline = median(baselinePool);
noise = 1.4826 * median(abs(baselinePool - median(baselinePool)));
noise = max(noise,eps);

edgeSkip = min(max(3,ceil(5/2)),floor(n/4));
searchStart = edgeSkip + 1;
searchStop = n - edgeSkip;
if searchStop <= searchStart
    searchStart = 1;
    searchStop = n;
end
[dipValue,localDipIdx] = min(ys(searchStart:searchStop));
dipIdx = searchStart + localDipIdx - 1;
dx = median(abs(diff(x)));
dx = max(dx,eps);
scanWidth = max(max(x) - min(x),dx);
height0 = max(baseline - dipValue,eps);
fitHalfWidth = max(6*dx,min(scanWidth/5,9*dx));
fitMask = abs(x - x(dipIdx)) <= fitHalfWidth;
if nnz(fitMask) < 7
    fitMask = false(size(x));
    localStart = max(1,dipIdx-3);
    localStop = min(n,dipIdx+3);
    fitMask(localStart:localStop) = true;
end
xFit = x(fitMask);
yLocal = y(fitMask);
centerLower = min(xFit);
centerUpper = max(xFit);
gamma0 = max(2*dx,min(fitHalfWidth/2,scanWidth/20));
p0 = [baseline,height0,x(dipIdx),gamma0];
lb = [min(yLocal),0,centerLower,dx/2];
heightUpper = max(2*max(abs(yLocal-baseline)),height0);
ub = [max(yLocal)+2*height0,heightUpper,centerUpper,fitHalfWidth];

objective = @(p) sum((lorentzianDip(p,xFit) - yLocal).^2);
fitOptions = optimset('Display','off','MaxFunEvals',5000,'MaxIter',2000);
if exist('fminsearchbnd','file') == 2
    pFit = fminsearchbnd(objective,p0,lb,ub,fitOptions);
else
    pFit = fminsearch(@(p)objective(boundVector(p,lb,ub)),p0,fitOptions);
    pFit = boundVector(pFit,lb,ub);
end

yFit = lorentzianDip(pFit,x);
yFitLocal = lorentzianDip(pFit,xFit);
baseline = pFit(1);
height = max(pFit(2),0);
center = pFit(3);
gamma = max(abs(pFit(4)),eps);
linewidth = 2*gamma;
dipValue = baseline - height;
contrast = height / max(abs(baseline),eps);
snr = height / noise;
ssRes = sum((yLocal - yFitLocal).^2);
ssTot = sum((yLocal - mean(yLocal)).^2);
if ssTot > 0
    fitR2 = 1 - ssRes/ssTot;
else
    fitR2 = NaN;
end

metrics = struct();
metrics.center = center;
metrics.baseline = baseline;
metrics.dip = dipValue;
metrics.height = height;
metrics.contrast = contrast;
metrics.noise = noise;
metrics.snr = snr;
metrics.linewidth = linewidth;
metrics.fitR2 = fitR2;
metrics.fitY = yFit;
metrics.fitMask = fitMask;
metrics.score = snr / linewidth * max(fitR2,0);
end

function yFit = lorentzianDip(p,x)
yFit = p(1) - p(2) ./ (1 + ((x - p(3))./p(4)).^2);
end

function p = boundVector(p,lb,ub)
p = max(min(p,ub),lb);
end

function text = vectorToCsvString(v)
text = sprintf('%.15g;',v(:));
if ~isempty(text)
    text = text(1:end-1);
end
end

function ySmooth = smoothVector(y,windowSize)
windowSize = min(windowSize,numel(y));
if windowSize <= 1
    ySmooth = y;
    return;
end
halfWindow = floor(windowSize/2);
ySmooth = zeros(size(y));
for idx = 1:numel(y)
    firstIdx = max(1,idx-halfWindow);
    lastIdx = min(numel(y),idx+halfWindow);
    ySmooth(idx) = mean(y(firstIdx:lastIdx));
end
end

function saveODMRPointPlot(x,y,metrics,pos,idx,numPositions,pngFile)
fig = figure('Name',sprintf('Magnet ODMR %04d',idx),'Visible','off');
plot(x,y,'o-','LineWidth',1.0,'MarkerSize',4);
hold on;
if isfield(metrics,'fitMask') && numel(metrics.fitMask) == numel(x)
    plot(x(metrics.fitMask),y(metrics.fitMask),'ko','MarkerSize',5);
end
if isfield(metrics,'fitY') && numel(metrics.fitY) == numel(x)
    plot(x,metrics.fitY,'r-','LineWidth',1.2);
end
yl = ylim;
plot([metrics.center metrics.center],yl,'r--','LineWidth',1.2);
plot(xlim,[metrics.baseline metrics.baseline],'k:','LineWidth',1.0);
hold off;
grid on;
xlabel('Frequency');
ylabel('Signal');
title(sprintf('Point %d/%d  X=%.4f Y=%.4f Z=%s',idx,numPositions,pos(1),pos(2),formatPosition(pos(3))));
legend({'ODMR','Fit points','Lorentzian fit','Dip center','Baseline'},'Location','best');
text(0.02,0.02,sprintf('center=%.6g\\nheight=%.4g\\ncontrast=%.4g\\nFWHM=%.4g\\nSNR=%.4g\\nR2=%.4g\\nscore=%.4g',...
    metrics.center,metrics.height,metrics.contrast,metrics.linewidth,metrics.snr,metrics.fitR2,metrics.score),...
    'Units','normalized','VerticalAlignment','bottom','BackgroundColor','w','EdgeColor',[0.7 0.7 0.7]);
saveas(fig,pngFile);
close(fig);
end

function plotScoreSummary(summaryTable,outputFolder)
valid = isfinite(summaryTable.Score) & isfinite(summaryTable.X) & isfinite(summaryTable.Y);
if ~any(valid)
    warning('No valid score values to plot.');
    return;
end
x = summaryTable.X(valid);
y = summaryTable.Y(valid);
score = summaryTable.Score(valid);
fig = figure('Name','Magnet ODMR optimization score');
if numel(unique(x)) > 1 && numel(unique(y)) > 1
    xVals = unique(x);
    yVals = unique(y);
    scoreMap = nan(numel(yVals),numel(xVals));
    for k = 1:numel(score)
        xi = find(xVals == x(k),1);
        yi = find(yVals == y(k),1);
        scoreMap(yi,xi) = score(k);
    end
    imagesc(xVals,yVals,scoreMap);
    axis xy;
    xlabel('X');
    ylabel('Y');
    title('ODMR score');
    colorbar;
else
    plot(1:numel(score),score,'o-','LineWidth',1.5);
    xlabel('Position index');
    ylabel('Score');
    title('ODMR score');
    grid on;
end
[~,bestLocal] = max(score);
hold on;
if numel(unique(x)) > 1 && numel(unique(y)) > 1
    plot(x(bestLocal),y(bestLocal),'wx','MarkerSize',12,'LineWidth',2);
end
hold off;
saveas(fig,fullfile(outputFolder,'magnet_odmr_score_map.png'));
end
