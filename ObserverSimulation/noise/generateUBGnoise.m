function [rangesMeasured] = generateUBGnoise(rangesSurface,incidenceAngles,surfaceProperties)
%GENERATEUBGNOISE Summary of this function goes here
%   Detailed explanation goes here

%NaN if angle & range larger than limits
rangesSurface(rangesSurface>0.8&incidenceAngles>1.3090) = NaN;
mu    = poly44(rangesSurface,incidenceAngles,'mean');
sigma = poly44(rangesSurface,incidenceAngles,'std');
sensorNoise = normrnd(mu,sigma,size(rangesSurface));
rangesMeasured = rangesSurface + sensorNoise;

end

