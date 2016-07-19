close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\MatlabCode\ObserverSimulation'))
%% testing orientation representation and rotation methods
%starting scan direction
v0 = [1 0 0]';
%rotation angles about z axis
scanAngle = -pi/2;
%orientation
t = 0:0.1:10;
eu = [pi/4 pi/3 pi/6]';
%rotation matrix/quaternion representing orientation  
tic
R1 = ypr2R(0,0,scanAngle);
%rotation matrix/quaternion representing scan angles
R2 = ypr2R(eu(1),eu(2),eu(3));
v1 = R2*(R1*v0);
toc
%% quaternion implementation'
tic
q = quatmultiply(angle2quat(eu(3),eu(2),eu(1)),angle2quat(scanAngle,0,0));
v2 = quatrot(q,v0')';
toc

tic
q = quatmultiply(repmat(angle2quat(eu(3),eu(2),eu(1)),5,1),repmat(angle2quat(scanAngle,0,0),5,1));
v2 = quatrot(q,repmat(v0',5,1))';
toc

%% quaternion interpolation
tic
t = [0:1/288000:1]';
q1 = angle2quat(0,0,0);
q2 = angle2quat(pi/2,0,0);
a0 = dot(q1,q2);
theta = acos(a0);

q3 = (sin((1-t)*theta)*q1 + sin(t*theta)*q2)/(sin(theta));
[y,p,r] = quat2angle(q3);
toc

