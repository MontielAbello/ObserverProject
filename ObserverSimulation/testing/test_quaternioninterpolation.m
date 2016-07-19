close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\MatlabCode\ObserverSimulation'))
%%
% tic
% simulationLength = 1000;
% rpy      = [linspace(0,pi/2,simulationLength);
%             linspace(0,pi/3,simulationLength);
%             linspace(0,pi/4,simulationLength)];
% q = angle2quat(rpy(3,:),rpy(2,:),rpy(1,:)); %y,p,r 
% toc
% %% quaternion interpolation
% 
% t1 = linspace(0,1,1000)';
% t2 = [0:0.001:1]';
% t2(end) = [];
% %t = [0:0.1:1]';
% tic
% t = t1;
% q1 = angle2quat(0,0,0);
% q2 = angle2quat(pi/4,pi/3,pi/2);
% a0 = dot(q1,q2);
% theta = acos(a0);
% q3 = (sin((1-t)*theta)*q1 + sin(t*theta)*q2)/(sin(theta));
% toc
% [y,p,r] = quat2angle(q3);
%%
sensorTrajectory = [0 0; 0 0; 0 0; 0 pi/2; 0 pi/3; 0 pi/4]; %initial-final position & euler angles
if 
qStart = angle2quat(sensorTrajectory(6,1),sensorTrajectory(5,1),sensorTrajectory(4,1));
qEnd   = angle2quat(sensorTrajectory(6,2),sensorTrajectory(5,2),sensorTrajectory(4,2));
q = quatspace(qStart,qEnd,1000);