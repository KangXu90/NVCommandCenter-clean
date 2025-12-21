function [e] = GenerateEvents(P)

e = [];

for k=1:numel(P.Channels),
    for jj=1:P.Channels(k).NumberOfRises,
        l = length(e)
        e(l+1) = P.Channels(k).RiseTimes(jj);
        e(l+2) = e(l+1) + P.Channels(k).RiseDurations(jj);
    end
end

f = unique(e);
e = sort(f,'ascend');