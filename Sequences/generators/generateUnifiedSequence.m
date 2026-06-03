function [PSeq, params] = generateUnifiedSequence(sequenceType, params, savePath)
%GENERATEUNIFIEDSEQUENCE Unified first-pass generator for common NV sequences.
%
% Copy/paste commands below. No output argument and no savePath means MATLAB
% opens the save-file dialog.
%
%   % Rabi: edit sweep start/stop/points.
%   generateUnifiedSequence('Rabi', struct('sequenceName','Rabi','piTime',50e-9,'piHalfTime',25e-9,'sweep',struct('start',0,'stop',500e-9,'points',101)));
%
%   % T1: edit sweep start/stop/points.
%   generateUnifiedSequence('T1', struct('sequenceName','T1','piTime',50e-9,'piHalfTime',25e-9,'includeSecondReadout',true,'sweep',struct('start',50e-9,'stop',100e-6,'points',201)));
%
%   % Ramsey.
%   generateUnifiedSequence('Ramsey', struct('sequenceName','Ramsey','piTime',50e-9,'piHalfTime',25e-9,'piHalfPhases',[0 0],'includeSecondReadout',true,'sweep',struct('start',20e-9,'stop',2e-6,'points',101)));
%
%   % Hahn-echo.
%   generateUnifiedSequence('HahnEcho', struct('sequenceName','HahnEcho','piTime',50e-9,'piHalfTime',25e-9,'piHalfPhases',[0 0],'piPhase',90,'includeSecondReadout',true,'sweep',struct('start',20e-9,'stop',2e-6,'points',101)));
%
%   % XY8, centered from 1H Larmor frequency.
%   generateUnifiedSequence('XY8', struct('sequenceName','XY8-8-1H','frequency',828e6,'piTime',50e-9,'piHalfTime',25e-9,'xy8Blocks',8,'includeSecondReadout',true,'sweep',struct('target','proton')));
%
%   % XY8, centered from 19F Larmor frequency.
%   generateUnifiedSequence('XY8', struct('sequenceName','XY8-8-19F','frequency',828e6,'piTime',50e-9,'piHalfTime',25e-9,'xy8Blocks',8,'includeSecondReadout',true,'sweep',struct('target','19F')));
%
%   % XY8, no Larmor target; edit sweep start/stop/points manually.
%   generateUnifiedSequence('XY8', struct('sequenceName','XY8-8','piTime',50e-9,'piHalfTime',25e-9,'xy8Blocks',8,'includeSecondReadout',true,'sweep',struct('start',20e-9,'stop',2e-6,'points',101)));
%
%   % WAHUHA.
%   generateUnifiedSequence('WAHUHA', struct('sequenceName','WAHUHA-64','piHalfTime',15e-9,'piTime',30e-9,'dsl4Pulses',64,'wahuhaPiHalfPhases',[90 90],'wahuhaPulseSpacingUnit',100e-9,'includeSecondReadout',true,'sweep',struct('start',0,'stop',0,'points',1)));
%
% This file is intentionally independent from the older generatePulseSequence_*
% scripts.  It is meant as a cleaner template that keeps common timing,
% hardware channels, and sweep metadata in one place.

if nargin < 1 || isempty(sequenceType)
    sequenceType = 'Rabi';
end
if nargin < 2 || isempty(params)
    params = struct();
end
if nargin < 3
    [fileName, folderName] = uiputfile('*.mat', 'Save pulse sequence');
    if isequal(fileName, 0)
        savePath = '';
    else
        savePath = fullfile(folderName, fileName);
    end
end

params = fillDefaults(params, sequenceType);

[Channels, sweepSpec] = buildSequence(sequenceType, params);
Sweeps = makeSweep(sweepSpec);

PSeq = PulseSequence(Channels, [], Sweeps, 1, params.sequenceName);
PSeq.setMWHWChannel(params.hw.mw);

if ~isempty(savePath)
    save(savePath, 'PSeq');
end

end

function params = fillDefaults(params, sequenceType)
hasSequenceName = isfield(params, 'sequenceName') && ~isempty(params.sequenceName);
hasPulseSpacing = isfield(params, 'pulseSpacing') && ~isempty(params.pulseSpacing);
params = setDefault(params, 'sequenceName', sequenceType);
params = setDefault(params, 'laserInitTime', 2e-6);
params = setDefault(params, 'laserReadoutTime', 2e-6);
params = setDefault(params, 'readoutDelay', 270e-9);
params = setDefault(params, 'counterWidth', 500e-9);
params = setDefault(params, 'delayLaserToMW', 2e-6);
params = setDefault(params, 'delayMWToReadout', 2e-6);
params = setDefault(params, 'piTime', 50e-9);
params = setDefault(params, 'piHalfTime', params.piTime/2);
params = setDefault(params, 'mwAmplitude', 1);
params = setDefault(params, 'pulseSpacing', 0);
params = setDefault(params, 'piHalfPhases', [0 0]);
params = setDefault(params, 'piPhase', 90);
params = setDefault(params, 'includeSecondReadout', []);
params = setDefault(params, 'xy8Blocks', 1);
params = setDefault(params, 'dsl4Pulses', 4);
params = setDefault(params, 'wahuhaPiHalfPhases', [90 90]);
params = setDefault(params, 'wahuhaPhaseBlock', [180 270 90 0 180 90 270 0 0 90 270 180 0 270 90 180]);
params = setDefault(params, 'wahuhaGapMultBlock', [1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2]);
params = setDefault(params, 'wahuhaPulseSpacingUnit', 50e-9);
params = setDefault(params, 'frequency', []);

if strcmpi(sequenceType, 'xy8') && ~hasSequenceName
    params.sequenceName = sprintf('XY8-%s', formatBlockCount(params.xy8Blocks));
end
if strcmpi(sequenceType, 'wahuha')
    params.dsl4GeneratedPulses = roundUpToMultiple(params.dsl4Pulses, 4);
    if ~hasPulseSpacing
        params.pulseSpacing = params.wahuhaPulseSpacingUnit;
    end
    if ~hasSequenceName
        params.sequenceName = sprintf('WAHUHA-%s', formatBlockCount(params.dsl4Pulses));
    end
end

if ~isfield(params, 'hw')
    params.hw = struct();
end
params.hw = setDefault(params.hw, 'counter', 2);
params.hw = setDefault(params.hw, 'laser', 1);
params.hw = setDefault(params.hw, 'mw', 3);
params.hw = setDefault(params.hw, 'endMarker', 5);

if ~isfield(params, 'sweep')
    params.sweep = struct();
end
params.sweep = setDefault(params.sweep, 'target', '');
params.sweep = setDefault(params.sweep, 'halfWidth', []);
params.sweep = setDefault(params.sweep, 'minStart', 10e-9);

switch lower(sequenceType)
    case 'rabi'
        params.sweep = setDefault(params.sweep, 'start', 0);
        params.sweep = setDefault(params.sweep, 'stop', 500e-9);
        params.sweep = setDefault(params.sweep, 'points', 101);
    otherwise
        params.sweep = setDefault(params.sweep, 'start', 20e-9);
        params.sweep = setDefault(params.sweep, 'stop', 2e-6);
        params.sweep = setDefault(params.sweep, 'points', 101);
end

params = applyLarmorSweepDefaults(params, sequenceType);
params = applySecondReadoutDefault(params, sequenceType);
end

function s = setDefault(s, fieldName, value)
if ~isfield(s, fieldName) || isempty(s.(fieldName))
    s.(fieldName) = value;
end
end

function text = formatBlockCount(value)
if isnumeric(value) && isscalar(value) && isfinite(value) && value == round(value)
    text = sprintf('%d', value);
else
    text = num2str(value);
end
end

function value = roundUpToMultiple(value, multiple)
if ~isnumeric(value) || ~isscalar(value) || ~isfinite(value) || value <= 0 || value ~= round(value)
    error('dsl4Pulses must be a positive integer scalar.');
end
value = ceil(value/multiple)*multiple;
end

function params = applySecondReadoutDefault(params, sequenceType)
if isempty(params.includeSecondReadout)
    if any(strcmpi(sequenceType, {'t1', 'ramsey', 'ramesy', 'hannecho', 'hahnecho', 'hahn_echo', 'xy8', 'wahuha'}))
        params.includeSecondReadout = true;
    else
        params.includeSecondReadout = false;
    end
end
params.includeSecondReadout = isTruthy(params.includeSecondReadout);
end

function tf = isTruthy(value)
if isempty(value)
    tf = false;
elseif islogical(value) || isnumeric(value)
    tf = any(value ~= 0);
elseif ischar(value)
    tf = any(strcmpi(value, {'true', 'on', 'yes', '1'}));
elseif isstring(value)
    tf = any(strcmpi(cellstr(value), {'true', 'on', 'yes', '1'}));
else
    tf = logical(value);
end
end

function params = applyLarmorSweepDefaults(params, sequenceType)
if isempty(params.frequency) || isempty(params.sweep.target)
    return;
end

if ~any(strcmpi(sequenceType, {'xy8', 'hannecho', 'hahnecho', 'hahn_echo'}))
    return;
end

target = lower(params.sweep.target);
target = strrep(target, '-', '');
target = strrep(target, '_', '');
target = strrep(target, ' ', '');

switch target
    case {'proton', 'h', '1h'}
        larmorKHzPerGauss = getSweepValue(params.sweep, 'larmorKHzPerGauss', 4.2576);
    case {'fluorine', 'f', '19f'}
        larmorKHzPerGauss = getSweepValue(params.sweep, 'larmorKHzPerGauss', 4.0053);
    case {'carbon', 'c', '13c'}
        larmorKHzPerGauss = getSweepValue(params.sweep, 'larmorKHzPerGauss', 1.0705);
    otherwise
        return;
end

frequencyMHz = normalizeFrequencyMHz(params.frequency);
Bgauss = abs((2870 - frequencyMHz)/2.8);
if ~isfinite(Bgauss) || Bgauss <= 0
    return;
end

larmorPeriod = 1/(larmorKHzPerGauss*Bgauss*1000);
sweepCenter = (larmorPeriod/2 - params.piTime)/2;
halfWidth = params.sweep.halfWidth;
if isempty(halfWidth)
    halfWidth = 30e-9;
end

params.sweep.center = sweepCenter;
params.sweep.start = max(params.sweep.minStart, sweepCenter - halfWidth);
params.sweep.stop = max(params.sweep.start, sweepCenter + halfWidth);
params.sweep.center = roundToNs(params.sweep.center);
params.sweep.start = roundToNs(params.sweep.start);
params.sweep.stop = max(params.sweep.start, roundToNs(params.sweep.stop));
params.sweep.points = nsSweepPoints(params.sweep.start, params.sweep.stop);
end

function value = getSweepValue(sweep, fieldName, defaultValue)
if isfield(sweep, fieldName) && ~isempty(sweep.(fieldName))
    value = sweep.(fieldName);
else
    value = defaultValue;
end
end

function frequencyMHz = normalizeFrequencyMHz(frequency)
frequencyMHz = frequency;
if frequencyMHz > 1e6
    frequencyMHz = frequencyMHz/1e6;
end
end

function value = roundToNs(value)
value = round(value*1e9)/1e9;
end

function points = nsSweepPoints(startValue, stopValue)
points = round((stopValue - startValue)*1e9) + 1;
points = max(1, points);
end

function multipliers = makeXy8SweepMultipliers(numPiPulses)
% first pi/2, first pi, and final readout pi/2 move by one tau; middle pulses by two
multipliers = 2*ones(1, numPiPulses + 2);
multipliers([1 2 end]) = 1;
end

function values = repeatBlock(block, count)
if isempty(block)
    error('WAHUHA phase and gap blocks must not be empty.');
end
values = zeros(1, count);
for k = 1:count
    values(k) = block(mod(k - 1, numel(block)) + 1);
end
end

function multipliers = makeWahuhaGapMultipliers(block, count)
multipliers = repeatBlock(block, count);
if ~isempty(multipliers)
    multipliers(end) = 1;
end
end

function t = addWahuhaTrain(channel, t, phases, gapMultipliers, p, finalPhase)
addPulse(channel, t, p.piHalfTime, 'pi2', p.mwAmplitude, p.wahuhaPiHalfPhases(1), 1);
t = t + p.pulseSpacing;
for k = 1:numel(phases)
    addPulse(channel, t, p.piHalfTime, 'sweep', p.mwAmplitude, phases(k), gapMultipliers(k));
    t = t + p.pulseSpacing*gapMultipliers(k);
end
addPulse(channel, t, p.piHalfTime, 'sweep', p.mwAmplitude, finalPhase, 1);
t = t + p.piHalfTime;
end

function t = addXy8Train(channel, t, phases, sweepMultipliers, p, finalPhase, amplitude)
edgeSpacing = p.pulseSpacing/2;
middleSpacing = p.pulseSpacing;
addPulse(channel, t, p.piHalfTime, 'pi2', amplitude, p.piHalfPhases(1), sweepMultipliers(1));
t = t + p.piHalfTime + edgeSpacing;
for k = 1:numel(phases)
    addPulse(channel, t, p.piTime, 'sweep', amplitude, phases(k), sweepMultipliers(k+1));
    if k < numel(phases)
        t = t + p.piTime + middleSpacing;
    else
        t = t + p.piTime + edgeSpacing;
    end
end
addPulse(channel, t, p.piHalfTime, 'sweep', amplitude, finalPhase, sweepMultipliers(end));
t = t + p.piHalfTime;
end

function [Channels, sweepSpec] = buildSequence(sequenceType, p)
Channels = makeChannels(p.hw);

laserCh = 2;
counterCh = 1;
mwCh = 3;
markerCh = 4;
ramseySecondReadout = false;
ramseyMarkerTrain = false;
hahnMarkerTrain = false;
xy8SecondReadout = false;
xy8MarkerTrain = false;
xy8Phases = [];
xy8SweepMultipliers = [];
wahuhaSecondReadout = false;
wahuhaPhases = [];
wahuhaGapMultipliers = [];

addPulse(Channels(laserCh), 0, p.laserInitTime, 'Init', 1, 0);
addPulse(Channels(counterCh), p.readoutDelay, p.counterWidth, 'Counter', 1, 0);

t = p.laserInitTime + p.delayLaserToMW;
sweepSpec = struct('channel', mwCh, 'sweepClass', 'Type', 'type', 'Duration', ...
    'rise', 'MW', 'start', p.sweep.start, 'stop', p.sweep.stop, ...
    'points', p.sweep.points, 'shifts', 2, 'add', 1);

switch lower(sequenceType)
    case 'rabi'
        addPulse(Channels(mwCh), t, 0, 'MW', p.mwAmplitude, 0);
        sweepSpec.type = 'Duration';
        t = t + p.sweep.stop;

    case {'ramsey', 'ramesy'}
        addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1));
        t = t + p.piHalfTime + p.pulseSpacing;
        addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2));
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';
        t = t + p.piHalfTime;
        ramseySecondReadout = p.includeSecondReadout;
        ramseyMarkerTrain = p.includeSecondReadout;

    case {'hannecho', 'hahnecho', 'hahn_echo'}
        addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1));
        t = t + p.piHalfTime + p.pulseSpacing;
        addPulse(Channels(mwCh), t, p.piTime, 'sweep', p.mwAmplitude, p.piPhase);
        t = t + p.piTime + p.pulseSpacing;
        addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2));
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';
        t = t + p.piHalfTime;
        hahnMarkerTrain = p.includeSecondReadout;

    case 'xy8'
        xy8Phases = repmat([0 90 0 90 90 0 90 0], 1, p.xy8Blocks);
        xy8SweepMultipliers = makeXy8SweepMultipliers(numel(xy8Phases));
        t = addXy8Train(Channels(mwCh), t, xy8Phases, xy8SweepMultipliers, p, p.piHalfPhases(2), p.mwAmplitude);
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';
        xy8SecondReadout = p.includeSecondReadout;
        xy8MarkerTrain = p.includeSecondReadout;

    case 'wahuha'
        wahuhaPhases = repeatBlock(p.wahuhaPhaseBlock, p.dsl4GeneratedPulses);
        wahuhaGapMultipliers = makeWahuhaGapMultipliers(p.wahuhaGapMultBlock, p.dsl4GeneratedPulses);
        t = addWahuhaTrain(Channels(mwCh), t, wahuhaPhases, wahuhaGapMultipliers, p, p.wahuhaPiHalfPhases(2));
        sweepSpec.type = 'Frequency';
        sweepSpec.rise = 'sweep';
        sweepSpec.start = 2e6;
        sweepSpec.stop = 2e6;
        sweepSpec.points = 1;
        sweepSpec.shifts = 0;
        sweepSpec.add = 0;
        wahuhaSecondReadout = p.includeSecondReadout;

    case 't1'
        readoutTime = t+p.delayMWToReadout;
        addPulse(Channels(laserCh), readoutTime, p.laserReadoutTime, 'sweep', 1, 0);
        addPulse(Channels(counterCh), readoutTime + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
        t = readoutTime + p.laserReadoutTime;
        if p.includeSecondReadout
            t = t + p.delayLaserToMW;
            addPulse(Channels(mwCh), t, p.piTime, 'pi', p.mwAmplitude, p.piPhase);
            t = t + p.piTime + p.delayMWToReadout;
            addPulse(Channels(laserCh), t, p.laserReadoutTime, 'sweep', 1, 0);
            addPulse(Channels(counterCh), t + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
            t = t + p.laserReadoutTime;
        end
        sweepSpec.channel = laserCh;
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';

    otherwise
        error('Unsupported sequence type: %s', sequenceType);
end

if ~strcmpi(sequenceType, 't1')
    readoutTime = t + p.delayMWToReadout;
    addPulse(Channels(laserCh), readoutTime, p.laserReadoutTime, 'Readout', 1, 0);
    addPulse(Channels(counterCh), readoutTime + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
    t = readoutTime + p.laserReadoutTime;
end

if ramseySecondReadout
    t = t + p.delayLaserToMW;
    addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1));
    t = t + p.piHalfTime + p.pulseSpacing;
    addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2) + 180);
    t = t + p.piHalfTime;

    readoutTime = t + p.delayMWToReadout;
    addPulse(Channels(laserCh), readoutTime, p.laserReadoutTime, 'Readout', 1, 0);
    addPulse(Channels(counterCh), readoutTime + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
    t = readoutTime + p.laserReadoutTime;
end

if ramseyMarkerTrain
    t = t + p.delayLaserToMW;
    addPulse(Channels(markerCh), t, p.piHalfTime, 'pi2', 1, p.piHalfPhases(1));
    t = t + p.piHalfTime + p.pulseSpacing;
    addPulse(Channels(markerCh), t, p.piHalfTime, 'sweep', 1, p.piHalfPhases(2));
    t = t + p.piHalfTime;
end

if xy8SecondReadout
    t = t + p.delayLaserToMW;
    t = addXy8Train(Channels(mwCh), t, xy8Phases, xy8SweepMultipliers, p, p.piHalfPhases(2) + 180, p.mwAmplitude);

    readoutTime = t + p.delayMWToReadout;
    addPulse(Channels(laserCh), readoutTime, p.laserReadoutTime, 'Readout', 1, 0);
    addPulse(Channels(counterCh), readoutTime + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
    t = readoutTime + p.laserReadoutTime;
end

if xy8MarkerTrain
    t = t + p.delayLaserToMW;
    t = addXy8Train(Channels(markerCh), t, xy8Phases, xy8SweepMultipliers, p, p.piHalfPhases(2), 1);
end

if wahuhaSecondReadout
    t = t + p.delayLaserToMW;
    t = addWahuhaTrain(Channels(mwCh), t, wahuhaPhases, wahuhaGapMultipliers, p, p.wahuhaPiHalfPhases(2) + 180);

    readoutTime = t + p.delayMWToReadout;
    addPulse(Channels(laserCh), readoutTime, p.laserReadoutTime, 'Readout', 1, 0);
    addPulse(Channels(counterCh), readoutTime + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
    t = readoutTime + p.laserReadoutTime;
end

if hahnMarkerTrain
    t = t + p.delayLaserToMW;
    addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1));
    t = t + p.piHalfTime + p.pulseSpacing;
    addPulse(Channels(mwCh), t, p.piTime, 'sweep', p.mwAmplitude, p.piPhase);
    t = t + p.piTime + p.pulseSpacing;
    addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2) + 180);
    t = t + p.piHalfTime;

    readoutTime = t + p.delayMWToReadout;
    addPulse(Channels(laserCh), readoutTime, p.laserReadoutTime, 'Readout', 1, 0);
    addPulse(Channels(counterCh), readoutTime + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
    t = readoutTime + p.laserReadoutTime + p.delayLaserToMW;

    addPulse(Channels(markerCh), t, p.piHalfTime, 'pi2', 1, p.piHalfPhases(1));
    t = t + p.piHalfTime + p.pulseSpacing;
    addPulse(Channels(markerCh), t, p.piTime, 'sweep', 1, p.piPhase);
    t = t + p.piTime + p.pulseSpacing;
    addPulse(Channels(markerCh), t, p.piHalfTime, 'sweep', 1, p.piHalfPhases(2));
    t = t + p.piHalfTime;
end

addPulse(Channels(markerCh), t + p.delayMWToReadout, 0, 'End', 1, 0);
end

function Channels = makeChannels(hw)
Channels = [PulseChannel(), PulseChannel(), PulseChannel(), PulseChannel()];
Channels(1).setHWChannel(hw.counter);
Channels(2).setHWChannel(hw.laser);
Channels(3).setHWChannel(hw.mw);
Channels(4).setHWChannel(hw.endMarker);
end

function riseIndex = addPulse(channel, riseTime, duration, riseType, amplitude, phase, sweepMultiplier)
if nargin < 7
    sweepMultiplier = 1;
end
channel.addRise();
riseIndex = channel.NumberOfRises;
channel.setRiseParams(riseIndex, riseTime, duration, riseType, amplitude, phase, 0, sweepMultiplier);
end

function Sweeps = makeSweep(spec)
Sweeps = PulseSweep();
Sweeps.setSweepParams(spec.channel, spec.sweepClass, spec.type, spec.rise, ...
    spec.start, spec.stop, spec.points, spec.shifts, spec.add);
end
