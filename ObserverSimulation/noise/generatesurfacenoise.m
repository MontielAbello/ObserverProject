function [rangesSurface] = generatesurfacenoise(rangesTrue,surfaceProperties,simulationLength,nScans,movement)
%GENERATERANDOMWALKNOISE Summary of this function goes here
%   Detailed explanation goes here

stepLength = 0.0005;
if movement %different random walk for each scan    
    surfaceNoise = -1 + 2*round(rand(nScans,simulationLength/nScans,1),1);
    surfaceNoise = stepLength*surfaceNoise;
    surfaceNoise = cumsum(surfaceNoise,2);
else %same random walk for each scan
    surfaceNoise = -1 + 2*round(rand(1,simulationLength/nScans,1),1);
    surfaceNoise = stepLength*surfaceNoise;
    surfaceNoise = cumsum(surfaceNoise,2);
    surfaceNoise = repmat(surfaceNoise,nScans,1);
end
surfaceNoise = reshape(surfaceNoise',simulationLength,1)';
rangesSurface = rangesTrue + surfaceNoise;

end

