classdef PulseChannel < handle

    % PulseChannel Class
    % Jonathan Hodges
    % jonathan.hodges@gmail.com
    % 27 July 2009
    %
    % derived from Jero Maze's Pulse Sequencer
    
    properties
        HWChannel       % string to identify hardware channel
        DelayOn = 0     % Delay time for channel to turn on
        DelayOff = 0    % Delay time for channel to turn off
        NumberOfRises = 0;   % number of events for pulse channel
        RiseTimes       % Times when a pulse turns on
        RiseDurations   % Duration of pulses
        RiseTypes       % logical types of each pulse
        RiseAmplitudes  % implement amplitude control
        RisePhases      % implement phase control
        RiseFrequencies % implement frequency modulation
        RiseSweepMultipliers % How much a sweep affects the rise
    end
    
    methods
        function [obj] = PulseChannel()
            
        end
        
        function [obj] = addRise(obj)
            if numel(obj.RiseTimes) < 1
                maxTime = 0;
            else
                maxTime = obj.RiseTimes(end) + obj.RiseDurations(end);
            end
            obj.NumberOfRises = obj.NumberOfRises + 1;
            obj.RiseTimes(end+1) = maxTime;
            % hard code in default duration
            obj.RiseDurations(end+1) = 1e-9;
            obj.RiseTypes{end+1} = '';
            obj.RiseAmplitudes(end+1) = [1.0];
            obj.RisePhases(end+1) = [0];
            obj.RiseSweepMultipliers(end+1) = [1.0];
            notify(obj,'PulseChannelChangedState');
        end
        
        function [obj] = deleteRise(obj,rise,bShift)
            
            if bShift
                shiftTime = obj.RiseDurations(rise);
            end
            
            obj.RiseTimes(rise) = [];
            obj.RiseDurations(rise) = [];
            inds = [1:obj.NumberOfRises];
            inds(rise) = [];
            obj.RiseTypes = obj.RiseTypes(inds);
            obj.RiseAmplitudes(rise) = [];
            obj.RisePhases(rise) = [];
            obj.NumberOfRises = obj.NumberOfRises - 1;
            
            % do the shift
            if bShift
                for k=rise:obj.NumberOfRises,
                    obj.RiseTimes(k) = obj.RiseTimes(k) - shiftTime;
                end
            end
            notify(obj,'PulseChannelChangedState');
        end
            

        function [obj] = setRiseParams(obj,rise,RiseTime,RiseDuration,RiseType,RiseAmplitude,RisePhase,RiseFreq, RiseMulti)
            obj.RiseTimes(rise) = RiseTime;
            obj.RiseDurations(rise) = RiseDuration;
            obj.RiseTypes{rise} = RiseType;
            obj.RiseAmplitudes(rise) = RiseAmplitude;
            obj.RisePhases(rise) = RisePhase;
            obj.RiseFrequencies(rise) = RiseFreq;
            obj.RiseSweepMultipliers(rise) = RiseMulti;
            notify(obj,'PulseChannelChangedState');
        end
        
        function [obj] = setHWChannel(obj,chn)
            obj.HWChannel = chn;
            notify(obj,'PulseChannelChangedState');
        end
        
                        % Make a copy of a handle object.
        function theClone = clone(obj)
            % Instantiate new object of the same class.
            theClone = feval(class(obj));
 
            % Copy all non-hidden properties.
            p = properties(obj);
            for i = 1:length(p)
                
                L = obj.(p{i});
                if isobject(L),
                    theClone.(p{i}) = obj.(p{i}).clone();
                else
                    theClone.(p{i}) = obj.(p{i});
                end
            end
        end
    end

    events
        PulseChannelChangedState
    end
end
