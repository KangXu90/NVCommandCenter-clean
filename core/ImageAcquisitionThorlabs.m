classdef ImageAcquisitionThorlabs < ImageAcquisition
    % 继承自 ImageAcquisition，专门用于 Thorlabs 电机控制
    
    properties
        Motors % 存储 X, Y, Z 电机句柄
    end

    methods
        function obj = ImageAcquisitionThorlabs()
            % 调用父类构造函数 (如果父类有特殊初始化)
            obj.Motors = struct('X',[],'Y',[],'Z',[]);
        end

        % --- 统一的扫描入口 ---
        function RunScan(obj, niObj, appHandle)
            % niObj: 传入的计数器对象
            % appHandle: 传入 App 句柄，用于检查 ScanAbort 标志和更新 UI
            
            % 1. 调用父类方法准备坐标向量
            obj.InitVarForScan(); 
            
            % 2. 识别哪些轴被勾选了
            enabledAxes = find(obj.CurrentScan.bEnable == 1);
            numAxes = length(enabledAxes);
            
            if numAxes == 2
                % 执行 2D 扫描 (Zig-Zag)
                obj.perform2DScan(enabledAxes, niObj, appHandle);
            elseif numAxes == 1
                % 执行 1D 扫描
                obj.perform1DScan(enabledAxes, niObj, appHandle);
            else
                error('请选择 1 个或 2 个轴进行扫描。');
            end
        end

        % --- 重写父类的 Z 轴移动方法 ---
        function setZPos(obj, newPos)
            % 覆盖父类的旧方法，使用 Kinesis 驱动
            if ~isempty(obj.Motors.Z) && obj.Motors.Z.IsConnected
                % Thorlabs Kinesis 需要 System.Decimal 格式
                obj.Motors.Z.MoveTo(System.Decimal(newPos), 60000);
            end
        end
        function InitVarForScan(obj)
            % 清空旧数据
            obj.CounterRawData = [];
            obj.ImageRawData = [];

            % 循环处理 X, Y, Z 三个轴
            for i = 1:3
                if obj.CurrentScan.bEnable(i)
                    vec = linspace(obj.CurrentScan.MinValues(i), ...
                        obj.CurrentScan.MaxValues(i), ...
                        obj.CurrentScan.NumPoints(i));
                else
                    vec = [];
                end

                % 动态赋值
                switch i
                    case 1, obj.CurrentScanVxVec = vec;
                    case 2, obj.CurrentScanVyVec = vec;
                    case 3, obj.CurrentScanVzVec = vec;
                end
            end
        end
        % 在 ImageAcquisitionThorlabs.m 的 methods 块中
        function setMotorSpeed(obj, axisName, maxVel)
            % axisName: 'X', 'Y' 或 'Z'
            % maxVel: 用户在 UI 填写的速度值 (mm/s)

            motor = obj.Motors.(axisName);
            if ~isempty(motor) && motor.IsConnected
                try
                    % 1. 获取当前速度参数对象
                    velParams = motor.GetVelocityParams();

                    % 2. 修改最大速度 (必须转为 System.Decimal)
                    velParams.MaxVelocity = System.Decimal(maxVel);

                    % 3. 可选：设置一个合理的加速度 (比如速度的 2 倍)
                    velParams.Acceleration = System.Decimal(maxVel * 2);

                    % 4. 写回硬件
                    motor.SetVelocityParams(velParams);
                catch ME
                    warning('设置 %s 轴速度失败: %s', axisName, ME.message);
                end
            end
        end
    end
    
    methods (Access = private)
        % 2D 扫描核心逻辑
        function perform2DScan(obj, axesIdx, niObj, app)
            fIdx = axesIdx(1); sIdx = axesIdx(2); % 快速轴和慢速轴
            fMotor = obj.getMotorByIndex(fIdx);
            sMotor = obj.getMotorByIndex(sIdx);
            fVec = obj.getVecByIndex(fIdx);
            sVec = obj.getVecByIndex(sIdx);
            
            mapData = zeros(length(fVec), length(sVec));

            cla(app.UIAxes);

            
               Dwelltime =  niObj.hCounterAcquisition.DwellTime;

            niObj.hCounterAcquisition.DwellTime = 0.01;

            for j = 1:length(sVec)
                if app.AbortScan, break; end % 检查 App 里的停止标志
                
                sMotor.MoveTo(System.Decimal(sVec(j)), 60000);
                
                % Zig-Zag 往返逻辑
                if mod(j,2) == 1, iRange = 1:length(fVec); else, iRange = length(fVec):-1:1; end
                
                for i = iRange
                    if app.AbortScan, break; end
                    
                    fMotor.MoveTo(System.Decimal(fVec(i)), 60000);
                    
                    % 采集数据
                    % first turn on the laser
                    niObj.laserOn();
                    niObj.hCounterAcquisition.DwellTime = 0.01;
                    niObj.hCounterAcquisition.GetCountsPerSecond();
                    mapData(i, j) = niObj.hCounterAcquisition.CountsPerSecond;
                    % first turn on the laser
                    niObj.laserOff();
                    
                    % 通过回调或直接绘图实时刷新 App 界面
                    imagesc(app.UIAxes, fVec, sVec, mapData');
                    axis(app.UIAxes, 'tight');
                    % 提取已采集（非零）的数据点
                    scannedData = mapData(mapData > 0);

                    if ~isempty(scannedData)
                        cMin = prctile(scannedData, 2, 'all');
                        cMax = prctile(scannedData, 98, 'all');

                        % 防止 cMin 和 cMax 相等导致报错
                        if cMax > cMin
                            app.UIAxes.CLim = [cMin, cMax];
                        end
                        colorbar(app.UIAxes);

                        drawnow limitrate;
                    end
                end
            end
          niObj.hCounterAcquisition.DwellTime = Dwelltime;
        end

        % 1D 扫描核心逻辑
        function perform1DScan(obj, axesIdx, niObj, app)
            idx = axesIdx(1);
            motor = obj.getMotorByIndex(idx);
            vec = obj.getVecByIndex(idx);
            counts = zeros(1, length(vec));
            % 建议先在循环外清理一次坐标轴
            cla(app.UIAxes);
            hold(app.UIAxes, 'on'); % 保持绘图，方便后续添加标注

           Dwelltime =  niObj.hCounterAcquisition.DwellTime;
            niObj.hCounterAcquisition.DwellTime = 0.05;

            for i = 1:length(vec)
                if app.AbortScan, break; end
                motor.MoveTo(System.Decimal(vec(i)), 60000);
                % 采集数据
                % first turn on the laser
                niObj.laserOn();
                niObj.hCounterAcquisition.GetCountsPerSecond();
                curveData(i) = niObj.hCounterAcquisition.CountsPerSecond;
                % first turn on the laser
                niObj.laserOff();

                counts(i) = niObj.hCounterAcquisition.CountsPerSecond;

                % 在 UIAxes 上画曲线
                plot(app.UIAxes, vec(1:i), curveData(1:i), '-o', 'Color', 'b', 'LineWidth', 1.5, 'MarkerSize', 6);                drawnow limitrate;
            end
            niObj.hCounterAcquisition.DwellTime = Dwelltime;
        end

        % 获取电机的辅助函数
        function motor = getMotorByIndex(obj, index)
            switch index
                case 1, motor = obj.Motors.X;
                case 2, motor = obj.Motors.Y;
                case 3, motor = obj.Motors.Z;
            end
        end
       

        % 获取坐标向量的辅助函数
        function vec = getVecByIndex(obj, index)
            switch index
                case 1, vec = obj.CurrentScanVxVec;
                case 2, vec = obj.CurrentScanVyVec;
                case 3, vec = obj.CurrentScanVzVec;
            end
        end
    end
end