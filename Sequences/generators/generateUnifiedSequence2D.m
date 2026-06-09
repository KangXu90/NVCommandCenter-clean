function [PSeq, params] = generateUnifiedSequence2D(sequenceType, params, savePath)
%GENERATEUNIFIEDSEQUENCE2D  2D-sweep wrapper around generateUnifiedSequence.
%
% Builds a PulseSequence with TWO sweep axes for the '2D-sweep' acquisition
% mode in NVCommandCenter.  Axis 1 is the native sweep of the chosen
% sequenceType (e.g. Rabi -> Duration of the MW pulse, the first MW pulse).
% Axis 2 is an additional PulseSweep defined by params.sweep2 (default:
% per-pulse IQ frequency offset on the first MW pulse).
%
% Axis convention (matches PulseSequence.incr, rightmost-fastest):
%   Sweeps(1) = outer / rows  (axis 1, from sequenceType native sweep)
%   Sweeps(2) = inner / cols  (axis 2, params.sweep2)
%
% The returned PSeq can be fine-tuned in the ConfigurePulseSweeps GUI; both
% sweeps appear in the listbox and edits persist on the live handle.
%
% Example (Rabi duration x per-pulse frequency offset):
%   generateUnifiedSequence2D('Rabi', struct( ...
%       'sequenceName','Rabi2D', ...
%       'sweep',  struct('start',0,'stop',200e-9,'points',41), ...
%       'sweep2', struct('start',-5e6,'stop',5e6,'points',21)));
%
% params.sweep2 fields (all optional, defaults shown):
%   channel    = params.hw.mw (3)   % channel to sweep
%   sweepClass = 'Type'             % 'Type' (all pulses of a type) or 'Rise'
%   type       = 'Frequency'        % Duration/Time/Amplitude/Phase/Frequency
%   rise       = 'MW'               % type label (Class 'Type') or rise index
%   start, stop, points             % required-ish; default -5e6,5e6,21
%   shifts     = 0                  % 0/1/2 timing shift behaviour
%   add        = 0                  % 0=replace, 1=add to baseline
%
% NOTE: 'Frequency' is only supported by ProcessPulseSequence under
% SweepClass='Type' (ProcessRiseClass handles Time/Duration/Amplitude/Phase
% only). For Rabi the MW pulse is the single 'MW'-typed rise, so a
% Type/'MW' frequency sweep is exactly the first MW pulse's frequency.

if nargin < 1 || isempty(sequenceType)
    sequenceType = 'Rabi';
end
if nargin < 2 || isempty(params)
    params = struct();
end
if nargin < 3
    [fileName, folderName] = uiputfile('*.mat', 'Save 2D pulse sequence');
    if isequal(fileName, 0)
        savePath = '';
    else
        savePath = fullfile(folderName, fileName);
    end
end

% Axis 1: build the base sequence + native sweep (no save here).
[PSeq, params] = generateUnifiedSequence(sequenceType, params, '');

% Axis 2: append a second sweep from params.sweep2.
if ~isfield(params, 'sweep2') || isempty(params.sweep2)
    params.sweep2 = struct();
end
spec2 = fillSweep2Defaults(params.sweep2, params.hw.mw);
params.sweep2 = spec2;

PSeq.addSweep();
PSeq.Sweeps(end).setSweepParams(spec2.channel, spec2.sweepClass, spec2.type, ...
    spec2.rise, spec2.start, spec2.stop, spec2.points, spec2.shifts, spec2.add);

if ~isempty(savePath)
    save(savePath, 'PSeq');
end

end

function spec = fillSweep2Defaults(spec, mwChannel)
spec = setDefault(spec, 'channel', mwChannel);
spec = setDefault(spec, 'sweepClass', 'Type');
spec = setDefault(spec, 'type', 'Frequency');
spec = setDefault(spec, 'rise', 'MW');
spec = setDefault(spec, 'start', -5e6);
spec = setDefault(spec, 'stop', 5e6);
spec = setDefault(spec, 'points', 21);
spec = setDefault(spec, 'shifts', 0);
spec = setDefault(spec, 'add', 0);
end

function s = setDefault(s, fieldName, value)
if ~isfield(s, fieldName) || isempty(s.(fieldName))
    s.(fieldName) = value;
end
end
