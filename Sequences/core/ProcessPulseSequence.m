function [Sequence, tempPS, AWGPS, TimeVector] = ProcessPulseSequence(varargin)
% PROCESSPULSESEQUENCE
% [Sequence, tempPS, AWGPS, TimeVector] = ProcessPulseSequence(PSeq, SourceFreq)
% [Sequence, tempPS, AWGPS, TimeVector] = ProcessPulseSequence(PSeq, SourceFreq, SeqType)
% [Sequence, tempPS, AWGPS, TimeVector] = ProcessPulseSequence(PSeq, SourceFreq, SeqType, AWGfrequency)
%
% 输出:
%   - Sequence:   PulseBlaster 指令结构 (Fields: Length, Data)
%   - tempPS:     应用 sweep 后的 PulseSequence 对象（仍是对象/克隆）
%   - AWGPS:      AWG 的“二值数组”视图 (int16 [nChannels x nSamples])
%   - TimeVector: 本次 sweep 用到的时间/参数向量（若存在）
%
% 说明:
%   1) 始终返回 PB 的指令 & AWG 的数组视图（与 SeqType 无关）
%   2) PB 触发通道：查找 HWChannel==3 的通道，仅保留第一脉冲，300 ns 宽度
%   3) AWG 视图：仅保留 HWChannel>=3 的通道，并删除 HWChannel==5 的“参考通道”
%   4) 保留对齐首个上升沿的逻辑

% ----------- 解析参数 -----------
if nargin < 2
    error('Usage: ProcessPulseSequence(PSeq, SourceFreq, [SeqType], [AWGfrequency])');
end
PSeq         = varargin{1};
SourceFreq   = varargin{2};           % PB/Instruction 的时钟（如 400e6）
SeqType      = 'Binary';
AWGfrequency = 1.0e9;                 % 默认 AWG 基带采样率（你的代码是 1.0e9）
if nargin >= 3 && ~isempty(varargin{3}), SeqType = varargin{3}; end %#ok<NASGU>
if nargin >= 4 && ~isempty(varargin{4}), AWGfrequency = varargin{4}; end

% ----------- (可选) 时间栅格化设置（默认关闭）-----------
% dt_pb  = 1/SourceFreq;   % PB tick = 2.5 ns
% dt_awg = 1/AWGfrequency;     % AWG tick = 1 ns
% NOTE: 若开启，请在 sweep 应用后、生成 PB/AWG 之前调用 quantizePS()。
% 并可选做“跨设备 5 ns 对齐”（LCM(2.5,1)=5 ns），示例见下方注释。

% ----------- 应用 sweep -----------
TimeVector = [];
tempPS     = PSeq;
if ~isempty(PSeq.Sweeps)
    [tempPS, TimeVector] = PulseSequenceSweepToArray(PSeq);
end

% ----------- (可选) 先量化到 PB tick（默认关闭；解除下一行注释启用）-----------
% tempPS = quantizePS(tempPS, 1/SourceFreq, 'contain');  % 'round' 或 'contain'

% ----------- 生成 PulseBlaster 指令视图 -----------
pbSeqObj = shrinkPBTriggerChannel(tempPS);                % 仅保留 HWChannel==3 的第一个脉冲
Sequence  = PulseSequenceToInstruction(pbSeqObj, SourceFreq);


% ----------- 生成 AWG 视图（删除无关通道，对齐首沿，转数组）-----------
awgPS   = buildAWGView(tempPS);                           % 仅保留 HWChannel>=3；删 ref(5)
awgPS   = alignFirstRiseToZero(awgPS);                    % 对齐首 rise
AWGPS   = PulseSequenceToArray(awgPS, AWGfrequency);      % int16 矩阵: 通道 x 采样点

% ----------- (可选) 将 awgPS 量化到 AWG tick（默认关闭）-----------
% awgPS = quantizePS(awgPS, 1/AWGfrequency, 'contain');
% AWGPS = PulseSequenceToArray(awgPS, AWGfrequency);


% ----------- (可选) 跨设备 5ns 对齐示意（默认关闭）-----------
% 想法：将“关键边沿时间”（如 PB 触发) 先量化到 5 ns，再各自映射到 1 ns / 2.5 ns。
% keyTimes = collectKeyEdges(pbSeqObj, awgPS);
% keyTimes_5ns = round(keyTimes / 5e-9) * 5e-9;
% % 然后把 keyTimes_5ns 写回 tempPS/awgPS，再分别 quantizePS(...)
% % 这里仅示意，不默认修改。

end % ====== 主函数结束 ======


% ==================== 子函数区 ====================

function PS = buildAWGView(PSin)
% 仅保留 AWG 相关通道；这里假定 AWG 使用 HWChannel>=3（含 3、5 等）
% 注意：不再删除 HWChannel==5

PS = PSin.clone();

AWGmask = arrayfun(@(c) isprop(c,'HWChannel') && ~isempty(c.HWChannel) && c.HWChannel >= 3, PS.Channels);

AWGidx  = find(AWGmask);           % 索引
PS.Channels = PS.Channels(AWGmask);    % 子集（如需）
end



function PS = alignFirstRiseToZero(PS)
% 找到所有保留通道的最早 rise，并整体左移，使最早 rise = 0
if isempty(PS.Channels), return; end
firstRise = +inf;
for k = 1:numel(PS.Channels)
    if ~isempty(PS.Channels(k).RiseTimes)
        firstRise = min(firstRise, min(PS.Channels(k).RiseTimes));
    end
end
if ~isfinite(firstRise) || firstRise == 0
    return;
end
for k = 1:numel(PS.Channels)
    PS.Channels(k).RiseTimes = PS.Channels(k).RiseTimes - firstRise;
end
end


function PB = shrinkPBTriggerChannel(PSin)
% 寻找 PB 触发通道（HWChannel==3），仅保留一个脉冲（300 ns）
% 其开始时间对齐到 “AWG 两路中更早的 first rise”
% 这里默认你的 AWG 两路是 HWChannel==3 和/或 HWChannel==5
% 若 3/5 都不存在，则回退到之前“保留自己的第一脉冲”的行为

PB = PSin.clone();

% 1) 找到 PB 触发通道（仍用 HWChannel==3 作为 PB 的触发线）
idxPB = [];
for k = 1:numel(PB.Channels)
    if isprop(PB.Channels(k),'HWChannel') && PB.Channels(k).HWChannel == 3
        idxPB = k; break;
    end
end
if isempty(idxPB)
    % 找不到触发线就不处理
    return;
end

% 2) 计算 AWG 两路(first rise)的最早时间：优先看 {3,5}；若都没有再看 >=3 的任意通道
awgCandidates = [3,5];
earliestAWG = +inf;
found = false;

% 先按 {3,5} 精确找
for k = 1:numel(PSin.Channels)
    ch = PSin.Channels(k);
    if ~isprop(ch,'HWChannel') || isempty(ch.RiseTimes), continue; end
    if any(ch.HWChannel == awgCandidates)
        earliestAWG = min(earliestAWG, min(ch.RiseTimes));
        found = true;
    end
end

% 如果 {3,5} 都没有，再回退到所有 HWChannel>=3 的通道
if ~found
    for k = 1:numel(PSin.Channels)
        ch = PSin.Channels(k);
        if ~isfield(ch,'HWChannel') || isempty(ch.RiseTimes), continue; end
        if ch.HWChannel >= 3
            earliestAWG = min(earliestAWG, min(ch.RiseTimes));
            found = true;
        end
    end
end

% 3) 压缩 PB 触发通道：只留一个脉冲，宽度 300ns；开始时间=earliestAWG（若找到）
ch = PB.Channels(idxPB);
if ch.NumberOfRises >= 1
    % 删除除第一以外的全部 rise
    while ch.NumberOfRises > 1
        ch.deleteRise(2, 0);
    end
    % 若成功找到 AWG 的最早 first rise，则把 PB 触发对齐过去
    if isfinite(earliestAWG)
        ch.RiseTimes(1)    = earliestAWG;
    end
    ch.RiseDurations(1) = 300e-9;
    PB.Channels(idxPB)  = ch;
end
end




function [Sequence] = PulseSequenceToArray(PSeq, SourceFreq)
% 将通道映射成 AWG“二值数组”视图（+1/-1，交替）
% 安全索引：起点使用 ceil，终点使用 floor-1，并夹住范围

% 最大时间 -> 样点数
tmax     = PSeq.GetMaxRiseTime;
SeqPoints = max(0, ceil(tmax * SourceFreq));
if SeqPoints <= 0
    Sequence = zeros(numel(PSeq.Channels), 0, 'int16');
    return;
end

Sequence = zeros(numel(PSeq.Channels), SeqPoints, 'int16');

for k = 1:numel(PSeq.Channels)
    nRise = PSeq.Channels(k).NumberOfRises;
    if nRise < 1, continue; end

    % 交替 +1 / -1（与原实现等价）
    riseMarker        = ones(1, nRise, 'int16');
    riseMarker(2:2:end) = -1;

    for l = 1:nRise
        startTime = PSeq.Channels(k).RiseTimes(l);
        stopTime  = startTime + PSeq.Channels(k).RiseDurations(l);

        % 考虑硬件延迟
        startTimeActual = startTime - PSeq.Channels(k).DelayOn;
        stopTimeActual  = stopTime  - PSeq.Channels(k).DelayOff;

        % 转样点（更稳健的边界处理）
        pStart = uint32( startTimeActual * SourceFreq );
        pStop  = uint32(stopTimeActual * SourceFreq) - 1;

        % 允许 0 宽最小修正
        if pStop < pStart
            pStop = pStart;
        end

        % 夹住范围 [0, SeqPoints-1]
        pStart = max(0, min(pStart, SeqPoints-1));
        pStop  = max(0, min(pStop,  SeqPoints-1));

        if pStop >= pStart
            Sequence(k, pStart+1 : pStop+1) = riseMarker(l);
        end
    end
end
end



function [tempPSeq, TimeVector] = PulseSequenceSweepToArray(PSeq)
% 应用 sweep 到一个 clone（不产生指令/数组，仅改字段）
tempPSeq   = PSeq.clone();
TimeVector = [];

for jj = 1:numel(PSeq.Sweeps)
    switch PSeq.Sweeps(jj).SweepClass
        case 'Rise'
            TimeVector = ProcessRiseClass(PSeq, tempPSeq, jj);
        case 'Type'
            TimeVector = ProcessTypeClass(PSeq, tempPSeq, jj);
        case 'Group'
            warning('Sweep Class "Group" not implemented.');
        otherwise
            warning('Unrecognized Sweep Class: %s', PSeq.Sweeps(jj).SweepClass);
    end
end
end


function TimeVector = ProcessRiseClass(PSeq, tempPSeq, jj)
% 对指定 channel+rise 做 sweep（Time/Duration/Amplitude/Phase）
ind  = PSeq.getSweepIndex();
chn  = PSeq.Sweeps(jj).Channels;
rise = PSeq.Sweeps(jj).SweepRises;

x = linspace(PSeq.Sweeps(jj).StartValue, PSeq.Sweeps(jj).StopValue, PSeq.Sweeps(jj).SweepPoints);
TimeVector = x;

% 如老序列无倍乘，补 1
if isempty(PSeq.Channels(chn).RiseSweepMultipliers)
    tempPSeq.Channels(chn).RiseSweepMultipliers = ones(PSeq.Channels(chn).NumberOfRises, 1);
end

switch PSeq.Sweeps(jj).SweepType
    case 'Time'
        oldRiseT = tempPSeq.Channels(chn).RiseTimes(rise);

        % shift 策略
        if PSeq.Sweeps(jj).SweepShifts == 1
            % shift 当前 channel 上所有晚于 oldRiseT 的脉冲
            inds = find(tempPSeq.Channels(chn).RiseTimes > oldRiseT);
            if ~isempty(inds)
                tempPSeq.Channels(chn).RiseTimes(inds) = ...
                    tempPSeq.Channels(chn).RiseTimes(inds) + ...
                    tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
            end
        elseif PSeq.Sweeps(jj).SweepShifts == 2
            % shift 所有 channel 上晚于 oldRiseT 的脉冲
            for qq = 1:numel(tempPSeq.Channels)
                inds = find(tempPSeq.Channels(qq).RiseTimes > oldRiseT);
                if ~isempty(inds)
                    tempPSeq.Channels(qq).RiseTimes(inds) = ...
                        tempPSeq.Channels(qq).RiseTimes(inds) + ...
                        tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
                    % 可选的微小舍入，避免浮点拖尾：
                        tempPSeq.Channels(qq).RiseTimes(inds) = round(tempPSeq.Channels(qq).RiseTimes(inds), 12);
                end
            end
        end

        % 扫描本脉冲的绝对/相对时间
        if PSeq.Sweeps(jj).SweepAdd
            tempPSeq.Channels(chn).RiseTimes(rise) = ...
                tempPSeq.Channels(chn).RiseTimes(rise) + ...
                tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
        else
            tempPSeq.Channels(chn).RiseTimes(rise) = ...
                tempPSeq.Channels(chn).RiseSweepMultipliers(rise) .* x(ind(jj));
        end

    case 'Duration'
        if PSeq.Sweeps(jj).SweepAdd
            tempPSeq.Channels(chn).RiseDurations(rise) = ...
                tempPSeq.Channels(chn).RiseDurations(rise) + ...
                tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
        else
            tempPSeq.Channels(chn).RiseDurations(rise) = ...
                tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
        end

        if PSeq.Sweeps(jj).SweepShifts == 1
            % 同通道晚于此脉冲的全部右移
            if rise+1 <= numel(tempPSeq.Channels(chn).RiseTimes)
                tempPSeq.Channels(chn).RiseTimes(rise+1:end) = ...
                    tempPSeq.Channels(chn).RiseTimes(rise+1:end) + ...
                    tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
            end
        elseif PSeq.Sweeps(jj).SweepShifts == 2
            % 所有通道晚于此脉冲起点的全部右移
            riseT = tempPSeq.Channels(chn).RiseTimes(rise);
            for k = 1:numel(tempPSeq.Channels)
                inds = find(tempPSeq.Channels(k).RiseTimes > riseT);
                if ~isempty(inds)
                    tempPSeq.Channels(k).RiseTimes(inds) = ...
                        tempPSeq.Channels(k).RiseTimes(inds) + ...
                        tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
                end
            end
        end

    case 'Amplitude'
        if PSeq.Sweeps(jj).SweepAdd
            tempPSeq.Channels(chn).RiseAmplitudes(rise) = ...
                tempPSeq.Channels(chn).RiseAmplitudes(rise) + ...
                tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
        else
            tempPSeq.Channels(chn).RiseAmplitudes(rise) = ...
                tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
        end

    case 'Phase'
        if PSeq.Sweeps(jj).SweepAdd
            tempPSeq.Channels(chn).RisePhases(rise) = ...
                tempPSeq.Channels(chn).RisePhases(rise) + ...
                tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
        else
            tempPSeq.Channels(chn).RisePhases(rise) = ...
                tempPSeq.Channels(chn).RiseSweepMultipliers(rise) * x(ind(jj));
        end
end
end


function TimeVector = ProcessTypeClass(PSeq, tempPSeq, jj)
% 对“某种类型”的全部脉冲做 sweep（Time/TimeExp/Duration/Amplitude/Phase）

% 获取 sweep index（支持 TimeExp 分段指数）
SweepType = PSeq.Sweeps(jj).SweepType;
ind = PSeq.getSweepIndex();
chn  = PSeq.Sweeps(jj).Channels;
riseTypeName = PSeq.Sweeps(jj).SweepRises;

% RiseSweepMultipliers 缺省补 1（保持长度一致）
if isempty(PSeq.Channels(chn).RiseSweepMultipliers)
    PSeq.Channels(chn).RiseSweepMultipliers = ones(1, PSeq.Channels(chn).NumberOfRises);
end

% 找到所有 riseTypeName 对应的 [channel, rise] 以及 rise 的绝对时间
pairs = zeros(0,2);
rTimes = zeros(0,1);
for k = 1:numel(PSeq.Channels)
    for kk = 1:numel(PSeq.Channels(k).RiseTypes)
        if strcmp(PSeq.Channels(k).RiseTypes(kk), riseTypeName)
            pairs  = [pairs;  k, kk]; %#ok<AGROW>
            rTimes = [rTimes; PSeq.Channels(k).RiseTimes(kk)]; %#ok<AGROW>
        end
    end
end
% 按时间排序
[~, order] = sort(rTimes, 'ascend');
pairs = pairs(order, :);

% 构造 TimeVector
switch PSeq.Sweeps(jj).SweepType
    case 'TimeExp'   % ← 新增：自然对数等间隔（ln 等间隔）
        % 参数读取并转 double
        tmin = double(PSeq.Sweeps(jj).StartValue);   % 最小时间（>0）
        tmax = double(PSeq.Sweeps(jj).StopValue);    % 最大时间（>tmin）
        Npts = double(PSeq.Sweeps(jj).SweepPoints);  % 采样点数（>=2）

        % 基本校验/兜底
        if isempty(Npts) || ~isfinite(Npts) || Npts < 2
            Npts = 50;  % 默认点数
        else
            Npts = floor(Npts);
        end
        if isempty(tmin) || ~isfinite(tmin) || tmin <= 0
            % ln 需要正数；若给了 <=0，用一个极小正数兜底
            tmin = 1e-9;
        end
        if isempty(tmax) || ~isfinite(tmax) || tmax <= tmin
            error('TimeLog: StopValue 必须是大于 StartValue 的正数。');
        end

        % 在 ln 轴上线性均分，再 exp 回时间域（包含端点）
        TimeVector = exp( linspace(log(tmin), log(tmax), Npts).' );  % 列向量

        % 如需额外在最前面加一个极小非零点，可解注下一行：
        % TimeVector = [1e-8; TimeVector];

    otherwise
        % 线性扫描（保持你原本逻辑）
        TimeVector = linspace( ...
            double(PSeq.Sweeps(jj).StartValue), ...
            double(PSeq.Sweeps(jj).StopValue), ...
            double(PSeq.Sweeps(jj).SweepPoints) ...
        ).';
end

% 应用 sweep
switch SweepType
    case {'Time', 'TimeExp'}
        for k = 1:size(pairs,1)
            chnK  = pairs(k,1);
            riseK = pairs(k,2);

            oldRiseT = tempPSeq.Channels(chnK).RiseTimes(riseK);

            if PSeq.Sweeps(jj).SweepShifts == 1
                % 注: 这里你的原代码写成 tempPSeq.Channles，现已修正
                inds = find(tempPSeq.Channels(chnK).RiseTimes > oldRiseT);
                if ~isempty(inds)
                    tempPSeq.Channels(chnK).RiseTimes(inds) = ...
                        tempPSeq.Channels(chnK).RiseTimes(inds) + ...
                        PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
                end
            elseif PSeq.Sweeps(jj).SweepShifts == 2
                for qq = 1:numel(tempPSeq.Channels)
                    inds = find(tempPSeq.Channels(qq).RiseTimes > oldRiseT);
                    if ~isempty(inds)
                        tempPSeq.Channels(qq).RiseTimes(inds) = ...
                            tempPSeq.Channels(qq).RiseTimes(inds) + ...
                            PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
                        % 避免浮点误差拖尾的轻微舍入（可选）：
                            tempPSeq.Channels(qq).RiseTimes(inds) = round(tempPSeq.Channels(qq).RiseTimes(inds), 12);
                    end
                end
            end

            if PSeq.Sweeps(jj).SweepAdd
                tempPSeq.Channels(chnK).RiseTimes(riseK) = ...
                    tempPSeq.Channels(chnK).RiseTimes(riseK) + ...
                    PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
            else
                tempPSeq.Channels(chnK).RiseTimes(riseK) = ...
                    PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
            end
        end

    case 'Duration'
        for k = 1:size(pairs,1)
            chnK  = pairs(k,1);
            riseK = pairs(k,2);
            if PSeq.Sweeps(jj).SweepAdd
                tempPSeq.Channels(chnK).RiseDurations(riseK) = ...
                    tempPSeq.Channels(chnK).RiseDurations(riseK) + ...
                    PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
            else
                tempPSeq.Channels(chnK).RiseDurations(riseK) = ...
                    PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
            end

            if PSeq.Sweeps(jj).SweepShifts == 2
                riseT = tempPSeq.Channels(chnK).RiseTimes(riseK);
                for kk = 1:numel(tempPSeq.Channels)
                    inds = find(tempPSeq.Channels(kk).RiseTimes > riseT);
                    if ~isempty(inds)
                        tempPSeq.Channels(kk).RiseTimes(inds) = ...
                            tempPSeq.Channels(kk).RiseTimes(inds) + ...
                            PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
                    end
                end
            end
        end

    case 'Amplitude'
        for k = 1:size(pairs,1)
            chnK  = pairs(k,1);
            riseK = pairs(k,2);
            if PSeq.Sweeps(jj).SweepAdd
                tempPSeq.Channels(chnK).RiseAmplitudes(riseK) = ...
                    tempPSeq.Channels(chnK).RiseAmplitudes(riseK) + ...
                    PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
            else
                tempPSeq.Channels(chnK).RiseAmplitudes(riseK) = ...
                    PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
            end
        end

    case 'Phase'
        for k = 1:size(pairs,1)
            chnK  = pairs(k,1);
            riseK = pairs(k,2);
            if PSeq.Sweeps(jj).SweepAdd
                tempPSeq.Channels(chnK).RisePhases(riseK) = ...
                    tempPSeq.Channels(chnK).RisePhases(riseK) + ...
                    PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
            else
                tempPSeq.Channels(chnK).RisePhases(riseK) = ...
                    PSeq.Channels(chn).RiseSweepMultipliers(riseK).*TimeVector(ind(jj));
            end
        end

    case 'Frequency'
        % 这里留空（你的代码里也是占位）
end
end


function [Instructions] = PulseSequenceToInstruction(PSeq, ClockRate)
% 将脉冲“事件”转成 PB 指令：每个段长度（tick 数）+ 段末的 bitmask
% 更稳健：全部事件排序 -> 合并同一时间 -> 计算差分 tick

eTimes = [];   % 事件时间（秒）
flags  = [];   % 对应 +2^HW / -2^HW

for k = 1:numel(PSeq.Channels)
    ch = PSeq.Channels(k);
    for jj = 1:ch.NumberOfRises
        startT = ch.RiseTimes(jj) - ch.DelayOn;
        stopT  = ch.RiseTimes(jj) + ch.RiseDurations(jj) - ch.DelayOff;

        eTimes(end+1) = startT; %#ok<AGROW>
        flags(end+1)  = + 2^ch.HWChannel; %#ok<AGROW>

        eTimes(end+1) = stopT; %#ok<AGROW>
        flags(end+1)  = - 2^ch.HWChannel; %#ok<AGROW>
    end
end

if isempty(eTimes)
    Instructions.Length = [];
    Instructions.Data   = [];
    return;
end

% 排序
[es, ord] = sort(eTimes, 'ascend');
fs        = flags(ord);

% 合并同一时间的 flag（求和）
[uniqT, ~, ic] = unique(es);
flagSum = accumarray(ic(:), fs(:), [], @sum);

% 转 tick，并取相邻差分作为段长度
ticks = int64(round(uniqT * ClockRate));
dtick = diff(ticks);
% 丢弃非正的段（理论上不会出现，但做个保护）
keep  = dtick > 0;

Instructions.Length = double(dtick(keep));
% 段的 mask = 累加后的走向（cumsum），去掉最后一个时间点（无段）
maskAll = cumsum(flagSum);
Instructions.Data   = maskAll(1:end-1);
Instructions.Data   = Instructions.Data(keep);
end


% --------- (可选) 全局时间量化工具（默认未调用） ---------
function PS = quantizePS(PSin, dt, mode)
% 将 PSin 中每个 channel 的 RiseTimes / RiseDurations 量化到 dt 的整数倍
% mode = 'round'（最近邻） 或 'contain'（开始ceil，结束floor，不提前/不延后）
PS = PSin.clone();

for k = 1:numel(PS.Channels)
    t  = PS.Channels(k).RiseTimes;
    du = PS.Channels(k).RiseDurations;

    switch lower(mode)
        case 'round'
            tq  = double(int64(round(t  ./dt))).*dt;
            duq = double(int64(round(du ./dt))).*dt;
            duq(duq <= 0) = dt;  % 至少 1 tick

        case 'contain'
            s = ceil( t./dt );
            e = floor((t+du)./dt);
            bad = e < s; e(bad) = s(bad);
            tq  = double(s).*dt;
            duq = double(e - s); duq(duq < 1) = 1;
            duq = duq.*dt;

        otherwise
            error('quantizePS: unknown mode %s', mode);
    end

    PS.Channels(k).RiseTimes     = tq;
    PS.Channels(k).RiseDurations = duq;
end
end


% --------- (可选) 收集跨设备关键边沿（示例） ---------
function keyTimes = collectKeyEdges(pbSeqObj, awgPS)
% 仅示例：收集 PB 的 HWChannel==3 的触发开始时刻 + AWG 的最早边沿
keyTimes = [];

% PB 触发
for k = 1:numel(pbSeqObj.Channels)
    if isfield(pbSeqObj.Channels(k),'HWChannel') && pbSeqObj.Channels(k).HWChannel == 3
        if ~isempty(pbSeqObj.Channels(k).RiseTimes)
            keyTimes(end+1) = pbSeqObj.Channels(k).RiseTimes(1); %#ok<AGROW>
        end
        break;
    end
end

% AWG 最早
minRise = +inf;
for k = 1:numel(awgPS.Channels)
    if ~isempty(awgPS.Channels(k).RiseTimes)
        minRise = min(minRise, min(awgPS.Channels(k).RiseTimes));
    end
end
if isfinite(minRise)
    keyTimes(end+1) = minRise;
end
end
