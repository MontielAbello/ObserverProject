close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))
%% Estimate angles using calibration functions
%load data
trialNoStr = '02';
trialNo = str2num(trialNoStr);
load(strcat('experimental/hokuyo/ranges/trial_',trialNoStr,'/clippedScansTime.mat'))
scansFull = load(strcat('experimental/hokuyo/ranges/trial_',trialNoStr,'/scans.txt'));
zAngle = linspace(pi/2,-pi/2,512);
%x = bsxfun(@times,scansClipped,sin(zAngle));
%y = bsxfun(@times,scansClipped,cos(zAngle));

%plot manual index switching
scansClippedShape = scansClipped;
scansClippedShape(isnan(scansClippedShape)) = 0;
scansMean = mean(scansClippedShape,2);
figure
plot(scansMean)
xlabel('scan index')
ylabel('mean range of scan in calibration area')
title('mean range - used to identify mins i.e. crossing horizontal')

%load indexes 
switchData = csvread('experimental/hokuyo/ranges/rotation_description.csv',1,2);
switchStart = switchData(:,1);          %start side
switchIndexes = switchData(:,2:end);    
switchIndexes(~switchIndexes) = NaN;    %remove padded zeros
currentSwitchIndexes = switchIndexes(trialNo,:);
currentSwitchIndexes(isnan(currentSwitchIndexes)) = [];
currentStart = switchStart(trialNo);

%up/down vector (1 is top half, 0 is bottom half)
side = zeros(size(scansClipped,1),1);
side(currentSwitchIndexes) = 1;
side = cumsum(side);
side = mod(side+currentStart,2);

%% Compute y-angle - something wrong
yAngles = zeros(size(scansClipped));
for ii = 1:size(scansClipped,1)
    yAngles(ii,:) = computeyangle(zAngle,scansClipped(ii,:),side(ii));
end
yAngles(:,isnan(yAngles(1,:))) = [];
yAngles = mean(yAngles,2);
figure
plot(yAngles)
xlabel('scan index')
ylabel('rotation angle about y-axis')
title('up/down sensor panning motion')

%% TODO: interpolate angles - vary through each scan
yAngles = repmat(yAngles,1,size(scansClipped,2))/3;
zAngles = repmat(zAngle,size(yAngles,1),1);

figure
plot3(zAngles,scansClipped,yAngles,'k.')
xlabel('z angle')
ylabel('range')
zlabel('y angle')
title('measured points in spherical coords')

%% Plot in cartesian - SHOULD SEE STRAIGHT WALL
x = scansFull.*cos(zAngles).*cos(yAngles);
y = scansFull.*sin(zAngles).*cos(yAngles);
z = scansFull.*sin(yAngles);

figure
hold on
plot3(x,y,z,'k.')
plot3(0,0,0,'r*','markersize',10)
quiver3(0,0,0,1,0,0,'k')
xlabel('x')
ylabel('y')
zlabel('z')
title('measured points in cartesian coords')
