%Class to handle shaped pulses

classdef shape < handle
    
    properties
        power
        numpoints
        pulse
        filename
        offset
        
    end
    
    methods
        %Constructor
        function shape_obj = shape()
            
            %Set to empty
            shape_obj.power = 0;
            shape_obj.numpoints = 0;
            shape_obj.pulse = [];
            shape_obj.filename = '';
            shape_obj.offset = 0;
            
        end
        
        %Set the pulse to a hard pulse with a specified power
        function square(shape_obj,powerin)
            shape_obj.power = powerin;
            shape_obj.numpoints = 1;
            shape_obj.pulse = [1 0];
        end
        
        %Function to create a Gaussian shape with a specified power
        function gaussian(shape_obj,powerin,numpoints,width)
            shape_obj.power = powerin;
            shape_obj.numpoints = numpoints;
            shape_obj.pulse = [exp(-(linspace(-width,width,numpoints).^2))' zeros(numpoints,1)];
        end
            
        
        %Load a pulse from a file name
        function loadpulse(shape_obj,filenamein)
            if(exist(filenamein,'file'))
                shape_obj.pulse = csvread(filenamein);
                shape_obj.pulse(:,2) = shape_obj.pulse(:,2);
            else
                error(['Unable to load pulsefile: ' filenamein]);
            end
            shape_obj.numpoints = size(shape_obj.pulse,1);
            shape_obj.filename = filenamein;
            
        end
        
    end
    
end

    
            
            