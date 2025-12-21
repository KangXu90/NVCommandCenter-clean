classdef SignalGenerator < handle
    
    
    properties
        Frequency
        FrequencyMode
        Amplitude
        SweepStart
        SweepStop
        SweepStep
        SweepPoints
        SweepMode
        SweepTrigger
        SweepPointTrigger
        SweepDirection
        RFState
        QueryString
    end
    
    methods
        
        function  obj = SignalGenerator()
        end
        
        function  setFrequency(obj)
        end
        
        function  setAmplitude(obj)
        end
        
        function  setSweepStart(obj)
        end
        
        function  setSweepStop(obj)
        end
        
        function  setSweepStep(obj)
        end
        
        function  setSweepPoints(obj)
        end
        
        function  setFrequencyMode(obj)
        end
        
        function  setSweepMode(obj)
        end
        
        function  setSweepTrigger(obj)
        end
        
        function  setSweepPointTrigger(obj)
        end
        
        function  setSweepDirection(obj)
        end
        
        function  setRFOn(obj)
        end
        
        function  setRFOff(obj)
        end
        
        %Macro function to set all the sweeping parameters at once
        function  setSweepAll(obj)
            obj.setSweepStart();
            obj.setSweepStop();
            obj.setSweepPoints();
            obj.setSweepMode();
            obj.setSweepTrigger();
            obj.setSweepPointTrigger();
            obj.setSweepDirection();
            obj.setSweepContinuous();
        end
        
        % get functions
        
        function  getFrequency(obj)
        end
        
        function  getAmplitude(obj)
        end
        
        function  getSweepStart(obj)
        end
        
        function  getSweepStop(obj)
        end
        
        function  getSweepStep(obj)
        end
        
        function  getSweepPoints(obj)
        end
        
        function  getFrequencyMode(obj)
        end
        
        function  getSweepTrigger(obj)
        end
        
        function  getSweepDirection(obj)
        end
        
        function  queryState(obj)
        end
    end
    
    events
        SignalGeneratorChangedState
    end
end
