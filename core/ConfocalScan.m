classdef ConfocalScan < handle
    % Confocal Scan object for NV imaging
    %
    % Jonathan Hodges <jhodges@mit.edu>
    % 5 May 2009
    %
    
    properties
        MaxValues = [0 0 0]; % x, y, z
        MinValues = [0 0 0]; % x, y, z
        NumPoints = [1 1 1]; % x, y, z
        DwellTime = 0.001 % seconds
        OffsetValues = [0 0 0]; % x, y, z
        bEnable = [1 1 0]; %Default to 2D scan
    end %properties
    
    methods
    
        % boring constructor
        function obj = ConfocalScan()
        end
        
        function [obj] = ImportScan(obj,S)
            
            % function [obj] = ImportScan(obj,S)
            % 
            % copies a structure object to current scan
            
            obj.MaxValues = S.MaxValues;
            obj.MinValues = S.MinValues;
            obj.NumPoints = S.NumPoints;
            obj.DwellTime = S.DwellTime;
            obj.OffsetValues = S.OffsetValues;
            obj.bEnable = S.bEnable;
        end
        
        function [S] = ExportScan(obj)
            
            % function [S] = ExportScan(obj)
            %
            % returns a structure for the current scan
            S.MaxValues = obj.MaxValues;
            S.MinValues = obj.MinValues;
            S.NumPoints = obj.NumPoints;
            S.DwellTime = obj.DwellTime;
            S.OffsetValues = obj.OffsetValues;
            S.bEnable = obj.bEnable;
        end
        
    end
    
    
    events
        ScanStateChange      % when data is ready, change scan state
    end
end