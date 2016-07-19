function [Sensor,simulationLength,dt] = initialisesensor(config)
%INITIALISESENSOR creates instance of rangesensor class
%Inputs
    %config           - struct with simulation settings
%Outputs
    %Sensor           - RangeSensor class instance
    %simulationLength - number of steps in simulation
    %dt               - simpler to define dt based on nScans and sensorType
%%
% 1. constants
DEG2RAD = pi/180;
    
%2. parameters determined by sensorType
switch config.sensorType
    case 'UBG-04LX-F01-default'
        scanTime = 1/24;   %time per scan in seconds
        nSteps   = 1024;
        dt       = scanTime/nSteps;
        simulationLength  = round(config.nScans*scanTime/dt);
        angularResolution = 360/nSteps*DEG2RAD;
        fieldOfView       = 180*DEG2RAD;
        scanStart         = -90*DEG2RAD;
        spinDirection     = 1;
    case 'UBG-04LX-F01-datasheet'
        scanTime = 0.028;   %time per scan in seconds
        nSteps   = 1080;
        dt       = scanTime/nSteps;
        simulationLength  = round(config.nScans*scanTime/dt);
        angularResolution = 360/nSteps*DEG2RAD;
        fieldOfView       = 240*DEG2RAD;
        scanStart         = -120*DEG2RAD;
        spinDirection     = 1;
    case 'UTM-30LX-EW'
        scanTime = 0.025;   %time per scan in seconds
        nSteps   = 1440;
        dt       = scanTime/nSteps;
        simulationLength  = round(config.nScans*scanTime/dt);
        angularResolution = 360/nSteps*DEG2RAD;
        fieldOfView       = 270*DEG2RAD;
        scanStart         = -135*DEG2RAD;
        spinDirection     = 1;
end %switch

% 3. sensor trajectory
switch config.sensorPath
    case 'waypoints'
        trajectory = waypoints2Trajectory(config.sensorWaypoints,config.sensorLoops,simulationLength);
        state = NaN;
    case 'initialconditions'
        %speed this up! mex file
        %add switch case for frames
        %add input config.sensorTwistWrenchFrame
        [trajectory,state] = initialState2Trajectory(config.sensorInitial,config.sensorTwistWrenchFrames,...
                                                     simulationLength,dt);
end
        
%3. scan angles
scanEnd    = scanStart + spinDirection*(fieldOfView-angularResolution);
scanAngles = linspace(scanStart,scanStart + spinDirection*2*pi,nSteps + 1);
scanAngles = scanAngles(1:end-1);
scanAngles = wrapToPi(scanAngles);
scanAngles(find(scanAngles==scanEnd):end) = NaN; %outside FOV
scanAngles = repmat(scanAngles,1,config.nScans); %reshape?

%scan directions
qCombined = quatmultiply(trajectory(4:7,:)',...
            angle2quat(scanAngles,zeros(1,simulationLength),zeros(1,simulationLength)));
startDirection = [1 0 0]';
startDirectionRep = repmat(startDirection',simulationLength,1);
scanDirections = quatrot(qCombined,startDirectionRep);
scanDirections = scanDirections';

%create class instance
Sensor = RangeSensor; 
Sensor.trajectory     = trajectory;
Sensor.state          = state;
Sensor.startDirection = startDirection;
Sensor.spinDirection  = spinDirection;
Sensor.scanAngles     = scanAngles;
Sensor.scanDirections = scanDirections;
Sensor.scanStart      = scanStart;
Sensor.scanEnd        = scanEnd;
Sensor.nSteps         = nSteps;
Sensor.rangesTrue      = NaN*zeros(1,simulationLength); 
Sensor.rangesMeasured  = NaN*zeros(1,simulationLength); 
Sensor.incidenceAngles = NaN*zeros(1,simulationLength); 
Sensor.iTriangleHit    = NaN*zeros(1,simulationLength); 

end %function

