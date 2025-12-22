function cfg = site_ccny()
% site_ccny  CCNY site configuration for NVCommandCenter / ImageAcquire.
% Centralize all paths + device names + channel mappings here.

cfg = struct();
cfg.site = 'ccny';
cfg.root = projectRoot();

%% ---------- Paths (project-relative) ----------
cfg.paths = struct();
cfg.paths.config = fullfile(cfg.root, 'config');
cfg.paths.sequences = fullfile(cfg.root, 'Sequences');

% Optional data folder (change as you like)
cfg.paths.data = struct();
cfg.paths.data.spinNoise = fullfile(cfg.root, 'data', 'SpinNoise');

%% ---------- NI-DAQ (DAQmx) ----------
cfg.ni = struct();
cfg.ni.libraryName = 'nidaqmx';

% nicaiu.dll (DAQmx C API). Prefer WINDIR, fallback to common location.
windir_ = getenv('WINDIR');
dll1 = fullfile(windir_, 'System32', 'nicaiu.dll');
dll2 = 'C:\WINDOWS\system32\nicaiu.dll';
cfg.ni.dll = firstExistingFile({dll1, dll2});

% Header (use the one shipped in your repo config/)
hdr1 = fullfile(cfg.paths.config, 'NIDAQmx.h');

% Fallback: NI default include path (optional)
hdr2 = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

cfg.ni.header = firstExistingFile({hdr1, hdr2});

% Device name and wiring mappings (EDIT HERE if you rewire)
cfg.ni.dev = 'Dev1';

% Counter inputs (APD TTL / etc.)
cfg.ni.counter = struct();
cfg.ni.counter.ctr0 = sprintf('%s/ctr0', cfg.ni.dev);
cfg.ni.counter.ctr1 = sprintf('%s/ctr1', cfg.ni.dev);

cfg.ni.counter.pfi0  = sprintf('/%s/PFI0',  cfg.ni.dev);   % TTL in (often APD)
cfg.ni.counter.pfi13 = sprintf('/%s/PFI13', cfg.ni.dev);   % alt TTL/clock line

% Clock lines (if you use internal/external clock selection)
cfg.ni.clock = struct();
cfg.ni.clock.internal = cfg.ni.counter.ctr1;   % uses ctr1 as clock source in your scripts, only for CounterAcquisition used for tracking and viewCounterAcquisition
cfg.ni.clock.pfi13    = cfg.ni.counter.pfi13;  % corresponding PFI terminal, connect to gating of PulseBlaster
cfg.ni.clock.externalName = 'Ext';
cfg.ni.clock.externalPFI  = cfg.ni.counter.pfi0;% TTL from APD works like sample clock to count on gating of PB

% Analog outputs for galvo (ImageAcquire)
cfg.ni.ao = struct();
cfg.ni.ao.x = sprintf('%s/ao0', cfg.ni.dev);
cfg.ni.ao.y = sprintf('%s/ao1', cfg.ni.dev);
%% ---------- Sanity checks ----------
% You can comment these out if you prefer "silent" config.
mustExist = {
    cfg.ni.dll, 'file', 'NI-DAQmx nicaiu.dll not found'
    cfg.ni.header, 'file', 'NIDAQmx.h not found (repo config or NI include)'
};

for k = 1:size(mustExist,1)
    p = mustExist{k,1};
    t = mustExist{k,2};
    msg = mustExist{k,3};
    if isempty(p) || exist(p, t) == 0
        warning('[site_ccny] %s. Path="%s"', msg, p);
    end
end
%% ---------- SpinCore / PulseBlaster (optional) ----------
cfg.spincore = struct();
cfg.spincore.libraryName = 'pb';

% Candidates (edit if your SpinCore install differs)
cfg.spincore.dll = firstExistingFile({
    'C:\SpinCore\SpinAPI\lib\spinapi64.dll', ...
    'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.dll' ...
});

cfg.spincore.header_spinapi = firstExistingFile({
    'C:\SpinCore\SpinAPI\include\spinapi.h', ...
    'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.h' ...
});

cfg.spincore.header_pulseblaster = firstExistingFile({
    'C:\SpinCore\SpinAPI\include\pulseblaster.h', ...
    'C:\SpinCore\SpinAPI\include\pulseblaster.h' ...
});
%% ---------- PI piezostage ----------
cfg.pi = struct();
cfg.pi.alias = 'E816';
cfg.pi.dll   = fullfile(cfg.root,'drivers','E816_DLL_x64.dll');
cfg.pi.h     = fullfile(cfg.root,'drivers','E816_DLL.h');

%% ---------- Tabor Proteus (TEProteusInst) ----------
cfg.tabor = struct();

% Enable/disable Proteus init from scripts
cfg.tabor.enable = true;

% Communication
cfg.tabor.connStr = '134.74.27.16';    % Proteus IP
cfg.tabor.paranoia_level = 1;          % 0 / 1 / 2

% Optional identification / expectations
cfg.tabor.idn_expected = 'P9484D';     % your instrument ID (optional)
cfg.tabor.do_reset = true;             % send *RST
cfg.tabor.do_clear = true;             % send *CLS

% Optional: make Proteus also serve as SignalGenerator handle
cfg.tabor.expose_as_signal_generator = true;
%% ---------- Microwave Amplifier (VISA-Serial) ----------
cfg.mwAmp = struct();
cfg.mwAmp.enable = true;

% VISA vendor (depends on your VISA installation: 'NI' is common)
cfg.mwAmp.vendor = 'NI';

% Resource name (Serial over VISA)
cfg.mwAmp.rsrc = 'ASRL5::INSTR';

% Serial settings (adjust to your amp spec)
cfg.mwAmp.baudRate = 9600;
cfg.mwAmp.dataBits = 8;
cfg.mwAmp.stopBits = 1;
cfg.mwAmp.parity   = 'none';
cfg.mwAmp.terminator = 'LF';     % or 'CR/LF' if needed
cfg.mwAmp.timeout = 2;           % seconds

% Optional: whether to close existing found object
cfg.mwAmp.closeExisting = true;

end


%% -------- helper: pick first existing file from candidates --------
function f = firstExistingFile(candidates)
f = '';
for i = 1:numel(candidates)
    c = candidates{i};
    if ~isempty(c) && exist(c, 'file') == 2
        f = c;
        return;
    end
end
% If none exists, return first candidate (so user sees intended path)
if ~isempty(candidates)
    f = candidates{1};
end
end
