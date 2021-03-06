function [io,config] = settings_default()
%This file used to input simulation settings.
%Adjust sensor/cube trajectory, sensor operation and observer function
%Simulation settings
    %io struct used to adust loading/saving of data and results
    %simulation parameters and display settings can be adjusted (2. and 3.)
    %currently, only the Hokuyo UBG-04LX-F01 is available to simulate 
    %(uses experimentally determined noise model)
%Trajectory settings
    %can be determined with waypoints or from initial conditions
    %set config.sensorPath, config.targetPath, config.backgroundPath to
    %either 'waypoints' or 'initialconditions'. 
    %If using 'waypoints', set config.xxxxxxWaypoints
    %if using 'initialconditions', set config.xxxxxxInitial.p0 etc
%Observer Settings
    %set initial conditions - config.observerInitial
    %twist and wrench can be defined in body fixed/inertial frames
    %config.updateMethod can be changed to apply observer correction via
    %screw, twist or wrench
    %set config.updateScale to tune observer gains
    %can turn config.orientationUpdate, config.positionUpdate,
    %config.sizeUpdate ON/OFF  
    
%% 1. loading and saving
%measurements
io.nameMeas = 'FOLDERPATH'; %save/load this 
io.loadMeas = 0;
io.fileMeas = strcat('data/simulated/',io.nameMeas,'/simdata.mat');  %loading
io.saveMeas = 0;      
%full results
io.nameRes = 'FOLDERPATH'; %save/load this
io.loadRes = 0;
io.fileRes = strcat('data/results/',io.nameRes,'/results.mat'); %loading
io.saveRes = 0;
io.saveNoisePlot      = 0;
io.saveErrorPlot      = 1;
io.saveFullStatePlot  = 1;
io.saveAnimation      = 0;
%% 2. simulation parameters
config.nSeconds        = 16;
config.nScans          = config.nSeconds*24;
config.movement        = 1; %are sensor or cube moving (random walk noise differs)
config.noise           = 1; 
config.observer        = 1;
config.observingObject = 0; %initially pointing at object
%% 3. display settings
config.animation      = 1;
config.displayFrames  = 4500;
config.displayScale   = 4;
config.showSensorAxes = 1;
config.showBackground = 0;
config.showAllPoints  = 1;
%% 4. initialise sensor
config.sensorType       = 'UBG-04LX-F01-default';
config.sensorLoops      = config.nSeconds*0.5; %needs to divide nScans
config.sensorPath       = 'waypoints';
%config.sensorPath      = 'initialconditions';
config.sensorWaypoints = [0 0;
                          0 0; 
                          0 0; 
                          -pi/8*unit([0 1 0]') pi/8*unit([0 1 0]')]; %initial-final position & scaled axis
config.sensorInitial.p0     = [0 0 0]';
config.sensorInitial.v0     = [0 0 0]';
config.sensorInitial.a0     = [0 0 0]';
config.sensorInitial.R0     = rot(-pi/6*unit([0 1 0]'));
config.sensorInitial.omega0 = pi/6*unit([0 1 0]');
config.sensorInitial.alpha0 = 0*unit([0 0 0]');
config.sensorTwistWrenchFrames = 'body-fixed';
%config.sensorTwistWrenchFrames = 'inertial';
%% 5. initialise environment
%target
config.targetPath     = 'waypoints'; %faster but velocity constant
%config.targetPath      = 'initialconditions';
config.targetWaypoints = [1 1;
                          0 0; 
                          0 0; 
                          pi/6*unit([1 2 3]') pi/6*unit([1 2 3]')]; %initial-final position & scaled axis
config.targetInitial.p0     = [1 0 0]';
config.targetInitial.v0     = [0 0 0]';
config.targetInitial.a0     = [0 0 0]';
config.targetInitial.R0     = rot(pi/4*unit([0 0 0]'));
config.targetInitial.omega0 = pi/8*unit([0 0 0]');
config.targetInitial.alpha0 = 0*unit([0 0 0]');
%config.targetTwistWrenchFrames = 'body-fixed';
config.targetTwistWrenchFrames = 'inertial';
config.targetSize           = 0.2;
%background
config.backgroundPath      = 'waypoints'; %faster but velocity constant
%config.backgroundPath      = 'initialconditions';
config.backgroundWaypoints = [0 0;
                              0 0; 
                              0 0; 
                              0*unit([0 0 0]') 0*unit([0 0 0]')]; %initial-final position & scaled axis
config.backgroundInitial.p0     = [0 0 0]';
config.backgroundInitial.v0     = [0 0 0]';
config.backgroundInitial.a0     = [0 0 0]';
config.backgroundInitial.R0     = rot(pi/4*unit([0 0 0]'));
config.backgroundInitial.omega0 = 0*unit([0 0 0]');
config.backgroundInitial.alpha0 = 0*unit([0 0 0]');
config.backgroundTwistWrenchFrames = 'body-fixed';
%config.backgroundTwistWrenchFrames = 'inertial';
config.backgroundSize           = [6 4 2]';
%% 6. initialise observer
%initial state estimate
config.observerInitial.p0     = [1 0 0]';
config.observerInitial.v0     = [0 0 0]';
config.observerInitial.a0     = [0 0 0]';
config.observerInitial.R0     = rot(pi/6*unit([0 0 0]'));
config.observerInitial.omega0 = 0*unit([0 0 0]');
config.observerInitial.alpha0 = 0*unit([0 0 0]');
config.observerInitial.s0     = 0.3;
%config.observerTwistWrenchFrames = 'body-fixed';
config.observerTwistWrenchFrames = 'inertial';
%update function settings
config.updateMethod              = 'screw';
%config.updateMethod              = 'twist';
%config.updateMethod              = 'wrench';
config.updateScale.p     = 0.0001;
config.updateScale.v     = 0.01;
config.updateScale.a     = 0.01;
config.updateScale.R     = 50000;
config.updateScale.omega = 8000;
config.updateScale.alpha = 10000;
config.updateScale.s     = 0.005;
config.orientationUpdate         = 1;
config.parallelOrientationUpdate = 0;
config.positionUpdate            = 0;
config.sizeUpdate                = 1;    
%separate target and background
%config.triggerMethod = 'difference';
config.triggerMethod = 'range';
config.differenceTrigger = 0.5;
config.rangeTrigger = 1.5;
end %end function

