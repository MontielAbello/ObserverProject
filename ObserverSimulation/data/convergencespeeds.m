clear all
close all

[a,s] = meshgrid(0:pi/16:pi/4,-0.5:0.5:2);
tA = [0	7.59	8.47	8.64	8.64;
      0	4.64	6.51	6.64	6.64;
      0	4.47	6.43	6.64	6.64;
      0	4.51	5.59	5.59	6.55;
      0	4.59	5.64	6.39	5.55;
      0	4.64	5.55	5.51	6.55];
tS = [4.59	4.39	4.34	3.64	3.64;
      0     0       0       0       0   ;
      2.64	3.34	3.39	3.39	3.43;
      3.55	3.51	3.47	3.47	3.51;
      4.34	3.64	3.64	3.64	4.34;
      4.43	4.43	4.43	4.43	4.51];
  
figure
hold on
mesh(a,s,tA);
plot3(a,s,tA,'k.','markersize',15);
xlabel('initial angle error (rad)')
ylabel('initial size error ratio')
zlabel('time to angle error < \pi/400 radians angle error (s)')
title('Orientation convergence speed')
view(-60,40)

figure
hold on
mesh(a,s,tS);
plot3(a,s,tS,'k.','markersize',15);
xlabel('initial angle error (rad)')
ylabel('initial size error ratio')
zlabel('time to size error ratio < |0.01| (s)')
title('Size convergence speed')
view(-60,40)
