classdef TrackerMIT < Tracker
    
    properties
        LaserControlLine
        ZController = 'Piezo';
        
        %Correct X/Y for movement with Z
        ZCorrection = [0 0];
    end
    
   methods
        function [obj] = TrackerMIT()
            addlistener(obj,'TrackerAbort',@(src,evnt)obj.setAbort);
        end
        
        function [counts] = GetCountsCurPos(obj)
            
            % next do the counter acquisition
           	obj.hCounterAcquisition.GetCountsPerSecond();
            counts = obj.hCounterAcquisition.CountsPerSecond();
         end
        
        function [counts] = GetCountsAtPos(obj,Pos)
            
            obj.hImageAcquisition.CursorPosition = Pos;
            obj.hImageAcquisition.SetCursor();
            [counts] = obj.GetCountsCurPos();
        end
        
        function [] = laserOn(obj)
            %Setup the laser line on the AWG and start the AWG
            obj.hwLaserController.setLines(1,obj.LaserControlLine);
            obj.hwLaserController.start();
            % Wait for the AWG to start
            obj.hwLaserController.hwHandle.OPCCheck();
        end
        
        function [] = laserOff(obj)
            obj.hwLaserController.setLines(0,obj.LaserControlLine);
            obj.hwLaserController.stop();
        end
        
        function [] = trackCenter(obj,needLaser)
            
                %Make sure we are using correct ZController
                curZController = obj.hImageAcquisition.ZController;
                obj.hImageAcquisition.ZController = obj.ZController;
                switch(obj.hImageAcquisition.ZController)
                    case 'Motor'
                        obj.hImageAcquisition.CursorPosition(3) =  obj.hImageAcquisition.interfaceAPTMotor.getPosition();
                    case 'Piezo'
                        obj.hImageAcquisition.CursorPosition(3) =  obj.hImageAcquisition.interfacePiezo.GetCurrentPosition();
                end
                         

                % turn laser on for tracking if we need to
                if(exist('needLaser','var'))
                    if(needLaser)
                        obj.laserOn();
                    end
                else
                    obj.laserOn();
                end
                
                % set up initial step sizes
                obj.CurrentStepSize = obj.InitialStepSize;

                % setup local vars
                iterCounter = 0;

                % get current position from ImageAcquistion
                Pos = obj.hImageAcquisition.CursorPosition;

                StepXMin = obj.MinimumStepSize(1);
                StepYMin = obj.MinimumStepSize(2);
                StepZMin = obj.MinimumStepSize(3);

                % main while loop for tracking center logic
                % as long as we haven't aborted or iterated too much or took
                % too small of a step, keep taking gradients and maximize the
                % counts

                while (~obj.hasAborted && (iterCounter < obj.MaxIterations) && (obj.CurrentStepSize(1) > StepXMin) && ...
                    (obj.CurrentStepSize(2) > StepYMin) && (obj.CurrentStepSize(3) > StepZMin) &&~obj.hasAborted )

                    % define local vars
                    PosX = Pos(1);
                    PosY = Pos(2);
                    PosZ = Pos(3);

                    %iterate the counter
                    iterCounter = iterCounter + 1;

                    % setup the nearest neighbor points
                    Nearest(1,:) = [PosX,PosY,PosZ] + [0,0,0];
                    Nearest(2,:) = [PosX,PosY,PosZ] + [obj.CurrentStepSize(1),0,0];
                    Nearest(3,:) = [PosX,PosY,PosZ] + [-obj.CurrentStepSize(1),0,0];
                    Nearest(4,:) = [PosX,PosY,PosZ] + [0,obj.CurrentStepSize(2),0];
                    Nearest(5,:) = [PosX,PosY,PosZ] + [0,-obj.CurrentStepSize(2),0];
                    Nearest(6,:) = [PosX,PosY,PosZ] + [0,0,obj.CurrentStepSize(3)];
                    Nearest(7,:) = [PosX,PosY,PosZ] + [0,0,-obj.CurrentStepSize(3)];

                    %Correct for X/Y movement with Z
                    Nearest(6,1:2) = Nearest(6,1:2) + obj.ZCorrection*obj.CurrentStepSize(3);
                    Nearest(7,1:2) = Nearest(7,1:2) - obj.ZCorrection*obj.CurrentStepSize(3);
                    
                    % check to see if any of the nearest points are over max.
                    % allowed positions
                    if (any(Nearest(:,1)>obj.MaxCursorPosition(1)) || any(Nearest(:,2)>obj.MaxCursorPosition(2)) ...
                            || any(Nearest(:,3)>obj.MaxCursorPosition(3)))
                        warning('Position over allowed max');
                        break;
                    end
                    if (any(Nearest(:,1)<obj.MinCursorPosition(1)) || any(Nearest(:,2)<obj.MinCursorPosition(2)) ...
                            || any(Nearest(:,3)<obj.MinCursorPosition(3)))
                        warning('Position over allowed min');
                        break;
                    end

                    % iterate though the NN points, getting counts
                    for k=1:7,
                        NNCounts(k) =  GetCountsAtPos(obj,Nearest(k,:));
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
                           posMove = G/norm(G).*obj.CurrentStepSize;
                           %Correct for X/Y movement with Z
                           posMove(1:2) = posMove(1:2) + obj.ZCorrection*posMove(3);
                           Pos = Pos + posMove;
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
                    obj.hImageAcquisition.CursorPosition = [PosX,PosY,PosZ];
                    obj.hImageAcquisition.SetCursor();
                end
                
                if(exist('needLaser','var'))
                    if(needLaser)
                        obj.laserOff();
                    end
                else
                    obj.laserOff();
                end
                
                %Return to previous Z controller
                obj.hImageAcquisition.ZController = curZController;
 
        end % trackCenter
        
        function setAbort(obj,evnt)
            obj.hasAborted = 1;
        end
        
   end
    
   events
       TrackerCountsUpdated
       StepSizeReduced
       PositionUpdated
       TrackerAbort
   end
end