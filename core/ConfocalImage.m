classdef ConfocalImage
%
% ConfocalImage class
% jhodges@mit.edu
% 18 June 2009
%
% Class stores images after scanning in two dimensions
    
    properties
       ImageData      % Raw matrix data of the image
       ScanData       % Confocal Scan parameters
       PositionZ      % Current Z position when plane scanned
       RangeY         % Y values for image
       DomainX        % X values for image
       DateTime       % Time stamp when image was acquired
       Notes          % Notes field
    end
    
    methods
        % ConfocalImage Constructor
        function [obj] = ConfocalImage()
            
            % set DateTime at construction
            obj.DateTime = now();
        end
    end
    
end