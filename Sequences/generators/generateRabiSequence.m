



function [PSeq,fn] = generateRabiSequence(start, stop, points, delayMW_AOM, delayDAQ_AOM,laserPulse,counterGate,script,seqName)

%      start = 0;
%      stop = 300e-9;
%      points = 61;
%      delayMW_AOM = 2e-6;
%      delayDAQ_AOM = 300e-9;
%    laserPulse = 20e-6;
%      counterGate = 0.3e-6;
% 
     

    Channels = generateChannels(delayMW_AOM, delayDAQ_AOM,laserPulse,counterGate);
    Groups = generateGroups();
    Channels(1,1).RiseFrequencies = [];
    Channels(1,2).RiseFrequencies = [];
    Channels(1,1).RiseSweepMultipliers = [1,1];
    Channels(1,2).RiseSweepMultipliers = [1,1];
    Channels(1,3).RiseSweepMultipliers = 1;
    Channels(1,4).RiseSweepMultipliers = [1,0];

    Sweeps = generateSweeps(3,'Type','Duration','MW',start,stop,points,2,1);%check the parameter

    PSeq = PulseSequence(Channels,[],Sweeps,0,seqName);%check the parameter
    
    PSeq.setMWHWChannel(3);
    if ~script
        [fn,fp] = uiputfile();
        fn = fullfile(fp,fn);
        save(fn,'PSeq');
    else
    end

end 

function[Channels] = generateChannels(delayMW_AOM, delayDAQ_AOM,laserPulse,counterGate)

  
      delayAOM_MW = 2e-6; %put a space after MW end and laser pulse start

% Initialize channels1
    Channels = [PulseChannel(),PulseChannel(),PulseChannel(),PulseChannel()];
    
    %set hw channels
    Channels(1).setHWChannel(2);
    Channels(2).setHWChannel(1);
    Channels(3).setHWChannel(3);
    Channels(4).setHWChannel(5);

    %configure AOM Initialization
    Channels(2).addRise();
    Channels(2).setRiseParams(1,0,laserPulse,'Rise',1,0,0,1); % changed from laserPulse/2
    Channels(1).addRise();
    %delayDAQ_AOM should be sweep to optimise, counterGate should also
    %sweep to optimise
    Channels(1).setRiseParams(1,delayDAQ_AOM,counterGate,'Counter',1,0,0,1);
    
    runningTime = laserPulse + delayMW_AOM;
    Channels(3).addRise();
    Channels(3).setRiseParams(1,runningTime,0e-9,'MW',0.1,0,0,1);% should check the Rabi config
   
    runningTime = runningTime + delayAOM_MW;
    %configure readout
    Channels(2).addRise();
    Channels(2).setRiseParams(2,runningTime,laserPulse,'Rise',1,0,0,1);
    %Configure Counter
    Channels(1).addRise();
    %delayDAQ_AOM should be sweep to optimise, counterGate should also
    %sweep to optimise
    Channels(1).setRiseParams(2,runningTime+delayDAQ_AOM,counterGate,'Counter',1,0,0,1); 
    runningTime = runningTime + laserPulse + delayMW_AOM;%here suppose MW width always 0 and get reference
    
    %config stop pulse
    Channels(4).addRise();
    %Considering the delay between DAQ and AOM, the AOM off also delayed 
    Channels(4).setRiseParams(1,runningTime,0,'MW',1,0,0,1);
    Channels(4).addRise();
    runningTime = runningTime+delayAOM_MW;
    %Considering the delay between DAQ and AOM, the AOM off also delayed 
    Channels(4).setRiseParams(2,runningTime,0,'End',1,0,0,1);
    
    %     %Configure Counter
    %     Channels(1).addRise();
%     Channels(1).setRiseParams(2,runningTime+delayDAQ_AOM,counterGate,'Counter',0,0,0,1);

    
end


function [Sweeps] = generateSweeps(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add)
    Sweeps = PulseSweep();
    Sweeps.setSweepParams(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add);
end

function [Groups] = generateGroups()
        Groups = PulseGroup();
end








