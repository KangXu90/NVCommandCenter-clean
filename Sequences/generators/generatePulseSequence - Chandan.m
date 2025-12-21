function [PSeq,fn] = generatePulseSequence(pi_2, pi, N_pi, pi_2_phases, pi_phaseBlock,corrTime,script)
    Channels = generateChannels(pi_2, pi, N_pi, pi_2_phases, pi_phaseBlock,corrTime);
    Groups = generateGroups();
    B = 210;
    Tdip = 1/(4.2576*B*1000)/2;
    TdipAdjusted = (Tdip - pi)/2;
    start = TdipAdjusted - 50e-9;
    if(start < 10e-9)
        start = 10e-9;
    end
    stop = TdipAdjusted + 50e-9; 
    Channels(1,1).RiseFrequencies = [];
    Channels(1,2).RiseFrequencies = [];
    Channels(1,1).RiseSweepMultipliers = [];
    Channels(1,2).RiseSweepMultipliers = [];
    if corrTime == 0
        Sweeps = generateSweeps(3,'Type','Time','sweep',start,stop,51,2,1);
    else
        Sweeps = generateSweeps(3,'Type','Time', 'corr' ,.01e-6,25e-6,201,2,1);
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

function[Channels] = generateChannels(pi_2,pi,N_pi,pi_2_phases, pi_phaseBlock,corrTime)
    counterGate = 0.25e-6;
    laserPulse = 10e-6;
    %Initialize channels1
    Channels = [PulseChannel(),PulseChannel(),PulseChannel()];
    
    %set hw channels
    Channels(1).setHWChannel(2);
    Channels(2).setHWChannel(1);
    Channels(3).setHWChannel(3);
    
    %configure AOM Initialization
    Channels(2).addRise();
    Channels(2).setRiseParams(1,0,laserPulse/2,'',0,0,0,1); % changed from laserPulse/2
  
   
    %build Phases for pseq
    phases = [];
    for i = 1:(N_pi/numel(pi_phaseBlock))
        phases = [phases,pi_phaseBlock];
    end
    %add pi/2 phases
    phases = [pi_2_phases(1),phases,pi_2_phases(2)];
    %configure MW pulses
    while Channels(3).NumberOfRises < N_pi + 2
        Channels(3).addRise();
    end
    runningTime = laserPulse/2 + 1e-6;
    PulseSpacing = 0;
    %configure first pulse train, if corrTime = 0 this is the only pulse
    %train
    for i = 1:Channels(3).NumberOfRises
        if i == 1 
            Channels(3).setRiseParams(i,runningTime,pi_2,'',1.0,pi_2_phases(1),0,1);
            runningTime = runningTime + pi_2 + PulseSpacing;
        elseif i == Channels(3).NumberOfRises
            Channels(3).setRiseParams(i,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2),0,1);
            runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
        elseif i == 2
            Channels(3).setRiseParams(i,runningTime + corrTime,pi,'sweep',1.0,phases(i),0,1);
            runningTime = runningTime + pi + PulseSpacing + corrTime;
        else
            Channels(3).setRiseParams(i,runningTime + corrTime*2,pi,'sweep',1.0,phases(i),0,2);
            runningTime = runningTime + pi + PulseSpacing + corrTime*2;
        end
    end
    %check if corrTime is non-zero, if it is add additional pulse train
    if corrTime~=0
        while Channels(3).NumberOfRises < 2*N_pi + 4
            Channels(3).addRise();
        end

        for i = 1:Channels(3).NumberOfRises/2
            if i == 1 
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime,pi_2,'corr',1.0,pi_2_phases(1),0,1);
                runningTime = runningTime + pi_2 + PulseSpacing;
            elseif i == Channels(3).NumberOfRises/2
                Channels(3).setRiseParams(i + Channels(3).NumberOfRises/2,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2),0,1);
                runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
            elseif i == 2
                Channels(3).setRiseParams(i + Channels(3).NumberOfRises/2,runningTime + corrTime,pi,'sweep',1.0,phases(i),0,1);
                runningTime = runningTime + pi + PulseSpacing + corrTime;
            else
                Channels(3).setRiseParams(i + Channels(3).NumberOfRises/2,runningTime+corrTime*2,pi,'sweep',1.0,phases(i),0,2);
                runningTime = runningTime + pi + PulseSpacing + corrTime*2;
            end
        end
    end
    %configure readout
    delay = 0;
    Channels(2).addRise();
    Channels(2).setRiseParams(2,runningTime + 1e-6 + delay ,laserPulse,'',0,0,0,1);
    runningTime = runningTime + 1e-6 + delay;%delay between end of pulse sequence and read out
    %Configure Counter
    Channels(1).addRise();
    Channels(1).setRiseParams(1,runningTime+250e-9,counterGate,'Counter',0,0,0,1);
   
%     if corrTime == 0
%         runningTime = runningTime + laserPulse + 1e-6;%adding first readout to running Time plus a 1us delay
%         while Channels(3).NumberOfRises < 2*N_pi + 4
%             Channels(3).addRise();
%         end
% 
%         %now for 3pi/2 data
%         for i = 1:Channels(3).NumberOfRises/2
%             if i == 1 
%                 Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime,pi_2,'',1.0,pi_2_phases(1),1,1);
%                 runningTime = runningTime + pi_2 + PulseSpacing;
%             elseif i == Channels(3).NumberOfRises/2
%                 Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2)+180,1,1);
%                 runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
%             elseif i == 2
%                 Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime + corrTime,pi,'sweep',1.0,phases(i),1,1);
%                 runningTime = runningTime + pi + PulseSpacing + corrTime;
%             else
%                 Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime + corrTime*2,pi,'sweep',1.0,phases(i),1,2);
%                 runningTime = runningTime + pi + PulseSpacing + corrTime*2;
%             end
%         end
%     else
%         while Channels(3).NumberOfRises < 3*N_pi + 6
%               Channels(3).addRise();
%         end
%         runningTime = runningTime + laserPulse + 1e-6;
%         for i = 1:Channels(3).NumberOfRises/3
%             if i == 1 
%                 Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*2/3,runningTime,pi_2,'',1.0,pi_2_phases(1),0,1);
%                 runningTime = runningTime + pi_2 + PulseSpacing;
%             elseif i == Channels(3).NumberOfRises/3
%                 Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*2/3,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2)+180,0,1);
%                 runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
%             elseif i == 2
%                 Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*2/3,runningTime + corrTime,pi,'sweep',1.0,phases(i),0,1);
%                 runningTime = runningTime + pi + PulseSpacing + corrTime;
%             else
%                 Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*2/3,runningTime + corrTime*2,pi,'sweep',1.0,phases(i),0,2);
%                 runningTime = runningTime + pi + PulseSpacing + corrTime*2;
%             end
%         end
%         %check if corrTime is non-zero, if it is add additional pulse train
%         if corrTime~=0
%             while Channels(3).NumberOfRises < 4*N_pi + 8
%                 Channels(3).addRise();
%             end
% 
%             for i = 1:Channels(3).NumberOfRises/4
%                 if i == 1 
%                     Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4,runningTime,pi_2,'corr',1.0,pi_2_phases(1),0,1);
%                     runningTime = runningTime + pi_2 + PulseSpacing;
%                 elseif i == Channels(3).NumberOfRises/4
%                     Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4,runningTime + corrTime,pi_2,'sweep',1.0,pi_2_phases(2),0,1);
%                     runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
%                 elseif i == 2
%                     Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4,runningTime + corrTime,pi,'sweep',1.0,phases(mod(i,length(phases))),0,1);
%                     runningTime = runningTime + pi + PulseSpacing + corrTime;
%                 else
%                     Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4,runningTime+corrTime*2,pi,'sweep',1.0,phases(mod(i,length(phases))),0,2);
%                     runningTime = runningTime + pi + PulseSpacing + corrTime*2;
%                 end
%             end
%         end
%     end
%     Channels(2).addRise();
%     Channels(2).setRiseParams(3,runningTime + 1e-6 + delay ,laserPulse,'',0,0,0,1);
%     runningTime = runningTime + 1e-6 + delay;%delay between end of pulse sequence and read out
%     %Configure Counter
%     Channels(1).addRise();
%     Channels(1).setRiseParams(2,runningTime+250e-9,counterGate,'Counter',0,0,0,1);

    %add the reference read and counter
    runningTime = runningTime + laserPulse + 1e-6;%adding second readout to running Time plus a 1us delay
    Channels(2).addRise();
    Channels(2).setRiseParams(3,runningTime + 1e-6 + delay ,laserPulse/2,'',0,0,0,1);
    runningTime = runningTime + 1e-6 + delay;%delay between end of pulse sequence and read out
    %Configure Counter
    Channels(1).addRise();
    Channels(1).setRiseParams(2,runningTime+250e-9,counterGate,'Counter',0,0,0,1);
        
    
end


function [Sweeps] = generateSweeps(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add)
    Sweeps = PulseSweep();
    Sweeps.setSweepParams(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add);
end

function [Groups] = generateGroups()
        Groups = PulseGroup();
end






