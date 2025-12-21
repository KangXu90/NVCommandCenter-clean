classdef SpinCorePulseBlaster < handle

	properties
		LibraryFile % spinapi.dll file
		LibraryHeader % path to spinapi.h file
		LibraryName % alias of loaded library
        LibraryHeader2
    end	
	
    properties (Constant = true)
       INST_CONTINUE    = 0
       INST_STOP        = 1
       INST_LOOP        = 2
       INST_END_LOOP    = 3
       INST_JSR         = 4
       INST_RTS         = 5
       INST_BRANCH      = 6
       INST_LONG_DELAY  = 7
       INST_WAIT        = 8
       PULSE_PROGRAM    = 0
       
       %flag_option map. string-to-bits
        ALL_FLAGS_ON	= hex2dec('1FFFFF');
        ONE_PERIOD		= hex2dec('200000');
        TWO_PERIOD		= hex2dec('400000');
        THREE_PERIOD	= hex2dec('600000');
        FOUR_PERIOD		= hex2dec('800000');
        FIVE_PERIOD		= hex2dec('A00000');
        SIX_PERIOD      = hex2dec('C00000');
        ON				= hex2dec('E00000');
       
    end
    
    
    
	methods
		function [obj] = SpinCorePulseBlaster(LibraryFile,LibraryHeader,LibraryHeader2,LibraryName)
            obj.LibraryFile = LibraryFile;
            obj.LibraryHeader = LibraryHeader;
            obj.LibraryName = LibraryName;
            obj.LibraryHeader2 = LibraryHeader2;
        end
		
		function [obj] = Initialize(obj)
			if ~libisloaded(obj.LibraryName)
				loadlibrary(obj.LibraryFile,obj.LibraryHeader,'addheader',obj.LibraryHeader2,'alias',obj.LibraryName);
			end
        end
		
        function [obj] = PBInit(obj)
            [err] = calllib(obj.LibraryName,'pb_init');
            if err ~= 0,
                error('Error Loading PulseBlaster Board');
            end
        end
        
        function [obj] = PBClose(obj)
            [err] = calllib(obj.LibraryName,'pb_close');
        end
        
        function [obj] = SetClock(obj,ClockRate)

            % NOTE!!!
            % Spin Core sets the clock in units of MHz, but controlling
            % software gives the clock in Hz, so must convert
            ClockRate = double(ClockRate/1e6);
            calllib(obj.LibraryName,'pb_core_clock',ClockRate);
        end
        
		function [obj] = PBStart(obj)
			[err] = calllib(obj.LibraryName,'pb_start');
			%obj.CheckError();
		end
		
		function [obj] = PBStop(obj)
            [err] = calllib(obj.LibraryName,'pb_stop');
        end
		
        function [obj] = StartProgramming(obj)
            [err] = calllib(obj.LibraryName,'pb_start_programming',obj.PULSE_PROGRAM);
        end

        
        function [obj] = StopProgramming(obj)
            [err] = calllib(obj.LibraryName,'pb_stop_programming');
        end

        function [obj] = PBInstruction(varargin)
            if nargin == 5,
                obj = varargin{1};
                flags = varargin{2};
                inst = varargin{3};
                inst_data = varargin{4};
                length = varargin{5};
                flagopt = obj.ON;
            elseif nargin == 6,
                obj = varargin{1};
                flags = varargin{2};
                inst = varargin{3};
                inst_data = varargin{4};
                length = varargin{5};
                flagopt = varargin{6};
            end
            flags = int32(bitor(flags,flagopt));
            inst = int32(inst);
            inst_data = int32(inst_data);
            length = double(length);
           [err] = calllib(obj.LibraryName,'pb_inst_pbonly',flags,inst,inst_data,length);
           if err < 0,
               warning('Spin Core Pulse Blaster Error: Code %d',err);
           end
        end
        
		
		function [obj] = Reset(obj)
		end
		
		function [obj] = Abort(obj)
		end
		
		function [obj] = ErrorCheck()
        end
		
        function delete(obj)
            obj.PBClose();
        end
	end

end