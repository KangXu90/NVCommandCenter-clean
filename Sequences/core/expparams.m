%Class file to store all the experimental parameters
classdef expparams < handle
    
    properties
        sp = shape.empty()
        defines
        ph
        phcycloops = 1
        numShots = 50e3
        numAverages = 16
        
        AWGfreq = 500e6
        IFfreq
        
        sequence
        ppFile
        
        channels = channel.empty()
        sweeps
        
        counterChannel
        
        BField = zeros(1,3);
        
        
  
    end
        
    methods
        %Constructor function
        function obj = expparams()
            
            %Initialize the predefined variables for 1 through 99
            for ct = 1:1:99
                %Delays
                obj.defines.(sprintf('d%d',ct)).type = 'delay';
                obj.defines.(sprintf('d%d',ct)).value = 0;
                
                %Pulse lengths
                obj.defines.(sprintf('p%d',ct)).type = 'pulse';
                obj.defines.(sprintf('p%d',ct)).value = 0;
                
                %Loop counters
                obj.defines.(sprintf('l%d',ct)).type = 'counter';
                obj.defines.(sprintf('l%d',ct)).value = 0;
                
                %Phases
                obj.ph(ct).values = [];
                obj.ph(ct).index = 1;
            end
            
            %Since shapes are a handle class we deal with this differently (see Initializing a
            %Handle Object Array) in the Help.  
            obj.sp(99) = shape();
        end %constructor function
        
        %Method to add channel
        function addchannel(obj,logicalName,physicalName,type,delayOn,delayOff)
            obj.channels(end+1) = channel(logicalName,physicalName,type,delayOn,delayOff);
        end
        
    end
        
end

    