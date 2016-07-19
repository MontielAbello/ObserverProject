close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))
%% for viewing scans from Hokuyo UBG-04LX-F01
data = load('noise/noisemeasurements/15/0/scans.txt');
%sigma = std(data,1);
quintiles = quantile(data,11,1);
%data_mean = mean(data,1);
data_mean = quintiles(6,:);
angles = linspace(pi/2,-pi/2,512);
x_mean = bsxfun(@times,data_mean,sin(angles));
y_mean = bsxfun(@times,data_mean,cos(angles));
x = bsxfun(@times,quintiles,sin(angles));
y = bsxfun(@times,quintiles,cos(angles));

figure
hold on
plot(0,0,'r.','markersize',10)
plot(x_mean,y_mean,'b.','markersize',10)
plot(x([1 11],:),y([1 11],:),'k.','markersize',1)
plot(x([2 10],:),y([2 10],:),'k.','markersize',2)
plot(x([3 9],:),y([3 9],:),'k.','markersize',4)
plot(x([4 8],:),y([4 8],:),'k.','markersize',6)
plot(x([5 7],:),y([5 7],:),'k.','markersize',8)
plot(x([1 11],:),y([1 11],:),'k.','markersize',1)
plot(x_mean,y_mean,'b.','markersize',10)
xlabel('x (m)')
ylabel('y (m)')
title('Measured surface noise: averaged data points')
%axis equal
axis([(1-0.1*sign(min(x_mean)))*min(x_mean)...
      (1+0.1*sign(max(x_mean)))*max(x_mean)...
      (1-0.1*sign(min(y_mean)))*min(y_mean)...
      (1+0.1*sign(max(y_mean)))*max(y_mean)]);


