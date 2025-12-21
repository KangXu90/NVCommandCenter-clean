classdef PulseSequencebis < handle
    
    properties
        linenum
        byLine
        expparams
        channels
        numPoints
        ppLines
    end
    
    methods
        %Constructor
        function PSobj = PulseSequencebis(expparams)
            PSobj.expparams = expparams;
            %Add reference to channels
            PSobj.channels = expparams.channels;
            PSobj.clearAll();
            
        end
        
        %Function to clear everything and start again
        function clearAll(PSobj)
            PSobj.linenum = 0;
            PSobj.byLine = struct([]);
            PSobj.numPoints = 0;
            for chct = 1:length(PSobj.channels)
                PSobj.channels(chct).clearAWGData();
            end
        end
        
        %Function to clear the AWG data
        function clearAWGData(PSobj)
            for chct = 1:length(PSobj.channels)
                PSobj.channels(chct).clearAWGData();
            end
        end
           
        %Add a delay to a specific channel
        function addDelay(PSobj,delay,channel)
            
            %If we have the channel input then do that specific channel
            if(exist('channel','var'))
                %Add on the delay
                PSobj.byLine(PSobj.linenum).(channel) = [PSobj.byLine(PSobj.linenum).(channel); delay 0 0];
                %Other wise do all the channels
            else
                for chct = 1:length(PSobj.channels)
                    tmpLogicalName = PSobj.channels(chct).logicalName;
                    PSobj.byLine(PSobj.linenum).(tmpLogicalName) = [PSobj.byLine(PSobj.linenum).(tmpLogicalName); delay 0 0];
                end
            end
        end
        
        %Add a pulse to a channel
        function addPulse(PSobj,pulseLength,shapeNum,phase,channel)
            PSobj.byLine(PSobj.linenum).(channel) = [PSobj.byLine(PSobj.linenum).(channel); [pulseLength shapeNum phase]];
        end
        
        %Increment the line counter
        function nextLine(PSobj)
            %Create empty arrays for all the channels
            PSobj.linenum = PSobj.linenum + 1;
            for chct = 1:length(PSobj.channels)
                tmpLogicalName = PSobj.channels(chct).logicalName;
                PSobj.byLine(PSobj.linenum).(tmpLogicalName) = [];
            end
        end
        
        
        function parse(PSobj)
            
            %Clear everything
            PSobj.clearAll();
            
            %First we want to do load the file and load each line into a
            %cell array of strings
            ppFID = fopen(PSobj.expparams.ppFile,'r');
            pplines = textscan(ppFID,'%s','delimiter','\n'); pplines = pplines{1};
            fclose(ppFID);
            
            %Save the lines for future reference (saved experiment data)
            PSobj.ppLines = pplines;
            
            %Make an array of line numbers for error reporting
            linenums = (1:1:length(pplines))';
            
            %Use regexp to find the comments and replace them with empty strings
            pplines = regexprep(pplines,';.*','');
            
            %Remove leading and trailing whitespace (actually textscan has already
            %removed leading spaces)
            pplines = strtrim(pplines);
            
            %Remove empty lines
            emptylines = find(~cellfun(@length,pplines));
            pplines(emptylines) = [];
            linenums(emptylines) = [];
            
            %Replace all the n,u,m,s with values
            pplines = regexprep(pplines,'([0-9]+)n','$1e-9');
            pplines = regexprep(pplines,'([0-9]+)u','$1e-6');
            pplines = regexprep(pplines,'([0-9]+)m','$1e-3');
            pplines = regexprep(pplines,'([0-9]+)s','$1e-0');
            
            
            %Check for definitions of pulses and delays
            %First delays: look for 'define delay delayname' and extract delayname as
            %token
            delaynames = regexp(pplines,'define delay (\w+)','tokens','once');
            delaylinenums = find(~cellfun(@isempty,delaynames))';
            %Setup the structure in PSobj.expparams.defines
            for ct = delaylinenums
                PSobj.expparams.defines.(delaynames{ct}{1}).value = [];
                PSobj.expparams.defines.(delaynames{ct}{1}).type = 'delay';
            end
            %Remove the lines
            pplines(delaylinenums) = [];
            linenums(delaylinenums) = [];
            
            %Now the same method for pulses
            pulsenames = regexp(pplines,'define pulse (\w+)','tokens','once');
            pulselinenums = find(~cellfun(@isempty,pulsenames))';
            for ct = pulselinenums
                PSobj.expparams.defines.(pulsenames{ct}{1}).value = [];
                PSobj.expparams.defines.(pulsenames{ct}{1}).type = 'pulse';
            end
            pplines(pulselinenums) = [];
            linenums(pulselinenums) = [];
            
            %Find the definitions: look for '"definename = value"' and extract delayname
            %and value as tokens
            deflines = regexp(pplines,'"\s*(\w+)\s*=\s*(\d*(?:\.\d+)?(?:e[-+]\d+)?)\s*"','tokens','once');
            deflinenums = find(~cellfun(@isempty,deflines))';
            for ct = deflinenums
                %Do some error checking to make sure it has been defined
                defvar = deflines{ct}{1};
                defvalue = str2double(deflines{ct}{2});
                
                if(isfield(PSobj.expparams.defines,defvar) && ~isnan(defvalue))
                    PSobj.expparams.defines.(defvar).value = defvalue;
                else
                    warning('Parser:defines', 'Variable %s has not been defined or has been defined improperly.',defvar);
                end
            end
            
            %Remove the lines
            pplines(deflinenums) = [];
            linenums(deflinenums) = [];
            
            %Do some more error checking to make sure all the variable defined
            %have a value and replace all delays with numerical values
            definenames = fieldnames(PSobj.expparams.defines);
            for definect = 1:1:length(definenames)
                if(isempty(PSobj.expparams.defines.(definenames{definect}).value))
                    warning('Parser:defines','Variable %s has been defined but not assigned a value.',definenames{definect} );
                end
                
                if(strcmp(PSobj.expparams.defines.(definenames{definect}).type,'delay'))
                    pplines = regexprep(pplines,sprintf('\\<%s\\>',definenames{definect}),num2str(PSobj.expparams.defines.(definenames{definect}).value));
                end
            end
            
            %Find the phase definitions: look for 'phphnum = (denominator) numerator'
            %and extract phvalue, denominator and numerator as tokens
            phaselines = regexp(pplines,'ph(\d{1,2})\s*=\s*\((\d+)\)(\s*\d+\s*)+','tokens','once');
            phaselinenums = find(~cellfun(@isempty,phaselines))';
            
            for ct = phaselinenums
                %Extract the tokens
                phnum = str2double(phaselines{ct}{1});
                phvalue = str2num(phaselines{ct}{3})/str2double(phaselines{ct}{2}); %#ok<ST2NM>
                
                %Set the value in PSobj.expparams
                PSobj.expparams.ph(phnum).values = phvalue;
                PSobj.expparams.ph(phnum).index = 1;
            end
            
            %Remove the lines
            pplines(phaselinenums) = [];
            linenums(phaselinenums) = [];
            
            %Deal with any loops now: look for the 'lo to label time loopnum' command.
            %If it is there, extract label and loopnum
            while(any(~cellfun(@isempty,regexp(pplines,'lo to \w+ times \w+'))))
                
                %Take the first one found and extract the tokens
                loopcommands = regexp(pplines,'lo to (\w+) times (\w+)','tokens','once');
                looplinenums = find(~cellfun(@isempty,loopcommands));
                looplabel = loopcommands{looplinenums(1)}{1};
                loopvalue = loopcommands{looplinenums(1)}{2};
                
                %Turn loop value into numeric
                %First see if it is already a numeric
                if(~isempty(regexp(loopvalue,'^\d+', 'once')))
                    loopvalue = round(str2double(loopvalue));
                else
                    %If is not then try to find it in the defines
                    try
                        loopvalue = round(PSobj.expparams.defines.(definenames{strcmp(loopvalue,definenames)}).value);
                    catch
                        warning(['Loop counter ' loopvalue ' is undefined on line ' int2str(linenums(looplinenums(1))) '. Using zero.']);
                        loopvalue = 0;
                    end
                end
                
                %Find what line number the label corresponds to
                label_linenum = find(strncmp([looplabel ','],pplines,length(looplabel)+1));
                
                %Report a warning if no label can be found
                if(isempty(label_linenum))
                    warning(['Could not find label ' looplabel '.']);
                elseif(length(label_linenum) > 1)
                    warning(['Repeated line number label ' looplabel]);
                else
                    %Repeat the necessary lines
                    %This is not terribly efficient but I can't think of a smarter way for now
                    if(label_linenum > 1)
                        tmp_pplines = pplines(1:label_linenum-1);
                        tmp_linenums = linenums(1:label_linenum-1);
                    elseif(label_linenum == 1)
                        tmp_pplines = {};
                        tmp_linenums = [];
                    end
                    for loopct = 1:1:loopvalue
                        tmp_pplines = [tmp_pplines;  pplines(label_linenum:looplinenums(1)-1)];
                        tmp_linenums = [tmp_linenums; linenums(label_linenum:looplinenums(1)-1)];
                    end
                    tmp_pplines = [tmp_pplines; pplines(looplinenums(1)+1:end)];
                    tmp_linenums = [tmp_linenums; linenums(looplinenums(1)+1:end)];
                    
                    %Remove the line labels on all the lines but the first (if we have
                    %two loops to the same label then we won't get confused)
                    tmp_pplines(label_linenum(1)+1:end) = regexprep(tmp_pplines(label_linenum(1)+1:end),[looplabel ','],'');
                    
                    %Assign the new pulse program back to pplines
                    pplines = tmp_pplines;
                    linenums = tmp_linenums;
                    
                end
            end
            
            for chct = 1:length(PSobj.channels)
                channelNames{chct} = PSobj.channels(chct).logicalName;
            end
            %Now go through line by line and figure out what to do with each remaining command. We
            %deal with each line seperately and create an array of arrays
            for linect = 1:1:length(pplines);
                curline = pplines{linect};
                
                PSobj.nextLine();
                
                %First check if there is channel info on this line by checking for (*):
                channelinfo = regexp(curline,'\((?<toParse>.*?)\):(?<channel>\w+)','names');
                %Then remove it from curline
                curline = regexprep(curline,'\(.*?\):\w+','');
                
                for chct = 1:length(channelinfo)
                    
                    %Check that it is a valid channel
                    chnum = strcmp(channelNames,channelinfo(chct).channel);
                    if(sum(chnum) ~= 1)
                        error('Trying to use undefined channel %s on line %d.',channelinfo(chct).channel,linenums(linect));
                    end
                    
                    %Split the commands up
                    commands = textscan(channelinfo(chct).toParse,'%s');
                    %Interpret them one by one
                    comct = 1;
                    while comct <= length(commands{1})
                        tmpCommand = commands{1}{comct};
                        didSomething = 0;
                        try
                            %Check for a pulse
                            pulsecommand = regexp(tmpCommand, '(?<pulseLength>\w+):sp(?<spnum>\d+)','names','once');
                            if(~isempty(pulsecommand))
                                %Look ahead to see the phase if it is a
                                %quadrature channel
                                if(strcmp(PSobj.channels(find(chnum)).type,'quadrature'))
                                    try
                                        phasecommand = regexp(commands{1}{comct+1},'ph(\d+)','tokens','once');
                                        tmpphnum = str2double(phasecommand{1});
                                        tmpph = PSobj.expparams.ph(tmpphnum);
                                        comct = comct+1;
                                    catch
                                        error('Phase not defined for pulse %s on line %d',tmpCommand,linenums(linect));
                                    end
                                else
                                    tmpph = PSobj.expparams.ph(1);
                                end
                                
                                %Try to get the length
                                try
                                    tmpLength = PSobj.expparams.defines.(pulsecommand.pulseLength).value;
                                catch
                                    error('Pulse %s on line %d is not well defined.',pulsecommand.pulseLength,linenums(linect));
                                end
                                
                                PSobj.addPulse(tmpLength, str2double(pulsecommand.spnum), tmpph.values(tmpph.index), channelinfo(chct).channel);
                                didSomething = 1;
                            end
                            
                            %Check for a delay
                            simpledelay = regexp(tmpCommand,'\<(\d*(?:\.\d+)?(?:e[-+]\d+)?)\>','tokens','once');
                            if(~isempty(simpledelay))
                                PSobj.addDelay(str2double(simpledelay),channelinfo(chct).channel);
                                didSomething = 1;
                            end
                            
                            %Check for phase commands
                            if(PSobj.checkPhaseCommands(tmpCommand))
                                didSomething = 1;
                            end
                            
                            %Spit out an error if we didn't handle the
                            %command.
                            if(~didSomething)
                                error('Command %s not handled on line %d',tmpCommand,linenums(linect));
                            end
                            comct = comct+1;

                        catch ME
                            error('Command %s not handled on line %d with error %s',tmpCommand,linenums(linect),ME.message);
                            comct = comct+1;
                        end
                    end
                    
                end
                
                
                %Check for simple delays      
                simpledelay = regexp(curline,'\<(\d*(?:\.\d+)?(?:e[-+]\d+)?)\>','tokens','once');
                
                %Add the delay to the output
                if(~isempty(simpledelay))
                    %Concatenate on the delay to the sequence
                    PSobj.addDelay(str2double(simpledelay));
                end
                
            end
            
            
        end  %parser method
        
        %Helper function to deal with phase increment/decrement commands
        function didSomething = checkPhaseCommands(PSobj,command)
            didSomething = 0;
            phaseincrement = regexp(command,'ipp(\d+)','tokens');
            for phct = 1:1:length(phaseincrement)
                phnum = str2double(phaseincrement{phct});
                PSobj.expparams.ph{phnum}.index = mod(PSobj.expparams.ph{phnum}.index,length(PSobj.expparams.ph{phnum}.values))+1;
                didSomething = 1;
            end
            %Now decrements
            phasedecrement = regexp(command,'dpp(\d+)','tokens');
            for phct = 1:1:length(phasedecrement)
                phnum = str2double(phasedecrement{phct});
                PSobj.expparams.ph{phnum}.index = mod(PSobj.expparams.ph{phnum}.index-2,length(PSobj.expparams.ph{phnum}.values))+1;
                didSomething = 1;
            end
            %Finally resets
            phasereset = regexp(command,'rpp(\d+)','tokens');
            for phct = 1:1:length(phasereset)
                phnum = str2double(phasereset{phct});
                PSobj.expparams.ph{phnum}.index = 1;
                didSomething = 1;
            end
        end
            
        %Function to produce waveforms for the AWG by discretizing the waveform
        %Also will handle line delays here
        function discretize(PSobj)
            
            %Clear the previous channel data
            for chct = 1:length(PSobj.channels)
                PSobj.channels(chct).clearAWGData;
            end
            
            %Now go through and handle each line
            for linect = 1:1:length(PSobj.byLine)
                
               %Find out what the maximum time is for this line
                maxTime = 0;
                for chct = 1:length(PSobj.channels)
                    tmpLogicalName = PSobj.channels(chct).logicalName;
                    chtime.(tmpLogicalName) = 0;
                    if(~isempty(PSobj.byLine(linect).(tmpLogicalName)))
                        %Round the times to the AWG disretization
                        PSobj.byLine(linect).(tmpLogicalName)(:,1) = (1/PSobj.expparams.AWGfreq)*round( PSobj.byLine(linect).(tmpLogicalName)(:,1)*PSobj.expparams.AWGfreq);
                        chtime.(tmpLogicalName) =  sum(PSobj.byLine(linect).(tmpLogicalName)(:,1));
                        maxTime = max(maxTime, chtime.(tmpLogicalName));
                    end
                end
                
                %For each channel discretize what is there and then add zeros to balance out the
                %channels
                for chct = 1:length(PSobj.channels)
                    tmpChannel = PSobj.channels(chct);
                    tmpLogicalName = tmpChannel.logicalName;
                    tmpByLine = PSobj.byLine(linect).(tmpLogicalName);
                    for ct = 1:size(tmpByLine,1)
                        time = tmpByLine(ct,1);
                        spnum = tmpByLine(ct,2);
                        pulsePhase = tmpByLine(ct,3);
                        
                        %If it is a pulse
                        if(spnum)
                            tmpShape = PSobj.expparams.sp(spnum);
                            
                            %Work out how many AWG timesteps per pulse point and make sure it is an
                            %integer
                            tsperpt = PSobj.expparams.AWGfreq/(tmpShape.numpoints/time);
                            if(abs(tsperpt - round(tsperpt))>1e6*eps)
                                warning(['Pulse does not have the right number of points for its length (' num2str(tsperpt) ') and is being rounded.']);
                            end
                            tsperpt = round(tsperpt);
                            
                            %Repeat points of the pulse if the AWG discretization is faster than the pulse disretization
                            tmpRepAmp = reshape(repmat(tmpShape.pulse(:,1)',tsperpt,1),tsperpt*tmpShape.numpoints,1);
                            tmpRepPhase = reshape(repmat(tmpShape.pulse(:,2)',tsperpt,1),tsperpt*tmpShape.numpoints,1);
                           
                            %Scale the power
                            tmpRepAmp = tmpRepAmp*10^(tmpShape.power/20);
                            
                            %Add phase ramp and pulse phase
                            tmpRepPhase = tmpRepPhase + pulsePhase - tmpShape.offset*(1/PSobj.expparams.AWGfreq)*(0:1:length(tmpRepPhase)-1)';
                            
                            %Otherwise add zeros for the delay
                        else
                            tmpRepAmp = zeros(round(time*PSobj.expparams.AWGfreq),1);
                            tmpRepPhase = zeros(round(time*PSobj.expparams.AWGfreq),1);
                            
                        end
                        %Now concatenate it on 
                        PSobj.channels(chct).addAWGData(tmpRepAmp,tmpRepPhase);
                    end
                    
                    %Zero pad to even out the channels
                    timeToAdd = maxTime - chtime.(tmpLogicalName);
                    if(timeToAdd > 1e2*eps)
                        pointsToAdd = round(timeToAdd*PSobj.expparams.AWGfreq);
                        PSobj.channels(chct).addAWGData(zeros(pointsToAdd,1),zeros(pointsToAdd,1));
                    end
                    
                end
                
            end
            
            %Set the number of points property
            PSobj.numPoints = size(PSobj.channels(1).AWGData,1);
            
        end %discretize method
        
        %Method to plot a pulse sequence to a specified axes
        function plot(PSobj,axesHandle)
            shift = 0;
            for chct = 1:length(PSobj.channels)
                %Setup the timeaxis
                timeaxis = (1/PSobj.expparams.AWGfreq)*(1:PSobj.numPoints);
                
                %Plot the amplitude data (??? add more options later)
                plot(axesHandle,timeaxis,PSobj.channels(chct).AWGData(:,1)+shift);
                
                hold(axesHandle,'on')
                
                %Plot a label
                text(0,shift+0.1,PSobj.channels(chct).logicalName,'Parent',axesHandle);
                
                shift = shift+1.2;
            end
            
        end  %plot function
        
      
        
        
    end %methods section
    
    
    
    events
        
        pulseSequenceUpdated
        
    end
    
end
