close all
clear all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))
%% for viewing scans from Hokuyo UBG-04LX-F01
%settings
saveScans = 0;
%load
folderPath = 'data/experimental/hokuyo/ranges/trial_10/';
scans = load(strcat(folderPath,'scans.txt'));
time_range = load(strcat(folderPath,'time_range.txt'));
%convert inf to nan
scans(isinf(scans)) = NaN;
t = time_range(:,1);
t = reshape(t,size(scans));
%cartesian coords
zAngle = linspace(pi/2,-pi/2,512);
x = bsxfun(@times,scans,sin(zAngle));
y = bsxfun(@times,scans,cos(zAngle));
%clipping
iMin = 140;
iMax = 175;
xClipped = NaN*zeros(size(x));
yClipped = NaN*zeros(size(y));
xClipped(:,iMin:iMax) = x(:,iMin:iMax);
yClipped(:,iMin:iMax) = y(:,iMin:iMax);
scansClipped = NaN*zeros(size(scans));
tClipped = NaN*zeros(size(t));
scansClipped(:,iMin:iMax) = scans(:,iMin:iMax);
tClipped(:,iMin:iMax) = t(:,iMin:iMax);
%saving
if saveScans
    save(strcat(folderPath,'clippedScansTime.mat'),'scansClipped','tClipped');
    save(strcat(folderPath,'fulltime.mat'),'t');
end
%plotting
figure
hold on
plot(x,y,'k.')
plot(xClipped,yClipped,'r.')
xlabel('x (m)')
ylabel('y (m)')
legend('All points','Calibration points')
title('Clipping scans to separate calibration points')






