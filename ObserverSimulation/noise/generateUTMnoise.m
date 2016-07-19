function [rangesMeasured] = generateUTMnoise(rangesSurface,incidenceAngles,surfaceProperties)
%GENERATEUTMNOISE Summary of this function goes here
%   Detailed explanation goes here

sigma = ((0.0006*rangesSurface/1000 + 0.00148)/1000 + 0.018);
sensorNoise = normrnd(0.03,sigma,size(rangesSurface));
rangesMeasured = rangesSurface + sensorNoise;

end

