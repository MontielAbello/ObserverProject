close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\MatlabCode\ObserverSimulation'))
%%
p0     = [0 0 0]'; 
v0     = [0 0 0]'; %body fixed?
a0     = [0 0 0]'; %body fixed?
euler0 = [0 0 0]';
omega0 = [0.1 0.2 0.3]'; %body fixed
alpha0 = [1 2 3]'; %body fixed
s0     = 1;
dt = 0.1;

R0 = ypr2R(euler0(1),euler0(2),euler0(3));
Wx0 = ypr2axis(omega0(1),omega0(2),omega0(3));
Ax0 = ypr2axis(alpha0(1),alpha0(2),alpha0(3));

w = norm(Wx0);
nw = Wx0/w;

a = norm(Ax0);
na = Ax0/a;

at = a*dt;
Axt = at*na;
Ra = rot(Axt);

Rw = rot(Wx0);

R2 = Rw*Ra;

R2ypr(R2)