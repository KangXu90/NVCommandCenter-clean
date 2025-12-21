function [ind] = incr(ind,maxind)

% set curdim to right most index
curdim = numel(ind);

[ind] = recur(ind,curdim,maxind);
end

function [ind] = recur(ind,curdim,maxind);
if curdim < 1,
    ind = zeros(size(ind));
    return
elseif ind(curdim) < maxind(curdim)
    ind(curdim) = ind(curdim) + 1;
    for k=curdim+1:numel(ind),
        ind(k) = 1;
    end
    return;
elseif ind(curdim) == maxind(curdim),
    [ind] = recur(ind,curdim-1,maxind);
end
end
    