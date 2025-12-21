%%Modifciation to the generate pulse sequence function to help make
%%creating swapped pulse sequences quicker.

function [PSeq,fn] = generatePulseSequenceSwap(pi_2, pi, softPi, nitroPi, N_pi, pi_2_phases, pi_phaseBlock,corrTime,script)
    Channels = generateChannels(pi_2, pi, softPi,nitroPi, N_pi, pi_2_phases, pi_phaseBlock,corrTime);
    Groups = generateGroups();
    B = 504;
    Tdip = 1/(4.2576*B*1000)/2;
    TdipAdjusted = (Tdip - pi)/2;
    start = TdipAdjusted - 20e-9;
    if(start < 20e-9)
        start = 20e-9;
    end
    stop = TdipAdjusted + 20e-9;
    Channels(1,1).RiseFrequencies = [];
    Channels(1,2).RiseFrequencies = [];
    Channels(1,1).RiseSweepMultipliers = [];
    Channels(1,2).RiseSweepMultipliers = [];
    if corrTime == 0
        Sweeps = generateSweeps(3,'Type','Time','sweep',125e-9,175e-9,51,2,1);
    else
        Sweeps = generateSweeps(4,'Type','Time', 'corr' ,.05e-6,25e-6,51,2,1);
    end
    PSeq = PulseSequence(Channels,[],Sweeps,0,num2str(N_pi));
    
    PSeq.setMWHWChannel(3);
    if ~script
        [fn,fp] = uiputfile();
        fn = fullfile(fp,fn);
        save(fn,'PSeq');
    else
    end

end

function[Channels] = generateChannels(pi_2,pi,softPi,nitroPi,N_pi,pi_2_phases, pi_phaseBlock,corrTime)

    %Initialize channels
    Channels = [PulseChannel(),PulseChannel(),PulseChannel(),PulseChannel()];
    
    %set hw channels
    Channels(1).setHWChannel(2);
    Channels(2).setHWChannel(1);
    Channels(3).setHWChannel(3);
    Channels(4).setHWChannel(4);
    
    %configure AOM Initialization
    Channels(2).addRise();
    Channels(2).setRiseParams(1,0,3e-6,'',0,0,0,1);
    
    %build Phases for pseq
    phases = [];
    for i = 1:(N_pi/numel(pi_phaseBlock))
        phases = [phases,pi_phaseBlock];
    end
    %add pi/2 phases
    phases = [pi_2_phases(1),phases,pi_2_phases(2)];
    %configure MW pulses
    %4 sets of pi pulses for the encode, decode, cycled encode and cycled
    %decode, 8 pi/2 pulses, 2 for each of the encode decode steps
    %and 4 soft swapping pulses
    while Channels(3).NumberOfRises < 4*N_pi + 12 
        Channels(3).addRise();
    end
    %configure rf pulses, 4 rf pulses, 2 for first swap, 2 for cycled swap
    for rfIter = 1:4
        Channels(4).addRise();
    end
    runningTime = 3.5e-6;
    PulseSpacing = 0;
    %configure first pulse train, if corrTime = 0 this is the only pulse
    %train
    for i = 1:Channels(3).NumberOfRises/4-1
        if i == 1 
            Channels(3).setRiseParams(i,runningTime,pi_2,'',1.0,pi_2_phases(1),0,1);
            runningTime = runningTime + pi_2 + PulseSpacing;
        elseif i == Channels(3).NumberOfRises/4-1
            Channels(3).setRiseParams(i,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2),0,1);
            runningTime = runningTime + pi_2 + PulseSpacing + corrTime+100e-9;
        elseif i == 2
            Channels(3).setRiseParams(i,runningTime + corrTime,pi,'sweep',1.0,phases(i),0,1);
            runningTime = runningTime + pi + PulseSpacing + corrTime;
        else
            Channels(3).setRiseParams(i,runningTime + corrTime*2,pi,'sweep',1.0,phases(i),0,2);
            runningTime = runningTime + pi + PulseSpacing + corrTime*2;
        end
    end
    %at the end of the first pulse train add swap pulses
    Channels(3).setRiseParams(N_pi+2+1,runningTime,softPi,'',.15,0,0,1);
    runningTime = runningTime + softPi+100e-9;
    Channels(4).setRiseParams(1,runningTime,nitroPi,'',1.0,0,0,1);
    runningTime = runningTime + nitroPi+2e-6;
    Channels(4).setRiseParams(2,runningTime,nitroPi,'corr',1.0,0,0,1);
    runningTime = runningTime + nitroPi+2e-6;
    Channels(3).setRiseParams(N_pi+2+2,runningTime,softPi,'',.15,0,0,1);
    runningTime = runningTime + softPi+100e-9;
    
    %now add the second pulse train
    for i = 1:Channels(3).NumberOfRises/4-1
        if i == 1 
            Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/4+1,runningTime,pi_2,'',1.0,pi_2_phases(1),0,1);
            runningTime = runningTime + pi_2 + PulseSpacing;
        elseif i == Channels(3).NumberOfRises/4-1
            Channels(3).setRiseParams(i + Channels(3).NumberOfRises/4+1,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2),0,1);
            runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
        elseif i == 2
            Channels(3).setRiseParams(i + Channels(3).NumberOfRises/4+1,runningTime + corrTime,pi,'sweep',1.0,phases(i),0,1);
            runningTime = runningTime + pi + PulseSpacing + corrTime;
        else
            Channels(3).setRiseParams(i + Channels(3).NumberOfRises/4+1,runningTime+corrTime*2,pi,'sweep',1.0,phases(i),0,2);
            runningTime = runningTime + pi + PulseSpacing + corrTime*2;
        end
    end

    %configure readout
    Channels(2).addRise();
    Channels(2).setRiseParams(2,runningTime + 2e-6 ,3e-6,'',0,0,0,1);
    runningTime = runningTime + 2e-6;%delay between end of pulse sequence and read out
    %Configure Counter
    Channels(1).addRise();
    Channels(1).setRiseParams(1,runningTime + 3e-7,2e-7,'Counter',0,0,0,1);
    runningTime = runningTime + 3.5e-6;
    for i = 1:Channels(3).NumberOfRises/4-1
        if i == 1 
            Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime,pi_2,'',1.0,pi_2_phases(1),0,1);
            runningTime = runningTime + pi_2 + PulseSpacing;
        elseif i == Channels(3).NumberOfRises/4-1
            Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2)+180,0,1);
            runningTime = runningTime + pi_2 + PulseSpacing + corrTime+100e-9;
        elseif i == 2
            Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime + corrTime,pi,'sweep',1.0,phases(i),0,1);
            runningTime = runningTime + pi + PulseSpacing + corrTime;
        else
            Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime + corrTime*2,pi,'sweep',1.0,phases(i),0,2);
            runningTime = runningTime + pi + PulseSpacing + corrTime*2;
        end
    end
        %configure cycled swap

        Channels(3).setRiseParams(3*(N_pi+2)+2+1,runningTime,softPi,'',.15,0,0,1);
        runningTime = runningTime + softPi+100e-9;
        Channels(4).setRiseParams(3,runningTime,nitroPi,'',1.0,0,0,1);
        runningTime = runningTime + nitroPi+2e-6;
        Channels(4).setRiseParams(4,runningTime,nitroPi,'corr',1.0,0,0,1);
        runningTime = runningTime + nitroPi+2e-6;
        Channels(3).setRiseParams(3*(N_pi+2)+2+2,runningTime,softPi,'',.15,0,0,1);
        runningTime = runningTime + softPi+100e-9;
        
    for i = 1:Channels(3).NumberOfRises/4-1
        if i == 1 
            Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4+1,runningTime,pi_2,'',1.0,pi_2_phases(1),0,1);
            runningTime = runningTime + pi_2 + PulseSpacing;
        elseif i == Channels(3).NumberOfRises/4-1
           Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4+1,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2),0,1);
           runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
        elseif i == 2
            Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4+1,runningTime + corrTime,pi,'sweep',1.0,phases(mod(i,length(phases))),0,1);
            runningTime = runningTime + pi + PulseSpacing + corrTime;
        else
            Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4+1,runningTime+corrTime*2,pi,'sweep',1.0,phases(mod(i,length(phases))),0,2);
            runningTime = runningTime + pi + PulseSpacing + corrTime*2;
        end
    end

    
    Channels(2).addRise();
    Channels(2).setRiseParams(3,runningTime + 4e-6 ,3e-6,'',0,0,0,1);
    runningTime = runningTime + 4e-6;%delay between end of pulse sequence and read out
    %Configure Counter
    Channels(1).addRise();
    Channels(1).setRiseParams(2,runningTime + 3e-7,2e-7,'Counter',0,0,0,1);

    
    
end


function [Sweeps] = generateSweeps(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add)
    Sweeps = PulseSweep();
    Sweeps.setSweepParams(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add);
end

function [Groups] = generateGroups()
        Groups = PulseGroup();
end






