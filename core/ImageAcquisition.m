classdef ImageAcquisition < handle
    % MATLAB class object for interfacing hardware control parameters to
    % software data acquisition
    %
    % Jonathan Hodges <jhodges@mit.edu>
    % 5 May 2009
    
    properties
        interfaceNIDAQ
        interfaceAPTMotor
        interfacePiezo
        ZController
        CurrentScan
        CurrentScanVxVec
        CurrentScanVyVec
        CurrentScanVzVec
        CounterRawData
        ImageRawData
        Image
        DutyCycle = 0.5;
        ZCounter
        TotalSamples;
        MinumumSamplesToAcquire = 100;
        CursorPosition = [0 0 0]; % position in X,Y,Z space of confocal spot
        CurrentPosition = [0 0 0];
        OffsetValues = [0 0 0];
        ConfocalImages = ConfocalImage(); 
        updateCounterListenerHandle;
        ClockLineForImage = 1; % set to 1 as default, can set in init script
        CountersForImage = 1;  % set to 1 as default, can set up others in init script
    end % properties
    
    events
        UpdateCounterData
        UpdateCursorPosition
    end
    
    methods
        
        
        function [] = InitVarForScan(obj)
            % clear out the raw counter variables and scan vectors
           	obj.CounterRawData = [];
            obj.ImageRawData = [];
            obj.CurrentScanVxVec = [];
            obj.CurrentScanVyVec = [];
            obj.CurrentScanVzVec = [];
    
        end
        
        function [] = SetCursor(obj)
            
            % X Y cursor positions controller with NI
            VxOffset = obj.OffsetValues(1);
            VyOffset = obj.OffsetValues(2);
            
            % set the offset voltages to the output voltage variables
            obj.interfaceNIDAQ.AnalogOutVoltages(1) = obj.CursorPosition(1) + VxOffset;
            obj.interfaceNIDAQ.AnalogOutVoltages(2) = obj.CursorPosition(2) + VyOffset;
            
            % call the command to write all outlines
            obj.interfaceNIDAQ.WriteAnalogOutAllLines();
            
            % Z cursor position set with either APT controller
            obj.setZPos(obj.CursorPosition(3));
            
            % notify listeners of the new position
            notify(obj,'UpdateCursorPosition');
        end
          function [] = SetCursor2D(obj)
            
            % X Y cursor positions controller with NI
            VxOffset = obj.OffsetValues(1);
            VyOffset = obj.OffsetValues(2);
            
            % set the offset voltages to the output voltage variables
            obj.interfaceNIDAQ.AnalogOutVoltages(1) = obj.CursorPosition(1) + VxOffset;
            obj.interfaceNIDAQ.AnalogOutVoltages(2) = obj.CursorPosition(2) + VyOffset;
            
            % call the command to write all outlines
            obj.interfaceNIDAQ.WriteAnalogOutAllLines();
            
            % Z cursor position set with either APT controller
%             obj.setZPos(obj.CursorPosition(3));
            
            % notify listeners of the new position
            notify(obj,'UpdateCursorPosition');
        end
           

        function [] = StartScan2D(obj)
            % start the counters and the voltages
            obj.interfaceNIDAQ.StartTask('Counter');
            obj.interfaceNIDAQ.StartTask('VoltageOut');
            
            % wait for it to start
            pause(0.1);
            
            % first start the pulse train
            obj.interfaceNIDAQ.StartTask('PulseTrain');
            
            %obj.interfaceNIDAQ.WaitUntilTaskDone('Counter');
        end
        
        function [] = SetPulseTrain(obj)
            
            obj.interfaceNIDAQ.CreateTask('PulseTrain');
            obj.interfaceNIDAQ.ConfigureClockOut('PulseTrain', obj.ClockLineForImage,1/obj.CurrentScan.DwellTime,obj.DutyCycle);
        end
        
        function SetCounter(obj)
            %Figure out how many samples we need
            %??? Is this property used anywhere else?
            obj.TotalSamples = prod(obj.CurrentScan.NumPoints(logical(obj.CurrentScan.bEnable(1:2))));
            %Unfortunately, a Z scan is different
            if(isequal(obj.CurrentScan.bEnable,[0 0 1]))
                obj.TotalSamples = 1; 
            end
            
            %Create the counter task and configure it
            obj.interfaceNIDAQ.CreateTask('Counter');
                   
            % loop over the obj.CountersForImage variables, adding counters
            for k=1:length(obj.CountersForImage)        
                
                obj.interfaceNIDAQ.ConfigureCounterIn('Counter',obj.CountersForImage(k),obj.TotalSamples+1);
            end
        end
            
        function [] = SetScan2D(obj)
            % loads 2D scanning parameters from ConfocalScan object then
            % prepares configuration of proper tasks for hardware interface
            % 
            % Leaves hardward ready to be triggered for initiating scan
            
            % Loop over XY dimensions to get values
            scan = obj.CurrentScan;
            % without offset
            Vx = linspace(scan.MinValues(1),scan.MaxValues(1),scan.NumPoints(1));
            
            obj.CurrentScanVxVec = Vx;
            
            % add offset from IA object, not the Scan (obsolete)
            Vx = Vx + obj.OffsetValues(1);
            
            Vy = linspace(scan.MinValues(2),scan.MaxValues(2),scan.NumPoints(2));

            obj.CurrentScanVyVec = Vy;
            Vy = Vy + obj.OffsetValues(2);
            
            % serialize Vx and Vy into Rastered Pairs
            ScanSize = scan.NumPoints(1)*scan.NumPoints(2);
            VoltagePairs = zeros(ScanSize,2);
            for k=1:2:scan.NumPoints(2),
                % Increasing Vx, fixed Vy
                VoltagePairs((k-1)*scan.NumPoints(1)+1:(k-1)*scan.NumPoints(1)+scan.NumPoints(1),:) = [Vx',repmat(Vy(k),scan.NumPoints(1),1)];
                % Decreasing Vx, fixed Vy++
                VoltagePairs(k*scan.NumPoints(1)+1:k*scan.NumPoints(1)+scan.NumPoints(1),:) = [Vx(end:-1:1)',repmat(Vy(k+1),scan.NumPoints(1),1)];
            end
            
            % now, load in the voltages into the NIDAQ
            
            obj.interfaceNIDAQ.CreateTask('VoltageOut');
            obj.interfaceNIDAQ.ConfigureVoltageOut('VoltageOut',[1,2],VoltagePairs(:),obj.ClockLineForImage);
            obj.ImageRawData = zeros(ScanSize+1,1);
            obj.CounterRawData = [];
            
        end
        
      function [] = SetScan1DXY(obj)
        % loads 2D scanning parameters from ConfocalScan object then
        % prepares configuration of proper tasks for hardware interface
        % 
        % Leaves hardward ready to be triggered for initiating scan

        % Loop over XY dimensions to get values
        scan = obj.CurrentScan;
        % without offset
        Vx = linspace(scan.MinValues(1),scan.MaxValues(1),scan.NumPoints(1));

        obj.CurrentScanVxVec = Vx;

        % add offset from IA object, not the Scan (obsolete)
        Vx = Vx + obj.OffsetValues(1);

        Vy = linspace(scan.MinValues(2),scan.MaxValues(2),scan.NumPoints(2));

        obj.CurrentScanVyVec = Vy;
        Vy = Vy + obj.OffsetValues(2);

        if scan.bEnable(1),
            V = Vx;
            NP = scan.NumPoints(1);
            VLine = 1;
        else
            V = Vy;
            NP = scan.NumPoints(2);
            VLine = 2;
        end
        
 
        % now, load in the voltages into the NIDAQ

        obj.interfaceNIDAQ.CreateTask('VoltageOut');
        obj.interfaceNIDAQ.ConfigureVoltageOut('VoltageOut',VLine,V(:),obj.ClockLineForImage);
        
        %Initialize the RawData to a row vector to distinguish from 2D data
        %This is fragile and should be done better.
        obj.ImageRawData = zeros(1,NP);
        obj.CounterRawData = [];
      end
        
  
        function [] = WaitUntilScanComplete(obj)
            
            SampsAvail = obj.interfaceNIDAQ.GetAvailableSamples('Counter');
            
            h = waitbar(0,'Acquiring Image...');
            while SampsAvail < obj.TotalSamples,
                waitbar((SampsAvail-1)/obj.TotalSamples,h);
                drawnow();
                SampsAvail = obj.interfaceNIDAQ.GetAvailableSamples('Counter');
            end
        end
        
        function [] = StreamCounterSamples(varargin)
            
            obj = varargin{1};
            
            if nargin > 1,
                MinSamples = varargin{2};
            else
                MinSamples = obj.MinumumSamplesToAcquire;
            end
            
            % get the number of samples ready
            SampsAvail = obj.interfaceNIDAQ.GetAvailableSamples('Counter');
            
            % if there are enough samples to warrant the function call, do
            % it
            if SampsAvail >= MinSamples
                obj.CounterRawData(end+1:end+SampsAvail) = obj.interfaceNIDAQ.ReadCounterBuffer('Counter',SampsAvail);
            end
            
            obj.ImageRawData(1:length(obj.CounterRawData)-1) = diff(obj.CounterRawData)/(obj.CurrentScan.DwellTime*obj.DutyCycle);
           
            % notify listeners of new available counter data
            notify(obj,'UpdateCounterData');
        end
        
        function [] = StreamCounterSamples1DZ(obj)
            
            % get the number of samples ready
            SampsAvail = obj.interfaceNIDAQ.GetAvailableSamples('Counter');
            
            counterdata = obj.interfaceNIDAQ.ReadCounterBuffer('Counter',SampsAvail);
            obj.CounterRawData(end+1) = diff(counterdata);
            
            obj.ImageRawData(1:length(obj.CounterRawData)) = obj.CounterRawData/(obj.CurrentScan.DwellTime*obj.DutyCycle);
            
            % notify listeners of new available counter data
            notify(obj,'UpdateCounterData');
        end
        
        function [] = ClearScan2D(obj)
            obj.interfaceNIDAQ.ClearTask('PulseTrain');
            obj.interfaceNIDAQ.ClearTask('Counter');
            obj.interfaceNIDAQ.ClearTask('VoltageOut');
        end
        
        function [] = ClearScan1DZ(obj)
            obj.interfaceNIDAQ.ClearTask('PulseTrain');
            obj.interfaceNIDAQ.ClearTask('Counter');

        end
        
        function [] = ZeroScan2D(obj)
            
            % use the IA offset values, not the scan offsets (obsolete)
            VxOffset = obj.OffsetValues(1);
            VyOffset = obj.OffsetValues(2);
            
            % set the offset voltages to the output voltage variables
            obj.interfaceNIDAQ.AnalogOutVoltages(1) = VxOffset;
            obj.interfaceNIDAQ.AnalogOutVoltages(2) = VyOffset;
            
            % call the command to write all outlines
            obj.interfaceNIDAQ.WriteAnalogOutAllLines();
        end
        
        %Helper function to move the Z stage with the correct controller
        %newPos is assumed to be in correct units for controller
        function setZPos(obj,newPos)
            switch obj.ZController
                case 'Motor'
                    obj.interfaceAPTMotor.moveAbsolute(newPos);
                case 'Piezo'
                    obj.interfacePiezo.SetPosition(newPos);
                otherwise
                    error('Unknown ZController.');
            end
        end
        
        function [] = SetScanZ(obj)
            
            %Setup the scan vector
            obj.CurrentScanVzVec = linspace(obj.CurrentScan.MinValues(3),obj.CurrentScan.MaxValues(3),obj.CurrentScan.NumPoints(3));
            
            %Initialize the Z Counter
            obj.ZCounter = 0;
            
        end
        
        function [] = IncrementScanZ(obj)
            
            if (obj.ZCounter < obj.CurrentScan.NumPoints(3)),
                obj.ZCounter = obj.ZCounter + 1;
               
                %Record the current Z position
                obj.CurrentPosition(3) =  obj.CurrentScanVzVec(obj.ZCounter);
                
                %Move there
                obj.setZPos(obj.CurrentScanVzVec(obj.ZCounter) + obj.OffsetValues(3));
         
            elseif (obj.ZCounter >= obj.CurrentScan.NumPoints(3)),
                disp('End of Scan range.  No more motion in Z');
            end
            
        end
     
        
        function [] = StartScan1DZ(obj)
            % manually loop over the dimension of the Z scan
            for k=1:obj.CurrentScan.NumPoints(3)
                % move the scanner up
                obj.IncrementScanZ();
                
                %start pulse train
                obj.interfaceNIDAQ.StartTask('PulseTrain');
                obj.interfaceNIDAQ.StartTask('Counter');
                obj.interfaceNIDAQ.WaitUntilTaskDone('Counter');
                
                obj.StreamCounterSamples1DZ();
                
                obj.interfaceNIDAQ.StopTask('PulseTrain');
                obj.interfaceNIDAQ.StopTask('Counter');

            end
        end
        
        function [] = StoreConfocalImage(obj)
            
            a = length(obj.ConfocalImages);
            
            isFirst = length(obj.ConfocalImages(1).ImageData);
            
            cImage = ConfocalImage();
            if size(obj.ImageRawData,1) > 1,
                cImage.ImageData = obj.UnpackImage();
            else
                cImage.ImageData = obj.ImageRawData;
            end
            
            cImage.ScanData = obj.CurrentScan.ExportScan();
            cImage.PositionZ = obj.CurrentPosition(3);
            cImage.RangeY = obj.CurrentScanVyVec;
            cImage.DomainX = obj.CurrentScanVxVec;
           
            % finally, copy the cImage to the object
            if isFirst == 0,
                obj.ConfocalImages = cImage;
            else
                obj.ConfocalImages(a+1) = cImage;
            end
        end
                    
        function [] = DecodeImage2D(obj)
            dimX = obj.CurrentScan.NumPoints(1);
            dimY = obj.CurrentScan.NumPoints(2);
            obj.Image = zeros(dimX,dimY);
            for k=1:dimY,
                temp = obj.ImageRawData((k-1)*dimX + 1: (k)*dimX );
                if mod(k,2) == 1,
                    obj.Image(:,k) = temp;
                else
                    obj.Image(:,k) = temp(end:-1:1);
                end
            end
        end
        
          function [img] = UnpackImage(obj)
            dimX = obj.CurrentScan.NumPoints(1);
            dimY = obj.CurrentScan.NumPoints(2);
            img = zeros(dimX,dimY);
            for k=1:dimY,
                temp = obj.ImageRawData((k-1)*dimX + 1: (k)*dimX );
                if mod(k,2) == 1,
                    img(:,k) = temp;
                else
                    img(:,k) = temp(end:-1:1);
                end
            end
            
            % another operation needed for unpacking, see notes 18 Jun 2009
            tmpImg = img(:,end:-1:1);
            img = transpose(tmpImg);
        end
    end
end