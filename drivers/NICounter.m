classdef NICounter < Counter
    
    properties
        CounterInLine
        CounterClockLine
    end
    
    methods
        % constructor
        function [obj] = NICounter(LibraryName,LibraryFilePath,HeaderFilePath)
            obj.hwHandle = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
        end
        
        function [obj] =  init(obj)
            
            obj.hwHandle.CreateTask('Counter');
            
            % configure pulse width style counter
            % total number of samples are NSamples * NCounterGates
            obj.hwHandle.ConfigurePulseWidthCounterIn('Counter',obj.CounterInLine,obj.NSamples*obj.NCounterGates,obj.MinCounts,obj.MaxCounts);
            
            % preallocate data arrays for speed
            obj.RawData = [];
            if length(obj.DataDims) == 1
                obj.AveragedData = NaN(obj.DataDims,obj.NCounterGates);
                obj.ProcessedData = NaN(obj.DataDims,obj.NCounterGates);
                
            else
                obj.AveragedData = NaN(obj.DataDims);
                obj.ProcessedData = NaN(obj.DataDims);
                
            end
            
            % reset aborted bool
            obj.hasAborted = 0;
            
        end
            
        function [obj] = arm(obj)
            obj.hwHandle.StartTask('Counter');
        end
        
        function [obj] =  disarm(obj)
            obj.hwHandle.StopTask('Counter');
        end
        
        function [obj] =  close(obj)
            obj.RawData = [];
            % don't clear the AveragedData.  That's your data you want to
            % save!!!
            %obj.AveragedData = [];
            obj.hwHandle.ClearTask('Counter');
        end
        
        function [] = abort(obj)
            obj.hwHandle.ClearTask('Counter');
            obj.hasAborted = 1;
        end
        
        function [a] = isFinished(obj)
            a = obj.hwHandle.IsTaskDone('Counter');
        end
        
        function [obj] =  streamCounts(obj)
            
            % get the number of samples ready
            SampsAvail = obj.hwHandle.GetAvailableSamples('Counter');
            
            if SampsAvail
                counterdata = obj.hwHandle.ReadCounterBuffer('Counter',SampsAvail);
                obj.RawData(obj.RawDataIndex+1:obj.RawDataIndex+SampsAvail) = counterdata;
                obj.RawDataIndex = obj.RawDataIndex + SampsAvail;
                % notify listeners of new available counter data
                notify(obj,'UpdateCounterData');
            end
                                                
        end
        
        function [obj] =  processRawDataCW(obj)
            
            % check to make sure RawData run was complete (ie not aborted)
            if length(obj.AveragedData) == length(obj.RawData)
                if(isnan(obj.AveragedData))
                    obj.AveragedData = double(obj.RawData);
                else
                    obj.AveragedData = (obj.AveragedData*(obj.AvgIndex -1) + double(obj.RawData))/obj.AvgIndex;
                end
            end
            
            % resest RawData matrix
            obj.RawData = [];
            notify(obj,'UpdateCounterProcData');
        end
        
        function [obj] = processRawDataPulsed(obj,inds)
            
            % first, unpack the counters
            % check to see if we missed a count and timed out
            if obj.RawDataIndex == obj.NCounterGates*obj.NSamples
                AvgCounts = mean(double(reshape(obj.RawData,obj.NCounterGates,obj.NSamples)),2)';
                if(isnan(obj.AveragedData(inds,:)))
                    obj.AveragedData(inds,:) = AvgCounts;
                else
                    obj.AveragedData(inds,:) = (obj.AveragedData(inds,:)*(obj.AvgIndex -1) + AvgCounts)/obj.AvgIndex;
                end
            end
            
            notify(obj,'UpdateCounterProcData');
        end
        function [obj] = processRawDataPulsed_Rabi(obj,inds)
            
            %             first, unpack the counters
            %             check to see if we missed a count and timed out
            if obj.RawDataIndex == obj.NCounterGates*obj.NSamples
                AvgCounts = mean(double(reshape(obj.RawData,obj.NCounterGates,obj.NSamples)),2)';
                AvgCountsContrast = AvgCounts(2)/AvgCounts(1);
                if(isnan(obj.ProcessedData(inds,:)))
                    obj.ProcessedData(inds,:) = AvgCountsContrast;
                else
                    obj.ProcessedData(inds,:) = (obj.ProcessedData(inds,:)*(obj.AvgIndex -1) + AvgCountsContrast)/obj.AvgIndex;
                end
            end
            
            
            notify(obj,'UpdateCounterProcData_Rabi');
        end
        function [obj] = processRawDataPulsed_T2(obj,inds)
            
            %             first, unpack the counters
            %             check to see if we missed a count and timed out
            if obj.RawDataIndex == obj.NCounterGates*obj.NSamples
                AvgCounts = mean(double(reshape(obj.RawData,obj.NCounterGates,obj.NSamples)),2)';
%                 AvgCountsContrast = (AvgCounts(1)-AvgCounts(4))/AvgCounts(1)-(AvgCounts(3)-AvgCounts(2))/AvgCounts(3);
                AvgCountsContrast = (AvgCounts(2)-AvgCounts(3))./ (AvgCounts(2)+ AvgCounts(3));
                if(isnan(obj.ProcessedData(inds,:)))
                    obj.ProcessedData(inds,:) = AvgCountsContrast;
                else
                    obj.ProcessedData(inds,:) = (obj.ProcessedData(inds,:)*(obj.AvgIndex -1) + AvgCountsContrast)/obj.AvgIndex;
                end
            end
            
            
            notify(obj,'UpdateCounterProcData_T2');
        end
        
        function [] = saveRawDataPulsed(obj,SweepIndex,AverageIndex,filepath)
            if length(obj.RawData)== obj.NCounterGates*obj.NSamples
                Q = reshape(obj.RawData,obj.NCounterGates,obj.NSamples)';
                Q = Q(:,2)-Q(:,1);
                %Q = abs(fftshift(fft(Q)));
                load(filepath);
                M = (M*(AverageIndex-1) + Q)/AverageIndex;
                save(filepath,'M');
            end
        end
        
    end %methods
    
    
end %classdef