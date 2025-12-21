function [varargout] = PulseSequencerFunctions(varargin)

action = varargin{1};


switch action
    case 'New'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        NewSequence(hObject,handles);
        handles = guidata(hObject);
        Init(hObject,handles,handles.PSeq);
    case 'Init'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        PSeq = handles.PSeq;
        Init(hObject,handles,PSeq);
    case 'DrawSequence'
        handles = varargin{4};
        PSeq = handles.PSeq;
        DrawSequence(handles.axes1,PSeq,[]);
        
    case 'AddChannel'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        handles.PSeq.addChannel();
        
    case 'DeleteChannel'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        DeleteChannel(handles);
        
   case 'AddRise'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
       AddRise(handles,handles.PSeq);
       
    case 'DeleteRise'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
       DeleteRise(handles,handles.PSeq);
       
    case 'AddGroup'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        handles.PSeq.addGroup();
        
    case 'SaveAs'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        [fn] = SaveAs(handles.PSeq);
        handles.filename = fn;
        guidata(hObject,handles);
        SetStatus(handles,sprintf('Saved PulseSequence %s',fn));
        
    case 'Save'

        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        if isfield(handles,'filename'),
            Save(handles.filename,handles.PSeq);
        else,
            [fn] = SaveAs(handles.PSeq);
            handles.filename = fn;
            guidata(hObject,handles);
            SetStatus(handles,sprintf('Saved PulseSequence %s',fn));
        end
        
    case 'Load'
        
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        [PSeq,fn,fp]  = Load();
        
        if fn ,
            handles.filename = fn;

            %replace copy with constructor
            handles.PSeq.copy(PSeq);
            handles.PSeq.SequenceName = fn;
            guidata(hObject,handles);

            set(handles.textSequence,'String',fn,'Tooltip',fullfile(fp,fn));
            Init(hObject,handles,handles.PSeq)
            SetStatus(handles,sprintf('Loaded PulseSequence %s',fn));
        else
            return;
        end
    
    case 'LoadExternal'
        
        [varargout{1},varargout{2},varargout{3}] = Load();
        return;
        
    case 'UpdateSelectedChannelPopup'
        
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        UpdateChannelRisePopup(handles,handles.PSeq);
        UpdateHWChannelPopup(handles,handles.PSeq);
        
    case 'UpdateSelectedGroupPopup'
        
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        UpdateGroupPopup(handles,handles.PSeq);
        
    case 'UpdateSelectedRise'
        
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        
        UpdateSelectedRise(handles,handles.PSeq);
    
    case 'UpdateRiseInput'
        
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        UpdateRiseInput(handles,handles.PSeq);
        
        % update selected rise after parsing input
        UpdateSelectedRise(handles,handles.PSeq);
        
    case 'UpdateGroupInput'
        
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        UpdateGroupInput(handles,handles.PSeq);
        
    case 'SetHWChannelPopup',
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        SetHWChannelPopup(handles,handles.PSeq);
        
    case 'DrawSequenceExternal'
        hAxes = varargin{2};
        PSeq = varargin{3};
        DrawSequence(hAxes,PSeq,[]);
        
    case 'ParseInput'
        input = varargin{2};
        [out] = ParseInput(input);
        varargout{1} = out;
        
    case 'PlaySweep'
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        PlaySweep(handles,handles.PSeq);
        
    case 'SliderPlay'
        
        hObject = varargin{2};
        eventdata = varargin{3};
        handles = varargin{4};
        
        SliderPlay(handles,handles.PSeq);
        
        
    case 'EventPSChangeState'
        hObject = varargin{4};
        handles = guidata(hObject);
        PSeq = handles.PSeq;
        hAxes = handles.axes1;
        
        
        DrawSequence(handles.axes1,PSeq,[]);
        
        UpdateChannelsPopup(handles.popupChannel,PSeq);
        
        UpdateChannelRisePopup(handles,PSeq);
        
        UpdateHWChannelPopup(handles,PSeq);
        
        UpdateGroups(handles,PSeq);
        
        UpdatePulseEvents(handles,PSeq);
        
        UpdateSweepSlider(handles,PSeq);

end

function Init(hObject,handles,PSeq)

% Draw the pulse sequence
DrawSequence(handles.axes1,handles.PSeq,[]);

% fill up the pulldown menus
UpdateChannelsPopup(handles.popupChannel,PSeq)

UpdateChannelRisePopup(handles,PSeq);

UpdateHWChannlesPopup(handles);

UpdateGroups(handles,PSeq);

UpdatePulseEvents(handles,PSeq);

UpdateSweepSlider(handles,PSeq);

handles.listener = addlistener(handles.PSeq,'PulseSeqeunceChangedState',@(src,evnt)PulseSequencerFunctions('EventPSChangeState',src,evnt,hObject));
guidata(hObject,handles);


%LoadIcons(handles)
function UpdateHWChannlesPopup(handles)

   z = [0:31];
   set(handles.popupHWChannel,'String',z);

function DrawSequence(hAxes,PSeq,options)

    if isempty(options),
        options.showTypes = 0;
        options.showTimes = 0;
        options.verticalSpacing = 1.5;
        options.xRes = 100;
    end
    
    % if there are no channels to plot, return
    if numel(PSeq.Channels)== 0, cla(hAxes); return; end
    
    % use HSV colormap
    Colors = hsv(numel(PSeq.Channels));
    
    % Get Scaling
    [ScaleT, ScaleStr] = GetScale(PSeq.GetMaxRiseTime());
    
    tmin = PSeq.GetMinRiseTime();
    tmax = PSeq.GetMaxRiseTime();
    
    % scale the y-axis
    ymin = -0.5;
    ymax = options.verticalSpacing*numel(PSeq.Channels);
    
    % clear the axes before replotting
    cla(hAxes);
    
    % loop over all Pulse Channels
    for ichn = numel(PSeq.Channels):-1:1

            % set high and low line values for the channel
            yLow = (ichn -1)*options.verticalSpacing ;
            yHigh = (ichn -1)*options.verticalSpacing  + 1;
            
            % set horizontal spacing
            s = linspace(0,1,options.xRes);
            
            one = ones(size(s));
            t0 = tmin;
            hold(hAxes,'on');
            xlim(hAxes,'auto');

        % code from Jero's DrawSequence function
        yH = 0;
        for irise = 1:PSeq.Channels(ichn).NumberOfRises %PLOT each rise
            t1 = PSeq.Channels(ichn).RiseTimes(irise);
            dt = PSeq.Channels(ichn).RiseDurations(irise);
            height = PSeq.Channels(ichn).RiseAmplitudes(irise);
            t2 = t1 + dt;
            xL = t0 + (t1-t0)*s;
            yL = yLow*one;
            xLH = t1*one;
            yLH = yLow + (yHigh - yLow)*s;
            xH = t1 + (t2-t1)*s;
            yH = yL + height*one;
            xHL = t2*one;
            yHL = yHigh + (yLow - yHigh)*s;
            plot(hAxes,ScaleT*[xL xLH xH xHL],[yL yLH yH yHL],'Color',Colors(ichn,:));
            t0 = t2;
            if options.showTimes
                text(ScaleT*xLH,(yL+yH)/2,...
                    [' (' NiceNotation(xHL(1)-xLH(1)) ', ' NiceNotation(xLH(1)) ')'],'FontSize',8,'Parent',hAxes);
            end
            if options.showTypes
                text(ScaleT*xLH,yH+0.2, PSeq.Channels(ichn).RiseTypes(irise),'FontSize',8,'Parent',hAxes);
            end
        end
        
        if yH > 0, % conditional statement will only plot if there is something to plot
            xL = t2 + (tmax-t2)*s;
            yL = yLow*one;
            plot(hAxes,ScaleT*xL,yL,'Color',Colors(ichn,:));
            %hold(hAxes,'off');
            text(ScaleT*(tmin+0.01*(tmax-tmin)),yLow-.25,sprintf('HW Channel:%d',PSeq.Channels(ichn).HWChannel),'Color',Colors(ichn,:),'Parent',hAxes);
            xlabel(hAxes,ScaleStr);
        else
            % plot a flat line
            plot(hAxes,ScaleT*[tmin tmax],[yLow yLow],'Color',Colors(ichn,:));
            text(ScaleT*(tmin+0.01*(tmax-tmin)),yLow-.25,sprintf('HW Channel:%d',PSeq.Channels(ichn).HWChannel),'Color',Colors(ichn,:),'Parent',hAxes);
        end
    end
    
    % plot Groups
    for k=1:numel(PSeq.Groups)
       evnts = PSeq.CalculateEvents();
       sev = PSeq.Groups(k).StartEvent;
       eev = PSeq.Groups(k).EndEvent;
       
       if eev > sev,
          h = rectangle('Position', [evnts(sev)*ScaleT,ymin+0.25,(evnts(eev)-evnts(sev))*ScaleT,ymax],'LineStyle',':','LineWidth',0.25,'EdgeColor','black');
          h2 = text(evnts(eev)*ScaleT+0.1   ,ymax-0.25,sprintf('x%d',PSeq.Groups(k).Loops));
          h3 = text((evnts(sev) + (evnts(eev)-evnts(sev))/2)*ScaleT+0.1 ,ymax-.1,PSeq.Groups(k).Name,'FontSize',8,'HorizontalAlignment','Center');
       end
    end

    if abs(tmax - tmin) < 1e14,
        xlim(hAxes,ScaleT*[tmin tmax]);
    end
    ylim(hAxes,[ymin ymax]);

    
function [] = UpdateChannelsPopup(hPop,PSeq)
    selected = get(hPop,'Value');
    s = {'Channel N'};
    for k=1:numel(PSeq.Channels),
        s{k+1} = ['Channel ',num2str(k)];
    end
    set(hPop,'String',s);
	
    if numel(PSeq.Channels) == 0,
        selected = 1;
    elseif selected > numel(PSeq.Channels)+1,
        selected = numel(PSeq.Channels)+1;
    end
    
    
    set(hPop,'Value',selected);

function UpdateGroups(handles,PSeq)
    selected = get(handles.popupGroups,'Value');
    s = {'Channel N'};
    for k=1:numel(PSeq.Groups),
        s{k+1} = ['Group ',num2str(k),': ',PSeq.Groups(k).Name];
    end
    set(handles.popupGroups,'String',s);
    
    if numel(PSeq.Groups) == 0,
        selected = 1;
    elseif selected > numel(PSeq.Groups) + 1,
        selected = numel(PSeq.Groups)+1;
    end
    
    set(handles.popupGroups,'Value',selected);

    
function UpdatePulseEvents(handles,PSeq)
    e = PSeq.CalculateEvents();
    
    if numel(e) < 1,

        s = '0';
        set(handles.popupStartEvent,'String',s);
        set(handles.popupEndEvent,'String',s);
        set(handles.popupStartEvent,'Value',1);
        set(handles.popupEndEvent,'Value',1);
    else
        s ={};
        for k=1:length(e),
            s{k} = num2str(k);
        end

        set(handles.popupStartEvent,'String',s);
        set(handles.popupEndEvent,'String',s);
    end

function UpdateSweepSlider(handles,PSeq)
    
    if numel(PSeq.Sweeps),
        pts = PSeq.Sweeps(1).SweepPoints;
        set(handles.sliderSweeps,'Min',1,'Max',pts,'Value',1);
    end
    
    
function [ScaleT, ScaleStr] = GetScale(tmax)
if tmax >= 0 & tmax <= 100e-12
    ScaleT = 1e12;
    ScaleStr = 'ps';
elseif tmax > 100e-12 & tmax <= 100e-9
    ScaleT = 1e9;
    ScaleStr = 'ns';
elseif tmax > 100e-9 & tmax <= 100e-6
    ScaleT = 1e6;
    ScaleStr = 'us';
elseif tmax > 100e-6 & tmax <= 100e-3
    ScaleT = 1e3;
    ScaleStr = 'ms';
elseif tmax > 100e-3 & tmax <= 100
    ScaleT = 1;
    ScaleStr = 's';
end

function [] = UpdateGroupPopup(handles,PSeq)
        % get the selected channel
        % subtract 1 since the "Channel N" is always the first element of
        % the popup
        Group = get(handles.popupGroups,'Value') - 1;
        
        % set Hardware Channel
        if Group > 0,
        
            G = PSeq.Groups(Group);

            set(handles.editGroupName,'String',G.Name);
            set(handles.editLoop,'String',num2str(G.Loops));
            
            if G.StartEvent,
                set(handles.popupStartEvent,'Value',G.StartEvent);
            else
                set(handles.popupStartEvent,'Value',1);
            end
            if G.EndEvent,
                set(handles.popupEndEvent,'Value',G.EndEvent);
            else
                set(handles.popupEndEvent,'Value',1);
            end
            
        else
        end

function [] = UpdateChannelRisePopup(handles,PSeq)
        % get the selected channel
        % subtract 1 since the "Channel N" is always the first element of
        % the popup
        Channel = get(handles.popupChannel,'Value') - 1;
        
        S{1} = 'Rise N';
        set(handles.Rise1,'String',S);

        % set Hardware Channel
        if Channel > 0,
        
            PC = PSeq.Channels(Channel);


            for k=1:PC.NumberOfRises,
                S{end+1} = num2str(k);
            end;
            set(handles.Rise1,'String',S);
            set(handles.Rise1,'Value',length(S));
        else,
            set(handles.Rise1,'Value',1);
        end
        
function [] = DeleteChannel(handles)
    
        % get the selected channel
        % subtract 1 since the "Channel N" is always the first element of
        % the popup
        Channel = get(handles.popupChannel,'Value') - 1;
        
        if Channel > 0,
            handles.PSeq.deleteChannel(Channel);
        end
        
function [] = UpdateRiseGUIData(handles,PSeq)

        % get the selected channel
        % subtract 1 since the "Channel N" is always the first element of
        % the popup
        Channel = get(handles.popupChannel,'Value') - 1;
        
        % get the selected rise
        % subtract 1 since "Rise N" is always the first element of popup
        Rise = get(handles.Rise1,'Value')-1;
        
        
        % set Hardware Channel
        if Channel > 0,
            PC = PulseSequence.Channels(Channel);

            S{1} = 'Rise N';
            for k=1:PC.NumberOfRises,
                S{end+1} = num2str(k);
            end;
            set(handles.Rise1,'String',S);
        end


    function [] = AddRise(handles,PSeq)
        
        % get the selected channel
        % subtract 1 since the "Channel N" is always the first element of
        % the popup
        chn = get(handles.popupChannel,'Value') - 1;
        if chn > 0,
            PSeq.addRiseToChannel(chn);
        end
        
    function [] = DeleteRise(handles,PSeq)
        
        % get the selected channel
        % subtract 1 since the "Channel N" is always the first element of
        % the popup
        chn = get(handles.popupChannel,'Value') - 1;
        rise = get(handles.Rise1,'Value') - 1;
        
        % shift
        bShift = get(handles.cbShift,'Value');
        
        if chn > 0 && rise > 0,
            PSeq.deleteRiseFromChannel(chn,rise,bShift);
        end
        
        
    function [] = LoadIcons(handles)


        [cdata,map] = imread('icons/16-circle-blue-add.png','png');
        handles.icons.addRise = ind2rgb(cdata,map);
        set(handles.AddRiseN1,'CData',handles.icons.addRise);

        
 function [] = UpdateSelectedRise(handles,PSeq)
            
        chn = get(handles.popupChannel,'Value') - 1;
        if chn > 0,
            
            rise = get(handles.Rise1,'Value') - 1;
        
            if rise > 0,
                
                % update the gui information
                C = PSeq.Channels(chn);
                T = C.RiseTimes(rise);
                DT = C.RiseDurations(rise);
                Type = C.RiseTypes{rise};
                Amp = C.RiseAmplitudes(rise);
                Ph = C.RisePhases(rise);
                Sm = C.RiseSweepMultipliers(rise);
                
                set(handles.editT,'String',sprintf('%.8g',T));
                set(handles.editDT,'String',sprintf('%.8g',DT));
                set(handles.editType,'String',Type);
                set(handles.editAmplitude,'String',sprintf('%.8g',Amp));
                set(handles.editPhase,'String',sprintf('%3.4f',Ph));
                set(handles.editSweepMulti,'String',sprintf('%.8g',Sm));
            end
        end
        
     function [] = UpdateRiseInput(handles,PSeq)
         
      s = get(handles.editT,'String');
      T = ParseInput(s);
      
      s = get(handles.editDT,'String');
      DT = ParseInput(s);
      
      
      s = get(handles.editType,'String');
      Type = s;
      
      
      s = get(handles.editAmplitude,'String');
      Amp = ParseInput(s);
      
      
      
      s = get(handles.editPhase,'String');
      Ph = ParseInput(s);
      
      s = get(handles.editSweepMulti,'String');
      SM = ParseInput(s);
         
      chn = get(handles.popupChannel,'Value') - 1;
        if chn > 0,
            
            rise = get(handles.Rise1,'Value') - 1;
        
            if rise > 0,
                PSeq.Channels(chn).setRiseParams(rise,T,DT,Type,Amp,Ph,0,SM);
            end
        end
        
         function [out] = ParseInput(s)
             
             
             % try to match a string in the form of %XXX.YYYn
             RESTRING1 = '(\d*)\.(\d*)([smun])$';
             [a,b] = regexp(s,RESTRING1,'tokens','match');
             
             % try to match as %XXXXn%
             RESTRING2 = '(\d*)([smun])$';
             [a2,b] = regexp(s,RESTRING2,'tokens','match');
             
             % try to match scientific notation
             RESTRING3 = '(\d*)\.(\d*)[eE][+-](\d*)';
             [a3] = regexp(s,RESTRING3);
             
             RESTRING4 = '(\d*)[eE][+-](\d*)';
             [a4] = regexp(s,RESTRING4);
             
             RESTRING5 = '(\d*)\.(\d*)';
             % try to match decimal
             [a5] = regexp(s,RESTRING5);
             
             
             if length(a),
                 temp = eval([a{1}{1},'.',a{1}{2}]);
                 switch a{1}{3},
                     case 'n'
                         temp = temp*1e-9;
                     case 'u'
                         temp = temp*1e-6;
                     case 'm'
                         temp = temp*1e-3;
                     case 's'
                         temp = temp;
                     otherwise
                         temp = temp*1e-9
                 end
             elseif length(a2),
                 temp = str2num(a2{1}{1});
                 switch a2{1}{2},
                     case 'n'
                         temp = temp*1e-9;
                     case 'u'
                         temp = temp*1e-6;
                     case 'm'
                         temp = temp*1e-3;
                     case 's'
                         temp = temp;
                     otherwise
                         temp = temp*1e-9
                 end
             elseif a3,
                 temp = str2num(s);
             elseif a4,
                 temp = str2num(s);
             elseif a5,
                 temp = str2num(s);
             else,
                 temp = str2num(s);
             end
             
             out = temp;
             
               
function [fn] = SaveAs(PSeq)
    
    [fn,fp] = uiputfile();
    fn = fullfile(fp,fn);
    Save(fn,PSeq);

    
function [] = Save(file,PSeq);
        
    save(file,'PSeq');

    
function [PSeq,fn,fp] = Load()
        
    PSeq = PulseSequence();
    
     if ispref('nv','SavedSequenceDirectory'),
         fp = getpref('nv','SavedSequenceDirectory');
     else
         fp = pwd;
     end
     
     [fn,fp] = uigetfile('.mat','Select PulseSequence File:');
     if fn,
         Q = load(fullfile(fp,fn));
         PSeq = Q.PSeq;
     else
         return;
     end
     
function SetHWChannelPopup(handles,PSeq)
             
      chn = get(handles.popupChannel,'Value') - 1;
      hwchn = get(handles.popupHWChannel,'Value') - 1;

      
        if chn > 0,
            
            rise = get(handles.Rise1,'Value') - 1;
        
            if rise > 0,

                PSeq.Channels(chn).setHWChannel(hwchn);
            end
        end
        
function UpdateGroupInput(handles,PSeq)
         
      se = get(handles.popupStartEvent,'Value');
      ee = get(handles.popupEndEvent,'Value');
      name = get(handles.editGroupName,'String');
      loops = get(handles.editLoop,'String');
      loops = str2num(loops);
         
      grp = get(handles.popupGroups,'Value') - 1;
        if grp > 0
                PSeq.Groups(grp).setGroupProperties(name,se,ee,loops);
        end
        
function UpdateHWChannelPopup(handles,PSeq)

        Channel = get(handles.popupChannel,'Value') - 1;
        
        
        % set Hardware Channel
        if Channel > 0,
        
            hwc = PSeq.Channels(Channel).HWChannel;
            
            set(handles.popupHWChannel,'Value',hwc+1);
        end
        
        
function SetStatus(handles,statusText)
set(handles.textStatus,'String',statusText);

function NewSequence(hObject,handles)
    
    handles.PSeq = PulseSequence();
    guidata(hObject,handles);
    
function PlaySweep(handles,PSeq)
    
    % clone the PS
    playPS = PSeq.clone();
    
    % Reset Sweep Index
    playPS.SweepIndex = 1;
            
            while playPS.getSweepIndex > 0,
                
                [BinarySequence,tempSequence,AWGPSeq] = ProcessPulseSequence(playPS,1e9); % 1GHz fake clock rate
                
                DrawSequence(handles.axes1,tempSequence,[]);
                
                pause(0.5);
                
                playPS.incrementSweepIndex();
                
            end
            
function SliderPlay(handles,PSeq)
    
    sliderVal = get(handles.sliderSweeps,'Value');
    playPS = PSeq.clone();
    playPS.SweepIndex = ceil(sliderVal);
    [BinarySequence,tempSequence] = ProcessPulseSequence(playPS,1e9); % 1GHz fake clock rate
    DrawSequence(handles.axes1,tempSequence,[]);
                
    


