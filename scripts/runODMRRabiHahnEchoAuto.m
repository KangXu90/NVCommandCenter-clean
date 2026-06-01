%% Automated ODMR -> Rabi -> Hahn echo workflow
% Open and initialize NVCommandCenter first. This script then configures each
% step, starts the existing GUI acquisition path, fits the result, and saves a
% transparent parameter/result bundle.

cfg = struct();
cfg.outputFolder = fullfile(pwd, 'data', 'auto_odmr_rabi_hahnecho');
cfg.stopOnFitFailure = true;

cfg.common.sequenceSamples = 10000;
cfg.common.trackEnable = false;
cfg.common.trackThreshold = 1;

% ODMR uses the current pulsed/f-sweep hardware path. If sequencePath is
% empty, the currently loaded pulse sequence is kept.
cfg.odmr.enabled = true;
cfg.odmr.mode = 'Pulsed/f-sweep';
cfg.odmr.processModeTag = 'buttonRabiMode';
cfg.odmr.averages = 10;
cfg.odmr.sequenceSamples = 50000;
cfg.odmr.sequencePath = fullfile(pwd, 'sequence_library', 'example', 'Pulsed-ESR-60us.mat');
cfg.odmr.sweepStartHz = 2.82e9;
cfg.odmr.sweepStopHz = 2.92e9;
cfg.odmr.sweepPoints = 101;
cfg.odmr.mwAmplitudeDbm = [];
cfg.odmr.setGeneratorToFit = true;
cfg.odmr.generatorFrequencyOffsetHz = 0; % Use -100e6 here if your SG is LO = ODMR center - IF.

cfg.rabi.enabled = true;
cfg.rabi.mode = 'Pulsed';
cfg.rabi.processModeTag = 'buttonRabiMode';
cfg.rabi.averages = 5;
cfg.rabi.sequenceSamples = 100000;
cfg.rabi.sweepStart = 0;
cfg.rabi.sweepStop = 500e-9;
cfg.rabi.sweepPoints = 101;
cfg.rabi.mwAmplitude = 1;
cfg.rabi.mwAmplitudeDbm = [];

cfg.hahn.enabled = true;
cfg.hahn.mode = 'Pulsed';
cfg.hahn.processModeTag = 'buttonT2Mode';
cfg.hahn.averages = 10;
cfg.hahn.sequenceSamples = 10000;
cfg.hahn.sweepStart = 20e-9;
cfg.hahn.sweepStop = 5e-6;
cfg.hahn.sweepPoints = 101;
cfg.hahn.mwAmplitude = 1;
cfg.hahn.piTimeFallback = 50e-9; % Used only when cfg.rabi.enabled is false.

if ~exist(cfg.outputFolder, 'dir')
    mkdir(cfg.outputFolder);
end

runStamp = datestr(now, 'yyyymmdd_HH-MM-SS');
result = struct();
result.startedAt = runStamp;
result.cfg = cfg;
result.steps = struct();

hFig = findNVCommandCenterFigure();
handles = guidata(hFig);

fprintf('Automated ODMR -> Rabi -> Hahn echo workflow\n');
fprintf('Output folder: %s\n', cfg.outputFolder);

if cfg.odmr.enabled
    fprintf('\n[ODMR] configuring and starting...\n');
    handles = configureCommon(hFig, handles, cfg.common);
    handles = configureODMR(hFig, handles, cfg.odmr);
    odmrData = startAndCollect(hFig, handles, 'ODMR');
    odmrFit = fitODMRTrace(odmrData.x, odmrData.y);
    result.steps.odmr = struct('data', odmrData, 'fit', odmrFit, 'cfg', cfg.odmr);
    saveStepPlot(cfg.outputFolder, runStamp, 'ODMR', odmrData, odmrFit);
    save(fullfile(cfg.outputFolder, ['auto_step_odmr_', runStamp, '.mat']), 'odmrData', 'odmrFit', 'cfg');
    fprintf('[ODMR] center %.9g Hz, contrast %.4g, R2 %.4g\n', odmrFit.center, odmrFit.contrast, odmrFit.r2);

    if cfg.odmr.setGeneratorToFit && isfinite(odmrFit.center)
        handles = guidata(hFig);
        handles = setSignalGeneratorFrequency(handles, odmrFit.center + cfg.odmr.generatorFrequencyOffsetHz);
        guidata(hFig, handles);
        fprintf('[ODMR] signal generator frequency set to %.9g Hz\n', odmrFit.center + cfg.odmr.generatorFrequencyOffsetHz);
    end
    requireFit('ODMR', odmrFit, cfg.stopOnFitFailure);
end

if cfg.rabi.enabled
    fprintf('\n[Rabi] generating sequence and starting...\n');
    handles = guidata(hFig);
    handles = configureCommon(hFig, handles, cfg.common);
    handles = configureRabi(hFig, handles, cfg.rabi);
    rabiData = startAndCollect(hFig, handles, 'Rabi');
    rabiFit = fitRabiTrace(rabiData.x, rabiData.y);
    result.steps.rabi = struct('data', rabiData, 'fit', rabiFit, 'cfg', cfg.rabi);
    saveStepPlot(cfg.outputFolder, runStamp, 'Rabi', rabiData, rabiFit);
    save(fullfile(cfg.outputFolder, ['auto_step_rabi_', runStamp, '.mat']), 'rabiData', 'rabiFit', 'cfg');
    fprintf('[Rabi] pi %.4g ns, period %.4g ns, contrast %.4g, R2 %.4g\n', ...
        rabiFit.piTime*1e9, rabiFit.period*1e9, rabiFit.contrast, rabiFit.r2);
    requireFit('Rabi', rabiFit, cfg.stopOnFitFailure);
else
    rabiFit = struct('piTime', cfg.hahn.piTimeFallback);
end

if cfg.hahn.enabled
    fprintf('\n[Hahn echo] generating sequence and starting...\n');
    handles = guidata(hFig);
    handles = configureCommon(hFig, handles, cfg.common);
    handles = configureHahnEcho(hFig, handles, cfg.hahn, rabiFit.piTime);
    hahnData = startAndCollect(hFig, handles, 'HahnEcho');
    hahnFit = fitHahnEchoTrace(hahnData.x, hahnData.y);
    result.steps.hahn = struct('data', hahnData, 'fit', hahnFit, 'cfg', cfg.hahn);
    saveStepPlot(cfg.outputFolder, runStamp, 'HahnEcho', hahnData, hahnFit);
    save(fullfile(cfg.outputFolder, ['auto_step_hahnecho_', runStamp, '.mat']), 'hahnData', 'hahnFit', 'cfg');
    fprintf('[Hahn echo] T2 %.4g us, contrast %.4g, R2 %.4g\n', ...
        hahnFit.t2*1e6, hahnFit.contrast, hahnFit.r2);
    requireFit('Hahn echo', hahnFit, cfg.stopOnFitFailure);
end

result.finishedAt = datestr(now, 'yyyymmdd_HH-MM-SS');
summaryPath = fullfile(cfg.outputFolder, ['auto_odmr_rabi_hahnecho_', runStamp, '.mat']);
save(summaryPath, 'result');
fprintf('\nWorkflow complete. Saved summary:\n  %s\n', summaryPath);

%% Local functions
function hFig = findNVCommandCenterFigure()
hFig = findall(0, 'Name', 'NVCommandCenter');
if isempty(hFig)
    error('NVCommandCenter is not open. Open and initialize it before running this script.');
end
hFig = hFig(1);
end

function handles = configureCommon(hFig, handles, commonCfg)
setEditIfPresent(handles, 'editSequenceSamples', commonCfg.sequenceSamples);
setEditIfPresent(handles, 'editTrackThreshold', commonCfg.trackThreshold);
setValueIfPresent(handles, 'cbTrackEnable', logical(commonCfg.trackEnable));
guidata(hFig, handles);
end

function handles = configureODMR(hFig, handles, odmrCfg)
setPopupByText(handles, 'popupMode', odmrCfg.mode);
setProcessMode(handles, odmrCfg.processModeTag);
setEditIfPresent(handles, 'editAverages', odmrCfg.averages);
setEditIfPresent(handles, 'editSequenceSamples', odmrCfg.sequenceSamples);
if ~isempty(odmrCfg.sequencePath)
    loaded = load(odmrCfg.sequencePath);
    if ~isfield(loaded, 'PSeq')
        error('ODMR sequence file does not contain PSeq: %s', odmrCfg.sequencePath);
    end
    handles.PulseSequence = loaded.PSeq;
end
handles = configureProteusSweep(handles, odmrCfg.sweepStartHz, odmrCfg.sweepStopHz, odmrCfg.sweepPoints);
if ~isempty(odmrCfg.mwAmplitudeDbm)
    handles = setSignalGeneratorAmplitude(handles, odmrCfg.mwAmplitudeDbm);
end
guidata(hFig, handles);
end

function handles = configureRabi(hFig, handles, rabiCfg)
setPopupByText(handles, 'popupMode', rabiCfg.mode);
setProcessMode(handles, rabiCfg.processModeTag);
setEditIfPresent(handles, 'editAverages', rabiCfg.averages);
setEditIfPresent(handles, 'editSequenceSamples', rabiCfg.sequenceSamples);
params = struct();
params.sequenceName = 'Rabi-Auto';
params.mwAmplitude = rabiCfg.mwAmplitude;
params.sweep = struct('start', rabiCfg.sweepStart, 'stop', rabiCfg.sweepStop, 'points', rabiCfg.sweepPoints);
handles.PulseSequence = generateUnifiedSequence('Rabi', params, '');
if ~isempty(rabiCfg.mwAmplitudeDbm)
    handles = setSignalGeneratorAmplitude(handles, rabiCfg.mwAmplitudeDbm);
end
guidata(hFig, handles);
end

function handles = configureHahnEcho(hFig, handles, hahnCfg, piTime)
setPopupByText(handles, 'popupMode', hahnCfg.mode);
setProcessMode(handles, hahnCfg.processModeTag);
setEditIfPresent(handles, 'editAverages', hahnCfg.averages);
setEditIfPresent(handles, 'editSequenceSamples', hahnCfg.sequenceSamples);
params = struct();
params.sequenceName = 'HahnEcho-Auto';
params.piTime = piTime;
params.piHalfTime = piTime/2;
params.mwAmplitude = hahnCfg.mwAmplitude;
params.includeSecondReadout = true;
params.sweep = struct('start', hahnCfg.sweepStart, 'stop', hahnCfg.sweepStop, 'points', hahnCfg.sweepPoints);
handles.PulseSequence = generateUnifiedSequence('HahnEcho', params, '');
guidata(hFig, handles);
end

function handles = configureProteusSweep(handles, startHz, stopHz, points)
if ~isfield(handles, 'TEProteusInst') || isempty(handles.TEProteusInst)
    error('handles.TEProteusInst is missing; cannot configure pulsed/f-sweep ODMR.');
end
awg = handles.TEProteusInst;
setObjectProperty(awg, 'SweepZoneState1', true);
setObjectProperty(awg, 'SweepZoneState2', false);
setObjectProperty(awg, 'SweepStart1', startHz);
setObjectProperty(awg, 'SweepStop1', stopHz);
setObjectProperty(awg, 'SweepPoints1', points);
end

function data = startAndCollect(hFig, handles, label)
startCallback = get(handles.buttonStart, 'Callback');
if isa(startCallback, 'function_handle')
    startCallback(handles.buttonStart, []);
elseif iscell(startCallback)
    feval(startCallback{:}, handles.buttonStart, []);
else
    NVCommandCenter('buttonStart_Callback', handles.buttonStart, [], guidata(handles.buttonStart));
end
drawnow;
handles = guidata(hFig);
statusText = getStatusText(handles);
if ~isempty(strfind(lower(statusText), 'abort')) || ~isempty(strfind(lower(statusText), 'error'))
    error('%s ended with status: %s', label, statusText);
end
data = collectTrace(handles);
data.status = statusText;
data.label = label;
end

function data = collectTrace(handles)
y = [];
if isfield(handles, 'Counter') && ~isempty(handles.Counter)
    if ~isempty(handles.Counter.ProcessedData)
        y = handles.Counter.ProcessedData;
    elseif ~isempty(handles.Counter.AveragedData)
        avg = handles.Counter.AveragedData;
        if size(avg, 2) >= 2
            y = avg(:, 2) ./ avg(:, 1);
        else
            y = avg(:, 1);
        end
    end
end
if isempty(y)
    error('No acquired data found in handles.Counter.');
end
if size(y, 2) > 1
    y = y(:, 1);
end
y = y(:);

x = [];
if isfield(handles, 'specialVec') && numel(handles.specialVec) == numel(y)
    x = handles.specialVec(:);
elseif isfield(handles, 'PulseSequence') && ~isempty(handles.PulseSequence.Sweeps)
    swp = handles.PulseSequence.Sweeps(1);
    x = linspace(swp.StartValue, swp.StopValue, swp.SweepPoints).';
end
if isempty(x) || numel(x) ~= numel(y)
    x = (1:numel(y)).';
end
data = struct('x', x, 'y', y);
if isfield(handles, 'Counter')
    data.averagedData = handles.Counter.AveragedData;
    data.processedData = handles.Counter.ProcessedData;
end
end

function fitOut = fitODMRTrace(x, y)
[x, y] = cleanTrace(x, y);
baseline0 = median(y);
[minY, idx] = min(y);
height0 = max(eps, baseline0 - minY);
center0 = x(idx);
gamma0 = max(abs(x(end)-x(1))/40, eps);
p0 = [baseline0, height0, center0, gamma0];
model = @(p, xx) p(1) - abs(p(2)) ./ (1 + ((xx - p(3)) ./ max(abs(p(4)), eps)).^2);
p = fminsearch(@(p)sum((y - model(p, x)).^2), p0, optimset('Display', 'off'));
yfit = model(p, x);
fitOut = fitCommon(x, y, yfit);
fitOut.baseline = p(1);
fitOut.height = abs(p(2));
fitOut.center = p(3);
fitOut.linewidth = 2*abs(p(4));
fitOut.contrast = fitOut.height / max(abs(fitOut.baseline), eps);
end

function fitOut = fitRabiTrace(x, y)
[x, y] = cleanTrace(x, y);
x0 = x - min(x);
offset0 = mean(y);
amp0 = (max(y) - min(y))/2;
period0 = estimatePeriod(x0, y);
tau0 = max(max(x0), eps);
p0 = [offset0, amp0, period0, 0, tau0];
model = @(p, xx) p(1) + p(2).*cos(2*pi*xx./max(abs(p(3)), eps) + p(4)).*exp(-xx./max(abs(p(5)), eps));
p = fminsearch(@(p)sum((y - model(p, x0)).^2), p0, optimset('Display', 'off', 'MaxIter', 5000, 'MaxFunEvals', 10000));
yfit = model(p, x0);
fitOut = fitCommon(x, y, yfit);
fitOut.period = abs(p(3));
fitOut.piTime = abs(p(3))/2;
fitOut.decayTime = abs(p(5));
fitOut.contrast = 2*abs(p(2))/max(abs(p(1)), eps);
end

function fitOut = fitHahnEchoTrace(x, y)
[x, y] = cleanTrace(x, y);
x0 = x - min(x);
offset0 = y(end);
amp0 = y(1) - y(end);
t20 = max(x0)/2;
p0 = [offset0, amp0, t20, 1.5];
model = @(p, xx) p(1) + p(2).*exp(-(xx./max(abs(p(3)), eps)).^max(abs(p(4)), 0.1));
p = fminsearch(@(p)sum((y - model(p, x0)).^2), p0, optimset('Display', 'off', 'MaxIter', 5000, 'MaxFunEvals', 10000));
yfit = model(p, x0);
fitOut = fitCommon(x, y, yfit);
fitOut.t2 = abs(p(3));
fitOut.stretch = max(abs(p(4)), 0.1);
fitOut.contrast = abs(p(2))/max(abs(p(1)), eps);
end

function fitOut = fitCommon(x, y, yfit)
ssRes = sum((y - yfit).^2);
ssTot = sum((y - mean(y)).^2);
if ssTot > 0
    r2 = 1 - ssRes/ssTot;
else
    r2 = NaN;
end
fitOut = struct('x', x, 'yfit', yfit, 'r2', r2, 'rmse', sqrt(mean((y-yfit).^2)));
end

function period = estimatePeriod(x, y)
y = y - mean(y);
if numel(x) < 4 || all(y == 0)
    period = max(max(x)-min(x), eps);
    return;
end
dx = median(diff(x));
f = abs(fft(y));
halfN = max(2, floor(numel(f)/2));
f = f(2:halfN);
if isempty(f)
    period = max(max(x)-min(x), eps);
    return;
end
[~, idx] = max(f);
freq = idx/(numel(y)*dx);
period = 1/max(freq, eps);
end

function [x, y] = cleanTrace(x, y)
x = x(:);
y = y(:);
valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);
[x, order] = sort(x);
y = y(order);
if numel(x) < 5
    error('Trace has too few valid points for fitting.');
end
end

function saveStepPlot(folder, stamp, label, data, fitOut)
fig = figure('Name', ['Auto ', label], 'Visible', 'off');
plot(data.x, data.y, 'o', 'MarkerSize', 4);
hold on;
plot(fitOut.x, fitOut.yfit, '-', 'LineWidth', 1.2);
grid on;
xlabel('Sweep');
ylabel('Signal');
title(sprintf('%s fit, R2 %.4g', label, fitOut.r2));
legend({'data', 'fit'}, 'Location', 'best');
saveas(fig, fullfile(folder, ['auto_', lower(label), '_', stamp, '.png']));
close(fig);
end

function requireFit(label, fitOut, stopOnFitFailure)
if stopOnFitFailure && (~isfinite(fitOut.r2) || fitOut.r2 < 0)
    error('%s fit failed quality check: R2 %.4g', label, fitOut.r2);
end
end

function setPopupByText(handles, fieldName, desiredText)
if ~isfield(handles, fieldName) || ~ishandle(handles.(fieldName))
    error('Missing popup control: %s', fieldName);
end
items = get(handles.(fieldName), 'String');
if ischar(items)
    items = cellstr(items);
end
idx = find(strcmpi(items, desiredText), 1);
if isempty(idx)
    error('Popup %s does not contain "%s".', fieldName, desiredText);
end
set(handles.(fieldName), 'Value', idx);
end

function setProcessMode(handles, tag)
if isfield(handles, tag) && ishandle(handles.(tag))
    set(handles.pnlProcessMode, 'SelectedObject', handles.(tag));
    set(handles.(tag), 'Value', 1);
else
    error('Missing process mode radio button: %s', tag);
end
end

function setEditIfPresent(handles, fieldName, value)
if isfield(handles, fieldName) && ishandle(handles.(fieldName))
    set(handles.(fieldName), 'String', num2str(value));
end
end

function setValueIfPresent(handles, fieldName, value)
if isfield(handles, fieldName) && ishandle(handles.(fieldName))
    set(handles.(fieldName), 'Value', value);
end
end

function handles = setSignalGeneratorFrequency(handles, frequencyHz)
sg = handles.SignalGenerator;
if isprop(sg, 'Frequency')
    sg.Frequency = frequencyHz;
elseif isprop(sg, 'Frequency1')
    sg.Frequency1 = frequencyHz;
else
    warning('SignalGenerator has no Frequency/Frequency1 property to set.');
    return;
end
try
    sg.setFrequency();
catch ME
    warning('Failed to apply signal generator frequency: %s', ME.message);
end
end

function handles = setSignalGeneratorAmplitude(handles, amplitudeDbm)
sg = handles.SignalGenerator;
if isprop(sg, 'Amplitude')
    sg.Amplitude = amplitudeDbm;
elseif isprop(sg, 'Amplitude1')
    sg.Amplitude1 = amplitudeDbm;
else
    warning('SignalGenerator has no Amplitude/Amplitude1 property to set.');
    return;
end
try
    sg.setAmplitude();
catch ME
    warning('Failed to apply signal generator amplitude: %s', ME.message);
end
end

function setObjectProperty(obj, propName, value)
if isprop(obj, propName)
    obj.(propName) = value;
elseif isstruct(obj) && isfield(obj, propName)
    obj.(propName) = value;
else
    warning('Object has no property "%s"; skipped.', propName);
end
end

function statusText = getStatusText(handles)
statusText = '';
if isfield(handles, 'textStatus') && ishandle(handles.textStatus)
    statusText = get(handles.textStatus, 'String');
end
if iscell(statusText)
    statusText = strjoin(statusText, ' ');
end
statusText = char(statusText);
end
