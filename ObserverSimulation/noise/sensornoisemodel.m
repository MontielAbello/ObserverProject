clear all
close all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))
%%
% ranges = zeros(31,5,1200);
% angleStr = {'0','20','40','60','80'};
% for ii = 1:31
%     folder1 = num2str(ii);
%     for jj = 1:5
%         folder2 = angleStr{jj};
%         filePath = strcat('noise/noisemeasurements/',folder1,'/',folder2,'/scans.txt');
%         data = load(filePath);
%         data = data(:,255)';
%         data(isinf(data)) = NaN;
%         ranges(ii,jj,:) = data;
%     end
% end
% save('noise/noiserange.mat','ranges');
load('noiserange.mat');
rangesTrue = 0.001*[250:50:1750]';
rangesTrue = repmat(rangesTrue,1,5,1200);
rangesError = rangesTrue - ranges;
errorMean = nanmean(rangesError,3);
errorStdDev = std(rangesError,0,3);
%exclude large error - model with NaN

[angle,range] = meshgrid(pi/180*[0:20:80],0.001*[250:50:1750]);
figure
mesh(range,angle,errorMean,gradient(errorMean));
colormap hsv
xlabel('range (m)')
ylabel('incidence angle (rad)')
zlabel('mean range error (m)')
%title('mean range error vs (r,\theta)')
figure  
errorMean(20:end,5) = NaN;
mesh(range,angle,errorMean,gradient(errorMean));
colormap hsv
xlabel('range (m)')
ylabel('incidence angle (rad)')
zlabel('mean range error (m)')
%title('mean range error vs (r,\theta) - outliers removed')
    
figure
mesh(range,angle,errorStdDev,gradient(errorStdDev));
xlabel('range (m)')
ylabel('incidence angle (rad)')
zlabel('range error standard deviation (m)')
%title('\sigma_{r_{error}} vs (r,\theta)')
figure
errorStdDev(12:end,5) = NaN;
mesh(range,angle,errorStdDev,gradient(errorStdDev));
xlabel('range (m)')
ylabel('incidence angle (rad)')
zlabel('range error standard deviation (m)')
%title('\sigma_{r_{error}} vs (r,\theta)')
    
figure
%suptitle('r_{error}(r,\theta) approximately normally distributed')
bins = 15;
rangeStrCell = {'0.25','0.50','0.75','1.00','1.25','1.50','1.75'};
rangeIndex = [1:5:31];
angleStrCell = {'0','20','40','60','80'};
for ii = 1:7
    rangeStr = rangeStrCell{ii};
    for jj = 1:5
        angleStr = angleStrCell{jj};
        %subplot(5,7,7*(jj-1)+ii);
        subplot(7,5,5*(ii-1)+jj);
        histogram(rangesError(rangeIndex(ii),jj,:),bins);
        xlabel('range error (m)')
        ylabel('frequency')
        title(strcat('r = ',rangeStrCell{ii},'m, \theta = ',angleStrCell{jj},'°'))
    end
end

%% surface fitting
[x,y] = meshgrid(0:0.01:2,0:0.01:pi/2);
p00 =    -0.06529;
p10 =      0.2024;
p01 =      0.2126;
p20 =     -0.3074;
p11 =     -0.1906;
p02 =      -0.533;
p30 =      0.2053;
p21 =      0.0228;
p12 =      0.4006;
p03 =      0.4629;
p40 =    -0.04912;
p31 =     0.01455;
p22 =     -0.0716;
p13 =     -0.1791;
p04 =     -0.1223;
zMean = p00 + p10*x + p01*y + p20*x.^2 + p11*x.*y + p02*y.^2 + p30*x.^3 + p21*x.^2.*y ... 
        + p12*x.*y.^2 + p03*y.^3 + p40*x.^4 + p31*x.^3.*y + p22*x.^2.*y.^2 ...
        + p13*x.*y.^3 + p04*y.^4;
figure
hold on
plot3(range,angle,errorMean,'k.');
mesh(x,y,zMean);
xlabel('range (m)')
ylabel('incidence angle (rad)')
zlabel('mean range error (m)')

p00 =    0.001242;
p10 =     0.00352;
p01 =   0.0006711;
p20 =   -0.005138;
p11 =    0.006146;
p02 =    -0.01128;
p30 =    0.004067;
p21 =    -0.00626;
p12 =     0.01021;
p03 =     0.01162;
p40 =   -0.001092;
p31 =    0.001337;
p22 =  -0.0005068;
p13 =   -0.007316;
p04 =   -0.002746;
zStdDev = p00 + p10*x + p01*y + p20*x.^2 + p11*x.*y + p02*y.^2 + p30*x.^3 + p21*x.^2.*y ... 
        + p12*x.*y.^2 + p03*y.^3 + p40*x.^4 + p31*x.^3.*y + p22*x.^2.*y.^2 ...
        + p13*x.*y.^3 + p04*y.^4;
figure
hold on
plot3(range,angle,errorStdDev,'k.');
mesh(x,y,zStdDev);
xlabel('range (m)')
ylabel('incidence angle (rad)')
zlabel('range error standard deviation(m)')