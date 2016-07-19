function [Environment] = initialiseenvironment(config,simulationLength,dt)
%INITIALISEENVIRONMENT models environment composed of multiple objects
%   object faces composed of triangles
%   each object has separate trajectory & surface properties
%Inputs
    %config      - struct with simulation settings
%Outputs
    %Environment - TargetObject class instance
%%
% 1. trajectory/state
switch config.targetPath
    case 'waypoints'
        targetTrajectory = waypoints2Trajectory(config.targetWaypoints,0,simulationLength); %0 - no looping
        targetState = NaN;
    case 'initialconditions'
        %speed this up! mex file
        [targetTrajectory,targetState] = initialState2Trajectory(config.targetInitial,...
                                                                 config.targetTwistWrenchFrames,...
                                                                 simulationLength,dt);
end %end switch

switch config.backgroundPath
    case 'waypoints'
        backgroundTrajectory = waypoints2Trajectory(config.backgroundWaypoints,0,simulationLength); %0 - no looping
        backgroundState = NaN;
    case 'initialconditions'
        %speed this up! mex file
        [backgroundTrajectory,backgroundState] = initialState2Trajectory(config.backgroundInitial,...
                                                                         config.backgroundTwistWrenchFrames,...
                                                                         simulationLength,dt);
end %end switch

% 2. triangles
targetTriangles = [1 2 3
                   2 4 3
                   4 3 7
                   4 8 7
                   5 6 7
                   8 6 7
                   2 6 5
                   2 1 5
                   2 6 8
                   2 4 8
                   1 5 7
                   1 3 7];
backgroundTriangles = [ 9    10    11
                       10    12    11
                       12    11    15
                       12    16    15
                       13    14    15
                       16    14    15
                       10    14    13
                       10     9    13
                       10    14    16
                       10    12    16
                        9    13    15
                        9    11    15];
% 3. points
initialPoints = 0.5*[-1    -1    -1    -1     1     1     1     1
                     -1    -1     1     1    -1    -1     1     1
                     -1     1    -1     1    -1     1    -1     1];
targetPoints     = bsxfun(@times,config.targetSize,initialPoints);
backgroundPoints = bsxfun(@times,config.backgroundSize,initialPoints);

% 4. points trajectory
targetPointsPath = initialisepointspath(targetPoints',targetTrajectory',simulationLength);
backgroundPointsPath = initialisepointspath(backgroundPoints',backgroundTrajectory',simulationLength);

% 5. class instance
Environment = TargetObject;
Environment.nObjects = 2;
Environment.nPoints = [size(initialPoints,2) size(initialPoints,2)];
Environment.trajectoryCell = {targetTrajectory,backgroundTrajectory}';
Environment.stateCell = {targetState,backgroundState}';
Environment.pointsPath = [targetPointsPath backgroundPointsPath];
Environment.triangles = [targetTriangles; backgroundTriangles];
Environment.trianglesCell = {targetTriangles,backgroundTriangles};
Environment.triangles2Object = [1*ones(1,size(targetTriangles,1))...
                                2*ones(1,size(backgroundTriangles,1))];
Environment.surfaceProperties = [0.5 0.5 0.5 1 1 298.15;
                                 0.1 0.1 0.1 1 1 298.15]';

end %function

