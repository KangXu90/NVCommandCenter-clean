classdef PIControl < handle
    
    properties
        LibAlias                % alias for library loaded
        LibraryFilePath         % path to E816_DLL.dll on Windows
        HeaderFilePath          % path to E816_DLL.h on Windows
        ID
        CurrentPosition = 0;
        StepSize
        axis
        
    end
    
    methods
        
        function [obj] = PIControl(LibraryName,LibraryFilePath,HeaderFilePath)
            obj.LibAlias = LibraryName;
            obj.LibraryFilePath = LibraryFilePath;
            obj.HeaderFilePath = HeaderFilePath;
            obj.initialize();
        end
        %loads DLL's for PI and connects to the device and turns on servos
        function [] = initialize(obj)
                % only load dll if it wasn't loaded before
            if(~libisloaded(obj.LibAlias))
                loadlibrary (obj.LibraryFilePath,obj.HeaderFilePath,'alias',obj.LibAlias);
            end
            %%
            % only connect to Controller if no connection exists
            if(~exist('ID'))
                obj.ID = calllib(obj.LibAlias,'E816_ConnectRS232',4,115200);%the arguments may need to change here depending on setup
                if(obj.ID<0)
                clear('ID');
                end
            end
            
            % query connected axes
            obj.axis = blanks(10);
            [ret,obj.axis] = calllib(obj.LibAlias,'E816_qSAI',obj.ID,obj.axis,10);
            %%
            % query servo state
            svo = zeros(size(obj.axis));
            [ret,obj.axis,svo] = calllib(obj.LibAlias,'E816_qSVO',obj.ID,obj.axis,svo);
            %%
            % set servo state to on
            svo = ones(size(obj.axis));
            calllib(obj.LibAlias,'E816_SVO',obj.ID,obj.axis,svo);
            
        end
        
        %returns the current position of Z
        function [position] = GetCurrentPosition(obj)
            [ret,obj.axis,position] = calllib(obj.LibAlias,'E816_qPOS',obj.ID,obj.axis,obj.CurrentPosition);   
            
        end
        
        %sets the step size
        function [] = SetStepSize(obj,step)
            obj.StepSize = step;
        end
        
        %changes the absolute position  of Z and sets the current value
        function [] = SetPosition(obj,pos)
            calllib(obj.LibAlias,'E816_MOV',obj.ID,obj.axis,pos);
            obj.CurrentPosition = pos;
        end
        
        %Changes the relative position of the Z axis by amount step
        function [] = ChangePositionRelative(obj,step)
            calllib(obj.LibAlias,'E816_MVR',obj.ID,obj.axis,step);
        end
        
        %steps Z up one step size
        function [] = StepPositionUp(obj)
           ChangePositionRelative(obj,obj.StepSize) 
        end
        
        %Steps Z down one step size 
        function [] = StepPositionDown(obj)
           ChangePositionRelative(obj,-1*obj.StepSize) 
        end
        
        function[] = destroy(obj)
            % close connection to controller
            calllib(obj.LibAlias,'E816_CloseConnection',obj.ID);
            % unload library
            unloadlibrary(obj.LibAlias);
            % delete ID variable
            clear('ID'); 
        end
        
    end
    
end

