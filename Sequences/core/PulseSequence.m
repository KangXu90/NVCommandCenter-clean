classdef PulseSequence < handle

    % PulseSeuqnce Class
    % Jonathan Hodges
    % jonathan.hodges@gmail.com
    % 27 July 2009
    %
    % derived from Jero Maze's Pulse Sequencer
    
    properties
        MWHWChannel
        Channels
        Groups
        Sweeps
        SweepIndex
        SequenceName
    end
    properties (Transient = true)
        Listeners
    end
    
    methods
        function [obj] = PulseSequence(varargin)
            if nargin == 6,
                obj.Channels = varargin{1};
                obj.Groups = varargin{2};
                obj.Sweeps = varargin{3};
                obj.SweepIndex = varargin{4};
                obj.SequenceName = varargin{5};
                obj.Listeners = varargin{6};
                
                % change the callbacks of the listners,
                for k=1:numel(obj.Listeners),
                    if isa(obj.Listeners{k},'event.listener'),
                        obj.Listeners{1,k}.Callback = @(src,evnt)obj.throwEvent();
                    end
                end
                
            elseif nargin == 5,
                obj.Channels = varargin{1};
                obj.Groups = varargin{2};
                obj.Sweeps = varargin{3};
                obj.SweepIndex = varargin{4};
                obj.SequenceName = varargin{5};
                
                % loop over channels, adding listeners
                for k=1:numel(obj.Channels),         
                     obj.Listeners{1,k} = ...
                        addlistener(obj.Channels(k),'PulseChannelChangedState',@(src,evnt)obj.throwEvent());
                end
                
                % loop over sweeps, adding listeners
                for k=1:numel(obj.Sweeps),
                     obj.Listeners{2,k} = ...
                        addlistener(obj.Sweeps(k),'PulseSweepChangedState',@(src,evnt)obj.throwEvent());
                end
                
                % loop over groups, adding listeners
                for k=1:numel(obj.Groups),
                     obj.Listeners{3,k} = ...
                        addlistener(obj.Groups(k),'PulseGroupChangedState',@(src,evnt)obj.throwEvent());
                end
            end
        end
        
        function SavePulseSequence(obj,fn)
        end
        
        function [minTime] = GetMinRiseTime(obj)
            minTime = 1e15;
            for k=1:numel(obj.Channels)
                temp = min(obj.Channels(k).RiseTimes);
                if temp < minTime
                    minTime = temp;
                end
            end
        end
        
        function [maxTime] = GetMaxRiseTime(obj)
            maxTime = 0;
            for k=1:numel(obj.Channels),
                temp = max(obj.Channels(k).RiseTimes + obj.Channels(k).RiseDurations);
                if temp > maxTime
                    maxTime = temp;
                end
            end
        end
        
        function [maxHWChannel] = GetMaxHWChannel(obj)
            maxHWChannel = 0;
            for k=1:numel(obj.Channels)
                if obj.Channels(k).HWChannel > maxHWChannel
                    maxHWChannel = obj.Channels(k).HWChannel;
                end
            end
        end
            
        function [obj] = addChannel(obj)
            temp = PulseChannel();
            temp.HWChannel = GetMaxHWChannel(obj);
            if numel(obj.Channels) == 0
                obj.Channels = temp;
            else
                obj.Channels(end+1) = temp;
            end
            
            ind = length(obj.Channels);
            obj.Listeners{1,ind} = ...
                addlistener(obj.Channels(end),'PulseChannelChangedState',@(src,evnt)obj.throwEvent());
            notify(obj,'PulseSeqeunceChangedState');
        end
        
        function [obj] = addSweep(obj)
            temp = PulseSweep();
            if numel (obj.Sweeps) == 0
                obj.Sweeps = temp;
            else
                obj.Sweeps(end+1) = temp;
            end
            ind = length(obj.Sweeps);
             obj.Listeners{2,ind} = ...
                addlistener(obj.Sweeps(end),'PulseSweepChangedState',@(src,evnt)obj.throwEvent());
            notify(obj,'PulseSeqeunceChangedState');
        end
        
        function [obj] = addGroup(obj)
            temp = PulseGroup();
            if numel (obj.Groups) == 0
                obj.Groups = temp;
            else
                obj.Groups(end+1) = temp;
            end
            ind = length(obj.Groups);
            obj.Listeners{3,ind} = addlistener(obj.Groups(end),'PulseGroupChangedState',@(src,evnt)obj.throwEvent());
            notify(obj,'PulseSeqeunceChangedState');
        end
        
        function [obj] = deleteChannel(obj,chn)
            obj.Channels(chn) = [];
            delete(obj.Listeners{1,chn});
            obj.Listeners{1,chn} = [];
            notify(obj,'PulseSeqeunceChangedState');
        end
        
        
        function [obj] = deleteSweep(obj,swp)
            obj.Sweeps(swp) = [];
            delete(obj.Listeners{2,swp});
            obj.Listeners{2,swp} = [];
            notify(obj,'PulseSeqeunceChangedState');
        end
        
        function [obj] = addRiseToChannel(obj,chn)
            obj.Channels(chn).addRise();
        end
        
        function [obj] = deleteRiseFromChannel(obj,chn,rise,bShift)
            obj.Channels(chn).deleteRise(rise,bShift);
        end
        
        function [channels] = getHardwareChannels(obj)
            channels = [obj.Channels(:).HWChannel];
        end
            
        function [] = throwEvent(obj)
            
            notify(obj,'PulseSeqeunceChangedState');
        end
        
        function [ind] = getSweepIndex(obj)
            
            if isempty(obj.SweepIndex)
                
                ind = [];
                % if it's empty, define as all ones
                for k=1:numel(obj.Sweeps)
                    ind(k) = 1;
                end
                obj.SweepIndex = ind;
                return;
            end
            
            TotalPts = 1;
            for k=1:numel(obj.Sweeps)
                TotalPts = TotalPts * obj.Sweeps(k).SweepPoints;
            end
                
            if prod(obj.SweepIndex) <= TotalPts
                ind = obj.SweepIndex;
            else
                ind = 0;
            end
        end
        
        function [ind] = getSweepIndexTimeExp(obj)
            
            if isempty(obj.SweepIndex)
                
                ind = [];
                % if it's empty, define as all ones
                for k=1:numel(obj.Sweeps)
                    ind(k) = 1;
                end
                obj.SweepIndex = ind;
                return;
            end
            
            TotalPts = 1;
            for k=1:numel(obj.Sweeps)
                TotalPts = TotalPts*obj.Sweeps(k).SweepPoints*obj.Sweeps(k).StopValue+1;
            end
                
            if prod(obj.SweepIndex) <= TotalPts
                ind = obj.SweepIndex;
            else
                ind = 1;
%                 ind = 0;
            end
        end        
        
        function [ind] = getSweepIndexMax(obj)

            ind = [];
            for k=1:numel(obj.Sweeps)
               ind(k) = obj.Sweeps(k).SweepPoints;
            end
        end
        
        function [ind] = getSweepIndexMaxTimeExp(obj)

            ind = [];
            for k=1:numel(obj.Sweeps)
               ind(k) = obj.Sweeps(k).SweepPoints*obj.Sweeps(k).StopValue+1;
            end
        end        
            
        
        function [] = incrementSweepIndex(obj)
            
            ind = obj.SweepIndex;
            for k=1:numel(obj.Sweeps),
                maxind(k) = obj.Sweeps(k).SweepPoints;
            end

            obj.SweepIndex = incr(ind,maxind);

        end
        
        function [] = incrementSweepIndexTimeExp(obj)
            
            ind = obj.SweepIndex;
            for k=1:numel(obj.Sweeps)
                maxind(k) = obj.Sweeps(k).SweepPoints*obj.Sweeps(k).StopValue+1;
            end

            obj.SweepIndex = incr(ind,maxind);

        end
        
        function [] = setMWHWChannel(obj,chn)
            
            obj.MWHWChannel = chn;

        end
        
        function [ind] = incr(ind,maxind)

        % set curdim to right most index
        curdim = numel(ind);

        [ind] = recur(ind,curdim,maxind);
        end

        function [ind] = recur(ind,curdim,maxind)
        if curdim < 1
            ind = zeros(size(ind));
            return
        elseif ind(curdim) < maxind(curdim)
            ind(curdim) = ind(curdim) + 1;
            for k=curdim+1:numel(ind)
                ind(k) = 1;
            end
            return;
        elseif ind(curdim) == maxind(curdim)
            [ind] = recur(ind,curdim-1,maxind);
        end
        end

        
        function theClone = clone(obj)
            % Instantiate new object of the same class.
            theClone = feval(class(obj));
            
            % due to array index, must assign the object, then remove
            theClone.Channels = PulseChannel();
            theClone.Channels(1) = [];
            
            theClone.Sweeps = PulseSweep();
            theClone.Sweeps(1) = [];
            
            theClone.Groups = PulseGroup();
            theClone.Groups(1) = [];
            
            % Copy all non-hidden properties.
            p = properties(obj);
            for i = 1:length(p)
                
                if isobject(obj.(p{i}))
                    for k=1:numel(obj.(p{i}))
                        theClone.(p{i})(end+1) = obj.(p{i})(k).clone();
                    end
                else
                    theClone.(p{i}) = obj.(p{i});
                end
            end
            
            % VERY IMPORTANT
            % you may have "cloned" the listeners, which is bad.
            % the clone should have the same handles to listeners.
            % this doesnt work
            % theClone.Listeners = obj.Listeners;
            % loop over channels, adding listeners
                for k=1:numel(theClone.Channels)         
                     theClone.Listeners{1,k} = ...
                        addlistener(theClone.Channels(k),'PulseChannelChangedState',@(src,evnt)theClone.throwEvent());
                end
                
                % loop over sweeps, adding listeners
                for k=1:numel(theClone.Sweeps),
                     theClone.Listeners{2,k} = ...
                        addlistener(theClone.Sweeps(k),'PulseSweepChangedState',@(src,evnt)theClone.throwEvent());
                end
        end
        
        function [obj] = copy(obj,obj2)          
            
            p = properties(obj);
            % copy the values back
            for k=1:length(p)
                obj.(p{k}) = obj2.(p{k});
            end
            notify(obj,'PulseSeqeunceChangedState');
        end
        
        %%% added by jhodges, 5 Apr 2010
        
        function [e] = CalculateEvents(obj)
        % function [e] = CalculateEvents(obj)
        %
        % Takes the PulseSequence, given in Rise Times and Durations, per
        % channel, and calculates the events for the sequence.
        % An event is defined as a time when one of the lines changes
        % state.
        e = [];

        for k=1:numel(obj.Channels)
            for jj=1:obj.Channels(k).NumberOfRises
                l = length(e);
                e(l+1) = obj.Channels(k).RiseTimes(jj);
                e(l+2) = e(l+1) + obj.Channels(k).RiseDurations(jj);
            end
        end

        f = unique(e);
        e = sort(f,'ascend');
        end    

    end
    
    methods (Static = true)
        function [obj] = loadobj(a)
            
            % add in the listeners, which should not be saved
            
%             for k=1:numel(a.Channels),
%                 a.Listeners{1,k} = ...
%                     addlistener(a.Channels(k),'PulseChannelChangedState',@(src,evnt)a.throwEvent());
%             end
%             for k=1:numel(a.Sweeps),
%                  a.Listeners{2,k} = ...
%                     addlistener(a.Sweeps(k),'PulseSweepChangedState',@(src,evnt)a.throwEvent());
%             end
%             if  sum(strcmp(fieldnames(a),'Listeners')),
%                 obj = PulseSequence(a.Channels,a.Groups,a.Sweeps,a.SweepIndex,a.SequenceName,a.Listeners);
%             else
%                 obj = PulseSequence(a.Channels,a.Groups,a.Sweeps,a.SweepIndex,a.SequenceName);
%             end
            obj = PulseSequence(a.Channels,a.Groups,a.Sweeps,a.SweepIndex,a.SequenceName);

        end
    end
    
    events
       PulseSeqeunceChangedState 
    end
end