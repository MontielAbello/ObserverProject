clear all
close all
%%
simulationLength = 4000;
config.sensorWaypoints = [0 0;
                          0 0; 
                          0 0; 
                          0*unit([0 0 0]') 0*unit([0 0 0]')]; %initial-final position & scaled axis
config.sensorLoops = 2;

%position
position = [linspace(config.sensorWaypoints(1,1),config.sensorWaypoints(1,2),0.5*simulationLength/config.sensorLoops);
            linspace(config.sensorWaypoints(2,1),config.sensorWaypoints(2,2),0.5*simulationLength/config.sensorLoops);
            linspace(config.sensorWaypoints(3,1),config.sensorWaypoints(3,2),0.5*simulationLength/config.sensorLoops)];
position = [position fliplr(position)];
position = repmat(position,1,config.sensorLoops);

%represent orientation with quaternions
qStart = a2q(config.sensorWaypoints(4:6,1))';
qEnd = a2q(config.sensorWaypoints(4:6,2))';
orientation = quatspace(qStart,qEnd,0.5*simulationLength/config.sensorLoops);
orientation = orientation';
orientation = [orientation fliplr(orientation)];
orientation = repmat(orientation,1,config.sensorLoops);

trajectory = [position; orientation];
