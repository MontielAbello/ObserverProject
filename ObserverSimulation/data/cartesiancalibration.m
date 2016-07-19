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
firstScan = 3;
lastScan = 11;
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

rangeTop     = range(1:5,:);
rangeBottom  = range(5:9,:);
zAngleTop    = bearing(1:5,:);
zAngleBottom = bearing(5:9,:);
yAngleTop    = elevation(1:5,:);
yAngleBottom = elevation(5:9,:);

%% visualisation
x = range.*cos(bearing).*cos(elevation);
y = range.*sin(bearing).*cos(elevation);
z = range.*sin(elevation);

figure
hold on
plot3(x,y,z,'k.')
plot3(0,0,0,'r*')
xlabel('x')
ylabel('y')
zlabel('z')
title('calibration points in cartesian coords')

%% cartesian fitting for top & bottom
xTop = rangeTop.*cos(zAngleTop).*cos(yAngleTop);
yTop = rangeTop.*sin(zAngleTop).*cos(yAngleTop);
zTop = rangeTop.*sin(yAngleTop);
xBottom = rangeBottom.*cos(zAngleBottom).*cos(yAngleBottom);
yBottom = rangeBottom.*sin(zAngleBottom).*cos(yAngleBottom);
zBottom = rangeBottom.*sin(yAngleBottom);

figure
hold on
plot3(xTop,yTop,zTop,'b.')
plot3(xBottom,yBottom,zBottom,'r.')
%plot3(0,0,0,'k*')
xlabel('x')
ylabel('y')
zlabel('z')
title('calibration points in cartesian coords')

[x,y] = meshgrid(1.9:0.001:2,-1:0.01:1);

p00 =       28.97;
p10 =      -14.93;
p01 =       1.323;
p11 =     -0.6643;
p02 =    -0.02739;
zTopFit = p00 + p10*x + p01*y + p11*x.*y + p02*y.^2;

p00 =       40.67;
p10 =      -20.95;
p01 =       2.057;
p11 =      -1.038;
p02 =     0.03455;
zBottomFit =  p00 + p10*x + p01*y + p11*x.*y + p02*y.^2;

figure
hold on
plot3(xTop,yTop,zTop,'b.')
mesh(x,y,zTopFit);
xlabel('x')
ylabel('y')
zlabel('z')
title('top fitting')                

% figure
% hold on
plot3(xBottom,yBottom,zBottom,'r.')
mesh(x,y,zBottomFit);
xlabel('x')
ylabel('y')
zlabel('z')
title('bottom fitting')

