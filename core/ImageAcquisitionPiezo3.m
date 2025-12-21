classdef ImageAcquisitionPiezo3 < ImageAcquisition
    %
    % Controller subclass of ImageAcquisition for 3 axis piezo scanning
    
    properties
        interfaceAPTPiezos % array of APTPiezoDriver elements for APT Piezo controllers
    end
    
    methods
         function [] = SetCursor(obj)
            
            % set the outputs
            % GIVEN IN MICRONS!!!
            obj.interfaceAPTPiezos(1).setPosOutput(obj.CursorPosition(1) + obj.OffsetValues(1));
            obj.interfaceAPTPiezos(2).setPosOutput(obj.CursorPosition(2) + obj.OffsetValues(2));
            obj.interfaceAPTPiezos(3).setPosOutput(obj.CursorPosition(3) + obj.OffsetValues(3));
            
            % notify listeners of the new position
            notify(obj,'UpdateCursorPosition');
        end
           
    end
    
end

