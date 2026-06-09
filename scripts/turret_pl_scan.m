% turret_pl_scan.m
% Moves the Zeiss turret through positions (low→high laser power) and
% records PL counts using the shared niObj handle – same pattern as the
% magnetalignment app.
%
% niObj is found automatically from the running magnetalignment app.
% If you do not want to use the GUI app, define niObj before running this script,
% or initialize it using your own hardware setup code.
%
% Example:
%   handles = ccnyInitScript(struct());
%   niObj = handles.NI;
%
% OUTPUT variables left in workspace:
%   POSITIONS, LASER_POWER_MW, plCounts, plStd

%% ================================================================
%  USER SETTINGS  –  edit this section before running
%% ================================================================

% --- Turret serial port ---
COM_PORT  = 'COM6';
BAUD_RATE = 115200;

% --- Turret positions ordered from lowest to highest laser power ---
% Measured powers per physical position:
%   Pos 3 = 0.0042 mW  |  Pos 2 = 0.0105 mW  |  Pos 1 = 0.037 mW
%   Pos 8 = 0.118  mW  |  Pos 7 = 0.428  mW  |  Pos 6 = 1.4   mW
%   Pos 4 = 5.3    mW  |  Pos 5 = 5.3    mW
POSITIONS      = [3,      2,      1,     8,     7,     6,   4,   5  ];
LASER_POWER_MW = [0.0042, 0.0105, 0.037, 0.118, 0.428, 1.4, 5.3, 5.3];

% --- Acquisition settings ---
DWELL_TIME_S  = 0.10;   % APD integration time per sample (s)
N_AVERAGES    = 5;       % samples averaged per position
SETTLE_TIME_S = 0.5;    % settle time after turret move (s)

%% ================================================================
%  VALIDATION
%% ================================================================

assert(length(LASER_POWER_MW) == length(POSITIONS), ...
    'LASER_POWER_MW and POSITIONS must be the same length.');

% --- Find NI handle from the running magnetalignment app ---
% Same pattern as ccnyInitScript: scan getappdata(0) for the app figure,
% then get the App Designer object via getappdata(hFig,'App'), same as
% guidata() for old GUIDE apps.
%% LOOK FOR ImageAcquire
apps = getappdata(0);
fN = fieldnames(apps);
for k=1:numel(fN),
    if ishandle(getfield(apps,fN{k})),
        try
            name = get(getfield(apps,fN{k}),'Name');
        catch ME
            name = 'failed';
        end
        if strcmp('ImageAcquire',name),
            hFig = getfield(apps,fN{k});
            IAHandles = guidata(hFig);
            niObj = IAHandles.Tracker;
            break;
        end
    end
end

if isempty(niObj)
    error('Could not find a running magnetalignment app. Please start it first.');
end

%% ================================================================
%  TURRET SERIAL PORT SETUP
%% ================================================================

% Close any leftover port from a previous interrupted run
if exist('s', 'var'), clear s; end

fprintf('Opening %s at %d baud ...\n', COM_PORT, BAUD_RATE);
s = serialport(COM_PORT, BAUD_RATE, 'Timeout', 8);
configureTerminator(s, 'LF');
flush(s);
pause(2);                          % wait for Arduino to boot and send banner
while s.NumBytesAvailable > 0     % drain startup banner
    readline(s);
    pause(0.05);
end
fprintf('Serial port ready.\n\n');

%% ================================================================
%  ACQUISITION LOOP
%% ================================================================

nPos     = length(POSITIONS);
plCounts = zeros(1, nPos);
plStd    = zeros(1, nPos);

origDwell = niObj.hCounterAcquisition.DwellTime;
niObj.hCounterAcquisition.DwellTime = DWELL_TIME_S;

fprintf('%-6s  %-12s  %-15s  %-12s\n', ...
    'Pos', 'Power (mW)', 'PL (cts/s)', 'Std (cts/s)');
fprintf('%s\n', repmat('-', 1, 50));

try
    for k = 1:nPos
        pos = POSITIONS(k);

        % --- Move turret ---
        writeline(s, sprintf('GOTO %d', pos));
        resp = strtrim(char(readline(s)));
        if ~startsWith(resp, 'OK')
            warning('GOTO %d returned: %s  – skipping.', pos, resp);
            plCounts(k) = NaN;  plStd(k) = NaN;
            continue;
        end

        pause(SETTLE_TIME_S);

        % --- Acquire N_AVERAGES samples (same pattern as ImageAcquisitionThorlabs) ---
        samples = zeros(1, N_AVERAGES);
        for n = 1:N_AVERAGES
            niObj.laserOn();
            niObj.hCounterAcquisition.GetCountsPerSecond();
            samples(n) = niObj.hCounterAcquisition.CountsPerSecond;
            niObj.laserOff();
            pause(0.05);
        end

        plCounts(k) = mean(samples);
        plStd(k)    = std(samples);

        fprintf('%-6d  %-12.4f  %-15.0f  %-12.0f\n', ...
            pos, LASER_POWER_MW(k), plCounts(k), plStd(k));
    end

catch ME
    niObj.hCounterAcquisition.DwellTime = origDwell;
    niObj.laserOff();
    clear s;
    rethrow(ME);
end

niObj.hCounterAcquisition.DwellTime = origDwell;
clear s;
fprintf('\nScan complete.\n');

%% ================================================================
%  PLOTS
%% ================================================================

validMask = ~isnan(plCounts);
pw  = LASER_POWER_MW(validMask);
pl  = plCounts(validMask) / 1e3;
err = plStd(validMask)    / 1e3;

%% ================================================================
%  EXPONENTIAL FIT:  PL = A * (1 - exp(-P / P_sat))
%  A     = saturation PL (kcounts/s)
%  P_sat = saturation power (mW) – power at which PL reaches 63% of A
%% ================================================================

ftModel = fittype('A * (1 - exp(-P / Psat))', ...
    'independent', 'P', 'coefficients', {'A', 'Psat'});

fitResult  = fit(pw(:), pl(:), ftModel, ...
    'StartPoint', [max(pl), median(pw)], ...
    'Lower',      [0,       0          ]);

A_fit    = fitResult.A;
Psat_fit = fitResult.Psat;
PL_at_sat = A_fit * (1 - exp(-1));   % PL at P = P_sat (~63% of A)

fprintf('\n--- Fit: PL = A*(1-exp(-P/Psat)) ---\n');
fprintf('  A (saturation PL) = %.2f  kcounts/s\n', A_fit);
fprintf('  P_sat             = %.4f  mW\n',          Psat_fit);
fprintf('  PL at P_sat       = %.2f  kcounts/s  (63%% of max)\n', PL_at_sat);

% --- Plot data + fit ---
P_fine = linspace(0, max(pw)*1.05, 300);

figure('Name', 'Turret PL vs Laser Power', 'NumberTitle', 'off');
errorbar(pw, pl, err, 'o', 'LineWidth', 1.5, 'MarkerSize', 7, ...
    'Color', [0.22 0.49 0.72], 'MarkerFaceColor', [0.22 0.49 0.72], ...
    'DisplayName', 'Data');
hold on;
plot(P_fine, fitResult(P_fine), 'r-', 'LineWidth', 2, ...
    'DisplayName', sprintf('Fit (P_{sat}=%.3f mW)', Psat_fit));
plot(Psat_fit, PL_at_sat, 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r', ...
    'DisplayName', sprintf('P_{sat}, %.2f kcps', PL_at_sat));
hold off;
xlabel('Laser Power (mW)');
ylabel('PL Signal (kcounts/s)');
title('PL vs Laser Power – turret scan');
legend('Location', 'southeast');
grid on;


%% ================================================================
%  SUMMARY TABLE
%% ================================================================

fprintf('\n%-6s  %-12s  %-15s  %-15s  %-12s\n', ...
    'Pos', 'Power (mW)', 'PL (cts/s)', 'Fit (cts/s)', 'Std (cts/s)');
fprintf('%s\n', repmat('-', 1, 65));
for k = 1:nPos
    if isnan(plCounts(k))
        fprintf('%-6d  %-12.4f  %-15s  %-15s  %-12s\n', ...
            POSITIONS(k), LASER_POWER_MW(k), 'FAILED', 'FAILED', 'FAILED');
    else
        plFit_k = fitResult(LASER_POWER_MW(k)) * 1e3;   % back to cts/s
        fprintf('%-6d  %-12.4f  %-15.0f  %-15.0f  %-12.0f\n', ...
            POSITIONS(k), LASER_POWER_MW(k), plCounts(k), plFit_k, plStd(k));
    end
end
