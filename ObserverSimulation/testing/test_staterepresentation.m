clear all
close all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\MatlabCode\ObserverSimulation'))
%%
p0     = [0 0 0]'; 
v0     = [0 0 0]'; %body fixed?
a0     = [0 0 0]'; %body fixed?
euler0 = [0.1 0.2 0.3]';
omega0 = [1 2 3]'; %body fixed
alpha0 = [0 0 0]'; %body fixed
s0     = 1;
dt = 0.1;
simulationLength = 1000;

R0 = ypr2R(euler0(1),euler0(2),euler0(3));
w0 = ypr2axis(omega0(1),omega0(2),omega0(3));
Wx = skew_symmetric(w0);

R1 = R0*expm(dt*Wx);
R2ypr(R1)