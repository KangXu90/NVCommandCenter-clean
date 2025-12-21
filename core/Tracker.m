classdef Tracker < handle
   
    properties
        hCounterAcquisition
        hwLaserController
        hwLaserState = 0
        hImageAcquisition
        InitialStepSize
        StepReductionFactor
        MinimumStepSize
        TrackingThreshold
        MaxIterations
        CurrentStepSize
        InitialPosition
        MinCursorPosition
        MaxCursorPosition
        hasAborted = 0;
    end
    
    methods
        function [obj] = Tracker()
        end
        
        function [counts] = GetCountsCurPos(obj)
            counts = 0;
        end
        
        function [counts] = GetCountsAtPos(obj,Pos)
            counts = 0;
        end
        
        function [] = laserOn(obj)
        end
        
        function [] = laserOff(obj)
        end
        
        function [obj] = trackCenter(obj)
        end
        
    end
end