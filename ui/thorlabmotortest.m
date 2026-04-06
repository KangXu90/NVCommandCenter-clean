% --- 1. 加载库与初始化 (只需执行一次) ---
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoCLI.dll');

import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.KCube.DCServoCLI.*

DeviceManagerCLI.BuildDeviceList();
SLnoList = DeviceManagerCLI.GetDeviceList();
serialNumbers = cell(ToArray(SLnoList));

% 检查连接的设备数量
if length(serialNumbers) < 3
    error('检测到的设备少于 3 个，请检查连接。');
end

timeout_val = 60000;

% --- 2. 分别定义别名并初始化设备 ---

% 定义别名列表（方便循环操作）
aliases = {'X', 'Z', 'Y'};

for i = 1:3
    sn = serialNumbers{i};
    alias = aliases{i};
    
    fprintf('正在初始化设备 %s (SN: %s)...\n', alias, sn);
    
    % 创建并连接
    dev = KCubeDCServo.CreateKCubeDCServo(sn);
    dev.Connect(sn);
    
    % 等待初始化并加载配置
    dev.WaitForSettingsInitialized(5000);
    motorSettings = dev.LoadMotorConfiguration(sn);
    
    % 注意：此处根据你的实际硬件修改型号
    % 如果三个都是 PRM1-Z8，则保持不变
    motorSettings.DeviceSettingsName = 'MTS25-Z8'; 
    
    motorSettings.UpdateCurrentConfiguration();
    dev.SetSettings(dev.MotorDeviceSettings, true, false);
    
    % 启动轮询
    dev.StartPolling(250);
    
    % 将实例存入结构体
    devices.(alias) = dev;
end

pause(1); % 等待所有设备稳定

% --- 3. 独立控制演示 ---

% % 1. 全部回零 (Home)
% fprintf('所有电机正在回零...\n');
% devices.X.Home(0);
% devices.Y.Home(0);
% devices.Z.Home(0);
% 
% % --- 2. 轮询各轴状态，直到全部完成 ---
% all_homed = false;
% tic; % 开始计时
% timeout_limit = 120; % 总超时时间 60 秒
% 
% while ~all_homed
%     % 获取各轴的“是否已回零”状态
%     % 注意：IsHomed 是 GenericMotorCLI 中的属性
%     isXDone = devices.X.Status.IsHomed;
%     isYDone = devices.Y.Status.IsHomed;
%     isZDone = devices.Z.Status.IsHomed;
% 
%     if isXDone && isYDone && isZDone
%         all_homed = true;
%         fprintf('所有轴回零成功！耗时: %.2f 秒\n', toc);
%     elseif toc > timeout_limit
%         error('回零超时，请检查硬件状态。');
%     end
% 
%     pause(0.2); % 稍微停顿，避免过度占用 CPU
% end
% 2. 分别移动到不同位置
devices.X.MoveTo(10, timeout_val); % X 轴移动到 10
devices.Y.MoveTo(10, timeout_val); % Y 轴移动到 45
devices.Z.MoveTo(0, timeout_val); % Z 轴移动到 90

% 3. 读取位置并打印
posX = System.Decimal.ToDouble(devices.X.Position);
posY = System.Decimal.ToDouble(devices.Y.Position);
posZ = System.Decimal.ToDouble(devices.Z.Position);

fprintf('当前位置 -> X: %.2f, Y: %.2f, Z: %.2f\n', posX, posY, posZ);

% --- 4. 断开连接 (清理) ---
aliasFields = fieldnames(devices);
for i = 1:length(aliasFields)
    name = aliasFields{i};
    devices.(name).StopPolling();
    devices.(name).Disconnect();
end
fprintf('所有设备已断开连接。\n');