% =========================================================================
% Copyright (C) 2016-2021 Tabor-Electronics Ltd <http://www.taborelec.com/>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>. 
% =========================================================================
% Author: Nadav Manos, Fractions by Joan Mercade
% Date: May 17, 2021
% Version: 2.0.1


classdef TEProteusInst < SignalGeneratorTabor
    % TEProteusInst: NI-VISA based connection to Proteus Instrument.
    
   
    properties
        ParanoiaLevel = 1; % Paranoia level (0:low, 1:normal, 2:high)        
    end
    
    properties (SetAccess=private)
        ConnStr = ''; % The Connection-String        
        ViSessn = 0;  % VISA Session
        
        ModelName = '';    % The Instrument Model Name
        SerialNum = '';    % The Instrument Serial Number
        
        % Number of channels 
        NumChannels = 4;
        
        % Number of parts
        NumParts = 2;
        
        % Number of channels per part
        ChanPerPart = 2;
        
        % Arbitrary-Memory Size (wave-points per channel)
        ArbMemSize = 32000000; 
        
        % Is Digital-Wave supported?
        DigitalSupport = true; 
        
        % Minimal Segment Length (# wave-points)
        MinSegLen = 64;
        
        % Segment Quantum (# wave-points)
        Granularity = 64; 
        
        % Minimal wave-point (DAC) value 
        MinWavVal = 0;
        
        % Maximal wave-point (DAC) value 
        MaxWavVal = 2^(16) - 1;
        
        % Maximal number of segments
        MaxNumSegs = 32000;
        
        % Minimal sampling-rate (samples/sec)
        MinSclk = 1000e6; % 1 GHz
        
        % Maximal sampling-rate (samples/sec)
        MaxSclk = 9000e6; % 9 GHz
    end
    
    properties (Constant=true)
        VISA_IN_BUFF_SIZE = 819200;   % VISA Input-Buffer Size (bytes)
        VISA_IN_BUFF_SIZE_LONG = 8192000;   % VISA Input-Buffer Size for Long Transfers (bytes)
        VISA_OUT_BUFF_SIZE = 819200;  % VISA Output-Buffer Size (bytes)
        VISA_OUT_BUFF_SIZE_LONG = 8192000;  % VISA Output-Buffer Size for Long Transfers (bytes)
        VISA_TIMEOUT_SECONDS = 10;  % VISA Timeout (seconds)
        BINARY_CHUNK_SIZE = 409600;   % Binary-Data Write Chunk Size (samples)
        WAIT_PAUSE_SEC = 0.02;      % Waiting pause (seconds)
    end
    
    methods % public
        
        function obj = TEProteusInst(connStr, paranoiaLevel)
            % TEProteusInst - Handle Class Constructor
            %
            % Synopsis
            %   obj = TEProteusInst(connStr, [verifyLevel])
            %
            % Description
            %   This is the constructor of the VisaConn (handle) class.
            %
            % Inputs ([]s are optional)
            %   (string) connStr      connection string: either a full  
            %                         VISA resource name, or an IP-Address.
            %   (int) [paranoiaLevel = 1] paranoia level [0,1 or 2].
            % 
            % Outputs
            %   (class) obj      VisaConn class (handle) object.
            %
            
            assert(nargin == 1 || nargin == 2);
            
            ipv4 = '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$';
            if 1 == regexp(connStr, ipv4)
                connStr = sprintf('TCPIP0::%s::5025::SOCKET', connStr);
            end
            
            if nargin == 2
                %verifyLevel = varargin(1);
                if paranoiaLevel < 1
                    obj.ParanoiaLevel = 0;
                elseif paranoiaLevel > 2
                    obj.ParanoiaLevel = 2;
                else
                    obj.ParanoiaLevel = fix(paranoiaLevel);
                end
            else
                obj.ParanoiaLevel = 1;
            end
            
            obj.ConnStr = connStr;
            % Select the right one for the active VISA Library
            obj.ViSessn = visa('NI', connStr);
            %obj.ViSessn = visa('keysight', connStr);
            %obj.ViSessn = visa('tek', connStr);
            
            set(obj.ViSessn, 'OutputBufferSize', obj.VISA_OUT_BUFF_SIZE);
            set(obj.ViSessn, 'InputBufferSize', obj.VISA_IN_BUFF_SIZE);
            obj.ViSessn.Timeout = obj.VISA_TIMEOUT_SECONDS;
            %obj.ViSessn.Terminator = newline;
           
        end
        
        function delete(obj)
            % delete - Handle Class Destructor
            %
            % Synopsis
            %   obj.delete()
            %
            % Description
            %   This is the destructor of the VisaConn (handle) class.
            %   (to be called on a VisaConn class object).
            %
                      
            obj.Disconnect();
            delete(obj.ViSessn);
            obj.ViSessn = 0;
        end
        
        function ok = Connect(obj)
            % Connect - open connection to remote instrument.
            %
            % Synopsis
            %    ok = obj.Connect()
            %
            % Description
            %    Open connection to the remote instrument
            %
            % Outputs
            %    (boolean) ok   true if succeeded; otherwise false.
            %
                        
            ok = false;
            try
                if strcmp(obj.ViSessn.Status, 'open')
                    ok = true;
                else
                    fopen(obj.ViSessn);
                    pause(obj.WAIT_PAUSE_SEC);
                    ok = strcmp(obj.ViSessn.Status, 'open');                    
                end                
            catch ex
                msgString = getReport(ex);
                warning('fopen failed:\n%s',msgString);
            end
        end
		
		function Disconnect(obj)
            % Disconnect - close connection to remote instrument.
            %
            % Synopsis
            %   obj.Disconnect()
            %
            % Description
            %    Close connection to remote-instrument (if open).
            
            if strcmp(obj.ViSessn.Status, 'open')
                stopasync(obj.ViSessn);
                flushinput(obj.ViSessn);
                flushoutput(obj.ViSessn);
                fclose(obj.ViSessn);
            end
        end
        
        function selectChannel(obj)
            obj.SendCmd(sprintf(':INST:CHAN %d', obj.Channel));
        end

        function  setFrequencyandPhase(obj)
            obj.SendCmd(sprintf(':NCO:CFR1 %d', obj.Frequency1));
            obj.SendCmd(sprintf(':NCO:CFR2 %d', obj.Frequency2));
            obj.SendCmd(sprintf(':NCO:PHAS1 %d', obj.Phase1));
            obj.SendCmd(sprintf(':NCO:PHAS2 %d', obj.Phase2));
        end

        function  setApply6dB(obj)
            if obj.Apply6dB1
                obj.SendCmd(':NCO:SIXD1 ON');
            else
                obj.SendCmd(':NCO:SIXD1 OFF');
            end
            if obj.Apply6dB2
                obj.SendCmd(':NCO:SIXD2 ON');
            else
                obj.SendCmd(':NCO:SIXD2 OFF');
            end
        end
        
        function setNCOmode(obj)
            obj.SendCmd(sprintf([':NCO:MODE ',obj.NCOmode]));
        end
        
        function setDACmode(obj)
            obj.SendCmd(sprintf([':MODE ', obj.DACmode]));
        end
        
        function setInterpolation(obj) %current not works good
            obj.SendCmd(sprintf(':INST:CHAN %d', obj.Channel));
            obj.SendCmd(sprintf([':SOUR:INT ', obj.Interpolation]));
        end
        
        function setSamplingRate(obj)
            obj.SendCmd(sprintf([':FREQ:RAST ',num2str(obj.SamplingRate)]));
        end
        
        function  setAmplitude(obj,channnel)
            obj.SendCmd(sprintf([':SOUR:VOLT ', num2str(obj.Amplitude)]));
        end
        
        function  setRFOn(obj)
            obj.SendCmd(':OUTP ON');
        end
        
        function  setRFOff(obj)
            obj.SendCmd(':OUTP OFF');
        end
        %%% get functions


        function  [obj] = getFrequencyandPhase(obj)
            obj.Frequency1 = obj.SendQuery(':NCO:CFR1 ?');
            obj.Frequency2 = obj.SendQuery(':NCO:CFR2 ?');
            obj.Phase1 = obj.SendQuery(':NCO:PHAS1 ?');
            obj.Phase2 = obj.SendQuery(':NCO:PHAS2 ?');
        end

        function  [obj] = getApply6dB(obj)
            obj.Apply6dB1 = isequal(obj.SendQuery(':NCO:SIXD1 ?'),'ON');
            obj.Apply6dB2 = isequal(obj.SendQuery(':NCO:SIXD2 ?'),'ON');
        end
        
        function [obj] = getNCOmode(obj)
            obj.NCOmode = obj.SendQuery(':NCO:MODE ?');
        end
        
        function [obj] = getDACmode(obj)
            obj.DACmode = obj.SendQuery(':MODE ?');
        end
        
        function [obj] = getInterpolation(obj)
            obj.Interpolation = obj.SendQuery(':SOUR:INT ?');
        end
        
        function [obj] = getSamplingRate(obj)
            obj.SamplingRate = obj.SendQuery(':FREQ:RAST ?');
        end
        
        function  [obj] = getAmplitude(obj)
            obj.Amplitude = obj.SendQuery(':SOUR:VOLT ?');
        end

        function  getRFState(obj)
            obj.RFState = isequal(obj.SendQuery(':OUTP ?'),'ON');
        end
 function [obj] = queryState(obj)
     
            [s] = obj.SendQuery(':INST:CHAN ?');
            Query{1} = sprintf('ACTIVE CHANNEL = \t\t%s',s);
            
            [s] = obj.SendQuery(':NCO:CFR1 ?');
            Query{2} = sprintf('FREQUENCY1 = \t\t%s HZ',s);
            [s] = obj.SendQuery(':NCO:PHAS1 ?');
            Query{3} = sprintf('PHASE1 = \t\t%s ',s);
            
            [s] = obj.SendQuery(':NCO:CFR2 ?');
            Query{4} = sprintf('FREQUENCY2 = \t\t%s HZ',s);
            [s] = obj.SendQuery(':NCO:PHAS2 ?');
            Query{5} = sprintf('PHASE2 = \t\t%s ',s);           
            
            [s] = obj.SendQuery(':NCO:MODE ?');
            Query{6} = sprintf('NCOmode = \t\t%s',s);
            [s] = obj.SendQuery(':MODE ?');
            Query{7} = sprintf('DACmode= \t\t%s ',s);
            [s] = obj.SendQuery(':SOUR:INT ?');
            Query{8} = sprintf('Interpolation = \t\t%s',s);
            [s] = obj.SendQuery(':FREQ:RAST ?');
            Query{9} = sprintf('SamplingRate= \t\t%s /s',s);
            [s] = obj.SendQuery(':SOUR:VOLT ?');
            Query{10} = sprintf('Amplitude = \t\t%s V',s);
            [s] = obj.SendQuery(':OUTP ?');
            Query{11} = sprintf('OUTP= \t\t%s',s);         
            [errNb, errDesc] = QuerySysErr(obj);
            Query{12} =  [num2str(errNb), errDesc];
            obj.QueryString = Query;
        end
        function [errNb, errDesc] = QuerySysErr(obj, bSendCls)
            % QuerySysErr - Query System Error from the remote instrument
            %
            % Synopsis
            %   [errNb, [errDesc]] = obj.QuerySysErr([bSendCls])
            %
            % Description
            %   Query the last system error from the remote instrument,
            %   And optionally clear the instrument's errors list.
            %
            % Inputs ([]s are optional)
            %   (bool) [bSendCls = false]  
            %           should clear the instrument's errors-list?
            %
            % Outputs ([]s are optional)
            %   (scalar) errNb     error number (zero for no error).
            %   (string) [errDesc] error description.
            
            if ~exist('bSendCls', 'var')
                bSendCls = false;
            end
            
            obj.waitTransferComplete();
            [answer, count, errmsg] = query(obj.ViSessn, 'SYST:ERR?');
            obj.waitTransferComplete();
                        
            if ~isempty(errmsg)
                error('getError() failed: %s', errmsg);
            end
            
            sep = find(answer == ',');
            if (isempty(sep) || count <= 0 || answer(count) ~= char(10))
                warning('querySysErr() received invalid answer: "%s"', answer);
                flushinput(obj.ViSessn);
            end
            
            if ~isempty(sep) && isempty(errmsg)
                errNb = str2double(answer(1:sep(1) - 1));
                errmsg = answer(sep(1):end);
                if 0 ~= errNb && nargin > 1 && bSendCls
                    query(obj.ViSessn, '*CLS; *OPC?');
                end
            else
                errNb =  -1;
                if isempty(errmsg)
                    errmsg = answer;
                end               
            end
            
            if nargout > 1
                errDesc = errmsg;
            end
        end       
        
        
        function SendCmd(obj, cmdFmt, varargin)
            % SendCmd - Send SCPI Command to instrument
            %
            % Synopsis
            %   obj.SendCmd(cmdFmt, ...)
            %
            % Description
            %   Send SCPI Command to the remote instrument.
            %
            % Inputs ([]s are optional)
            %   (string) cmdFmt      command string-format (a la printf).
            %            varargin    arguments for cmdFmt
            obj.waitTransferComplete();
            
            if nargin > 2
                cmdFmt = sprintf(cmdFmt, varargin{1:end});                
            end
            
            resp = '';
            errMsg = '';
            respLen = 0;
            
            if obj.ParanoiaLevel == 0
                fprintf(obj.ViSessn, cmdFmt);
                obj.waitTransferComplete();
            elseif obj.ParanoiaLevel == 1
                cmdFmt = strcat(cmdFmt, ';*OPC?');
                [resp, respLen, errMsg] = query(obj.ViSessn, cmdFmt);
            elseif obj.ParanoiaLevel >= 2
                cmdFmt = strcat(cmdFmt, ';:SYST:ERR?');
                [resp, respLen, errMsg] = query(obj.ViSessn, cmdFmt);
            end
            
            if (obj.ParanoiaLevel > 0 && ~isempty(errMsg))
                error('query(''%s\'') failed\n %s', cmdFmt, errMsg);
            elseif (obj.ParanoiaLevel >= 2 && respLen > 0)
                resp = deblank(resp);
                sep = find(resp == ',');
                if ~isempty(sep)
                    errNb = str2double(resp(1:sep(1) - 1));
                    if 0 ~= errNb
                        query(obj.ViSessn, '*CLS; *OPC?');
                        warning('System Error #%d after ''%s'' (%s).', ...
                            errNb, cmdFmt, resp);
                    end
                end
            end
        end
        
        function resp = SendQuery(obj, qformat, varargin)
            % SendQuery - Send SCPI Query to instrument
            %
            % Synopsis
            %   resp = obj.SendQuery(qformat, ...)
            %
            % Description
            %   Send SCPI Query to the remote instrument,
            %   And return the instrument's response (string).
            %
            % Inputs ([]s are optional)
            %   (string) qformat     query string-format (a la printf).
            %            varargin    arguments for qformat
            %
            % Outputs ([]s are optional)
            %   (string) resp     the instrument's response.
            
            obj.waitTransferComplete();
            if nargin == 2
                [resp, respLen, errMsg] = query(obj.ViSessn, qformat);
            elseif nargin > 2
                qformat = sprintf(qformat, varargin{1:end});
                [resp, respLen, errMsg] = query(obj.ViSessn, qformat);
            else
                resp = '';
                errMsg = '';
                respLen = 0;
            end
            
            if ~isempty(errMsg)
                error('query(''%s\'') failed\n %s', qformat, errMsg);
            end
            
            if respLen > 0
                % remove trailing blanks
                resp = deblank(resp);
            end
        end
        
        function SendBinaryData(obj, pref, datArray, elemType)            
            % SendBinaryData - Send binary data to instrument
            %
            % Synopsis
            %   obj.SendBinaryData(pref, datArray, elemType)
            %
            % Description
            %   Send array of basic-type elements to the remote instrument
            %   as binary-data with binary-data header and (optional) SCPI
            %   statement prefix (e.g. ":TRAC:DATA").
            %
            % Inputs ([]s are optional)
            %   (string) pref      SCPI statement (e.g. ":TRAC:DATA")
            %                      sent before the binary-data header.
            %   (array)  datArray  array of fixed-size elements.
            %   (string) elemType  element type name (e.g. 'uint8')
            
            obj.waitTransferComplete();
            
            
                        
            if ~exist('pref', 'var')
                pref = '';
            end            
            if ~exist('datArray', 'var')
                datArray = [];
            end            
            if ~exist('elemType', 'var')
                elemType = 'uint8';
                datArray = typecast(datArray, 'uint8');
            end 
            
            numItems = length(datArray);  
            switch elemType
                case { 'int8', 'uint8' 'char' }
                    itemSz = 1;
                case { 'int16', 'uint16' }
                    itemSz = 2;
                case { 'int32', 'uint32', 'single' }
                    itemSz = 4;
                case { 'int64', 'uint64', 'double' }
                    itemSz = 8;
                otherwise
                    error('unsopported element-type ''%s''', elemType);
            end
            
            assert(itemSz >= 1 && itemSz <= obj.BINARY_CHUNK_SIZE);
            
            getChunk = @(offs, len) datArray(offs + 1 : offs + len);
            
            % make binary-data header
            szStr = sprintf('%lu', numItems * itemSz);
            pref = sprintf('*OPC?;%s#%u%s', pref, length(szStr), szStr);
            % send it (without terminating new-line!):            
            fwrite(obj.ViSessn, pref, 'char');
            obj.waitTransferComplete();
            
            % send the binary-data (in chunks):            
            offset = 0;
            chunkLen = fix(obj.BINARY_CHUNK_SIZE / itemSz);
            while offset < numItems
                if offset + chunkLen > numItems
                    chunkLen = numItems - offset;
                end
                dat = getChunk(offset, chunkLen);
                fwrite(obj.ViSessn, dat, elemType);
                obj.waitTransferComplete();                
                offset = offset + chunkLen;
            end
            
            % read back the response to that *OPC? query:
            q = fscanf(obj.ViSessn, '%s');
            %fgets(obj.ViSessn, 2);
            
            if obj.ParanoiaLevel >= 2
                [errNb, errDesc] = obj.QuerySysErr(1);
                if 0 ~= errNb
                    warning('System Error #%d (%s) after sending ''%s ..''.', errNb, errDesc, pref);
                end
            end
        end
        
        function datArray = ReadBinaryData(obj, pref, elemType)            
            % ReadBinaryData - Read binary data from instrument
            %
            % Synopsis
            %   datArray = obj.ReadBinaryData(pref, elemType)
            %
            % Description
            %   Read array of basic-type elements from the instrument.
            %
            % Inputs ([]s are optional)
            %   (string) pref      SCPI statement (e.g. ":TRAC:DATA")
            %                      sent before the binary-data header.
            %   (string) elemType  element type name (e.g. 'uint8')
            %
            % Outputs ([]s are optional)
            %   (array)  datArray  array of fixed-size elements.
            
            obj.waitTransferComplete();
            
            set(obj.ViSessn, 'InputBufferSize', obj.VISA_IN_BUFF_SIZE_LONG);
            
            if ~exist('pref', 'var')
                pref = '';
            end            
            
            switch elemType
                case { 'int8', 'uint8' 'char' }
                    itemSz = 1;
                case { 'int16', 'uint16' }
                    itemSz = 2;
                case { 'int32', 'uint32', 'single' }
                    itemSz = 4;
                case { 'int64', 'uint64', 'double' }
                    itemSz = 8;
                otherwise
                    error('unsopported element-type ''%s''', elemType);
            end
            
            assert(itemSz >= 1 && itemSz <= obj.BINARY_CHUNK_SIZE);            
            
            % Send the prefix (if it is not empty)
            if ~isempty(pref)
                fprintf(obj.ViSessn, pref);
            end
            obj.waitTransferComplete();
            
            % Read binary header
            while true
                ch = fread(obj.ViSessn, 1, 'char');
                if ch == '#'
                    break
                end
            end
            
            % Read the first digit
            ch = fread(obj.ViSessn, 1, 'char');
            assert ('0' < ch && ch <= '9');
            
            ndigits = ch - '0';
            %fprintf('ReadBinaryData: ndigits = %d\n', ndigits);
            
            sizestr = fread(obj.ViSessn, ndigits, 'char');
            numbytes = 0;
            for n = 1:ndigits
                ch = sizestr(n, 1);
                numbytes = numbytes * 10 + (ch - '0');
            end
            
            %fprintf('ReadBinaryData: numbytes = %d\n', numbytes);
            
            datLen = ceil(numbytes / itemSz);
            assert(datLen * itemSz == numbytes);
            datArray = zeros(1, datLen, elemType);
            
            chunkLen = fix(obj.BINARY_CHUNK_SIZE / itemSz);
            
            %fprintf('ReadBinaryData: datLen=%d, chunkLen=%d\n', datLen, chunkLen);
            
            % send the binary-data (in chunks):            
            offset = 0;
            
            while offset < datLen
                if datLen - offset < chunkLen
                    chunkLen = datLen - offset;
                end
                datArray(offset + 1 : offset + chunkLen) = ...
                    fread(obj.ViSessn, chunkLen, elemType);
                %obj.waitTransferComplete();                
                offset = offset + chunkLen;
            end
            
            % read the terminating newline character
            ch = fread(obj.ViSessn, 1, 'char');
            assert(ch == newline);
            
            set(obj.ViSessn, 'InputBufferSize', obj.VISA_IN_BUFF_SIZE);
        end    
        
        function model = identifyModel(obj)
            idnStr = obj.SendQuery('*IDN?');    
            idnStr = split(idnStr, ',');    

            if length(idnStr) > 1
                model = idnStr(2);
            else
                model ='';
            end

            model = char(model);
            obj.ModelName = model;
        end

        function options = getOptions(obj)
            optStr = obj.SendQuery('*OPT?');    
            options = split(optStr, ',');    
        end

        function maxSr = getMaxSamplingRate2(obj, model)

            maxSr = 9.0E+9;

            if contains(model, 'P258')
                maxSr = 2.5E+9;
            elseif contains(model, 'P128')
                maxSr = 1.25E+9;
            end
        end
        
        function maxSr = getMaxSamplingRate(obj)
            maxSr = obj.SendQuery(':FREQ:RAST MAX?');    
            maxSr = str2double(maxSr);
        end

        function minSr = getMinSamplingRate2(obj, model)

            minSr = 1.0E+9;    
        end
        
        function minSr = getMinSamplingRate(obj)
            minSr = obj.SendQuery(':FREQ:RAST MIN?');    
            minSr = str2double(minSr);
        end

        function granularity = getGranularity(obj, model, options)

            flagLowGranularity = false;

            for i = 1:length(options)
                if contains(options(i), 'LWG')
                    flagLowGranularity = true;
                end        
            end
            
            sR = obj.SendQuery(':FREQ:RAST?');    
            sR = str2double(sR);
            % For P9082 and P9484 granularity is 64 for SR > 2.5E9
            granularity = 64;    
            if flagLowGranularity && sR<=2.5E9
                granularity = 32;
            end        

            if contains(model, 'P258')
                granularity = 32;    
                if flagLowGranularity
                    granularity = 16;
                end
            elseif contains(model, 'P128')
                granularity = 32;    
                if flagLowGranularity
                    granularity = 16;
                end
            end
        end

        function numOfChannels = getNumOfChannels(obj, model)

            numOfChannels = 4;

            if contains(model, 'P9082')
                numOfChannels = 2;
            elseif contains(model, 'P9482')
                numOfChannels = 2;
            elseif contains(model, 'P1282')
                numOfChannels = 2;
            elseif contains(model, 'P2582')
                numOfChannels = 2;
           elseif contains(model, 'P2584')
                numOfChannels = 4;
            elseif contains(model, 'P2588')
                numOfChannels = 8;
            elseif contains(model, 'P25812')
                numOfChannels = 12;
            end
        end
        
        function dacRes = getDacResolution2(obj, model)

            dacRes = 16;

            if contains(model, 'P908')
                dacRes = 8;            
            end
        end
        
        function dacRes = getDacResolution(obj)           
            
            dacRes = obj.SendQuery(':TRAC:FORM?');
            
            if contains(dacRes, 'U8')
                dacRes = 8;
            else
                dacRes = 16;
            end
        end

        function retval = Quantization (obj, myArray, dacRes)

            minLevel = 1;
            maxLevel = 2 ^ dacRes - 1;
            numOfLevels = maxLevel - minLevel + 1;

            retval = round((numOfLevels .* (myArray + 1) - 1) ./ 2);
            retval = retval + minLevel;

            retval(retval > maxLevel) = maxLevel;
            retval(retval < minLevel) = minLevel;

        end


        function [normI,  normQ] = NormalIq(obj,wfmI, wfmQ)
            maxPwr = double(max(wfmI.*wfmI + wfmQ .* wfmQ));
            maxPwr = maxPwr ^ 0.5;
            normI = double(wfmI / maxPwr);
            normQ = double(wfmQ / maxPwr);
        end

        function outWfm = Interleave(obj,wfmI, wfmQ)

            wfmLength = length(wfmI);
            if length(wfmQ) < wfmLength
                wfmLength =  length(wfmQ);
            end

            %wfmLength = 2 * wfmLength;
            outWfm = zeros(1, 2 * wfmLength);

            outWfm(1:2:(2 * wfmLength - 1)) = wfmI;
            outWfm(2:2:(2 * wfmLength)) = wfmQ;
        end

        function result = SendWfmToProteus( instHandle,...
                channel,...
                segment,...
                myWfm,...
                dacRes)

            %Select Channel
            instHandle.SendCmd(sprintf(':INST:CHAN %d', channel));
            instHandle.SendCmd(sprintf(':TRAC:DEF %d, %d', segment, length(myWfm)));
            % select segmen as the the programmable segment
            instHandle.SendCmd(sprintf(':TRAC:SEL %d', segment));


            % format Wfm
            myWfm = instHandle.Quantization(myWfm, dacRes);
            % Download the binary data to segment
            %             prefix = ':TRAC:DATA 0,';
            prefix = sprintf(':TRAC:DATA 0,');

            if dacRes == 16
                instHandle.SendBinaryData(prefix, myWfm, 'uint16');
            else
                instHandle.SendBinaryData(prefix, myWfm, 'uint8');
            end

            result = length(myWfm);
        end

        function result = SendMkrToProteus(instHandle, myMkr)
            % Download the binary data to segment
            prefix = ':MARK:DATA 0,';
            instHandle.SendBinaryData(prefix, myMkr);
            % instHandle.SendBinaryData(prefix, myMkr, 'uint8'); % alternative form
            result = length(myMkr);
        end

        function mkrData = FormatMkr2(instHandle, dac_Mode, mkr1, mkr2)
            % Mkr1 goes to bit 0 and Mkr2 goes to bit 1 in a 4-bit Nibble
            mkrData = mkr1 + 2 * mkr2;
            % For DAC Mode 8, just one Nibble per Byte is sent
            % For DAC Mode 16, two consecutive nibbles are multiplexed in one byte
            if dac_Mode == 16
                mkrData = mkrData(1:2:length(mkrData)) + ...
                    16 * mkrData(2:2:length(mkrData));
            end
        end

        function mkrData = FormatMkr4(dac_Mode, mkr1, mkr2, mkr3, mkr4)
            % Mkr1 goes to bit 0 and Mkr2 goes to bit 1 in a 4-bit Nibble
            mkrData = mkr1 + 2 * mkr2 + 4 * mkr3 + 8 * mkr4;
            % For DAC Mode 8, just one Nibble per Byte is sent
            % For DAC Mode 16, two consecutive nibbles are multiplexed in one byte
            if dac_Mode == 16
                mkrData = mkrData(1:2:length(mkrData)) + ...
                    16 * mkrData(2:2:length(mkrData));
            end
        end
        function myWfm = padWfmIQ(myWfm, granul_interleaved, min_baseband_pts)
            % myWfm: 已经 I/Q 交织的向量（长度 = 2 * baseband 点数）
            % granul_interleaved: 设备粒度（针对交织后的数组）
            % min_baseband_pts: 每个通道（I 或 Q）的最小点数

            curr_baseband_pts = numel(myWfm) / 2;
            % 粒度对交织数组生效 → 对 baseband 的粒度是 granul/2
            baseband_gran = max(1, granul_interleaved / 2);

            target_baseband_pts = max( ...
                ceil(curr_baseband_pts / baseband_gran) * baseband_gran, ...
                min_baseband_pts);

            target_interleaved_pts = 2 * target_baseband_pts;

            if target_interleaved_pts > numel(myWfm)
                myWfm(end+1 : target_interleaved_pts) = 0;
            end
        end

        
    end % public methods

    methods (Access = private) % private methods

        function waitTransferComplete(obj)
            % waitTransferComplete - wait till transfer status is 'idle'
            while ~strcmp(obj.ViSessn.TransferStatus,'idle')
                pause(obj.WAIT_PAUSE_SEC);
            end
        end
        
        function readDeviceOpts(obj)
            % read the device options

            idn = obj.SendQuery('*IDN?');
            idn = strsplit(idn, ',');
            opt = obj.SendQuery('*OPT?');

            obj.ModelName = idn{2};
            obj.SerialNum = idn{3};

            if (strcmp(obj.ModelName, 'SE5082')),
                obj.MinSclk = 100e6;
                obj.MaxSclk = 5000e6;
                memOpt = opt(2:3);
                obj.ArbMemSize = str2double(memOpt) * 1E6;
                obj.DigitalSupport = any(regexp(opt,'D$'));
            else
                error('Model %s is not yet supported', obj.ModelName);
            end

        end
    end % private methods
    
end

