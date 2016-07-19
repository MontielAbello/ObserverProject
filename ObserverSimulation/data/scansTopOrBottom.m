close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))
%% for viewing scans from Hokuyo UBG-04LX-F01
trialNoStr = '01';
trialNo = str2num(trialNoStr);
load(strcat('experimental/hokuyo/ranges/trial_',trialNoStr,'/clippedScansTime.mat'))
zAngle = linspace(pi/2,-pi/2,512);
x = bsxfun(@times,scansClipped,sin(zAngle));
y = bsxfun(@times,scansClipped,cos(zAngle));

scansClipped(isnan(scansClipped)) = 0;
scansMean = mean(scansClipped,2);
figure
plot(scansMean)
xlabel('scan index')
ylabel('mean range of scan in calibration area')

%load indexes 
switchData = csvread('experimental/hokuyo/ranges/rotation_description.csv',1,2);
switchStart = switchData(:,1);          %start side
switchIndexes = switchData(:,2:end);    
switchIndexes(~switchIndexes) = NaN;    %remove padded zeros
currentSwitchIndexes = switchIndexes(trialNo,:);
currentSwitchIndexes(isnan(currentSwitchIndexes)) = [];
currentStart = switchStart(trialNo);

%up/down vector
side = zeros(size(scansClipped,1),1);
side(currentSwitchIndexes) = 1;
side = cumsum(side);
side = mod(side+currentStart,2);

