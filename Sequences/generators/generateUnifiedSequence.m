function [PSeq, params] = generateUnifiedSequence(sequenceType, params, savePath)
%GENERATEUNIFIEDSEQUENCE Unified first-pass generator for common NV sequences.
%
% Usage:
%   PSeq = generateUnifiedSequence('Rabi');
%   PSeq = generateUnifiedSequence('Ramsey', struct('piTime',50e-9));
%   [PSeq, params] = generateUnifiedSequence('XY8', params, 'my_xy8.mat'); % also returns defaults/calculated sweep values
%   PSeq = generateUnifiedSequence('Rabi', params, ''); % no save dialog/file; sequence is returned in PSeq
%   % Step-by-step Larmor-centered XY8/Hahn sweep setup:
%   params.frequency = 828e6; params.sweep.target = 'proton';
%   % One-line command to copy/paste; omitting savePath opens the save dialog:
%   generateUnifiedSequence('XY8', struct('frequency',828e6,'piTime',50e-9,'piHalfTime',25e-9,'xy8Blocks',8,'sweep',struct('target','proton')));
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
params = setDefault(params, 'sequenceName', sequenceType);
params = setDefault(params, 'laserInitTime', 10e-6);
params = setDefault(params, 'laserReadoutTime', 10e-6);
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
params = setDefault(params, 'xy8Blocks', 1);
params = setDefault(params, 'frequency', []);

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
end

function s = setDefault(s, fieldName, value)
if ~isfield(s, fieldName) || isempty(s.(fieldName))
    s.(fieldName) = value;
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
        ramseySecondReadout = true;
        ramseyMarkerTrain = true;

    case {'hannecho', 'hahnecho', 'hahn_echo'}
        addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1));
        t = t + p.piHalfTime + p.pulseSpacing;
        addPulse(Channels(mwCh), t, p.piTime, 'sweep', p.mwAmplitude, p.piPhase);
        t = t + p.piTime + p.pulseSpacing;
        addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2));
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';
        t = t + p.piHalfTime;
        hahnMarkerTrain = true;

    case 'xy8'
        xy8Phases = repmat([0 90 0 90 90 0 90 0], 1, p.xy8Blocks);
        xy8SweepMultipliers = makeXy8SweepMultipliers(numel(xy8Phases));
        addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1), xy8SweepMultipliers(1));
        t = t + p.piHalfTime + p.pulseSpacing;
        for k = 1:numel(xy8Phases)
            addPulse(Channels(mwCh), t, p.piTime, 'sweep', p.mwAmplitude, xy8Phases(k), xy8SweepMultipliers(k+1));
            t = t + p.piTime + p.pulseSpacing;
        end
        addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2), xy8SweepMultipliers(end));
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';
        t = t + p.piHalfTime;
        xy8SecondReadout = true;
        xy8MarkerTrain = true;

    case 't1'
        readoutTime = t;
        addPulse(Channels(laserCh), readoutTime, p.laserReadoutTime, 'sweep', 1, 0);
        addPulse(Channels(counterCh), readoutTime + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
        sweepSpec.channel = laserCh;
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';
        t = readoutTime + p.sweep.stop + p.laserReadoutTime;

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
    addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1), xy8SweepMultipliers(1));
    t = t + p.piHalfTime + p.pulseSpacing;
    for k = 1:numel(xy8Phases)
        addPulse(Channels(mwCh), t, p.piTime, 'sweep', p.mwAmplitude, xy8Phases(k), xy8SweepMultipliers(k+1));
        t = t + p.piTime + p.pulseSpacing;
    end
    addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2) + 180, xy8SweepMultipliers(end));
    t = t + p.piHalfTime;

    readoutTime = t + p.delayMWToReadout;
    addPulse(Channels(laserCh), readoutTime, p.laserReadoutTime, 'Readout', 1, 0);
    addPulse(Channels(counterCh), readoutTime + p.readoutDelay, p.counterWidth, 'Counter', 1, 0);
    t = readoutTime + p.laserReadoutTime;
end

if xy8MarkerTrain
    t = t + p.delayLaserToMW;
    addPulse(Channels(markerCh), t, p.piHalfTime, 'pi2', 1, p.piHalfPhases(1), xy8SweepMultipliers(1));
    t = t + p.piHalfTime + p.pulseSpacing;
    for k = 1:numel(xy8Phases)
        addPulse(Channels(markerCh), t, p.piTime, 'sweep', 1, xy8Phases(k), xy8SweepMultipliers(k+1));
        t = t + p.piTime + p.pulseSpacing;
    end
    addPulse(Channels(markerCh), t, p.piHalfTime, 'sweep', 1, p.piHalfPhases(2), xy8SweepMultipliers(end));
    t = t + p.piHalfTime;
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
