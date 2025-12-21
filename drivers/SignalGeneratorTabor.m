classdef SignalGeneratorTabor < handle
    
    
    properties
        Channel = 1
        Frequency1 = 2E9
        Phase1 = 0.00
        Apply6dB1 = 1
        Frequency2 = 0
        Phase2 = 0.00
        Apply6dB2 = 0
        DACmode = 'DUC'
        NCOmode = 'SING'
        Interpolation = 'X8'
        SamplingRate = 8E9
        Amplitude = 0.5
        
        SweepStart1 = 1.8e9
        SweepStop1 = 2.0e9
        SweepPoints1 = 101
        SweepStart2 = 3.94e9
        SweepStop2 = 3.74e9
        SweepPoints2 = 101

        SweepZoneState1 = 1
        SweepZoneState2 = 0
        SweepChannel = 1
        
        RFState = 0
        QueryString
    end
    
    methods
        
        function  obj = SignalGeneratorTabor()
        end
        
        function  setFrequency(obj)
        end
        
        function  setAmplitude(obj)
        end     
        
        function  setApply6dB(obj)
        end     
        
        function  setRFOn(obj)
        end
        
        function  setRFOff(obj)
        end
        
        %Macro function to set all the sweeping parameters at once
%         function  setSweepAll(obj)
%             obj.setSweepStart();
%             obj.setSweepStop();
%             obj.setSweepPoints();
%             obj.setSweepMode();
%             obj.setSweepTrigger();
%             obj.setSweepPointTrigger();
%             obj.setSweepDirection();
%             obj.setSweepContinuous();
%         end
        
        % get functions
        
        function  getFrequency(obj)
        end
        
        function  getAmplitude(obj)
        end
           
        function  getFrequencyMode(obj)
        end
        
        function  queryState(obj)
        end
    end
    
    events
        SignalGeneratorChangedState
    end
end
