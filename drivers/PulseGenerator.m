classdef PulseGenerator < handle
   
    
    properties
        ClockRate
        hwHandle
    end
    
    methods
        function [obj] = PulseGenerator
        end
        
        function [obj] = setClockRate(obj,ClockRate)
            obj.ClockRate = ClockRate;
            obj.hwHandle.setSourceFrequency(obj.ClockRate);
        end
        
        function [obj] = init(obj)
        end
        
        function [obj] = start(obj)
        end
        
        function [obj] = sendSequence(obj,BinarySequence)
        end
        
        function [obj] = stop(obj)
        end
        
        function [obj] = close(obj)
        end
        
        function [obj] = abort(obj)
        end
    end
    
end