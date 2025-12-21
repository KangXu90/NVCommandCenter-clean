classdef RohdeSchwarzSignalGenerator < SignalGenerator
   
    
    properties
         Protocol      % GPIB or TCPIP
         SocketHandle  % handle associated with Protocol class
         GPIBnum       % GPIB Channel
         GPIBbus       % GPIB bus
         GPIBdriver    % GPIB driver
         IPAddress     % Device IP Address for TCP/IP control
         TCPPort       % Port for TCP/IP control
         Timeout = 10;      % TimeoutTime
         InputBufferSize = 2^16;
         OutputBufferSize =2^16;
    end
    
    methods
        function [obj] = RohdeSchwarzSignalGenerator(varargin)
            Protocol = varargin{1};
            switch Protocol,
                case 'gpib',
                    obj.GPIBdriver = varargin{2};
                    obj.GPIBbus = varargin{3};
                    obj.GPIBnum = varargin{4};
                    
                    % create gpib object
                    obj.SocketHandle = gpib(obj.GPIBdriver,obj.GPIBbus,obj.GPIBnum);
                case 'tcpip',
                    obj.IPAddress = varargin{2};
                    obj.TCPPort = varargin{3};
                    obj.SocketHandle = tcpip(obj.IPAddress,obj.TCPPort);
                otherwise,
                    error('Only protocols `tcpip` and `gpib` are supported');
            end
            
            % 
            set(obj.SocketHandle,'Timeout',10);
            set(obj.SocketHandle,'InputBufferSize',1000000);
            set(obj.SocketHandle,'OutputBufferSize',1000000);
        end
        
        function [obj] = open(obj)
            
            try,
                fopen(obj.SocketHandle);
            catch ME1,
                disp('here');
            end
        end
        
        function [obj] = close(obj)
            fclose(obj.SocketHandle);
        end
        
        function [obj] = setFrequency(obj)

            % send the set frequency command
            obj.writeToSocket(sprintf(':FREQuency:FIXed %f',obj.Frequency));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
        end
        
        function [obj] = setFrequencyToValue(obj,Frequency)
              % send the set frequency command
            obj.writeToSocket(sprintf(':FREQuency:FIXed %f',Frequency));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function [obj] = setFrequencyMode(obj)

            % send the set frequency command
            obj.writeToSocket(sprintf(':FREQuency:MODE %s',obj.FrequencyMode));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
        end
        
        
        function [obj] = setAmplitude(obj)
            
                                
            % send the set frequency command
            obj.writeToSocket(sprintf(':POWER:LEVEL:IMMEDIATE:AMPLITUDE %f DBM',obj.Amplitude));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
           
        end
        
        function [obj] = setSweepStart(obj)
                        
            
            % send the set frequency command
            obj.writeToSocket(sprintf(':SOUR:FREQ:STAR %f Hz',obj.SweepStart));
            
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
        end
        
        function [obj] = setSweepStop(obj)
                                    
         
            
            % send the set frequency command
            obj.writeToSocket(sprintf(':SOUR:FREQ:STOP %f Hz',obj.SweepStop));
            
      
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        
        function [obj] = setSweepPoints(obj)
            
            obj.writeToSocket(sprintf('SWEEP:POINTS %d',obj.SweepPoints));
              
            % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        
        function [obj] = setSweepMode(obj)
            
            switch obj.SweepMode,
                case {'LIST','STEP'},
                    %obj.writeToSocket(sprintf('LIST:MODE MANUAL'));
                    %obj.writeToSocket(sprintf(':LIST:TYPE %s',obj.SweepMode));

                    % sets to Frequency (not power Sweep mode)
                    obj.writeToSocket(sprintf('SOUR:FREQ:MODE SWE'));
                    obj.writeToSocket(sprintf('SOUR:SWE:MODE %s',obj.SweepMode));

                case {'CW','FIXED'}
                    obj.writeToSocket(sprintf(':FREQUENCY:MODE %s',obj.SweepMode));
                    obj.writeToSocket(sprintf(':POWER:MODE FIXED'));
            end
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function [obj] = setSweepTrigger(obj)
            
            obj.writeToSocket(sprintf('TRIG:FSW:SOUR %s',obj.SweepTrigger));
            
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
            
        end 
        
        function [obj] = setSweepPointTrigger(obj)
            
            %obj.writeToSocket(sprintf('SOUR:LIST:TRIG:SOUR %s',obj.SweepPointTrigger));
            
             % notify of the state change
            %notify(obj,'SignalGeneratorChangedState');
            
        end
        
        function [obj] = setSweepContinuous(obj)
        end
        
        function [obj] = armSweep(obj)
            %obj.setFrequencyToValue(obj.SweepStart);
            %obj.writeToSocket(sprintf('SOUR:SWE:FREQ:MODE STEP'));
            %obj.setSweepTrigger();
            %obj.writeToSocket(sprintf('SOUR:FREQ:MODE SWE'));
            obj.writeToSocket(sprintf('SWE:RES:ALL'));
        end
        
        function [obj] = setRFOn(obj)
            
            obj.RFState = 1;
            
        
            obj.writeToSocket(sprintf(':OUTPUT:STATE 1'));
            
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function [obj] = setRFOff(obj)
        
            obj.RFState = 0;
            
            obj.writeToSocket(sprintf(':OUTPUT:STATE 0'));
            
             % notify of the state change
            notify(obj,'SignalGeneratorChangedState');
        end
        
        
        % GET FUNCTIONS
        function [obj] = getFrequency(obj)
            s = obj.writeReadToSocket(sprintf(':FREQuency:FIXED?'));
            obj.Frequency = str2num(s);
        end
        
        function [obj] = getFrequencyMode(obj)
            s = obj.writeReadToSocket(sprintf(':FREQuency:MODE?'));
            obj.FrequencyMode = deblank(s);
        end
        
        function [obj] = getAmplitude(obj)
            s = obj.writeReadToSocket(sprintf(':POWER:LEVEL:IMMEDIATE:AMPLITUDE?'));
            obj.Amplitude = str2num(s);
        end
        
        function [obj] = getSweepStart(obj)
            s = obj.writeReadToSocket(sprintf(':FREQuency:START?'));
            obj.SweepStart = str2num(s);
        end
        
        function [obj] = getSweepStop(obj)
            s = obj.writeReadToSocket(sprintf(':FREQuency:STOP?'));
            obj.SweepStop = str2num(s);
        end
        
        function [obj] = getSweepStep(obj)
        end
        
        function [obj] = getSweepPoints(obj)
            s = obj.writeReadToSocket(sprintf(':SWEEP:POINTS?'));
            obj.SweepPoints = str2num(s);
        end
        
        function [obj] = getSweepMode(obj)
            s = obj.writeReadToSocket(sprintf('SOUR:SWE:FREQ:MODE?'));
            obj.SweepMode = deblank(s);
        end
        
        function [obj] = getSweepTrigger(obj)
            s = obj.writeReadToSocket(sprintf('TRIG:FSW:SOUR?'));
            obj.SweepTrigger = deblank(s);
        end 
        
        function [obj] = getSweepDirection(obj)
            %s = obj.writeReadToSocket(sprintf(':SOURCE:LIST:DIRECTION?'));
            % no direction
            s = '';
            obj.SweepDirection = deblank(s);
        end 
        
        function [obj] = queryState(obj)
            
            [s] = obj.writeReadToSocket(':SOURCE:FREQuency:FIXed?');
            Query{1} = sprintf('FREQUENCY = \t\t%s HZ',s(1:end-1));
            
            [s] = obj.writeReadToSocket(':SOURce:POWer:LEVel:IMMediate:AMPLitude?');
            Query{2} = sprintf('AMPLITUDE = \t\t%s dBM',s(1:end-1));
            
            [s] = obj.writeReadToSocket(':OUTPUT:STATE?');
            Query{3} = sprintf('RF STATE = \t\t\t%s',s(1:end-1));

            [s] = obj.writeReadToSocket(':FREQuency:START?');
            Query{4} = sprintf('FREQUENCY START = \t%s HZ',s(1:end-1));
            
            
            [s] = obj.writeReadToSocket(':FREQuency:STOP?');
            Query{5} = sprintf('FREQUENCY STOP = \t%s HZ',s(1:end-1));
            
            [s] = obj.writeReadToSocket(':SWEEP:POINTS?');
            Query{6} = sprintf('SWEEP POINTS = \t\t%s',s(1:end-1));
            
                
            [s] = obj.writeReadToSocket('TRIG:FSW:SOUR?');
            Query{7} = sprintf('TRIGGER SOURCE = \t%s',s(1:end-1));

            %[s] = obj.writeReadToSocket(':SOURCE:LIST:DIRECTION?');
            s = '';
            Query{8} = sprintf('SWEEP DIRECTION = \t%s',s(1:end-1));
            
            %[s] = obj.writeReadToSocket(':FREQ:MODE?');
            s = '';
            Query{9} = sprintf('FREQ MODE = \t\t%s',s(1:end-1));
            
            %[s] = obj.writeReadToSocket(':LIST:TYPE?');
            s ='';
            Query{10} = sprintf('SWEEP TYPE = \t\t%s',s(1:end-1));


            obj.QueryString = Query;
        end
        
        function [obj] = reset(obj)
            obj.writeToSocket('*RST');
        end
        
        function [obj] = setModulationOff(obj);
            obj.writeToSocket(':OUTPUT:MODULATION:STATE 0');
        end
        
            
        function delete(obj)
            fclose(obj.SocketHandle);
        end
        
        function writeToSocket(obj,string)
            
            % check if the socket is already open
            if (strcmp(obj.SocketHandle.Status,'closed')),
                % open a socket connection
                fopen(obj.SocketHandle);
                CloseOnDone = 1;
            else,
                CloseOnDone = 0;
            end
            
            % send the set frequency command
            fprintf(obj.SocketHandle,string)
            
            if CloseOnDone,
                % close the socket
                fclose(obj.SocketHandle);
            end
            
        end
        
        function [output] = writeReadToSocket(obj,string)
            
            % check if the socket is already open
            if (strcmp(obj.SocketHandle.Status,'closed')),
                % open a socket connection
                fopen(obj.SocketHandle);
                CloseOnDone = 1;
            else,
                CloseOnDone = 0;
            end

            
            % send the set frequency command
            fprintf(obj.SocketHandle,string)
            
            output = fscanf(obj.SocketHandle);
            
            if CloseOnDone,
                % close the socket
                fclose(obj.SocketHandle);
            end
        end
            
    end
end