close all
clear all
%% for viewing scans from Hokuyo UBG-04LX-F01
data = load('experimental/hokuyo/ranges/trial_30/scans.txt');
zAngle = linspace(pi/2,-pi/2,512);
x = bsxfun(@times,data,sin(zAngle));
y = bsxfun(@times,data,cos(zAngle));
x(isinf(x)) = NaN;
y(isinf(y)) = NaN;

figure
axis([min(min(x)) max(max(x)) min(min(y)) max(max(y))])
xlabel('x')
ylabel('range')
hold on
for ii = 1:size(x,1)
    plotScan = plot(x(ii,:),y(ii,:),'k.');
    drawnow
    pause(0.1)
    delete(plotScan)
end




