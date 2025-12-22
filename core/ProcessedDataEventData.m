classdef ProcessedDataEventData < event.EventData
    properties
        inds
        expType
    end

    methods
        function obj = ProcessedDataEventData(inds, expType)
            obj.inds = inds;
            if nargin < 2
                obj.expType = '';
            else
                obj.expType = expType;
            end
        end
    end
end
