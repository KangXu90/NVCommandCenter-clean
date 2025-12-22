classdef DataProcessor < handle
    % DataProcessor
    % Pulse-mode data processing (Rabi/T2) decoupled from NICounter acquisition.
    %
    % Responsibilities:
    %   - Read RawData from Counter (after NICounter streamCounts completes)
    %   - Update Counter.AveragedData / Counter.ProcessedData for a single sweep index (inds)
    %   - Notify listeners with inds + expType for incremental plot updates

    properties
        CounterRef  % handle to Counter (e.g., NICounter)
    end

    events
        UpdateCounterProcData
        UpdateCounterProcData_Rabi
        UpdateCounterProcData_T2
    end

    methods
        function obj = DataProcessor(counterObj)
            if nargin > 0
                obj.CounterRef = counterObj;
            end
        end

        function processRawDataPulsed(obj, inds)
            c = obj.CounterRef;

            % Only process if full acquisition for this point is present
            if c.RawDataIndex == c.NCounterGates * c.NSamples
                AvgCounts = mean(double(reshape(c.RawData, c.NCounterGates, c.NSamples)), 2)';

                if isnan(c.AveragedData(inds,:))
                    c.AveragedData(inds,:) = AvgCounts;
                else
                    c.AveragedData(inds,:) = (c.AveragedData(inds,:) * (c.AvgIndex - 1) + AvgCounts) / c.AvgIndex;
                end
            end

            notify(obj, 'UpdateCounterProcData', ProcessedDataEventData(inds, c.expType));
        end

        function processRawDataPulsed_Rabi(obj, inds)
            c = obj.CounterRef;


            AvgCountsContrast = c.AveragedData(inds,2) / c.AveragedData(inds,1);

            if isnan(c.ProcessedData(inds,:))
                c.ProcessedData(inds,:) = AvgCountsContrast;
            else
                c.ProcessedData(inds,:) = (c.ProcessedData(inds,:) * (c.AvgIndex - 1) + AvgCountsContrast) / c.AvgIndex;
            end


            notify(obj, 'UpdateCounterProcData_Rabi', ProcessedDataEventData(inds, c.expType));
        end

        function processRawDataPulsed_T2(obj, inds)
            c = obj.CounterRef;

            AvgCountsContrast = (c.AveragedData(inds,2) - c.AveragedData(inds,3)) ./ (c.AveragedData(inds,2) + c.AveragedData(inds,3));

            if isnan(c.ProcessedData(inds,:))
                c.ProcessedData(inds,:) = AvgCountsContrast;
            else
                c.ProcessedData(inds,:) = (c.ProcessedData(inds,:) * (c.AvgIndex - 1) + AvgCountsContrast) / c.AvgIndex;
            end


            notify(obj, 'UpdateCounterProcData_T2', ProcessedDataEventData(inds, c.expType));
        end
    end
end
