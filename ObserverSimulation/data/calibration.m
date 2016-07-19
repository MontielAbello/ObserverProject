close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))
%% SOMETHING WRONG WITH THIS FITTING - only works for small angles
%% TRY FITTING PLANE IN CARTESIAN, THEN GETTING y-ANGLE FROM FITTED Z
scan01 = load('data/experimental/hokuyo/calibration/-30 deg/scans.txt');
scan02 = load('data/experimental/hokuyo/calibration/-25 deg/scans.txt');
scan03 = load('data/experimental/hokuyo/calibration/-20 deg/scans.txt');
scan04 = load('data/experimental/hokuyo/calibration/-15 deg/scans.txt');
scan05 = load('data/experimental/hokuyo/calibration/-10 deg/scans.txt');
scan06 = load('data/experimental/hokuyo/calibration/-5 deg/scans.txt');
scan07 = load('data/experimental/hokuyo/calibration/0 deg/scans.txt');
scan08 = load('data/experimental/hokuyo/calibration/+5 deg/scans.txt');
scan09 = load('data/experimental/hokuyo/calibration/+10 deg/scans.txt');
scan10 = load('data/experimental/hokuyo/calibration/+15 deg/scans.txt');
scan11 = load('data/experimental/hokuyo/calibration/+20 deg/scans.txt');
scan12 = load('data/experimental/hokuyo/calibration/+25 deg/scans.txt');
scan13 = load('data/experimental/hokuyo/calibration/+30 deg/scans.txt');

mean01 = mean(scan01,1);
mean02 = mean(scan02,1);
mean03 = mean(scan03,1);
mean04 = mean(scan04,1);
mean05 = mean(scan05,1);
mean06 = mean(scan06,1);
mean07 = mean(scan07,1);
mean08 = mean(scan08,1);
mean09 = mean(scan09,1);
mean10 = mean(scan10,1);
mean11 = mean(scan11,1);
mean12 = mean(scan12,1);
mean13 = mean(scan13,1);

%compute points
firstScan = 2;
lastScan = 12;
nScan = lastScan - firstScan + 1;
bearing = linspace(-pi/2,pi/2,512);
bearing = bearing(182:331); %limit to 2x2 metre square target area
elevation = pi/180*linspace(-30,30,13);
elevation = elevation(firstScan:lastScan)';
bearing = repmat(bearing,nScan,1);
elevation = repmat(elevation,1,150);
range = [mean01; mean02; mean03; mean04; mean05;
         mean06; mean07; mean08; mean09;
         mean10; mean11; mean12; mean13];
range = range(firstScan:lastScan,182:331);   
clearvars -except bearing elevation range firstScan lastScan nScan

rangeTop     = range(1:6,:);
rangeBottom  = range(6:11,:);
zAngleTop    = bearing(1:6,:);
zAngleBottom = bearing(6:11,:);
yAngleTop    = elevation(1:6,:);
yAngleBottom = elevation(6:11,:);

%% Surface fitting - TOP
[x,y] = meshgrid(-0.5:0.01:0.5,1.9:0.01:2.5);

p00 =        56.9;
p10 =     -0.6503;
p01 =      -70.17;
p20 =       13.58;
p11 =       0.636;
p02 =       28.53;
p30 =     0.06109;
p21 =       -5.49;
p12 =     -0.1553;
p03 =      -3.857;
zTop = p00 + p10*x + p01*y + p20*x.^2 + p11*x.*y + p02*y.^2 + p30*x.^3 + p21*x.^2.*y ...
                    + p12*x.*y.^2 + p03*y.^3;
%% Surface fitting - BOTTOM
p00 =      -135.9;
p10 =     -0.7532;
p01 =       175.7;
p20 =      -25.83;
p11 =      0.5988;
p02 =      -75.09;
p30 =     -0.1728;
p21 =        11.1;
p12 =     -0.1131;
p03 =       10.64;
zBottom = p00 + p10*x + p01*y + p20*x.^2 + p11*x.*y + p02*y.^2 + p30*x.^3 + p21*x.^2.*y ...
                    + p12*x.*y.^2 + p03*y.^3;
%% spherical coords visualisation - poly44
figure
hold on
plot3(zAngleTop,rangeTop,yAngleTop,'b.');
plot3(zAngleBottom,rangeBottom,yAngleBottom,'r.');
xlabel('z angle')
ylabel('range')
zlabel('y angle')
title('calibration points')
legend('top wall half','bottom wall half')

figure
hold on
plot3(zAngleTop,rangeTop,yAngleTop,'b.');
mesh(x,y,zTop);
xlabel('z angle')
ylabel('range')
zlabel('y angle')
title('fit - top')

figure
hold on
plot3(zAngleBottom,rangeBottom,yAngleBottom,'b.');
mesh(x,y,zBottom);
xlabel('z angle')
ylabel('range')
zlabel('y angle')
title('fit - bottom')



%% cartesian coords
points = zeros(3,nScan,150);
points(1,:,:) = range.*cos(bearing).*cos(elevation);
points(2,:,:) = range.*sin(bearing).*cos(elevation);
points(3,:,:) = range.*sin(elevation);
x = reshape(points(1,:,:),nScan*150,1);
y = reshape(points(2,:,:),nScan*150,1);
z = reshape(points(3,:,:),nScan*150,1);

x = range.*cos(bearing).*sin(elevation);
y = range.*sin(bearing).*sin(elevation);
z = range.*cos(elevation);

