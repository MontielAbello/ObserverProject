function [cubepose] = jointangles2cubepose(angles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DEG2RAD = pi/180;

q1 = angles(1);
q2 = angles(2);
q3 = angles(3);
q4 = angles(4);
q5 = angles(5);
q6 = angles(6);

%world -> base
% R0 = [0 -1  0;
%       1  0  0;
%       0  0  1];
R0 = rot([0 0 pi]');  
t0 = [1.14 0 0.725]';
%base -> j1
R1 = [cos(q1)   -sin(q1)     0;
      -sin(q1)  -cos(q1)     0;
      0         0           -1];
t1 = [0 0 0.1544]';
%j1 -> j2
R2 = [sin(q2)   cos(q2)     0;
      0         0           1;
      cos(q2)   -sin(q2)    0];
t2 = [0 0 -0.1181]';
%j2 -> j3
R3 = [-cos(q3)  sin(q3)     0;
      sin(q3)   cos(q3)     0;
      0         0          -1];
t3 = [0.41 0 -0.0098]';
%j3 -> j4
R4 = [0         0          -1;
      sin(q4)   cos(q4)     0;
      cos(q4)   -sin(q4)    0];
t4 = [0.2073 0 0]';
%j4 -> j5
R5 = [cos(-55*DEG2RAD)*cos(q5)  cos(-55*DEG2RAD)*(-sin(q5))     sin(-55*DEG2RAD);
      sin(q5)                   cos(q5)                         0;
      -sin(-55*DEG2RAD)*cos(q5) sin(-55*DEG2RAD)*sin(q5)        cos(-55*DEG2RAD)];
t5 = [cos(55*DEG2RAD)*0.0743 0 -sin(55*DEG2RAD)*0.0743]';
%j5 -> j6
R6 = [cos(55*DEG2RAD)*cos(q6)   cos(55*DEG2RAD)*(-sin(q6))      sin(55*DEG2RAD);
      sin(q6)                   cos(q6)                         0;
      -sin(55*DEG2RAD)*cos(q6)  sin(55*DEG2RAD)*sin(q6)         cos(55*DEG2RAD)];
t6 = [-cos(55*DEG2RAD)*0.0743 0 -sin(55*DEG2RAD)*0.0743]';
%j6 -> cube
R7 = [1 0 0;
      0 1 0;
      0 0 1];
t7 = [0 0 0.2]'; %CHECK THAT AXIS CORRECT  

%frames
T_W_base =  [R0 t0; 0 0 0 1];
T_base_j1 = [R1 t1; 0 0 0 1];
T_j1_j2 =   [R2 t2; 0 0 0 1];
T_j2_j3 =   [R3 t3; 0 0 0 1];
T_j3_j4 =   [R4 t4; 0 0 0 1];
T_j4_j5 =   [R5 t5; 0 0 0 1];
T_j5_j6 =   [R6 t6; 0 0 0 1];
T_j6_cube = [R7 t7; 0 0 0 1];

%HOW TO COMPOSE???
T0 = T_j6_cube;
T1 = T_j5_j6;
T2 = T_j4_j5;
T3 = T_j3_j4;
T4 = T_j2_j3;
T5 = T_j1_j2;
T6 = T_base_j1;
T7 = T_W_base;

cubepose = T7*T6*T5*T4*T3*T2*T1*T0;

end %end function

