function [points] = initialisepoints(p0,R0,s0)
%INITIALISEPOINTS creates cube points given position, orientation, size
%   position: 3x1 vector [x y z]'
%   orientation: 4x1 quaternion [w x y z]'
%   size: units - m

pointsInitial = 0.5*s0*[-1    -1    -1
                        -1    -1     1
                        -1     1    -1
                        -1     1     1
                         1    -1    -1
                         1    -1     1
                         1     1    -1
                         1     1     1]';
pointsRotated = R0*pointsInitial;
points = bsxfun(@plus,pointsRotated,p0);


end %function

