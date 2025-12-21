function root = projectRoot()
% projectRoot  Return NVCommandCenter project root folder.
% Works regardless of current working directory.

here = fileparts(mfilename('fullpath'));  % .../config
root = fileparts(here);                   % default: parent of config

% If user moved this file, climb upward to find a marker file.
marker = 'startup_minimal.m';
maxUp = 6;
cur = root;

for k = 1:maxUp
    if exist(fullfile(cur, marker), 'file') == 2
        root = cur;
        return;
    end
    parent = fileparts(cur);
    if strcmp(parent, cur)
        break;
    end
    cur = parent;
end

% fallback: return parent of this config folder
root = fileparts(here);
end
