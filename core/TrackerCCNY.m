% This is the version used by NVCommandCenter (Fer 2021-11)
classdef TrackerCCNY < Tracker
    
    properties
        LaserControlLine
        ZController = 'Piezo';
        TargetList
    end
    
   methods
        function [obj] = TrackerMIT()
            addlistener(obj,'TrackerAbort',@(src,evnt)obj.setAbort);
        end
        
        function [counts] = GetCountsCurPos(obj)
            
            % first turn on the laser
            obj.laserOn();

            % next do the counter acquisition
           	obj.hCounterAcquisition.GetCountsPerSecond();
            counts = obj.hCounterAcquisition.CountsPerSecond;
            
            
            % turn off the laser
            obj.laserOff();
        end
        
        function [counts] = GetCountsAtPos(obj,Pos)
            counts = 0;
            obj.hImageAcquisition.CursorPosition = Pos;
            obj.hImageAcquisition.SetCursor();

            [counts] = obj.GetCountsCurPos();
        end
        
        
        function [] = laserOn(obj)
            obj.hwLaserController.stop();
            obj.hwLaserController.setLines(1,obj.LaserControlLine);
            obj.hwLaserController.start();
        end
        
        function [] = laserOff(obj)
            obj.hwLaserController.stop();
            obj.hwLaserController.setLines(0,obj.LaserControlLine);
            obj.hwLaserController.start();
        end
        %First Attempt at Z Tracking, iterates through points from -.3 to
        %.3 at .1 steps,
        %gets the counts and position at each
        %point, and finds the maximum counts. It then sets the Z equal to
        %the corresponding position. This doubtfully the most effcient
        %Z Tracking.
%         function [] = ZTrack(obj)
%            
%             obj.ZTracking.initialize();
%             ZCounts = zeros(7,2);
%             i = 1;
%             CurrentPosition = obj.ZTracking.GetCurrentPosition();
%             obj.ZTracking.SetPosition(CurrentPosition - .6);
%             while(i<=7)
%                 
%                 ZCounts(i,1) = obj.GetCountsCurPos();
%                 ZCounts(i,2) = obj.ZTracking.GetCurrentPosition();
%                 obj.ZTracking.SetPosition(ZCounts(i,2) +.2);
%                 i = i + 1;
%                 
%             end
%             
%             [counts,index] = max(ZCounts(:,1));
%             disp(ZCounts);%outputs the Z information to the console
%             obj.ZTracking.SetPosition(ZCounts(index,2));%sets the Z position to the optimal value
%             
%             
%             obj.ZTracking.destroy();%closes communication with the PI
%         end
        
        function [newRefPoint] = trackCenter(obj,jumpPoint)
                
                %Make sure we are using correct ZController,
               % if use motor as z Controller (or xyz controller)
               %, could we used it to alignment the field?
                curZController = obj.hImageAcquisition.ZController;
                obj.hImageAcquisition.ZController = obj.ZController;
                switch(obj.hImageAcquisition.ZController)
                    case 'Motor'
                        obj.hImageAcquisition.CursorPosition(3) =  obj.hImageAcquisition.interfaceAPTMotor.getPosition();
                    case 'Piezo'
                        obj.hImageAcquisition.CursorPosition(3) =  obj.hImageAcquisition.interfacePiezo.GetCurrentPosition();
                end
           
                % set up initial step sizes
                obj.CurrentStepSize = obj.InitialStepSize;

                % setup local vars
                iterCounter = 0;

                % get current position from ImageAcquistion
               
                diffPos = obj.hImageAcquisition.CursorPosition(1:3) - jumpPoint;
                Pos = diffPos;

                StepXMin = obj.MinimumStepSize(1);
                StepYMin = obj.MinimumStepSize(2);
                StepZMin = obj.MinimumStepSize(3);

                % main while loop for tracking center logic
                % as long as we haven't aborted or iterated too much or took
                % too small of a step, keep taking gradients and maximize the
                % counts

                while (~obj.hasAborted && (iterCounter < obj.MaxIterations) && (obj.CurrentStepSize(1) > StepXMin) && ...
                        (obj.CurrentStepSize(2) > StepYMin) && (obj.CurrentStepSize(3) > StepZMin) &&~obj.hasAborted )
                    %                  while (~obj.hasAborted && (iterCounter < obj.MaxIterations) && (obj.CurrentStepSize(1) > StepXMin) && ...
                    %                         (obj.CurrentStepSize(2) > StepYMin))
                    % define local vars
                    PosX = Pos(1);
                    PosY = Pos(2);
                    PosZ = Pos(3);
                    
                    %iterate the counter
                    iterCounter = iterCounter + 1;
%                    obj.CurrentStepSize(1) = 0;
%                     obj.CurrentStepSize(2) = 0;
                    % setup the nearest neighbor points
                    % NOTE: FER'S EDITION 2021-11. All the *0.1 are
                    % introduced by me to reduce the step size:
                    Nearest(1,:) = [PosX,PosY,PosZ] + [0,0,0];
                    Nearest(2,:) = [PosX,PosY,PosZ] + [obj.CurrentStepSize(1),0,0];
                    Nearest(3,:) = [PosX,PosY,PosZ] + [-obj.CurrentStepSize(1),0,0];
                    Nearest(4,:) = [PosX,PosY,PosZ] + [0,obj.CurrentStepSize(2),0];
                    Nearest(5,:) = [PosX,PosY,PosZ] + [0,-obj.CurrentStepSize(2),0];
                    Nearest(6,:) = [PosX,PosY,PosZ] + [0,0,obj.CurrentStepSize(3)];% Daniela lmodified*0.5
                    Nearest(7,:) = [PosX,PosY,PosZ] + [0,0,-obj.CurrentStepSize(3)]; % Daniela *0.5
                    %                   Nearest(6,:) = [PosX,PosY,PosZ] + [0,0,0];% Daniela lmodified*0.5
                    %                   Nearest(7,:) = [PosX,PosY,PosZ] + [0,0,0]; % Daniela *0.5
                    
                    % check to see if any of the nearest points are over
                    % max.
                    % allowed positions
                    if (any(Nearest(:,1)>obj.MaxCursorPosition(1)) || any(Nearest(:,2)>obj.MaxCursorPosition(2)) ...
                            || any(Nearest(:,3)>obj.MaxCursorPosition(3)))
                        warning('Position over allowed max');
                        break;
                    end
                    if (any(Nearest(:,1)<obj.MinCursorPosition(1)) || any(Nearest(:,2)<obj.MinCursorPosition(2)) ...
                            || any(Nearest(:,3)<obj.MinCursorPosition(3)))
                        warning('Position below allowed min');
                        break;
                    end
                    NNCounts = zeros(1,7);
                    % iterate though the NN points, getting counts
                    for k=1:7
                        thisPos = Nearest(k,:);
                        NNCounts(k) =  GetCountsAtPos(obj,thisPos);
                        % NNCounts(k) =  GetCountsAtPos2D(obj,thisPos); % modified by kang to realize 2D scan
                    end
                    
                    % throw event that counts have been updated;
                    notify(obj,'TrackerCountsUpdated',TrackerEventData(NNCounts));
                    
                    % apply a threshold to the obtained NN counts
                    deltaNNCounts = NNCounts - NNCounts(1);
                    [Inds] = find( deltaNNCounts > obj.TrackingThreshold);
                    
                    % create a boolean vector of the points above the threshold
                    % only these are included in the gradient calcualtion
                    bThresh = zeros(1,7);
                    bThresh(Inds) = 1;
                    bThresh(2:5)=0; % by Kang 20240115 tracking only on z direnctions
                    %tracing commented by Daniela
                    
                    %                      add by kang to tracking only on x and y direnctions
                                         % bThresh(6) = 0;
                                         % bThresh(7) = 0;
                    
                    % 3D deformed to 1D steps
                    stepVec = [1 obj.CurrentStepSize(1),...
                        -obj.CurrentStepSize(1),obj.CurrentStepSize(2),-obj.CurrentStepSize(2),...
                        obj.CurrentStepSize(3),-obj.CurrentStepSize(3)];
                    
                    % calculate the Gradient Directions
                    gradVec = (deltaNNCounts./stepVec).*bThresh;
                   
                    % If no points greater than threshold, keep orginal reference
                    if  sum(bThresh)==0,
                        % If Ref. Position did not change, reduce the step sizes
                        obj.CurrentStepSize = obj.CurrentStepSize.*obj.StepReductionFactor;
                        notify(obj,'StepSizeReduced',TrackerEventData(obj.CurrentStepSize));
                    else % calculate the new maximum point, climb the hill
                        
                        % Update the reference position
                        G = [gradVec(2) + gradVec(3),gradVec(4)+gradVec(5),gradVec(6) + gradVec(7)];
                        
                        % seems to be a bug with G/norm(G) giving NaN, so check to make
                        % sure the numbers are non-zero
                        if norm(G) < 1e-8
                            
                        else
                            Pos = Pos + G/norm(G).*obj.CurrentStepSize;
                            notify(obj,'PositionUpdated',TrackerEventData(Pos));
                        end
                    end
                    
                end % main while loop
                
                
                if obj.hasAborted,
                    obj.hImageAcquisition.CursorPosition = Pos;
                    obj.hImageAcquisition.SetCursor();
                    obj.hasAborted = 0;
                else
                    % update Cursor to final tracked position
                    obj.hImageAcquisition.CursorPosition = [PosX,PosY,PosZ] + jumpPoint;
%                  
%                 
                    obj.hImageAcquisition.SetCursor(); % added by kang only tracking 2D

                end
                newRefPoint = [PosX,PosY,PosZ];
        end % trackCenter
        
        function setAbort(obj,evnt)
            obj.hasAborted = 1;
        end
        
        function [] = addTarget(obj,name,targetCoords)
            if(length(targetCoords) == 3)
                obj.TargetList = [obj.TargetList ; [targetCoords,name]];
            elseif(length(targetCoords) == 2)
                obj.TargetList = [obj.TargetList ; [targetCoords,0,name]];
            else
                errordlg('Coordinates are either only one number or more than three numbers.','Error in coordinates');
            end
            notify(obj,'TargetListUpdated');
        end
        
        function [] = removeTarget(obj,targetNumber)
            if(targetNumber > length(obj.TargetList) || targetNumber == 0)
                errordlg('Target does not exist','Error in deleting target');
            else
                obj.TargetList(targetNumber,:) = [];
            end
            notify(obj,'TargetListUpdated');
        end
        
        function [] = trackTarget(obj,targetNumber)
            
            initialTargetPosition = obj.TargetList(targetNumber,1:3);
            obj.hImageAcquisition.CursorPosition = initialTargetPosition;
            obj.hImageAcquisition.SetCursor();
            obj.trackCenter([0,0,0]);

            finalTargetPosition = obj.hImageAcquisition.CursorPosition;
            drift = finalTargetPosition - initialTargetPosition;
            targets = length(obj.TargetList(:,1));
            drift = repmat(drift, [targets,1]);
            obj.TargetList(:,1:3) = obj.TargetList(:,1:3) + drift;
            notify(obj,'TargetListUpdated');
        end
        
        function [] = goToTarget(obj,targetNumber)
            
            initialTargetPosition = obj.TargetList(targetNumber,1:3);
            obj.hImageAcquisition.CursorPosition = initialTargetPosition;
            obj.hImageAcquisition.SetCursor();
            notify(obj,'TargetListUpdated');
        end
        function [] = clearTargets(obj)
            
            obj.TargetList(:,:) = [];
            
            notify(obj,'TargetListUpdated');
        end
        function [] = adjustTargets(obj, targetNumber)
           
            targets = length(obj.TargetList(:,1));
            initialTargetPosition = obj.TargetList(targetNumber,1:3);
            finalTargetPosition = obj.hImageAcquisition.CursorPosition;
            drift = finalTargetPosition - initialTargetPosition;
            drift = repmat(drift, [targets,1]);
            obj.TargetList(:,1:3) = obj.TargetList(:,1:3) + drift;  
            notify(obj,'TargetListUpdated');
        end
        
        
   end
    
   events
       TrackerCountsUpdated
       StepSizeReduced
       PositionUpdated
       TrackerAbort
       TargetListUpdated
   end
end