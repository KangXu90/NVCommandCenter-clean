classdef PulseSweep < handle
    
    
    properties
        Channels
        SweepClass % Rise, Type, Group
        SweepType  % Duration, Time, Amplitude, etc
        SweepRises % Rises associated with sweep
        StartValue % Start of Stop values
        StopValue
        SweepPoints
        SweepShifts % 0,1,2 (none,per channel, globally)
        SweepAdd
        CurrentSweepIndex
    end
    
    methods
            function theClone = clone(obj)
                % Instantiate new object of the same class.
                theClone = feval(class(obj));

                % Copy all non-hidden properties.
                p = properties(obj);
                for i = 1:length(p)

                        if isobject(obj.(p{i})),
                        theClone.(p{i}) = obj.(p{i}).clone();
                    else,
                        theClone.(p{i}) = obj.(p{i});
                    end
                end
            end
            
            function [obj] = setSweepParams(obj,Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add)

                obj.Channels = Channel;
                obj.SweepType = Type;
                obj.SweepClass = Class;
                obj.StartValue = StartValue;
                obj.StopValue = StopValue;
                obj.SweepRises = Rise;
                obj.SweepPoints = Points;
                obj.SweepShifts = Shifts;
                obj.SweepAdd = Add;
  
                notify(obj,'PulseSweepChangedState');
            end
    end
    events
        PulseSweepChangedState;
    end
end