function [points] = ranges2Points(ranges,trajectory,scanAngles,startDirection,simulationLength)
%RANGES2POINTS Summary of this function goes here
%   Detailed explanation goes here
qScanAngles = angle2quat(scanAngles,zeros(1,simulationLength),zeros(1,simulationLength));
qRotation   = quatmultiply(trajectory(4:7,:)',qScanAngles);
startDirectionRep = repmat(startDirection',simulationLength,1);
points = quatrot(qRotation,bsxfun(@times,ranges',startDirectionRep)) +...
                      trajectory(1:3,:)';
points = points';
    

end

