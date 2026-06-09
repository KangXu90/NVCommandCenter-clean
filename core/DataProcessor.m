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
        UpdateCounter2D
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

        function processRawDataPulsed2D(obj, inds)
            % 2D-sweep processing. inds = [innerIdx outerIdx].
            % Updates Counter.AveragedData(i,j,:) (raw counts, gates on dim 3) with
            % the running average, then Counter.ProcessedData(i,j,1) with the
            % contrast for the selected process mode -- same definitions as the 1D
            % Rabi/T2 methods below (Rabi: gate2/gate1; T2: (g3-g2)/(g2+g3)).
            % Additive: leaves the 1D methods/events untouched.
            c = obj.CounterRef;

            if c.RawDataIndex == c.NCounterGates * c.NSamples
                AvgCounts = mean(double(reshape(c.RawData, c.NCounterGates, c.NSamples)), 2)';
                AvgCounts = reshape(AvgCounts, 1, 1, []);   % 1 x 1 x gates

                prev = c.AveragedData(inds(1), inds(2), :);
                if all(isnan(prev(:)))
                    c.AveragedData(inds(1), inds(2), :) = AvgCounts;
                else
                    c.AveragedData(inds(1), inds(2), :) = ...
                        (prev * (c.AvgIndex - 1) + AvgCounts) / c.AvgIndex;
                end

                % processed contrast for this grid point (per process mode)
                a = c.AveragedData(inds(1), inds(2), :);   % 1 x 1 x gates
                switch c.expType
                    case 'Rabi'
                        if size(a,3) >= 2, val = a(:,:,2) ./ a(:,:,1); else, val = a(:,:,1); end
                    case 'T2'
                        if size(a,3) >= 3, val = (a(:,:,3) - a(:,:,2)) ./ (a(:,:,2) + a(:,:,3)); else, val = a(:,:,1); end
                    otherwise
                        if size(a,3) >= 2, val = a(:,:,1) ./ a(:,:,2); else, val = a(:,:,1); end
                end
                c.ProcessedData(inds(1), inds(2), 1) = val;
            end

            notify(obj, 'UpdateCounter2D', ProcessedDataEventData(inds, c.expType));
        end

        function processRawDataPulsed_Rabi(obj, inds)
            c = obj.CounterRef;


            AvgCountsContrast = c.AveragedData(inds,2) / c.AveragedData(inds,1);

            if isnan(c.ProcessedData(inds,:))
                c.ProcessedData(inds,1) = AvgCountsContrast;
            else
                c.ProcessedData(:,1) = c.AveragedData(:,2) ./ c.AveragedData(:,1);
            end


            notify(obj, 'UpdateCounterProcData_Rabi', ProcessedDataEventData(inds, c.expType));
        end

        function processRawDataPulsed_T2(obj, inds)
            c = obj.CounterRef;

            AvgCountsContrast = (c.AveragedData(inds,3) - c.AveragedData(inds,2)) ./ (c.AveragedData(inds,2) + c.AveragedData(inds,3));

            if isnan(c.ProcessedData(inds,:))
                c.ProcessedData(inds,1) = AvgCountsContrast;
            else
                c.ProcessedData(:,1) = (c.AveragedData(:,3) - c.AveragedData(:,2)) ./ (c.AveragedData(:,2) + c.AveragedData(:,3));
            end

            notify(obj, 'UpdateCounterProcData_T2', ProcessedDataEventData(inds, c.expType));
        end
    end
end
