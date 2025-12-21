function [Sequence,tempPS] = ProcessPulseProgramTekAWG(PSeq,hTek,SourceFreq)

% first, given the clock rate of the parse out the Pulse Program, channel
% by channel and put into a data structure

Sequence =  PulseSequenceToArray(PSeq,SourceFreq);
tempPS = [];

% if there are sweeps enabled, process the sweep
if numel(PSeq.Sweeps),
    [Sequence,tempPS] = PulseSequenceSweepToArray(PSeq,SourceFreq);
end

end

function [Sequence] = PulseSequenceToArray(PSeq,SourceFreq)

    % get the max time of the sequence
    tmax = PSeq.GetMaxRiseTime;
    SeqPoints = ceil(tmax*SourceFreq);

    Sequence = zeros(numel(PSeq.Channels),SeqPoints);

    for k=1:numel(PSeq.Channels),

        % loop over the rises
        for l=1:PSeq.Channels(k).NumberOfRises,
            startTime = PSeq.Channels(k).RiseTimes(l);
            
            % account for HW delay
            startTimeActual = startTime - PSeq.Channels(k).DelayOn;
            
            stopTime = startTime + PSeq.Channels(k).RiseDurations(l);
            % account for HW delay
            stopTimeActual = stopTime - PSeq.Channels(k).DelayOff;
            pStart = uint32(startTimeActual*SourceFreq);
            pStop = uint32(stopTimeActual*SourceFreq);

            % add one for Matlab type indexing
            Sequence(k,pStart+1:pStop+1) = 1; % set high
        end
    end
end

function [Sequence, tempPSeq] = PulseSequenceSweepToArray(PSeq,SourceFreq)

    % get the max time of the sequence
    tmax = PSeq.GetMaxRiseTime;

    
    % create a dummy sequence which we can copy in an modify
    tempPSeq = PSeq.clone();
    
    % loop thru the sweeps updating the channels
    for jj=1:numel(PSeq.Sweeps),
        
        switch PSeq.Sweeps(jj).SweepClass
            case 'Rise'
                switch PSeq.Sweeps(jj).SweepType
                    case 'T'
                        % increse the sweep time
                        ind = PSeq.getSweepIndex();
                        chn = PSeq.Sweeps(jj).Channels;
                        rise = PSeq.Sweeps(jj).SweepRises;
                        x = linspace(PSeq.Sweeps(jj).StartValue,PSeq.Sweeps(jj).StopValue,PSeq.Sweeps(jj).SweepPoints);
                        
                        if PSeq.Sweeps(jj).SweepAdd,
                            tempPSeq.Channels(chn).RiseTimes(rise) = tempPSeq.Channels.RiseTimes(chn) + x(ind(jj));
                        else
                            tempPSeq.Channels(chn).RiseTimes(rise) = x(ind(jj));
                        end
                        
                        if PSeq.Sweeps(jj).SweepShifts == 1,
                            tempPSeq.Channels.RiseTimes(chn+1:end) = tempPSeq.Channels.RiseTimes(chn+1:end) + x(ind(jj));
                        end
                        
                    case 'DT'
                    case 'Amp'
                    case 'Ph'
                end
            case 'Type'
                warning('not implemented')
            case 'Group'
                warning('not implemented')
        end
        
    end
    
    
    Sequence =  PulseSequenceToArray(tempPSeq,SourceFreq);

end
        
        