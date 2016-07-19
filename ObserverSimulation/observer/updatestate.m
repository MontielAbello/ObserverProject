function [stateUpdate] = updatestate(stateCombined,rangesPredicted,rangesMeasured,scanDirections,config)
%UPDATESTATE updates state based on difference between measured and
%predicted ranges

%% output
stateUpdate = cell(4,1);
pDelta = [0 0 0]';
vDelta = [0 0 0]';
aDelta = [0 0 0]';
RDelta = eye(3)';
omegaDelta = zeros(3,3);
alphaDelta = zeros(3,3);
sDelta = 0;
%intermediate output
angularDelta = [0 0 0]';
linearDelta  = [0 0 0]';
%% state
%time ii+1
p0 = stateCombined{1}(1:3,4);
v0 = stateCombined{2}(1:3,4);
a0 = stateCombined{3}(1:3,4);
R0 = stateCombined{1}(1:3,1:3);
omega0 = stateCombined{2}(1:3,1:3);
alpha0 = stateCombined{3}(1:3,1:3);
s0 = stateCombined{4};

%% intersection points
pointsPredicted = bsxfun(@times,scanDirections,rangesPredicted);
pointsMeasured  = bsxfun(@times,scanDirections,rangesMeasured);
iHitPredicted = find(~isnan(rangesPredicted));
iHitMeasured = find(~isnan(rangesMeasured));   

%% determine orientation adjustment
%normal
if sum(isnan(rangesPredicted)) <= 1 %at least 3 points
    p1 = iHitPredicted(1); p2 = iHitPredicted(2); p3 = iHitPredicted(3);
    normalPredicted = cross(pointsPredicted(:,p2)-pointsPredicted(:,p1),pointsPredicted(:,p3)-pointsPredicted(:,p1));
end
if sum(isnan(rangesMeasured)) <= 1
    p1 = iHitMeasured(1); p2 = iHitMeasured(2); p3 = iHitMeasured(3); 
    normalMeasured = cross(pointsMeasured(:,p2)-pointsMeasured(:,p1),pointsMeasured(:,p3)-pointsMeasured(:,p1));
end
%rotation perpendicular to scan direction
if config.orientationUpdate && (sum(isnan(rangesPredicted)) <= 1) && (sum(isnan(rangesMeasured)) <= 1) %both normals available
    %rotate in axis from predicted normal towards measured normal ie cross
    perpendicularAxis = cross(normalPredicted,normalMeasured);
    angle = atan2(norm(perpendicularAxis),dot(normalPredicted,normalMeasured));
    if abs(angle) > pi/4
        perpendicularAxis = -perpendicularAxis;
    end       
    angularDelta = angularDelta + perpendicularAxis;
end
%rotation about scan direction vector
if config.parallelOrientationUpdate && ~isequal(isnan(rangesPredicted),isnan(rangesMeasured)) && sum(isnan(rangesPredicted)) <= 1 && ~any(isnan(normalPredicted))
    parallelAxis = unit(normalPredicted);
    parallelAngle = 0.00005*sign(parallelAxis(1)); %find a better way to get correct direction!!!
    angularDelta = angularDelta + parallelAngle*parallelAxis;
end

%% position adjustment
if config.positionUpdate && sum(~isnan(rangesPredicted)) > 0 && sum(~isnan(rangesMeasured)) > 0
    %seeing part of each cube
    pointsPredictedHit = pointsPredicted(:,iHitPredicted);
    pointsMeasuredHit  = pointsMeasured(:,iHitMeasured);        
    %take mean of hits
    pointsPredictedMean = mean(pointsPredictedHit,2);
    pointsMeasuredMean  = mean(pointsMeasuredHit,2);
    %calculate vector from predicted to measured
    updateDirection = pointsMeasuredMean - pointsPredictedMean;
    %pDelta = pDelta + 0.005*[2 100 10]'.*updateDirection;
    %scale according to geometry of scanner and object position, and
    %scanning dynamics
    rangesMean = mean([rangesPredicted(iHitPredicted) rangesMeasured(iHitMeasured)]);
    %p0 = p0; 
    p1 = rangesMean*scanDirections(:,1);
    p2 = rangesMean*scanDirections(:,2);
    p3 = rangesMean*scanDirections(:,3);
    l1 = norm(p1-p0);
    l2 = norm(p2-p1);
    l3 = norm(p3-p2);
    updateDirection = updateDirection./[l1 l2 l3]';
    if any(isnan(updateDirection))
        updateDirection = [0 0 0]';
    end
    linearDelta = linearDelta + updateDirection;
end

%% size adjustment
%perpendicular position update
    %not seeing same pattern
if config.sizeUpdate
    if ~isequal(isnan(rangesMeasured),isnan(rangesPredicted))
        if sum(~isnan(rangesPredicted)) > 0 && sum(~isnan(rangesMeasured)) > 0 && (sum(isnan([rangesPredicted rangesMeasured])) > 0)
            %seeing part of each cube
            pointsPredictedHit = pointsPredicted(:,iHitPredicted);
            pointsMeasuredHit  = pointsMeasured(:,iHitMeasured);        
            %take mean of hits
            pointsPredictedMean = mean(pointsPredictedHit,2);
            pointsMeasuredMean  = mean(pointsMeasuredHit,2);
            %calculate vector from predicted to measured
            updateDirection = pointsMeasuredMean - pointsPredictedMean;
            %define updates
            sDelta = sDelta + 0.1*dot(updateDirection,scanDirections(:,1));
        end
    elseif sum(~isnan(rangesPredicted)) > 0 && sum(~isnan(rangesMeasured)) > 0
    %parallel position update
        %average predicted and measured ranges
        %move along scan direction +/-, change size +/-
        rangeError = mean(rangesMeasured(~isnan(rangesMeasured)) - rangesPredicted(~isnan(rangesPredicted)));
        sDelta = sDelta - rangeError;
    end
end %if config.sizeUpdate

%% update
%above, get rotation axis, position update vector, size update
%scale rotation and position according to config
switch config.updateMethod
    case 'screw'
        RDelta = rot(config.updateScale.R*angularDelta);
        pDelta = config.updateScale.p.*linearDelta;
    case 'twist'
        omegaDelta = config.updateScale.omega*skew_symmetric(angularDelta);
        vDelta     = config.updateScale.v.*linearDelta;
    case 'wrench'
        alphaDelta = config.updateScale.alpha*skew_symmetric(angularDelta);
        aDelta     = config.updateScale.a.*linearDelta;
end

stateUpdate{1} = [(RDelta*R0)           (p0 + pDelta); 0 0 0 1]; 
stateUpdate{2} = [(omega0 + omegaDelta) (v0 + vDelta); 0 0 0 0]; 
stateUpdate{3} = [(alpha0 + alphaDelta) (a0 + aDelta); 0 0 0 0]; 
stateUpdate{4} = s0 + config.updateScale.s*sDelta; 


end

