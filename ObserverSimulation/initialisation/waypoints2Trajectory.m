function [trajectory] = waypoints2Trajectory(waypoints,loops,simulationLength)

%interpolation from waypoints to compute trajectory of body

if any(loops)
    position = [linspace(waypoints(1,1),waypoints(1,2),0.5*simulationLength/loops);
                linspace(waypoints(2,1),waypoints(2,2),0.5*simulationLength/loops);
                linspace(waypoints(3,1),waypoints(3,2),0.5*simulationLength/loops)];
    position = [position fliplr(position)];
    position = repmat(position,1,loops);

    %represent orientation with quaternions
    qStart = a2q(waypoints(4:6,1));
    qEnd = a2q(waypoints(4:6,2));
    orientation = quatspace(qStart',qEnd',0.5*simulationLength/loops);
    orientation = orientation';
    orientation = [orientation fliplr(orientation)];
    orientation = repmat(orientation,1,loops);
else %no loops
    position = [linspace(waypoints(1,1),waypoints(1,2),simulationLength);
                linspace(waypoints(2,1),waypoints(2,2),simulationLength);
                linspace(waypoints(3,1),waypoints(3,2),simulationLength)];
    qStart = a2q(waypoints(4:6,1));
    qEnd = a2q(waypoints(4:6,2));
    orientation = quatspace(qStart',qEnd',simulationLength);
    orientation = orientation';        
end

trajectory = [position; orientation];

end

