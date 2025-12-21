function [NewPS] = ExpandLoops(PSeq)

% get all the events
evnts = PSeq.CalculateEvents;

% get the groups for the pulse sequence
G = PSeq.Groups;

% create a clone of the pulse sequence.  We will update the clone

NewPS = PSeq.clone();


for k=1:numel(G),
    
    % get absolute times for start and stop events
    eventStartTime = evnts(G(k).StartEvent);
    eventEndTime = evnts(G(k).EndEvent);
    
    % loop over all the channels
    for jj=1:numel(PSeq.Channels),
        
        % get channel
        C = PSeq.Channels(jj);
        
        % find all the rises that occur between the start and end event
        % times
        
        beforeInds = find(C.RiseTimes < eventStartTime);
        loopInds = find((C.RiseTimes >= eventStartTime) & (C.RiseTimes < eventEndTime));
        afterInds = find(C.RiseTimes >= eventEndTime);
        

        % reset arrays
        NewPS.Channels(jj).RiseTimes = [];
        NewPS.Channels(jj).RiseDurations = [];
        NewPS.Channels(jj).RiseTypes = {};
        NewPS.Channels(jj).RiseAmplitudes  =[];
        NewPS.Channels(jj).RisePhases = [];
        
        % set before Inds to be the same
        NewPS.Channels(jj).RiseTimes(beforeInds) = PSeq.Channels(jj).RiseTimes(beforeInds);
        NewPS.Channels(jj).RiseDurations(beforeInds) = PSeq.Channels(jj).RiseDurations(beforeInds);
        NewPS.Channels(jj).RiseTypes(beforeInds) = PSeq.Channels(jj).RiseTypes(beforeInds);
        NewPS.Channels(jj).RiseAmplitudes(beforeInds) = PSeq.Channels(jj).RiseAmplitudes(beforeInds);
        NewPS.Channels(jj).RisePhases(beforeInds) = PSeq.Channels(jj).RisePhases(beforeInds);
        % now expand the loop
        for ll=1:G(k).Loops,
            len = length(NewPS.Channels(jj).RiseTimes);
            NewPS.Channels(jj).RiseTimes(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RiseTimes(loopInds) + (ll-1)*(eventEndTime-eventStartTime);
            NewPS.Channels(jj).RiseDurations(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RiseDurations(loopInds);
            NewPS.Channels(jj).RiseTypes(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RiseTypes(loopInds);
            NewPS.Channels(jj).RiseAmplitudes(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RiseAmplitudes(loopInds);
            NewPS.Channels(jj).RisePhases(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RisePhases(loopInds);
        end
        
        % now add the time to the after rises
        NewPS.Channels(jj).RiseTimes(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RiseTimes(afterInds) + (G(k).Loops - 1)*(eventEndTime - eventStartTime);
        NewPS.Channels(jj).RiseDurations(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RiseDurations(afterInds);
        NewPS.Channels(jj).RiseTypes(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RiseTypes(afterInds);
        NewPS.Channels(jj).RiseAmplitudes(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RiseAmplitudes(afterInds);
        NewPS.Channels(jj).RisePhases(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RisePhases(afterInds);
        
        % update the Number of Rise
        NewPS.Channels(jj).NumberOfRises = numel(NewPS.Channels(jj).RiseTimes);
    end
    
end

% expanded PS should not have any groups
NewPS.Groups = [];
for k=1:numel(NewPS.Listeners{3,:}),
    delete(NewPS.Listeners{3,k});
    NewPS.Listeners{3,k} = [];
end

