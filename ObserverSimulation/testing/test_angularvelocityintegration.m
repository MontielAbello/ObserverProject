close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\MatlabCode\ObserverSimulation'))
%% Testing angular velocity integration
dt = 0.1;
rpy0 = [0.01 0.02 0.03]';
omega = [0.1 0.2 0.3]';
omega = ypr2axis(omega(1),omega(2),omega(3));

R1 = ypr2R(rpy0(1),rpy0(2),rpy0(3));
W = skew_symmetric(omega);
R2 = R1*expm(dt*W);
rpy1 = R2ypr(R2)

Wb = [0 -omega(1) -omega(2) -omega(3);
      omega(1) 0 omega(3) -omega(2);
      omega(2) -omega(3) 0 omega(1);
      omega(3) omega(2) -omega(1) 0];
q0 = angle2quat(rpy0(1),rpy0(2),rpy0(3));  
q2 = expm(0.5*dt*Wb)*q0';
[y,p,r] = quat2angle(q2');
rpy2 = [r p y]'

Mq = [-q0(2) -q0(3) -q0(4);
       q0(1)  q0(4) -q0(3);
      -q0(4)  q0(1)  q0(2);
       q0(3) -q0(2)  q0(1)];
q3 = q0' + 0.5*dt*Mq*omega;
[y,p,r] = quat2angle(q3');
rpy3 = [r p y]'

domega = dt*omega;
q4 = [cos(norm(domega)/2) domega'./norm(domega)*sin(norm(domega)/2)];
q5 = quatmultiply(q4,q0);
[y,p,r] = quat2angle(q5);
rpy4 = [r p y]'
% *above methods work for small rotations - try in internal model and see if accurate enough