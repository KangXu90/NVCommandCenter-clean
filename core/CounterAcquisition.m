classdef CounterAcquisition < handle
    
    % MATLAB class object for interfacing hardware control parameters to
    % software data acquisition for reading counter
    %
    % Jonathan Hodges <jhodges@mit.edu>
    % 8 June 2009
   
    
    properties
        interfaceNIDAQ;   % handle to hardware interface for counter
        DwellTime;
        DutyCycle = 0.5;
        NumberOfSamples;
        CounterData;
        CountsPerSecond;
        LoopsUntilTimeOut;
        CounterInLine = 0;
        CounterOutLine = 0;
        
    end
    
    methods
        
      function [] = SetPulseTrain(obj)
            
        obj.interfaceNIDAQ.CreateTask('PulseTrain');

        %ConfigureClockOut(obj,TaskName,CounterOutLines,ClockFrequency,Duty
        %Cycle)
        obj.interfaceNIDAQ.ConfigureClockOut('PulseTrain',obj.CounterOutLine,1/obj.DwellTime,obj.DutyCycle);
      end
        
      function [] = SetCounter(obj)
            obj.interfaceNIDAQ.CreateTask('CounterAcq');

            obj.interfaceNIDAQ.ConfigureCounterIn('CounterAcq',obj.CounterInLine,obj.NumberOfSamples);
      end
      
      
      function [] = GetCountsPerSecond(obj)
            
         
            % configure the pulses and counters
            
            obj.SetCounter();
            obj.SetPulseTrain();
            
            % first start the pulse train
            obj.interfaceNIDAQ.StartTask('PulseTrain');
            
            % wait for it to start
            pause(0.1);
            
            % start the counters and the voltages
            obj.interfaceNIDAQ.StartTask('CounterAcq');
            
            % wait for it to start
            pause(0.1);
            
            % wait until the counter finishes
            obj.interfaceNIDAQ.WaitUntilTaskDone('CounterAcq');

            % read out the data
            obj.CounterData = obj.interfaceNIDAQ.ReadCounterBuffer('CounterAcq',obj.NumberOfSamples);
            
            % clear the tasks
            obj.interfaceNIDAQ.ClearTask('CounterAcq');
            obj.interfaceNIDAQ.ClearTask('PulseTrain');
            
            % process the data into a meaningful number
            
            DiffCounts = diff(obj.CounterData);
            TotalCounts = sum(DiffCounts);
            % counts per second is total counts divided by the total
            % acquisition time, which is the number of sample periods X
            % dwell time X duty cycle
            obj.CountsPerSecond = TotalCounts/((obj.NumberOfSamples-1)*obj.DwellTime*obj.DutyCycle);

      end
        
    end
end