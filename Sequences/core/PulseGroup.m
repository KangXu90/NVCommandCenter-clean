classdef PulseGroup < handle
   
    properties
        Name
        StartEvent
        EndEvent
        Loops
    end
    
    methods
        function [obj] = setStartEvent(obj,event)
            obj.StartEvent = event;
            notify(obj,'PulseGroupChangedState');
        end
        
        function [obj] = setEndEvent(obj,event)
            obj.EndEvent = event;
            notify(obj,'PulseGroupChangedState');
        end
        
        function [obj] = setLoops(obj,loops)
            obj.Loops = loops;
            notify(obj,'PulseGroupChangedState');
        end
        
        function [obj] = setGroupProperties(obj,name,startev,endev,loops)
            obj.Name = name;
            obj.Loops = loops;
            obj.StartEvent = startev;
            obj.EndEvent = endev;
            notify(obj,'PulseGroupChangedState');
        end
        
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
    end
    events
        PulseGroupChangedState
    end
end