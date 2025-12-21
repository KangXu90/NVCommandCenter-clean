classdef TekAWGController < handle
%
% Class for controlling Tektronix AWG5000 series using GPIB or TCPIP
% Sockets
%
% Written By Colm Ryan, University of Waterloo, Dec 2008
%
% Ever so slightly modified by Jonathan Hodges, jonathan.hodges@gmail.com,  MIT/Harvard, 30 July 2009
%
% 

    
    properties
        
         Protocol      % GPIB, TCPIP, or serial
         SocketHandle  % handle associated with Protocol class
         GPIBCOM       % Serial port associated with GPIB USB adapter
         GPIBnum       % GPIB Channel
         GPIBbus       % GPIB bus
         GPIBdriver    % GPIB driver
         IPAddress     % Device IP Address for TCP/IP control
         TCPPort       % Port for TCP/IP control
         
        %Maximum number of samples per channel
        maxsamples = 16e6;
        
        %Maximum number of segments in sequence mode
        maxsegments = 8e3;
        
        %Maximum number of waveforms
        maxwaveforms = 32e3;
        
        %Minimum seqment length for hardware sequencer
        minsegment_length = 250;
        
        
        
    end  %Properties section
    
    methods
        
        %Constructor function 
        function obj = TekAWGController(varargin)
            obj.Protocol = varargin{1};
            switch obj.Protocol,
                case 'serial'
                    obj.GPIBCOM = varargin{2};
                    obj.SocketHandle = serial(obj.GPIBCOM);
                    obj.SocketHandle.Terminator = 'CR/LF';
                case 'gpib',
                    obj.GPIBdriver = varargin{2};
                    obj.GPIBbus = varargin{3};
                    obj.GPIBnum = varargin{4};
                    
                    % create gpib object
                    obj.SocketHandle = gpib(obj.GPIBdriver,obj.GPIBbus,obj.GPIBnum);
                case 'tcpip',
                    obj.IPAddress = varargin{2};
                    obj.TCPPort = varargin{3};

                    % see if there is already a tcpip object for this
                    % addr:port, and if so, just clone the handle
                    a = instrfind('RemoteHost',obj.IPAddress,'RemotePort',obj.TCPPort);
                    if ~isempty(a),
                        obj.SocketHandle = a(end);
                    else
                        obj.SocketHandle = tcpip(obj.IPAddress,obj.TCPPort);
                    end

                otherwise,
                    error('Only protocols `tcpip` and `gpib` are supported');
            end
            
            set(obj.SocketHandle,'Timeout',60);
            set(obj.SocketHandle,'InputBufferSize',1000);
            set(obj.SocketHandle,'OutputBufferSize',2*obj.maxsamples+1000);
        end
        
        function initialize(obj)

        end
        
        %Destructor function
        function delete(obj)
            %Close the object
            obj.close();
            %Clean up the instrument object
            
            %% 3 dec 2009,  don't delete this now
            %delete(obj.SocketHandle);
        end

    
        %Open function
        function open(awg_obj)
            % only open if it's not open
            if ~strcmp(get(awg_obj.SocketHandle,'Status'),'open'),
                fopen(awg_obj.SocketHandle);
            end
        end
        
        %Close function
        function close(awg_obj)
            fclose(awg_obj.SocketHandle);
        end
        
        %Function to send string through
        function sendstr(awg_obj,str_in)
            
            % check to see if the socket is open
            if ~strcmp(get(awg_obj.SocketHandle,'Status'),'open'),
                fopen(awg_obj.SocketHandle);
            end
            fprintf(awg_obj.SocketHandle,str_in);
        end
        
        %Function to query
        function result = querystr(awg_obj,str_in)
            result = query(awg_obj.SocketHandle,str_in);
        end
        
        %Function to reset 
        function reset(awg_obj)
            awg_obj.sendstr('*RST');
        end
        
        %Function to start AWG
        function start(awg_obj)
            awg_obj.sendstr('AWGCONTROL:RUN');
        end
        
        %Function to stop AWG
        function stop(awg_obj)
            awg_obj.sendstr('AWGCONTROL:STOP');
        end
        
        %Function to load a waveform
        function create_waveform(awg_obj,name,shape,marker1,marker2)
                
                %Expects column vectors for shape,marker1,marker2
                %Delete the old wavefrom if it was there
                awg_obj.sendstr(sprintf('WLIST:WAVEFORM:DELETE "%s"',name));
                %Create the new waveform
                awg_obj.sendstr(sprintf('WLIST:WAVEFORM:NEW "%s", %d, INT',name,length(shape)));
                
                %Load the actual waveform                               
                binblockwrite(awg_obj.SocketHandle,awg_obj.shapeToAWGInt(shape,marker1,marker2),'uint16',sprintf('WLIST:WAVEFORM:DATA "%s", ',name));
                
                % need to send LF to finish bbw
                awg_obj.sendstr('');
        end
        
        function create_waveform_binary(awg_obj,name,binarysequence)
            
                binData = int16(binarysequence);
                
                % TEK AWG5014B requires the binary block data in little endian
                % (LSB first) byte ordering, but binblockwrite seems to ignore 
                % the byte ordering so manually swap it
                binData = swapbytes(binData);   
                
                %Expects column vectors for shape,marker1,marker2
                %Delete the old wavefrom if it was there
                awg_obj.sendstr(sprintf('WLIST:WAVEFORM:DELETE "%s"',name));
                %Create the new waveform
                awg_obj.sendstr(sprintf('WLIST:WAVEFORM:NEW "%s", %d, INT',name,length(binData)));
                
                %Load the actual waveform                               
                binblockwrite(awg_obj.SocketHandle,binData,'uint16',sprintf('WLIST:WAVEFORM:DATA "%s", ',name));
                
                % need to send LF to finish bbw
                awg_obj.sendstr('');
        end
            
        %Function to set marker voltages
        function setmarker(awg_obj,channelnum,markernum,low,high)
            awg_obj.sendstr(sprintf('SOURCE%d:MARKER%d:VOLTAGE:LOW %d;HIGH %d',channelnum,markernum,low,high));
        end
        
        
        %Function to force an event in software
        function forceEvent(awg_obj)
            awg_obj.sendstr('EVENT:IMMEDIATE');
        end
        
        %Function to send a software trigger
        function sendTrigger(awg_obj)
            awg_obj.sendstr('*TRG');
        end
        
        %Function to initialize a sequence
        function initialize_sequence(awg_obj,length)
            awg_obj.sendstr(sprintf('SEQUENCE:LENGTH %d;LENGTH %d',0,length));
        end
        
        %Function to set the parameters of a sequence segment
        function setSegment(awg_obj,segnum,waveforms,loops,jumpto,forceto,trig)
            %Set the waveforms
            for wavect = 1:1:length(waveforms)
                awg_obj.sendstr(sprintf('SEQUENCE:ELEMENT%d:WAVEFORM%d "%s"',segnum,wavect,waveforms{wavect}));
            end
            %Set the loops
            if(~isempty(loops))
                if(isinf(loops))
                    awg_obj.sendstr(sprintf('SEQUENCE:ELEMENT%d:LOOP:INF 1',segnum));
                else
                    awg_obj.sendstr(sprintf('SEQUENCE:ELEMENT%d:LOOP:COUNT %d',segnum,loops));
                end
            end
            %Set the jump to
            if(~isempty(jumpto))
                awg_obj.sendstr(sprintf('SEQUENCE:ELEMENT%d:GOTO:STATE %d',segnum,logical(jumpto)));
                awg_obj.sendstr(sprintf('SEQuence:ELEMent%d:GOTO:INDex %d',segnum,jumpto));
            end
            %Set the force event jump
            if(~isempty(forceto))
                awg_obj.sendstr(sprintf('SEQUENCE:ELEMENT%d:JTARGET:TYPE INDEX',segnum));
                awg_obj.sendstr(sprintf('SEQUENCE:ELEMENT%d:JTARGET:INDEX %d',segnum,forceto));
            end
            %Set the wait for trigger status
            if(~isempty(trig))
                awg_obj.sendstr(sprintf('SEQUENCE:ELEMENT%d:TWAIT %d',segnum,logical(trig)));
            end
        end
        
        function setSourceFrequency(awg_obj,freq)
            awg_obj.sendstr(sprintf('SOURCE1:FREQUENCY %g',freq));
        end
        
        function setSourceWaveForm(awg_obj,channel,WaveName)
            awg_obj.sendstr(sprintf('SOURCE%d:WAVEFORM "%s"',channel,WaveName));
        end
        
        function setSourceAmplitudeandOffset(awg_obj,channel,amplitude,offset)
            awg_obj.sendstr(sprintf('SOURCE%d:VOLTAGE:AMPLITUDE %d;:VOLTAGE:OFFSET %d',channel,amplitude,offset));
        end

        function setSourceOutput(awg_obj,channel,state)
            awg_obj.sendstr(sprintf('OUTPUT%d:STATE %d',channel,logical(state)));
        end
        
        function [status] = OPCCheck(awg_obj)
            %Wait until the previous operation is complete by waiting for
            %an OPC response
            status = awg_obj.querystr('*OPC?');
        end
            
        
        end %Methods section

        methods(Static)
        
        function binData = shapeToAWGInt(shape,marker1,marker2)
                
            %Check pulse-in to make sure it is between -1 and 1
%             if(max(abs(shape)) > 1)
%                 errordlg('Pulse is outside the range [-1, 1].');
%                 binData = 0;
%                 return;
%             end
%             
            % Convert decimal shape on [-1,1] to binary on [0,2^14 (16383)] 
            binData = shape;

            % Set markers - bits 14 and 15 of each point
            binData = bitset(binData,15,marker1);
            binData = bitset(binData,16,marker2);
            
            % TEK AWG5014B requires the binary block data in little endian
            % (LSB first) byte ordering, but binblockwrite seems to ignore 
            % the byte ordering so manually swap it
            binData = swapbytes(binData);            
            
        end            
        
        end %Static methods
end
