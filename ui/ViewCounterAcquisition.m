classdef ViewCounterAcquisition < handle
    
    properties
        hCounterAcquisition
        hFig
        hText
        hStart
        hStop
        hReset
        hSave
        hTraceButton
        hOverride
        hDC
        hDW
        hSample
        CounterStatus = 0
        hTrace = 0
        hTraceAxes
        CounterHistory = [];
        CounterIniatialParameter
    end
    
    
    methods
    
        function [obj] = ViewCounterAcquisition(CA)
            obj.hCounterAcquisition = CA;
            obj.Init();
        end
   
        function [] = Init(obj)
            
            % open of the figure
            obj.hFig = figure('Visible','on','Position',[20,40,200,150],'MenuBar','none','Toolbar','none','Name','Counter','NumberTitle','off');
            obj.hTrace = figure('Visible','on','Position',[20,195,200,100],'Name','Counter Trace','MenuBar','none','Toolbar','none','NumberTitle','off');
            obj.hTraceAxes = axes('Parent',obj.hTrace);
            
            % add CPS text box
            obj.hText = uicontrol(obj.hFig,'Style','text','String','0',...
            'FontSize',30,'Position',[10,95,190,50]);
            
            align(obj.hText,'Center','Middle');
                
            % add start and stop buttons

            obj.hStart = uicontrol(obj.hFig,'Style','pushbutton','String','Start','Position',[10,65,50,20],'Callback',@(src,event)StartCounter(obj));
            obj.hTrace = uicontrol(obj.hFig,'Style','pushbutton','String','Trace','Position',[75 65 50 20],'Callback',@(src,event)ShowTrace(obj));
            obj.hStop = uicontrol(obj.hFig,'Style','pushbutton','String','Stop','Position',[140 65 50 20],'Callback',@(src,event)StopCounter(obj));
            obj.hReset = uicontrol(obj.hFig,'Style','pushbutton','String','Reset','Position',[10 40 50 20],'Callback',@(src,event)ResetTrace(obj));
            obj.hSave = uicontrol(obj.hFig,'Style','pushbutton','String','SaveTrace','Position',[75 40 50 20],'Callback',@(src,event)SaveTrace(obj));

            obj.hOverride = uicontrol(obj.hFig,'Style','checkbox','String','Override','Position',[10 10 70 20]);
            uicontrol(obj.hFig,'Style','text','String','DC','Position',[80 7 20 20]);
            obj.hDC = uicontrol(obj.hFig,'Style','edit','String','0.5','Position',[110 10 30 20]);
            uicontrol(obj.hFig,'Style','text','String','DW','Position',[140 7 20 20]);
            obj.hDW = uicontrol(obj.hFig,'Style','edit','String','0.01','Position',[160 10 30 20]);
            uicontrol(obj.hFig,'Style','text','String','Samp','Position',[120 40 40 20]);
            obj.hSample = uicontrol(obj.hFig,'Style','edit','String','10','Position',[160 40 30 20]);
        end

        function ShowTrace(obj)
            if strcmp(get(obj.hTrace,'Visible'),'on')
                set(obj.hTrace,'Visible','off');
            else
                set(obj.hTrace,'Visible','on');
            end
        end
        
        function ResetTrace(obj)
            obj.CounterHistory = [];
%             obj.hCounterAcquisition = obj.CounterIniatialParameter;
        end
        
        function SaveTrace(obj)

            t = [0:10:10*(length(obj.CounterHistory)-1)];
            T = table(obj.CounterHistory');   
            % Write table T to a new spreadsheet file named 'patientdata.xlsx'
            currentDateTime = datetime('now');
            formattedDate = datestr(currentDateTime, 'ddmmyyyy');
            filename = ['CouterTrace-',formattedDate,'.xlsx'];
            writetable(T,  filename, 'Sheet', 1, 'Range', 'D1');
            
        end
        
        
        function StartCounter(obj)
            obj.CounterIniatialParameter = obj.hCounterAcquisition;

             % start counter ok
            obj.CounterStatus = 0;
            
            % should we over-ride the counter?
            if get(obj.hOverride,'Value');
                Dwell = str2double(get(obj.hDW,'String'));
                DutyCycle = str2double(get(obj.hDC,'String'));
                NumberOfSamples = str2double(get(obj.hSample,'String'));

                obj.hCounterAcquisition.DwellTime = Dwell;
                obj.hCounterAcquisition.DutyCycle = DutyCycle;
                obj.hCounterAcquisition.NumberOfSamples = NumberOfSamples;

            end
            
            for k=1:obj.hCounterAcquisition.LoopsUntilTimeOut
                if ~obj.CounterStatus
                    obj.hCounterAcquisition.GetCountsPerSecond();
                    obj.CounterHistory(end+1) = obj.hCounterAcquisition.CountsPerSecond;
                    set(obj.hText,'String',num2str(round(obj.hCounterAcquisition.CountsPerSecond)));
                    
                    % update plot
                    plot(obj.CounterHistory,'b-','Parent',obj.hTraceAxes);
                else
                    obj.CounterStatus = 0;
                    break;
                end
            end
         end
      
         function StopCounter(obj)
             obj.CounterStatus = 1;
             obj.hCounterAcquisition = obj.CounterIniatialParameter;
             disp(mean(obj.CounterHistory));
             disp(sqrt(var(obj.CounterHistory)));
         end
         
         function delete(obj)
             close(obj.hFig);
         end
    end
end

