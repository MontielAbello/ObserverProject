%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Simulation of range measurements of rigid bodies and cube state observer
%Author: Montiel Abello
%Email:  montiel.abello@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Low level stuff
close all
clear all
folderpath = pwd;
addpath(genpath(folderpath))
if isempty(gcp('nocreate'))   
    parpool('local',8) %no. of parallel threads
end
%% 2. Initialisation
%settings = 'default'; %can specify here or in loadsettings file
[io,config,switchupdatestate,settings] = loadsettings();
%folder names
if io.saveMeas; mkdir(fullfile('data\simulated',io.nameMeas)); end
if io.saveRes;  mkdir(fullfile('data\results',io.nameRes));    end
if ~io.loadRes %NOT LOADING FULL WORKSPACE 
if ~io.loadMeas %NOT LOADING MEASUREMENTS
tic
[Sensor,simulationLength,dt] = initialisesensor(config);  
Environment = initialiseenvironment(config,simulationLength,dt);
Observer = initialiseobserver(config.observerInitial,simulationLength);
observingObject = config.observingObject;
t = 0:dt:(simulationLength-1)*dt; 
t1  = toc; str = sprintf('initialisation: %.2fs',t1); disp(str);
%% class property assignment
Strajectory      = Sensor.trajectory;   
SspinDirection   = Sensor.spinDirection;
SscanAngles      = Sensor.scanAngles;
SscanDirections  = Sensor.scanDirections;
SscanStart       = Sensor.scanStart;
SscanEnd         = Sensor.scanEnd;
SrangesTrue      = Sensor.rangesTrue;
SincidenceAngles = Sensor.incidenceAngles;
SiTriangleHit    = Sensor.iTriangleHit;
EpointsPath      = Environment.pointsPath;
Etriangles       = Environment.triangles;
%% 3. Parallel simulation loop
tic
parfor ii = 1:simulationLength
    if SscanAngles(ii) >= SscanStart*SspinDirection...
           && SscanAngles(ii) <= SscanEnd*SspinDirection
            % calculate range
            [intersect,range,incidenceAngle,iHit] = computerangemex(Strajectory(1:3,ii)',...
                                                                    SscanDirections(:,ii)',...
                                                                    EpointsPath(:,:,ii)',...
                                                                    Etriangles);    
            SrangesTrue(ii)      = range;
            SincidenceAngles(ii) = incidenceAngle; 
            SiTriangleHit(ii)    = iHit;
    end %endif    
end %end parfor
t2 = toc; str = sprintf('computing ranges: %.2fs',t2); disp(str);
%% class property update
Sensor.rangesTrue      = SrangesTrue;
Sensor.incidenceAngles = SincidenceAngles;
Sensor.iTriangleHit    = SiTriangleHit;
%% 4. Add noise
if config.noise
    tic
    Sensor.incidenceAngles = wrapToPi(Sensor.incidenceAngles);
    Sensor.objectHitSurfaceProperties = findsurfaceproperties(Sensor.iTriangleHit,...
                                                              Environment.triangles2Object,...
                                                              Environment.surfaceProperties);
    Sensor.rangesMeasured = addnoise(Sensor,config.sensorType,simulationLength,config.nScans,config.movement);
    t3 = toc; str = sprintf('simulating noise: %.2fs',t3); disp(str);
else
    Sensor.rangesMeasured = Sensor.rangesTrue;
end
else %if ~io.loadMeas
    configCurrent = config;
    clearvars -except io configCurrent
    load(io.fileMeas);
    config = configCurrent;
    Observer = initialiseobserver(config.observerInitial,simulationLength);
end %if ~io.loadMeas
if io.saveMeas
    save(fullfile('data\simulated',io.nameMeas,'simdata.mat'),'-regexp','^(?!(io)$).') %save all except io
end
%% 5. Observer simulation loop
%isolate target measurements from background
Sensor.rangesMeasuredTarget = Sensor.rangesMeasured;
observingObjectVector       = zeros(1,simulationLength);
observingObjectVector(1)    = observingObject;
if config.observer
    tic
    Observer.pointsPathEstimated(:,:,1) = initialisepoints(config.observerInitial.p0,...
                                                           config.observerInitial.R0,...
                                                           config.observerInitial.s0);
    for ii = 1:simulationLength-1
        % 5.1. state estimate
            %*add switch case for frames
            %pass config.observerTwistWrenchFrames as input
        Observer.stateEstimated(:,ii+1) = estimatestate(Observer.stateEstimated(:,ii),config.observerTwistWrenchFrames,dt);
        % 5.2. measurement prediction
        if (SscanAngles(ii) >= SscanStart*SspinDirection) && (SscanAngles(ii) <= SscanEnd*SspinDirection)
            %5.3. compute range
            [intersect,range,incidenceAngle,iHit] =  computerangemex(Sensor.trajectory(1:3,ii)',...
                                                                     Sensor.scanDirections(:,ii)',...
                                                                     Observer.pointsPathEstimated(:,:,ii)',...
                                                                     Observer.triangles);  
            Observer.rangesPredicted(ii) = range;
            % 5.4. check if observing object
            switch config.triggerMethod
                case 'difference'
                    if abs(diff(Sensor.rangesMeasured(ii:ii+1))) > config.differenceTrigger
                        observingObject = mod(observingObject+1,2);
                    end
                case 'range'
                    if Sensor.rangesMeasured(ii+1) > config.rangeTrigger
                        observingObject = 0;
                    else
                        observingObject = 1;
                    end
            end %switch           
            observingObjectVector(ii+1) = observingObject; %*should this be ii+1 or ii????
            if observingObject == 0
                Sensor.rangesMeasuredTarget(ii+1) = NaN;
            end
            % 5.5. state update
            if observingObject && (ii > Sensor.nSteps+1)
                iiInput = [ii ii-1 ii-Sensor.nSteps ii-1-Sensor.nSteps];
                Observer.stateEstimated(:,ii+1) = switchupdatestate(Observer.stateEstimated(:,ii+1),...%should this start ii+1 or ii???
                                                                    Observer.rangesPredicted(iiInput),...
                                                                    Sensor.rangesMeasuredTarget(iiInput),...
                                                                    Sensor.scanDirections(:,iiInput),config);
            end %if observingObject...
        end %if ScanAngles...
        % 5.6. update object points
        Observer.pointsPathEstimated(:,:,ii+1) = initialisepoints(Observer.stateEstimated{1,ii+1}(1:3,4),...
                                                                  Observer.stateEstimated{1,ii+1}(1:3,1:3),...
                                                                  Observer.stateEstimated{4,ii+1});
        
    end %for ii = 1:simulationLength-1
    t4 = toc; str = sprintf('observer: %.2fs',t4); disp(str);    
end %if config.observer
%% 6. Post processing
tic
% 6.1. ranges -> points
coordinatesTrue     = ranges2Points(Sensor.rangesTrue,Sensor.trajectory,Sensor.scanAngles,Sensor.startDirection,simulationLength);
coordinatesMeasured = ranges2Points(Sensor.rangesMeasured,Sensor.trajectory,Sensor.scanAngles,Sensor.startDirection,simulationLength);
% 6.2. observer error
%position
if config.observer
    pGroundTruth    = Environment.trajectoryCell{1}(1:3,:);
    pPredictedCell  = cell2mat(Observer.stateEstimated(1,:));
    pPredicted      = pPredictedCell(1:3,4:4:end);
    pError          = pGroundTruth - pPredicted;
    pErrorMagnitude = sqrt(pError(1,:).^2 + pError(2,:).^2 + pError(3,:).^2);
    %orientation - angle
    qGroundTruth = Environment.trajectoryCell{1}(4:7,:);
    qCell        = mat2cell(qGroundTruth,4,ones(1,simulationLength));
    RGroundTruth = cell(1,simulationLength);
    RError       = cell(1,simulationLength);
    angleError   = zeros(1,simulationLength);
    RPredictedCell = Observer.stateEstimated(1,:);
    axisGroundTruth = zeros(3,simulationLength);
    axisPredicted   = zeros(3,simulationLength);
    parfor ii = 1:simulationLength
        RGroundTruth{ii} = q2R(qCell{ii});
        RError{ii}       = RGroundTruth{ii}*(RPredictedCell{ii}(1:3,1:3))';
        angleError(ii)   = norm(arot(RError{ii}));
        axisGroundTruth(:,ii)  = arot(RGroundTruth{ii});
        axisPredicted(:,ii)    = arot(RPredictedCell{ii}(1:3,1:3));
    end
    %size - percentage
    sPredicted  = cell2mat(Observer.stateEstimated(4,:));
    sError      = sPredicted - config.targetSize;
    sErrorRatio = sError/config.targetSize;
    %convergence performance
%     iiAngle = find(angleError<pi/400,1);
%     iiSize = find(abs(sErrorRatio)<0.01,1);
%     tAngle = t(iiAngle);
%     tSize = t(iiSize);
%     str = sprintf('below 1 percent angle error: %.2fs',tAngle); disp(str)
%     str = sprintf('below 1 percent size error: %.2fs',tSize); disp(str)
    if strcmp(config.targetPath,'initialconditions')
        %ground truth
        twistGroundTruth = cell2mat(Environment.stateCell{1}(2,:));
        wrenchGroundTruth = cell2mat(Environment.stateCell{1}(3,:));
            %linear
        vGroundTruth = twistGroundTruth(1:3,4:4:end);
        aGroundTruth = wrenchGroundTruth(1:3,4:4:end);
            %angular
        omegaGroundTruthCross = twistGroundTruth(1:3,:);
        omegaGroundTruthCross(:,4:4:end) = [];
        %skew symmetric to vector
        omegaGroundTruth = [omegaGroundTruthCross(3,2:3:end);
                            omegaGroundTruthCross(1,3:3:end);
                            omegaGroundTruthCross(2,1:3:end)];
        alphaGroundTruthCross = wrenchGroundTruth(1:3,:);
        alphaGroundTruthCross(:,4:4:end) = [];
        %skew symmetric to vector
        alphaGroundTruth = [alphaGroundTruthCross(3,2:3:end);
                            alphaGroundTruthCross(1,3:3:end);
                            alphaGroundTruthCross(2,1:3:end)];
        %predicted
        twistPredicted  = cell2mat(Observer.stateEstimated(2,:));
        wrenchPredicted = cell2mat(Observer.stateEstimated(3,:));
            %linear
        vPredicted = twistPredicted(1:3,4:4:end);
        aPredicted = wrenchPredicted(1:3,4:4:end);
            %angular
        omegaPredictedCross = twistPredicted(1:3,:);
        omegaPredictedCross(:,4:4:end) = [];
        omegaPredicted = [omegaPredictedCross(3,2:3:end);
                            omegaPredictedCross(1,3:3:end);
                            omegaPredictedCross(2,1:3:end)];
        alphaPredicted = wrenchPredicted(1:3,:);
        alphaPredicted(:,4:4:end) = [];
        alphaPredicted = [alphaPredicted(3,2:3:end);
                            alphaPredicted(1,3:3:end);
                            alphaPredicted(2,1:3:end)];
        %error
        vError = vGroundTruth - vPredicted;
        aError = aGroundTruth - aPredicted;
        vErrorMagnitude = sqrt(vError(1,:).^2 + vError(2,:).^2 + vError(3,:).^2);
        aErrorMagnitude = sqrt(aError(1,:).^2 + aError(2,:).^2 + aError(3,:).^2);
        omegaError = omegaGroundTruth - omegaPredicted; 
        alphaError = alphaGroundTruth - alphaPredicted;
        omegaErrorMagnitude = sqrt(omegaError(1,:).^2 + omegaError(2,:).^2 + omegaError(3,:).^2);
        alphaErrorMagnitude = sqrt(alphaError(1,:).^2 + alphaError(2,:).^2 + alphaError(3,:).^2);
    end %if strcmp(config.targetPath,'initialconditions')
end %if config.observer
t5 = toc; str = sprintf('post processing: %.2fs',t5); disp(str);
else %if ~io.loadRes
configCurrent = config;
clearvars -except io configCurrent
load(io.fileRes)
%config = configCurrent;
end %if ~io.loadRes
%% 7. Plot results %overlay observingObjectVector
tic
%range for figures
if isempty(Environment.nPoints); Environment.nPoints = [8 8]; end;
xRange = [reshape(Environment.pointsPath(1,1:Environment.nPoints(1),:),numel(Environment.pointsPath(1,1:Environment.nPoints(1),:)),1,1); Sensor.trajectory(1,:)'];
yRange = [reshape(Environment.pointsPath(2,1:Environment.nPoints(1),:),numel(Environment.pointsPath(1,1:Environment.nPoints(1),:)),1,1); Sensor.trajectory(2,:)'];
zRange = [reshape(Environment.pointsPath(3,1:Environment.nPoints(1),:),numel(Environment.pointsPath(1,1:Environment.nPoints(1),:)),1,1); Sensor.trajectory(3,:)'];
if config.showBackground
    xRange = [xRange; reshape(Environment.pointsPath(1,:,:),numel(Environment.pointsPath(1,:,:)),1,1)];
    yRange = [yRange; reshape(Environment.pointsPath(2,:,:),numel(Environment.pointsPath(1,:,:)),1,1)];
    zRange = [zRange; reshape(Environment.pointsPath(3,:,:),numel(Environment.pointsPath(1,:,:)),1,1)];
end
if config.observer
    xRange = [xRange; reshape(Observer.pointsPathEstimated(1,:,:),numel(Observer.pointsPathEstimated(1,:,:)),1,1)];
    yRange = [yRange; reshape(Observer.pointsPathEstimated(2,:,:),numel(Observer.pointsPathEstimated(1,:,:)),1,1)];
    zRange = [zRange; reshape(Observer.pointsPathEstimated(3,:,:),numel(Observer.pointsPathEstimated(1,:,:)),1,1)];
end
plotRange = [(1-0.2*sign(min(min(xRange))))*min(min(xRange))...
             (1+0.2*sign(max(max(xRange))))*max(max(xRange))...
             (1-0.2*sign(min(min(yRange))))*min(min(yRange))...
             (1+0.2*sign(max(max(yRange))))*max(max(yRange))...
             (1-0.2*sign(min(min(zRange))))*min(min(zRange))...
             (1+0.2*sign(max(max(zRange))))*max(max(zRange))];
% 7.1. plot average measurement
if config.movement == 0
    %create patch matrix
    %create patch to overlay on figures when required
    %plot(t,observingObjectVector,'r') % add patch
    %patch([1 3 3 1],[1 1 5 5],'g','FaceAlpha',0.5)
    %h = patch([1 3 3 1],[1 1 5 5],'g','FaceAlpha',0.1);
    
    rangesSplit     = reshape(Sensor.rangesMeasured,simulationLength/config.nScans,config.nScans)';
    rangesQuintiles = quantile(rangesSplit,11,1);
    rangesAveraged  = mean(rangesSplit,1);
    %rangesAveraged  = rangesQuintiles(6,:);
    x_mean = bsxfun(@times,rangesAveraged,sin(Sensor.scanAngles(1:Sensor.nSteps)));
    y_mean = bsxfun(@times,rangesAveraged,cos(Sensor.scanAngles(1:Sensor.nSteps)));
    x = bsxfun(@times,rangesQuintiles,sin(Sensor.scanAngles(1:Sensor.nSteps)));
    y = bsxfun(@times,rangesQuintiles,cos(Sensor.scanAngles(1:Sensor.nSteps)));
    plotAverage = figure;
    hold on
    plot(0,0,'r.','markersize',10)
    plot(x_mean,y_mean,'b.','markersize',10)
    plot(x([1 11],:),y([1 11],:),'k.','markersize',1)
    plot(x([2 10],:),y([2 10],:),'k.','markersize',2)
    plot(x([3 9],:),y([3 9],:),'k.','markersize',4)
    plot(x([4 8],:),y([4 8],:),'k.','markersize',6)
    plot(x([5 7],:),y([5 7],:),'k.','markersize',8)
    plot(x([1 11],:),y([1 11],:),'k-','markersize',1)
    xlabel('x (m)')
    ylabel('y (m)')
    title('Simulated surface noise: averaged data points')
end
% 7.2. ground truth,predicted & error
if config.observer
    plotPoseSize = figure;
    %position error magnitude
    subplot(3,3,1)
        hold on
        plot(t,zeros(1,length(t)),'k-.')
        plot(t,pErrorMagnitude)
        xlabel('t (s)')
        ylabel('Position error (m)')
        title('Position error')
    %angle error 
    subplot(3,3,2)
        hold on
        if max(angleError) > pi/4
            plot(t,pi/2*ones(1,length(t)),'k-.') 
        end
        plot(t,zeros(1,length(t)),'k-.')
        %plot(t,observingObjectVector,'r') % add patch
        plot(t,angleError,'linewidth',1)
        xlabel('t (s)')
        ylabel('Angle error (rad)')
        title('Angle error')
    %size error ratio
    subplot(3,3,3)
        hold on
        plot(t,zeros(1,length(t)),'k-.')
        plot(t,sErrorRatio)
        xlabel('t (s)')
        ylabel('Size error ratio')
        title('Size error ratio')
    %position - ground truth
    subplot(3,3,4)
        plot(t,zeros(1,length(t)),'k-.')
        plot(t,pGroundTruth)
        xlabel('t (s)')
        ylabel('Ground truth position (m)')
        title('Ground truth position')
        legend('x','y','z')
    %orientation axis - ground truth
    subplot(3,3,5)
        plot(t,axisGroundTruth)
        xlabel('t (s)')
        ylabel('Ground truth orientation axis')
        title('Ground truth orientation axis')
        legend('x','y','z')
    %size - ground truth
    subplot(3,3,6)
        plot(t,config.targetSize*ones(1,length(t)))
        xlabel('t (s)')
        ylabel('ground truth size (m)')
        title('ground truth size')
    %position - predicted
    subplot(3,3,7)
        plot(t,pPredicted)
        xlabel('t (s)')
        ylabel('Predicted position (m)')
        title('Predicted position')
        legend('x','y','z')
    %orientation axis - predicted
    subplot(3,3,8)
        plot(t,axisPredicted)
        xlabel('t (s)')
        ylabel('Predicted orientation axis')
        title('Predicted orientation axis')
        legend('x','y','z')
    %size - predicted
    subplot(3,3,9)
        plot(t,sPredicted)
        xlabel('t (s)')
        ylabel('Size predicted (m)')
        title('Size predicted')

    if strcmp(config.targetPath,'initialconditions')
        %linear & angular velocity & acceleration - true, predicted, error (4x3 subplot)
        plotTwistWrench = figure;
        %linear velocity - error
        subplot(3,4,1)
            hold on
            plot(t,zeros(1,length(t)),'k-.')
            plot(t,vErrorMagnitude)
            xlabel('t (s)')
            ylabel('Velocity error (m/s)')
            title('Velocity error')
        %linear acceleration - error
        subplot(3,4,2)
            hold on
            plot(t,zeros(1,length(t)),'k-.')
            plot(t,aErrorMagnitude)
            xlabel('t (s)')
            ylabel('Acceleration error (m/s^2)')
            title('Acceleration error')
        %angular velocity - error
        subplot(3,4,3)       
            hold on
            plot(t,zeros(1,length(t)),'k-.')
            plot(t,omegaErrorMagnitude)
            xlabel('t (s)')
            ylabel('Angular velocity error (rad/s)')
            title('Angular velocity error')
        %angular acceleration - error
        subplot(3,4,4)
            hold on
            plot(t,zeros(1,length(t)),'k-.')
            plot(t,alphaErrorMagnitude)
            xlabel('t (s)')
            ylabel('Angular acceleration error (rad/s^2)')
            title('Angular acceleration error')
        %linear velocity - ground truth
        subplot(3,4,5)
            plot(t,vGroundTruth)
            xlabel('t (s)')
            ylabel('Velocity ground truth (m/s)')
            title('Velocity ground truth')
            legend('x','y','z')
        %linear acceleration - ground truth
        subplot(3,4,6)
            plot(t,aGroundTruth)
            xlabel('t (s)')
            ylabel('Acceleration ground truth (m/s^2)')
            title('Acceleration ground truth')
            legend('x','y','z')
        %angular velocity - ground truth
        subplot(3,4,7)
            plot(t,omegaGroundTruth)
            xlabel('t (s)')
            ylabel('Angualar velocity axis ground truth')
            title('Angualar velocity axis ground truth')
            legend('x','y','z')
        %angular acceleration - ground truth
        subplot(3,4,8)
            plot(t,alphaGroundTruth)
            xlabel('t (s)')
            ylabel('Angualar acceleration axis ground truth')
            title('Angualar acceleration axis ground truth')
            legend('x','y','z')
        %linear velocity - predicted
        subplot(3,4,9)
            plot(t,vPredicted)
            xlabel('t (s)')
            ylabel('Velocity predicted (m/s)')
            title('Velocity predicted')
            legend('x','y','z')
        %linear acceleration - predicted
        subplot(3,4,10)
            plot(t,aPredicted)
            xlabel('t (s)')
            ylabel('Acceleration predicted (m/s^2)')
            title('Acceleration predicted truth')
            legend('x','y','z')
        %angular velocity - predicted
        subplot(3,4,11)
            plot(t,omegaPredicted)
            xlabel('t (s)')
            ylabel('Angualar velocity axis predicted')
            title('Angualar velocity axis predicted')
            legend('x','y','z')
        %angular acceleration - predicted
        subplot(3,4,12)
            plot(t,alphaPredicted)
            xlabel('t (s)')
            ylabel('Angualar acceleration axis predicted')
            title('Angualar acceleration axis predicted')
            legend('x','y','z')
    end %if strcmp(config.targetPath,'initialconditions')
end %if config.observer
t6 = toc; str = sprintf('plotting results: %.2fs',t6); disp(str);
%% 8. Animation
if config.animation
    tic
    %preparing animation
    if config.showSensorAxes
        xAxisRep = repmat([1 0 0],simulationLength,1);
        yAxisRep = repmat([0 1 0],simulationLength,1);
        zAxisRep = repmat([0 0 1],simulationLength,1);
        sensorXDirection = quatrot(Sensor.trajectory(4:7,:)',xAxisRep)';
        sensorYDirection = quatrot(Sensor.trajectory(4:7,:)',yAxisRep)';
        sensorZDirection = quatrot(Sensor.trajectory(4:7,:)',zAxisRep)';
    end
    figure
    hold on
    axis equal
    view(-70,40)
    axis(plotRange);
    xlabel('x')
    ylabel('y')
    zlabel('z')
    t7 = toc; str = sprintf('preparing animation: %.2fs',t7); disp(str);
    %animation
    tic
    for ii = [config.displayFrames:config.displayFrames:simulationLength simulationLength]
        %plot sensor position
        plotSensorPosition = plot3(Sensor.trajectory(1,ii),...
                                   Sensor.trajectory(2,ii),...
                                   Sensor.trajectory(3,ii),'b*');
        %plot sensor orientation
        if config.showSensorAxes
            plotSensorXDir = quiver3(Sensor.trajectory(1,ii),...
                                     Sensor.trajectory(2,ii),...
                                     Sensor.trajectory(3,ii),...
                                         sensorXDirection(1,ii),...
                                         sensorXDirection(2,ii),...
                                         sensorXDirection(3,ii),0.2,'r-');
            plotSensorYDir = quiver3(Sensor.trajectory(1,ii),...
                                     Sensor.trajectory(2,ii),...
                                     Sensor.trajectory(3,ii),...
                                         sensorYDirection(1,ii),...
                                         sensorYDirection(2,ii),...
                                         sensorYDirection(3,ii),0.2,'g-');
            plotSensorZDir = quiver3(Sensor.trajectory(1,ii),...
                                     Sensor.trajectory(2,ii),...
                                     Sensor.trajectory(3,ii),...
                                         sensorZDirection(1,ii),...
                                         sensorZDirection(2,ii),...
                                         sensorZDirection(3,ii),0.2,'b-');
        end
        %plot scan direction
        if ~isnan(Sensor.rangesTrue(ii))
            scanColour = 'g-';
        else
            scanColour = 'r-';
        end
        plotScan = quiver3(Sensor.trajectory(1,ii),...
                           Sensor.trajectory(2,ii),...
                           Sensor.trajectory(3,ii),...
                           Sensor.scanDirections(1,ii),...
                           Sensor.scanDirections(2,ii),...
                           Sensor.scanDirections(3,ii),...
                           min(config.displayScale,Sensor.rangesTrue(ii)),scanColour);
        set(plotScan,'ShowArrowHead','off')
        %plot target object
        plotTarget = trimesh(Environment.trianglesCell{1},...
                             Environment.pointsPath(1,:,ii),...
                             Environment.pointsPath(2,:,ii),...
                             Environment.pointsPath(3,:,ii),...
                             'FaceAlpha',0.5,'EdgeColor',[0.1 0.1 0.1]);
        %plot background                
        if config.showBackground
            plotBackground = trimesh(Environment.trianglesCell{2},...
                                     Environment.pointsPath(1,:,ii),...
                                     Environment.pointsPath(2,:,ii),...
                                     Environment.pointsPath(3,:,ii),...
                                     'FaceAlpha',0.1,'EdgeColor',[0.75 0.75 0.75]);
        end
        %plot object predicted
        if config.observer
            plotObjectEstimated = trimesh(Observer.triangles,...
                                     Observer.pointsPathEstimated(1,:,ii),...
                                     Observer.pointsPathEstimated(2,:,ii),...
                                     Observer.pointsPathEstimated(3,:,ii),...
                                     'FaceAlpha',0.25,'EdgeColor',[0.1 0.5 0.5]);
        end %if config.observer
            %plot ground truth intersection point
            plotCoordinatesTrue = plot3(coordinatesTrue(1,ii-config.displayFrames+1:ii),...
                                        coordinatesTrue(2,ii-config.displayFrames+1:ii),...
                                        coordinatesTrue(3,ii-config.displayFrames+1:ii),...
                                        '.','MarkerEdgeColor',[0,0.25,0.5],'markersize',1);
            %plot measured intersection point
            plotCoordinatesMeasured = plot3(coordinatesMeasured(1,ii-config.displayFrames+1:ii),...
                                            coordinatesMeasured(2,ii-config.displayFrames+1:ii),...
                                            coordinatesMeasured(3,ii-config.displayFrames+1:ii),...
                                            '.','MarkerEdgeColor',[0.75,0,0],'markersize',1);      
        drawnow  
        %delete for next image
        if ii < simulationLength %dont erase last
           delete(plotSensorPosition)
            if config.showSensorAxes
                delete(plotSensorXDir)
                delete(plotSensorYDir)
                delete(plotSensorZDir)
                if ~config.showAllPoints
                    delete(plotCoordinatesTrue)
                    delete(plotCoordinatesMeasured)
                end
            end
            delete(plotScan)
            delete(plotTarget)
            if config.observer
                delete(plotObjectEstimated)
            end    
            if config.showBackground
                delete(plotBackground)
            end
        end %if ii < simulationLength        
    end %for ii =...
    t8 = toc; str = sprintf('animation: %.2fs',t8  ); disp(str);
end %if config.animation
%% 9. Save Results
if io.saveRes
    tic
    if config.observer
        saveas(plotPoseSize,fullfile(strcat(folderpath,'\data\results'),io.nameRes,'observer_error'),'jpg')
    end
    if strcmp(config.targetPath,'initialconditions')
        saveas(plotTwistWrench,fullfile(strcat(folderpath,'\data\results'),io.nameRes,'observer_error'),'jpg')
    end
    clear plotBackground plotCoordinatesMeasured plotCoordinatesTrue plotPoseSize plotTwistWrench ...
          plotGroundTruth plotMeasurement plotTarget plotObjectEstimated plotScan ...
          plotSensorPosition plotSensorXDir plotSensorYDir plotSensorZDir 
    save(fullfile(strcat(folderpath,'\data\results'),io.nameRes,'results.mat'),'-regexp','^(?!(io)$).')
    t9 = toc; str = sprintf('saving results: %.2fs',t8  ); disp(str);
end %io.saveRes
