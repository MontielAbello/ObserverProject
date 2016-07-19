clear all
close all
%%
target.p0     = [1 0 0]'; %P_B_A_A
target.v0     = [0 0 0]'; %V_B_A_B
target.a0     = [0 0 0]'; %A_B_A_B
target.R0     = rot(pi/6*unit([1 2 3]')); %R_B_A_A
target.omega0 = 0*unit([0 0 0]'); %Omega_B_A_B
target.alpha0 = 0*unit([0 0 0]'); %Alpha_B_A_B
target.size = 0.5;

background.p0     = [1 0 0]'; %P_B_A_A
background.v0     = [0 0 0]'; %V_B_A_B
background.a0     = [0 0 0]'; %A_B_A_B
background.R0     = rot(0*unit([0 0 0]')); %R_B_A_A
background.omega0 = 0*unit([0 0 0]'); %Omega_B_A_B
background.alpha0 = 0*unit([0 0 0]'); %Alpha_B_A_B
background.size = [6 4 2]';

%calculate linear and angular position, velocity, acceleration over time