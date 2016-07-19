function [pointsPath] = initialisepointspath(initialPoints,trajectory,simulationLength)

%computes position of object points in inertial frame using body
%trajectory and points in body fixed frame

    %replicate and reshape initial points
    trajectoryRep = repmat(trajectory,1,size(initialPoints,1))';
    trajectoryRep = reshape(trajectoryRep,size(trajectory,2),size(initialPoints,1)*simulationLength)';
    initialPointsRep = repmat(initialPoints,simulationLength,1);
    %rotate points - see if this is faster with rotation matrices
    pointsPath = quatrot(trajectoryRep(:,4:7),initialPointsRep) + trajectoryRep(:,1:3);
    %reshape
    pointsPath = reshape(pointsPath',3,size(initialPoints,1),size(pointsPath,1)/size(initialPoints,1));
    %pointsPath = permute(pointsPath,[2 1 3]);


end

