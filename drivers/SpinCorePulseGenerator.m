classdef SpinCorePulseGenerator < PulseGenerator

    properties
       LONG_DELAY_TIMESTEP = 500e-9; 
       DEBUG_MODE = 0;
    end
    methods
        function [obj] = setClockRate(obj,ClockRate)
            obj.ClockRate = ClockRate;
        end
        
        function [obj] = Initialize(obj,LibraryFile,HeaderFile,HeaderFile2,LibraryName)
        
            obj.hwHandle = SpinCorePulseBlaster(LibraryFile,HeaderFile,HeaderFile2,LibraryName);
            obj.hwHandle.Initialize();
        end
        
        
        function [obj] = init(obj)
           
           % initiate the pulse blaster
           obj.hwHandle.PBClose();
           obj.hwHandle.PBInit();
           
           % set the clock rate
           obj.hwHandle.SetClock(obj.ClockRate);
           
           obj.hwHandle.PBStop();

        end
        
        function [obj] = sendSequence(obj,BinarySequence,HWChannels,NumberPoints,InfLoop)
            
            
           s ={};
           
           Instr = obj.ConvertToHex(BinarySequence);
           
           % start programming
           obj.hwHandle.StartProgramming();
          
           if ~InfLoop,
               s{end+1} = sprintf('0x0,100ns,LOOP,%d',NumberPoints);
               obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_LOOP,NumberPoints,100);
           end
           

    
            % process all the instructions
            for k=1:numel(Instr),

                Temp = Instr(k).Data; % int8
                HWChannels = int8(HWChannels); % convert from double to int8, 3 Dec. 2010,jhodges
                IntOrdered = Temp.*(2.^HWChannels);
                FlagInstr = sum(IntOrdered);

              %% send instruction of 40ns, all lines high


                if Instr(k).Length > 2^8,
                    % LONG_DELAY
                    % # of cycles per LONG_DELAY_TIMESTEP 
                    CyclesPerLD = round(obj.LONG_DELAY_TIMESTEP*obj.ClockRate);

                    % how many long delays do we need to make up the Instr.Length
                    LongDelayInt = floor(Instr(k).Length/CyclesPerLD);

                    % how much time is remaining?
                    ContinueCycles = Instr(k).Length - CyclesPerLD*LongDelayInt;

                    if (ContinueCycles < 5) && (ContinueCycles > 0), % 22 March 2011, jhodges, added Cycles>0
                        
                        % 22 March 2011, jhodges
                        % try to change the long delay int to accommodate
                        % Continues of < 5
                        LongDelayInt = LongDelayInt - 1; % take away one LongDelay Period
                        ContinueCyles = ContinueCycles + CyclesPerLD;
                        
                        %REMOVED 22-Mar-2011
                        %ContinueCycles = 0;
                        %disp('Dropped instruction because less than 5 clock cycles');
                    end

                    if LongDelayInt > 1,
                        obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_LONG_DELAY,LongDelayInt,obj.LONG_DELAY_TIMESTEP*1e9);
                         s{end+1} = sprintf('0x%s,%.1f ns,LONG_DELAY,%d',dec2hex(FlagInstr,6),obj.LONG_DELAY_TIMESTEP*1e9,LongDelayInt);
                    else,
                         obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,LongDelayInt*obj.LONG_DELAY_TIMESTEP*1e9);
                         s{end+1} = sprintf('0x%s,%.1f ns,CONTINUE,%d',dec2hex(FlagInstr,6),obj.LONG_DELAY_TIMESTEP*1e9,0);
                    end
                    
                    if ContinueCycles > 0,
                        obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,ContinueCycles/obj.ClockRate*1e9);
                        s{end+1} = sprintf('0x%s,%.1f ns,CONTINUE,0',dec2hex(FlagInstr,6),ContinueCycles/obj.ClockRate*1e9);
                    end

                elseif Instr(k).Length > 5 && Instr(k).Length <= 2^8,

                    LongDelayInt = 0;
                    ContinueCycles = Instr(k).Length;
                    s{end+1} = sprintf('0x%s,%.1f ns,CONTINUE,0',dec2hex(FlagInstr,6),ContinueCycles/obj.ClockRate*1e9);
                    obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,ContinueCycles/obj.ClockRate*1e9);
                elseif Instr(k).Length < 5,
                    LongDelayInt = 0;
                    ContinueCycles = Instr(k).Length;
                    MinimumInstrLength = 5;
                    s{end+1} = sprintf('0x%s,%.1f ns,CONTINUE,0',dec2hex(FlagInstr,6),MinimumInstrLength/obj.ClockRate*1e9);
                    obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,MinimumInstrLength/obj.ClockRate*1e9);
                end;

            end % end Instr loop
            
            % add a short 100ns delay to the end
            s{end+1} = '0x0,100 ns,CONTINUE,0';
            obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_CONTINUE,0,100);
            
            % TEST
            %s{end+1} = '0x0,500 ns,LONG_DELAY,40000';
            %obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_LONG_DELAY,4000,500.0);
            
            if InfLoop,
                obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_BRANCH,0,100);
                 s{end+1} = '0x0,100 ns,BRANCH,0';
            else
                obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_END_LOOP,0,100);
                s{end+1} = '0x0,100 ns,END_LOOP,0';
            end


            
            if obj.DEBUG_MODE > 0,
                for k=1:length(s),
                    disp(s{k});
                end
            end
            
            obj.hwHandle.StopProgramming();
            
        end % sendSequence
        
        function [obj] = setLines(obj,bHigh,controlLine)
            % setLines(bHigh,controlLine)
            %
            % bHigh = boolean value for line (0/1)
            % controlLine = line to set
            
            
            FlagInstr = bHigh*(2.^controlLine);
            
            obj.hwHandle.StartProgramming();
            
            % SET LINE FOR 500ns
            % instruction 0
            obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,500);
            % BRANCH FOR 500ns
            % instrunction 1
            obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_BRANCH,0,500);
            
            obj.hwHandle.StopProgramming();
        end
            
        function [obj] = start(obj)
           obj.hwHandle.PBStart();
        end
        
        function [obj] = stop(obj)
           obj.hwHandle.PBStop();
        end
        
        function [obj] = close(obj)
            obj.hwHandle.PBClose();
        end
    end
    methods (Static = true)
        function [Instructions] = ConvertToHex(BinarySequence)
            
           
            % Sum along the pulses to get the total
            % representation
            BS_Sum = sum(BinarySequence,1);         

            
            % Take the diff of the sum.  Where the sum changes, indicates a
            % change in the PB instruction
            BS_Diff = diff(BS_Sum);
            
            % If the values are not zero, then this gives the location of
            % the change
            InstructionPos = find(BS_Diff~=0);
            
            t = 0;
            Instructions = struct();
            for k=1:numel(InstructionPos),
                % added new statement control 22 Mar 2011
                if k == 1,
                    Instructions(k).Length = InstructionPos(k) - t - 1;
                else
                    Instructions(k).Length = InstructionPos(k) - t + 1;
                end

                Instructions(k).Data = BinarySequence(:,InstructionPos(k));
                t = InstructionPos(k);
            end
            Instructions(end+1).Length = length(BinarySequence) - t - 1;
            Instructions(end).Data = BinarySequence(:,end);
        end
            
    end
end

