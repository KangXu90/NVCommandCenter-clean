classdef TekPulseGenerator < PulseGenerator
    
    properties
        %Number of hardware channels.
        numChannels = 2
        %Physical Names of the Channels
        channelNames
        
    end
    
    methods
        
        function [obj] = TekPulseGenerator(varargin)
            obj.hwHandle = TekAWGController(varargin{:});
            
            
        end
        
        function [obj] = init(obj)
            
            V = obj.hwHandle;
            
            % reset the device
            V.reset();
            
            % set marker voltage high/low
            % CH1: MK1
            V.setmarker(1,1,0,2.7);
            % CH1: MK2
            V.setmarker(1,2,0,2.7);
            % CH2: MK1
            V.setmarker(2,1,0,2.7);
            % CH2: MK2
            V.setmarker(2,2,0,2.7);
            
            % set the digital line out voltages
            V.sendstr('SOURCE1:DIGital:VOLTage:LEVel:IMMediate:LOW 0');
            V.sendstr('SOURCE1:DIGital:VOLTage:LEVel:IMMediate:HIGH 2.5');
            
            % set the analog voltage
            % ??? this should not be hardcoded
            for chct = 1:obj.numChannels
                V.sendstr(sprintf('SOURCE%d:VOLTage:LEVel:IMMediate:AMPLITUDE 1',chct));
            end
            
            
            
            % set clock freq of AWG
            V.setSourceFrequency(obj.ClockRate);
            
            % set to sequence mode
            V.sendstr('AWGCONTROL:RMODE SEQUENCE');
            
            %Create the channel Names
            %??? this should not be hardcoded
            obj.channelNames = cell(obj.numChannels,3);
            for chct = 1:obj.numChannels
                obj.channelNames{chct,1} = sprintf('CH%d.Analog',chct);
                obj.channelNames{chct,2} = sprintf('CH%d.Marker1',chct);
                obj.channelNames{chct,3} = sprintf('CH%d.Marker2',chct);
            end
            
        end
        
        function [obj] = sendSequence(obj,BinarySequence,HWChannels,SequenceSamples,InfLoop)
            
            V = obj.hwHandle;
            
            % Do Hardware Routing
            [WaveA] = obj.CreateSequenceShape(BinarySequence,HWChannels);
            
            if ~isempty(WaveA),
                V.create_waveform_binary('NV_PSeq_A',WaveA);
            end
            
            %             if ~isempty(WaveB),
            %                 V.create_waveform_binary('NV_PSeq_B',WaveB);
            %             end
            
            % assign waveform A to channel 1
            if ~isempty(WaveA),
                V.setSourceWaveForm(1,'NV_PSeq_A');
                % turn on the output to channel 1
                V.setSourceOutput(1,1);
            end
            %
            %             if ~isempty(WaveB),
            %                 V.setSourceWaveForm(1,'NV_PSeq_B');
            %                 % turn on the output to channel 2
            %                 V.setSourceOutput(2,1);
            %             end
            
            % Make a Sequence
            V.initialize_sequence(1);
            
            % assign sequence waveform names
            if ~isempty(WaveA),
                waveforms{1} = 'NV_PSeq_A';
            end
            
            %             if ~isempty(WaveB),
            %                 waveforms{2} = 'NV_PSeq_B';
            %             end
            
            
            if InfLoop,
                V.setSegment(1,waveforms,Inf,[],[],[]);
            else
                
                NumSeqElements = ceil(SequenceSamples/(2^16));
                
                % Make a Sequence
                V.initialize_sequence(NumSeqElements);
                
                
                for k=1:ceil(SequenceSamples/(2^16)),
                    if SequenceSamples/k/(2^16) < 1,
                        V.setSegment(k,waveforms,SequenceSamples - (k-1)*(2^16),[],[],[]);
                    else
                        V.setSsegment(k,waveforms,2^16,[],[]);
                    end
                end
            end
            
            % turn the channels on
            % turn on the output to channel 1
            V.setSourceOutput(1,1);
            %V.setSourceOutput(2,1);
            
            % wait until the device settles
            V.OPCCheck();
        end % sendSequence
        
        %Function to load the waveforms an analog sequence
        function sendPulseSequence(obj,pulseSequence,expNum)
            
            %We assume that each channel has one analog output and two
            %markers. Therefore we create an array with 3 columns for each
            %channel
            channelData = cell(1,obj.numChannels);
            for chct = 1:1:obj.numChannels
               channelData{chct} = zeros(pulseSequence.numPoints,3); 
            end
            
            for chct = 1:length(pulseSequence.channels)
                tmpChannel = pulseSequence.channels(chct);
                switch tmpChannel.type
                    case {'marker','analog'}
                        %Find out which channel
                        [chnum,colnum] = find(strcmp(obj.channelNames,tmpChannel.physicalName));
                        %Load in the data
                        channelData{chnum}(:,colnum) = tmpChannel.AWGData;
                    case 'quadrature'
                        %Get the X and Y data from the IF modulation
                        %Trig arguements array
                        theta = 2*pi*(pulseSequence.expparams.IFfreq*(1/pulseSequence.expparams.AWGfreq)*(1:pulseSequence.numPoints)' + tmpChannel.AWGData(:,2));
                        %Find the X channel
                        [chnum,colnum] = find(strcmp(obj.channelNames,tmpChannel.physicalName{1}));
                        %Load in the data
                        channelData{chnum}(:,colnum) = tmpChannel.AWGData(:,1).*cos(theta);
                        %Find the Y channel
                        [chnum,colnum] = find(strcmp(obj.channelNames,tmpChannel.physicalName{2}));
                        %Load in the data
                        channelData{chnum}(:,colnum) = -tmpChannel.AWGData(:,1).*sin(theta);
                end
            end
            
            %Now actually send it to the AWG
            for chct = 1:obj.numChannels
                obj.hwHandle.create_waveform(sprintf('NV_CH%d_Exp%d',chct,expNum),channelData{chct}(:,1),channelData{chct}(:,2),channelData{chct}(:,3));
            end
            
        end
        
        %Method to setup sequence with
        function loadPulseSequence(obj,numShots,numExp,trackingEnable,trackingLine)
            %Initialize the sequence to the correct length.  We allow one
            %more segment to handle tracking.
            trackingEnable = logical(trackingEnable);
            if(trackingEnable)
                obj.hwHandle.initialize_sequence(numExp+1)
                obj.hwHandle.create_waveform_binary('NV_Tracking',(2^13+2^trackingLine)*ones(250,1));
                obj.hwHandle.create_waveform_binary('NV_Tracking_Zeros',2^13*ones(250,1));
                obj.hwHandle.setSegment(1,{'NV_Tracking','NV_Tracking_Zeros'},Inf,[],2,1);
            else
                obj.hwHandle.initialize_sequence(numExp)
            end
                
            %Now set each segment with wait for trigger
            for segct = 1:numExp
                waveformNames = cell(obj.numChannels,1);
                for chct = 1:obj.numChannels
                    waveformNames{chct} = sprintf('NV_CH%d_Exp%d',chct,segct);
                end
                obj.hwHandle.setSegment(segct+trackingEnable,waveformNames,numShots,segct+trackingEnable+1,[],1);
            end
            
            %Set the last element to jump to one
            obj.hwHandle.sendstr(sprintf('SEQUENCE:ELEMENT%d:GOTO:STATE 1;INDEX 1',segct+trackingEnable));
        end
        
        
        function [obj] = start(obj)
            obj.hwHandle.start();
        end %start
        
        function [obj] = stop(obj)
            obj.hwHandle.stop();
        end
        
        function [obj] = close(obj)
        end
        
        function [] = abort(obj)
            %Stop the AWG
            obj.hwHandle.stop();
            %Turn off the outputs
            for chct = 1:obj.numChannels
                obj.hwHandle.setSourceOutput(chct,0);
            end
            
        end
        
        function [obj] = setLines(obj,BinarySequence,HWChannels)
            
            V = obj.hwHandle;
            
            % Do Hardware Routing
            WaveA = sum(BinarySequence.*(2.^HWChannels));
            
            V.create_waveform_binary('NV_PSeq_A',WaveA);
            V.OPCCheck();
            
            V.setSourceWaveForm(1,'NV_PSeq_A');
            
            % Make a Sequence
            V.initialize_sequence(1);
            
            waveforms{1} = 'NV_PSeq_A';
            
            V.initialize_sequence(1);
            V.setSegment(1,waveforms,1,[],[],[]);
            
            % turn the channels on
            % turn on the output to channel 1
            V.setSourceOutput(1,1);
            %V.setSourceOutput(2,1);
            
            V.sendstr('SEQuence:ELEMent1:LOOP:INF 1');
            
        end % setLines
        
    end %methods
    
    methods (Static),
        
        function [WaveA] = CreateSequenceShape(BinarySequence,HWChannels)
            
            % change HW channels to binary representation
            chnbin =2.^HWChannels;
            
            % repeat the matrix and do elementwise multiplication
            % then do row sum
            WaveA = sum(BinarySequence.*repmat(chnbin,1,size(BinarySequence,2)),1);
            
            % for safety always set the sequence to low after running
            WaveA(end+1) = 0;
            
            
        end
        
        function [WaveA, WaveB] = CreateShapes(RawSequence)
            
            % for safety always set the sequence to low after running
            RawSequence(:,end+1) = 0;
            Sz = size(RawSequence,1);
            if Sz == 1,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = zeros(1,size(RawSequence,2));
                WaveA.Marker2 = zeros(1,size(RawSequence,2));
                WaveB = [];
            elseif Sz == 2,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = zeros(1,size(RawSequence,2));
                WaveB = [];
                
            elseif Sz == 3,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = RawSequence(3,:);
                WaveB = [];
            elseif Sz == 4,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = RawSequence(3,:);
                WaveB.Shape = RawSequence(4,:);
                WaveB.Marker1 = zeros(1,size(RawSequence,2));
                WaveB.Marker2 = zeros(1,size(RawSequence,2));
            elseif Sz == 5,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = RawSequence(3,:);
                WaveB.Shape = RawSequence(4,:);
                WaveB.Marker1 = RawSequence(5,:);
                WaveB.Marker2 = zeros(1,size(RawSequence,2));
            elseif Sz == 6,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = RawSequence(3,:);
                WaveB.Shape = RawSequence(4,:);
                WaveB.Marker1 = RawSequence(5,:);
                WaveB.Marker2 = RawSequence(6,:);
            else
                WaveA = [];
                WaveB = [];
            end
        end
        
    end %methods Static
end %classdef