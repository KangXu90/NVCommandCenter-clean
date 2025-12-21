function [PSeq,fn] = generatePulseSequence_XY8_kang(pi_2, pi, N_pi, pi_2_phases, pi_phaseBlock,corrTime,script,ref,RiseAmp)
    Channels = generateChannels(pi_2, pi, N_pi, pi_2_phases, pi_phaseBlock,corrTime,RiseAmp);
    Groups = generateGroups();
    f = 1863; %MHz
    B = (2870-f)/2.8;
    Tdip = round(1/(4.2576*B*1000)/2,9);
    TdipAdjusted = (Tdip - pi)/2;
    start = TdipAdjusted - 30e-9;
    if(start < 10e-9)
        start = 10e-9;
    end
    stop = TdipAdjusted + 30e-9; 
    % Channels(1,1).RiseFrequencies = [];
    % Channels(1,2).RiseFrequencies = [];
    % Channels(1,1).RiseSweepMultipliers = [];
    % Channels(1,2).RiseSweepMultipliers = [];
    if corrTime == 0
        Sweeps = generateSweeps(3,'Type','Time','sweep',0,0,2,0,1);
    else
        Sweeps = generateSweeps(3,'Type','Time', 'corr' ,.01e-6,10.01e-6,101,2,1);
    end
    
    if ~ref
        Channels = Channels(1:3);
    end
    PSeq = PulseSequence(Channels,[],Sweeps,1,['WAHUHA' num2str(N_pi)]);
    
    PSeq.setMWHWChannel(3);
    if ~script
        [fn,fp] = uiputfile();
        fn = fullfile(fp,fn);
        save(fn,'PSeq');
    else
    end

end

function[Channels] = generateChannels(pi_2,pi,N_pi,pi_2_phases, pi_phaseBlock,corrTime,RiseAmp)
   
    delayMW_AOM = 2e-6;
    delayAOM_MW = 2e-6;
    delayDAQ_AOM = 300e-9;
    counterGate = 800e-9;
    laserPulse = 20e-6;

    
    
%     Counterzone = 0.5e-6;
    correlationtime = 0;
    
% Initialize channels1
    Channels = [PulseChannel(),PulseChannel(),PulseChannel(),PulseChannel()];
    
    %set hw channels
    Channels(1).setHWChannel(2);
    Channels(2).setHWChannel(1);
    Channels(3).setHWChannel(3);
    Channels(4).setHWChannel(5);
    
    %configure AOM Initialization
    Channels(2).addRise();
    Channels(2).setRiseParams(1,0,laserPulse/2,'Rise',1,0,0,1); % changed from laserPulse/2
    Channels(1).addRise();
    %delayDAQ_AOM should be sweep to optimise, counterGate should also
    %sweep to optimise
    Channels(1).setRiseParams(1,laserPulse/2-counterGate,counterGate,'Counter',1,0,0,1);
    runningTime = laserPulse/2 + delayMW_AOM;

    % build Phases for pseq
    phases = zeros(1, N_pi);
    for i = 1:N_pi
        idx = mod(i-1, numel(pi_phaseBlock)) + 1;
        phases(i) = pi_phaseBlock(idx);
    end
    % add pi/2 phases
    phases = [pi_2_phases(1), phases, pi_2_phases(2)];

    gapMultBlock = [2 2 2 2 2 2 2 2];
    gapMult = zeros(1, N_pi); 
    for i = 1:N_pi
        idx = mod(i-1, numel(gapMultBlock)) + 1;
        gapMult(i) = gapMultBlock(idx);
    end
    gapMult = [1 gapMult 1]; % τ = gapMult * b * PulseSpacing
    b = 1;
    PulseSpacingUnit = 80e-9;
    PulseSpacing = gapMult * b * PulseSpacingUnit;


    %configure MW pulses
    while Channels(3).NumberOfRises < N_pi + 2
        Channels(3).addRise();
     end
    


    %configure first pulse train, if corrTime = 0 this is the only pulse
    %train
    for i = 1:Channels(3).NumberOfRises
        if i == 1 
            Channels(3).setRiseParams(i,runningTime,pi_2,'',RiseAmp,pi_2_phases(1),0,1);
            runningTime = runningTime + PulseSpacing(i);
        elseif i == Channels(3).NumberOfRises
            Channels(3).setRiseParams(i,runningTime + corrTime,pi_2,'sweep',RiseAmp,pi_2_phases(2),0,1);
            runningTime = runningTime + pi_2  + corrTime;
        elseif i == Channels(3).NumberOfRises-1
            Channels(3).setRiseParams(i,runningTime + corrTime*2,pi,'sweep',RiseAmp,phases(i),0,1);
            runningTime = runningTime +  PulseSpacing(i)/2 + corrTime*2;
        else
            Channels(3).setRiseParams(i,runningTime + corrTime*2,pi,'sweep',RiseAmp,phases(i),0,1);
            runningTime = runningTime +  PulseSpacing(i) + corrTime*2;
        end
    end
    %check if corrTime is non-zero, if it is add additional pulse train
    if corrTime~=0
        runningTime = runningTime + correlationtime;
        while Channels(3).NumberOfRises < 2*N_pi + 4
            Channels(3).addRise();
        end
        
        for i = 1:Channels(3).NumberOfRises/2
            if i == 1
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises/2,runningTime,pi_2,'corr',RiseAmp,pi_2_phases(1),0,1);
                runningTime = runningTime + pi_2 + PulseSpacing;
            elseif i == Channels(3).NumberOfRises/2
                Channels(3).setRiseParams(i + Channels(3).NumberOfRises/2,runningTime + corrTime,pi_2,'sweep',RiseAmp,pi_2_phases(2),0,1);
                runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
            elseif i == 2
                Channels(3).setRiseParams(i + Channels(3).NumberOfRises/2,runningTime + corrTime,pi,'sweep',RiseAmp,phases(i),0,1);
                runningTime = runningTime + pi + PulseSpacing + corrTime;
            else
                Channels(3).setRiseParams(i + Channels(3).NumberOfRises/2,runningTime+corrTime*2,pi,'sweep',RiseAmp,phases(i),0,2);
                runningTime = runningTime + pi + PulseSpacing + corrTime*2;
            end
        end
    end
    runningTime = runningTime + delayAOM_MW;
    
    %configure readout
    Channels(2).addRise();
    Channels(2).setRiseParams(2,runningTime,laserPulse,'Rise',1,0,0,1);
  
    %Configure Counter
    Channels(1).addRise();
    Channels(1).setRiseParams(2,runningTime+delayDAQ_AOM,counterGate,'Counter',1,0,0,1);
 

    if corrTime == 0
        runningTime = runningTime + laserPulse + delayMW_AOM;%adding first readout to running Time plus a 1us delay
        while Channels(3).NumberOfRises < 2*N_pi + 4
            Channels(3).addRise();
        end

        %now for 3pi/2 data
    for i = 1:Channels(3).NumberOfRises/2
        if i == 1 
            Channels(3).setRiseParams(i+Channels(3).NumberOfRises/2,runningTime,pi_2,'',RiseAmp,pi_2_phases(1),0,1);
            runningTime = runningTime + PulseSpacing(i);
        elseif i == Channels(3).NumberOfRises/2
            Channels(3).setRiseParams(i+Channels(3).NumberOfRises/2,runningTime + corrTime,pi_2,'sweep',RiseAmp,pi_2_phases(2)+180,0,1);
            runningTime = runningTime + pi_2  + corrTime;
        elseif i ==  Channels(3).NumberOfRises/2-1
            Channels(3).setRiseParams(i+Channels(3).NumberOfRises/2,runningTime + corrTime*2,pi,'sweep',RiseAmp,phases(i),0,1);
            runningTime = runningTime + PulseSpacing(i)/2 + corrTime*2;
        else
            Channels(3).setRiseParams(i+Channels(3).NumberOfRises/2,runningTime + corrTime*2,pi,'sweep',RiseAmp,phases(i),0,1);
            runningTime = runningTime + PulseSpacing(i) + corrTime*2;
        end
    end
    else % corrTime~=0
        runningTime = runningTime + laserPulse + delayMW_AOM;
        while Channels(3).NumberOfRises < 3*N_pi + 6
            Channels(3).addRise();
        end
        for i = 1:Channels(3).NumberOfRises/3
            if i == 1
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*2/3,runningTime,pi_2,'',RiseAmp,pi_2_phases(1),0,1);
                runningTime = runningTime + pi_2 + PulseSpacing;
            elseif i == Channels(3).NumberOfRises/3
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*2/3,runningTime + corrTime,pi_2,'sweep',RiseAmp,pi_2_phases(2),0,1);
                runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
            elseif i == 2
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*2/3,runningTime + corrTime,pi,'sweep',RiseAmp,phases(i),0,1);
                runningTime = runningTime + pi + PulseSpacing + corrTime;
            else
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*2/3,runningTime + corrTime*2,pi,'sweep',RiseAmp,phases(i),0,2);
                runningTime = runningTime + pi + PulseSpacing + corrTime*2;
            end
        end
        %check if corrTime is non-zero, if it is add additional pulse train
        runningTime = runningTime + correlationtime;
        while Channels(3).NumberOfRises < 4*N_pi + 8
            Channels(3).addRise();
        end
        
        for i = 1:Channels(3).NumberOfRises/4
            if i == 1
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4,runningTime,pi_2,'corr',RiseAmp,pi_2_phases(1),0,1);
                runningTime = runningTime + pi_2 + PulseSpacing;
            elseif i == Channels(3).NumberOfRises/4
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4,runningTime + corrTime,pi_2,'sweep',RiseAmp,pi_2_phases(2)+180,0,1);
                runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
            elseif i == 2
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4,runningTime + corrTime,pi,'sweep',RiseAmp,phases(mod(i,length(phases))),0,1);
                runningTime = runningTime + pi + PulseSpacing + corrTime;
            else
                Channels(3).setRiseParams(i+ Channels(3).NumberOfRises*3/4,runningTime+corrTime*2,pi,'sweep',RiseAmp,phases(mod(i,length(phases))),0,2);
                runningTime = runningTime + pi + PulseSpacing + corrTime*2;
            end
        end     
    end
    runningTime = runningTime + delayAOM_MW;
    
    %config RO of the second signal
    Channels(2).addRise();
    Channels(2).setRiseParams(3,runningTime,laserPulse/2,'Rise',1,0,0,1);
    
    %Configure Counter
    Channels(1).addRise();
    Channels(1).setRiseParams(3,runningTime + delayDAQ_AOM,counterGate,'Counter',1,0,0,1);
       runningTime = runningTime + laserPulse/2 + delayMW_AOM;%here suppose MW width always 0 and get reference
    
    % while Channels(4).NumberOfRises < N_pi + 2
    %     Channels(4).addRise();
    % end
    %configure first pulse train, if corrTime = 0 this is the only pulse
    %train
    % for i = 1:Channels(4).NumberOfRises
    %     if i == 1 
    %         Channels(4).setRiseParams(i,runningTime,pi_2,'',RiseAmp,pi_2_phases(1),0,1);
    %         runningTime = runningTime + pi_2 + PulseSpacing;
    %     elseif i == Channels(4).NumberOfRises
    %         Channels(4).setRiseParams(i,runningTime + corrTime,pi_2,'sweep',RiseAmp,pi_2_phases(2),0,1);
    %         runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
    %     elseif i == 2
    %         Channels(4).setRiseParams(i,runningTime + corrTime,pi,'sweep',RiseAmp,phases(i),0,1);
    %         runningTime = runningTime + pi + PulseSpacing + corrTime;
    %     else
    %         Channels(4).setRiseParams(i,runningTime + corrTime*2,pi,'sweep',RiseAmp,phases(i),0,2);
    %         runningTime = runningTime + pi + PulseSpacing + corrTime*2;
    %     end
    % end
    %check if corrTime is non-zero, if it is add additional pulse train
    % if corrTime~=0
    %     while Channels(4).NumberOfRises < 2*N_pi + 4
    %         Channels(4).addRise();
    %     end
    % 
    %     for i = 1:Channels(4).NumberOfRises/2
    %         if i == 1 
    %             Channels(4).setRiseParams(i+ Channels(4).NumberOfRises/2,runningTime,pi_2,'corr',RiseAmp,pi_2_phases(1),0,1);
    %             runningTime = runningTime + pi_2 + PulseSpacing;
    %         elseif i == Channels(4).NumberOfRises/1
    %             Channels(4).setRiseParams(i + Channels(4).NumberOfRises/2,runningTime + corrTime,pi_2,'sweep',RiseAmp,pi_2_phases(2),0,1);
    %             runningTime = runningTime + pi_2 + PulseSpacing + corrTime;
    %         elseif i == 2
    %             Channels(4).setRiseParams(i + Channels(4).NumberOfRises/2,runningTime + corrTime,pi,'sweep',RiseAmp,phases(i),0,1);
    %             runningTime = runningTime + pi + PulseSpacing + corrTime;
    %         else
    %             Channels(4).setRiseParams(i + Channels(4).NumberOfRises/2,runningTime+corrTime*2,pi,'sweep',RiseAmp,phases(i),0,2);
    %             runningTime = runningTime + pi + PulseSpacing + corrTime*2;
    %         end
    %     end
    % end
    % Channels(4).addRise();
    % runningTime = runningTime+delayAOM_MW;
    % %Considering the delay between DAQ and AOM, the AOM off also delayed 
    % Channels(4).setRiseParams(Channels(4).NumberOfRises,runningTime,0,'End',1,0,0,1);
%     %Config 2st Ref
%     Channels(1).addRise();
%     Channels(1).setRiseParams(4,runningTime+laserPulse-2e-6,counterGate,'Counter',0,0,0,1);

    
    
end


function [Sweeps] = generateSweeps(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add)
    Sweeps = PulseSweep();
    Sweeps.setSweepParams(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add);
end

function [Groups] = generateGroups()
        Groups = PulseGroup();
end





