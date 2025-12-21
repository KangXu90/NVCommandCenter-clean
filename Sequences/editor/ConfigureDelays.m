
function [] = ConfigureDelays(varargin)

if nargin > 0,
    % called with PSeq
    PSeq = varargin{1};
    Channels = PSeq.Channels;
    for k=1:numel(Channels),
        On(k) = Channels(k).DelayOn;
        Off(k) = Channels(k).DelayOff;
        rownames{k} = ['Channel ',num2str(k)];
    end

else,
    Channels = [];
    On = [];
    Off = [];
end
    
hFig = figure();
cnames = {'Delay On','Delay Off'};



cedit(1:numel(cnames)) = true;

if ~isempty(On),
    dat = [On',Off'];
else,
    dat = zeros(2,2);
end

t1 = uitable('Data',dat,'ColumnName',cnames,...
            'RowName',rownames,...
            'ColumnEditable',cedit,...
            'CellEditCallback',@(evnt,src)cbCellEdit(evnt,src),...
            'Parent',hFig,'Position',[200 200 250 100]);
        
t2 = uicontrol('Style','pushbutton','String','Cancel',...
            'Callback',@(evnt,src)CloseIt(hFig),...
            'Parent',hFig,'Position',[200 100 50 20]);
        
        t3 = uicontrol('Style','pushbutton','String','Save',...
            'Callback',@(evnt,src)SaveIt(t1,Channels),...
            'Parent',hFig,'Position',[260 100 50 20]);
        
        
 
    function [] = cbCellEdit(evnt,src)
        
        % get the data from the table
        raw = get(evnt,'Data');
        for k=1:length(raw),
        end
        
    function [] = SaveIt(src,Channels)
        % set
        if ~isempty(Channels),
            % get data from table
            data = get(src,'Data');
            for k=1:length(data),
                Channels(k).DelayOn = data(k,1);
                Channels(k).DelayOff = data(k,2);
            end
        end
        h = get(src,'Parent');
        close(h);
        
        
        function [] = CloseIt(hFig)
            close(hFig);
            
        