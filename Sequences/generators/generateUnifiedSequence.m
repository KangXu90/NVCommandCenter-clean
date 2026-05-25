function [PSeq, params] = generateUnifiedSequence(sequenceType, params, savePath)
%GENERATEUNIFIEDSEQUENCE Unified first-pass generator for common NV sequences.
%
% Usage:
%   PSeq = generateUnifiedSequence('Rabi');
%   PSeq = generateUnifiedSequence('Ramsey', struct('piTime',50e-9));
%   [PSeq, params] = generateUnifiedSequence('XY8', params, 'my_xy8.mat');
%   PSeq = generateUnifiedSequence('Rabi', params, ''); % do not save
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
params = setDefault(params, 'pulseSpacing', 1e-9);
params = setDefault(params, 'piHalfPhases', [0 0]);
params = setDefault(params, 'piPhase', 90);
params = setDefault(params, 'xy8Blocks', 1);

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
end

function s = setDefault(s, fieldName, value)
if ~isfield(s, fieldName) || isempty(s.(fieldName))
    s.(fieldName) = value;
end
end

function [Channels, sweepSpec] = buildSequence(sequenceType, p)
Channels = makeChannels(p.hw);

laserCh = 2;
counterCh = 1;
mwCh = 3;
markerCh = 4;
hahnMarkerTrain = false;

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

    case 'ramsey'
        addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1));
        t = t + p.piHalfTime + p.pulseSpacing;
        addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2));
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';
        t = t + p.piHalfTime + p.sweep.stop;

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
        phases = repmat([0 90 0 90 90 0 90 0], 1, p.xy8Blocks);
        addPulse(Channels(mwCh), t, p.piHalfTime, 'pi2', p.mwAmplitude, p.piHalfPhases(1));
        t = t + p.piHalfTime + p.pulseSpacing;
        for k = 1:numel(phases)
            addPulse(Channels(mwCh), t, p.piTime, 'sweep', p.mwAmplitude, phases(k));
            t = t + p.piTime + p.pulseSpacing;
        end
        addPulse(Channels(mwCh), t, p.piHalfTime, 'sweep', p.mwAmplitude, p.piHalfPhases(2));
        sweepSpec.type = 'Time';
        sweepSpec.rise = 'sweep';
        t = t + p.piHalfTime + (2*numel(phases)+1)*p.sweep.stop;

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

function riseIndex = addPulse(channel, riseTime, duration, riseType, amplitude, phase)
channel.addRise();
riseIndex = channel.NumberOfRises;
channel.setRiseParams(riseIndex, riseTime, duration, riseType, amplitude, phase, 0, 1);
end

function Sweeps = makeSweep(spec)
Sweeps = PulseSweep();
Sweeps.setSweepParams(spec.channel, spec.sweepClass, spec.type, spec.rise, ...
    spec.start, spec.stop, spec.points, spec.shifts, spec.add);
end
