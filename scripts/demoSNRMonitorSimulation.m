function dataset = demoSNRMonitorSimulation(mode, nAverages, saveDataset)
% demoSNRMonitorSimulation  Exercise SNRMonitor with synthetic data.
%
% Usage:
%   demoSNRMonitorSimulation
%   demoSNRMonitorSimulation('rabi')
%   demoSNRMonitorSimulation('ramsey')
%   demoSNRMonitorSimulation('hahnecho')
%   demoSNRMonitorSimulation('odmr', 50, true)
%   data = demoSNRMonitorSimulation('all', 40, true)
%
% The script does not touch hardware. It creates cumulative averaged traces
% that look like real running averages, opens SNRMonitor, and feeds one trace
% per average number.

if nargin < 1 || isempty(mode)
    mode = 'all';
end
if nargin < 2 || isempty(nAverages)
    nAverages = 100;
end
if nargin < 3 || isempty(saveDataset)
    saveDataset = true;
end

mode = lower(mode);
rootFolder = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(rootFolder,'core'));

dataset = buildSNRMonitorDemoDataset(nAverages);

if saveDataset
    outFolder = fullfile(rootFolder,'data','snr_monitor_demo');
    if ~exist(outFolder,'dir')
        mkdir(outFolder);
    end
    save(fullfile(outFolder,'snr_monitor_demo_dataset.mat'),'dataset');
end

monitor = SNRMonitor();
set(monitor.hEnable,'Value',1);

switch mode
    case 'rabi'
        runDemo(monitor,dataset.rabi,'Rabi','Pulsed');
    case 'ramsey'
        runDemo(monitor,dataset.ramsey,'Ramsey','Pulsed');
    case {'hahn','hahnecho','hahn_echo'}
        runDemo(monitor,dataset.hahnecho,'Hahn echo','Pulsed');
    case 'odmr'
        runDemo(monitor,dataset.odmr,'','Pulsed/f-sweep');
    case {'xy6','proton','sensing'}
        runDemo(monitor,dataset.xy6,'T2','Pulsed');
    case 'all'
        runDemo(monitor,dataset.rabi,'Rabi','Pulsed');
        pause(0.5);
        monitor.reset();
        runDemo(monitor,dataset.ramsey,'Ramsey','Pulsed');
        pause(0.5);
        monitor.reset();
        runDemo(monitor,dataset.hahnecho,'Hahn echo','Pulsed');
        pause(0.5);
        monitor.reset();
        runDemo(monitor,dataset.odmr,'','Pulsed/f-sweep');
        pause(0.5);
        monitor.reset();
        runDemo(monitor,dataset.xy6,'T2','Pulsed');
    otherwise
        error('Unknown mode "%s". Use rabi, ramsey, hahnecho, odmr, xy6, or all.',mode);
end
end

function runDemo(monitor,traceSet,expType,modeName)
setModePopup(monitor,traceSet.monitorMode);
setSignalPopup(monitor,traceSet.signalMethod);
setNoisePopup(monitor,traceSet.noiseMethod);
monitor.SignalWindow = traceSet.signalWindow;
monitor.ReferenceWindow = traceSet.referenceWindow;

for avgIndex = 1:size(traceSet.yAvg,2)
    monitor.update(traceSet.x,traceSet.yAvg(:,avgIndex),avgIndex,expType,modeName);
    pause(0.08);
end
end

function dataset = buildSNRMonitorDemoDataset(nAverages)
rng(7);
dataset.rabi = makeRabiDataset(nAverages);
dataset.ramsey = makeRamseyDataset(nAverages);
dataset.hahnecho = makeHahnEchoDataset(nAverages);
dataset.odmr = makeODMRDataset(nAverages);
dataset.xy6 = makeXY6Dataset(nAverages);
dataset.description = ['Synthetic cumulative-average traces for ', ...
    'SNRMonitor GUI testing. Columns in yAvg are average number 1..N.'];
dataset.created = datestr(now);
end

function traceSet = makeRabiDataset(nAverages)
nPts = 95;
x = linspace(0,2e-7,nPts)';
clean = 0.94 + 0.075*cos(2*pi*x/4.2e-8 + 0.35).*exp(-x/3.5e-7);
clean = clean + 0.01*sin(2*pi*x/1.6e-7);
singleNoise = 0.055;
slowDrift = linspace(0,0.01,nAverages);
yAvg = cumulativeAverage(clean,singleNoise,slowDrift);

traceSet = baseTraceSet(x,yAvg,'Sin damp','Auto','Residual');
traceSet.signalWindow = [];
traceSet.referenceWindow = [];
traceSet.clean = clean;
end

function traceSet = makeRamseyDataset(nAverages)
nPts = 120;
x = linspace(0,8e-6,nPts)';
envelope = exp(-(x/4.8e-6).^1.4);
clean = 0.98 + envelope .* ( ...
    0.055*cos(2*pi*0.78e6*x + 0.2) + ...
    0.032*cos(2*pi*1.16e6*x + 1.1) + ...
    0.018*cos(2*pi*1.55e6*x - 0.4));
clean = clean + 0.004*(x - mean(x))/span(x);
singleNoise = 0.038;
slowDrift = 0.008*cumsum(randn(1,nAverages))/sqrt(nAverages);
yAvg = cumulativeAverage(clean,singleNoise,slowDrift);

traceSet = baseTraceSet(x,yAvg,'Ramsey','Auto','Residual');
traceSet.signalWindow = [];
traceSet.referenceWindow = [];
traceSet.clean = clean;
end

function traceSet = makeHahnEchoDataset(nAverages)
nPts = 90;
x = linspace(0,12e-6,nPts)';
baseline = 0.975;
contrast = 0.18;
t2 = 4.2e-6;
clean = baseline + contrast*exp(-x/t2);
clean = clean + 0.006*(x - mean(x))/span(x);
singleNoise = 0.04;
slowDrift = 0.006*cumsum(randn(1,nAverages))/sqrt(nAverages);
yAvg = cumulativeAverage(clean,singleNoise,slowDrift);

traceSet = baseTraceSet(x,yAvg,'Exp decay','Auto','Residual');
traceSet.signalWindow = [];
traceSet.referenceWindow = [];
traceSet.clean = clean;
end

function traceSet = makeODMRDataset(nAverages)
nPts = 101;
x = linspace(2.81e9,2.93e9,nPts)';
center = 2.872e9;
linewidth = 8.5e6;
baseline = 1 + 0.012*(x - mean(x))/span(x);
dip = 0.14 ./ (1 + ((x-center)/linewidth).^2);
clean = baseline - dip;
singleNoise = 0.045;
slowDrift = 0.006*sin(linspace(0,1.4*pi,nAverages));
yAvg = cumulativeAverage(clean,singleNoise,slowDrift);

traceSet = baseTraceSet(x,yAvg,'Lorentz','Auto','Residual');
traceSet.signalWindow = [47,55];
traceSet.referenceWindow = [4,22];
traceSet.clean = clean;
end

function traceSet = makeXY6Dataset(nAverages)
nPts = 80;
x = linspace(0,40,nPts)';
baseline = 1.0 - 0.002*x;
feature = 0.055*exp(-0.5*((x-18)/3.0).^2);
clean = baseline - feature + 0.018*cos(2*pi*x/14).*exp(-x/55);
singleNoise = 0.035;
slowDrift = 0.012*cumsum(randn(1,nAverages))/sqrt(nAverages);
yAvg = cumulativeAverage(clean,singleNoise,slowDrift);

traceSet = baseTraceSet(x,yAvg,'XY6/sensing','Signal-reference','Reference window');
traceSet.signalWindow = [33,42];
traceSet.referenceWindow = [60,76];
traceSet.clean = clean;
end

function traceSet = baseTraceSet(x,yAvg,monitorMode,signalMethod,noiseMethod)
traceSet.x = x;
traceSet.yAvg = yAvg;
traceSet.monitorMode = monitorMode;
traceSet.signalMethod = signalMethod;
traceSet.noiseMethod = noiseMethod;
traceSet.signalWindow = [];
traceSet.referenceWindow = [];
end

function yAvg = cumulativeAverage(clean,singleNoise,slowDrift)
nPts = numel(clean);
nAverages = numel(slowDrift);
yAvg = NaN(nPts,nAverages);
running = zeros(nPts,1);
for avgIndex = 1:nAverages
    spatialRipple = 0.006*sin((1:nPts)'/7 + avgIndex/5);
    oneShot = clean + slowDrift(avgIndex) + spatialRipple + singleNoise*randn(nPts,1);
    running = running + oneShot;
    yAvg(:,avgIndex) = running / avgIndex;
end
end

function setModePopup(monitor,value)
setPopupByString(monitor.hMode,value);
end

function setSignalPopup(monitor,value)
setPopupByString(monitor.hSignalMethod,value);
end

function setNoisePopup(monitor,value)
setPopupByString(monitor.hNoiseMethod,value);
end

function setPopupByString(hPopup,value)
strings = get(hPopup,'String');
idx = find(strcmp(strings,value),1);
if ~isempty(idx)
    set(hPopup,'Value',idx);
end
end

function v = span(x)
v = max(x) - min(x);
end
