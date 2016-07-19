close all
clear all

%% Testing integration methods for internal model
dt = 0.1;
t = 0:dt:10;
%initial conditions
%position
p0 = [0 0 0]';
%velocity
v0 = [0 0 0]';
%acceleration
a0 = [0 0 0]';
%euler angles
e0 = [0 0 0]';
%angular velocity
ev0 = [0 0 0]';
%angular acceleration
ea0 = [0 0 0]';
%state
x = zeros(18,length(t));
x(:,1) = [p0; v0; a0; e0; ev0; ea0];
for i = 1:length(t) - 1
    %update p,v,a - assume a(t) = 0
    x(7:9,i+1) = x(7:9,i);
    x(4:6,i+1) = x(4:6,i) + dt*x(7:9,i);
    x(1:3,i+1) = x(1:3,i) + dt*x(4:6,i);
    %update orientation - assume angular acceleration = 0
    x(16:18,i+1) = x(16:18,i);
    x(13:15,i+1) = somefunction(x(13:15,i),x(16:18,i),dt);
    x(10:12,i+1) = somefunction(x(10:12,i),x(13:15,i),dt);
    
end