function startup_minimal()
% startup_minimal  Add project folders to MATLAB path (clean + reproducible)

root = fileparts(mfilename('fullpath'));

t = tic;


% 1) Reset path to MATLAB default so you don't accidentally use old projects
restoredefaultpath;

dt_restore = toc(t);

t = tic;

% 2) Add only the folders you want (edit these names to match your project)
mustAdd = {
    fullfile(root,'app')
    fullfile(root,'core')
    fullfile(root,'ui')
    fullfile(root,'config')
    fullfile(root,'assets')
};

for k = 1:numel(mustAdd)
    if exist(mustAdd{k}, 'dir')
        addpath(mustAdd{k});
    end
end

% 3) Add recursively for code-heavy trees
recursiveAdd = {
    fullfile(root,'drivers')
    fullfile(root,'sequences')
};

for k = 1:numel(recursiveAdd)
    if exist(recursiveAdd{k}, 'dir')
        addpath(genpath(recursiveAdd{k}));
    end
end
dt_add = toc(t);


% 4) Remove folders you never want on path (optional but recommended)
%    e.g., huge .mat libraries, data, version-control metadata
removePatterns = {
    [filesep '.svn' filesep]
    [filesep '.git' filesep]
    [filesep 'sequence_library' filesep]
    [filesep 'data' filesep]
    [filesep 'archive' filesep]
};

p = strsplit(path, pathsep);
keep = true(size(p));
for i = 1:numel(p)
    for j = 1:numel(removePatterns)
        if contains(p{i}, removePatterns{j})
            keep(i) = false;
            break;
        end
    end
end
path(strjoin(p(keep), pathsep));

t = tic;

rehash;

dt_rehash = toc(t);


fprintf('[startup_minimal] Path set for project: %s\n', root);
end
