function [objectHitSurfaceProperties] = findsurfaceproperties(iTriangleHit,triangles2Object,surfaceProperties)

    %cant index with NaN - add NaN to end and change all NaN index to that
    %element
    surfaceProperties = surfaceProperties';
    triangles2Object = [triangles2Object NaN];
    iTriangleHit(isnan(iTriangleHit)) = length(triangles2Object);
    %vector of index of object hit
    iObjectHit = triangles2Object(iTriangleHit);
    %cant index with NaN - add NaN to end and change all NaN index to that
    %element
    surfaceProperties = [surfaceProperties; 
                         NaN*surfaceProperties(1,:)];                 
    iObjectHit(isnan(iObjectHit)) = size(surfaceProperties,1);
    %each row is surface properties of object hit
    objectHitSurfaceProperties = surfaceProperties(iObjectHit,:);
    objectHitSurfaceProperties = objectHitSurfaceProperties';
    
end

