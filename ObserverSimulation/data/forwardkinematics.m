clear all
close all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))
if isempty(gcp('nocreate'))
    parpool('local',8)
end
%%
DEG2RAD = pi/180;

jointAngles = load('experimental/kinova/trial_01/joint_angles.txt');
S_cube = cell(1,size(jointAngles,1));
orientation = zeros(4,size(jointAngles,1));
position = zeros(3,size(jointAngles,1));

parfor ii = 1:size(jointAngles,1)
    S_cube{ii} = jointangles2cubepose(DEG2RAD*jointAngles(ii,2:7));
    orientation(:,ii) = a2q(arot(S_cube{ii}(1:3,1:3)));
    position(:,ii) = S_cube{ii}(1:3,4);
end
trajectory = [position; orientation];
triangles = [1 2 3
             2 4 3
             4 3 7
             4 8 7
             5 6 7
             8 6 7
             2 6 5
             2 1 5
             2 6 8
             2 4 8
             1 5 7
             1 3 7];
         
cubePoints = 0.1*0.5*[-1    -1    -1    -1     1     1     1     1
                      -1    -1     1     1    -1    -1     1     1
                      -1     1    -1     1    -1     1    -1     1];
pointsPath = initialisepointspath(cubePoints',trajectory',size(jointAngles,1));

%plotting
xRange = [reshape(pointsPath(1,1:8,:),numel(pointsPath(1,1:8,:)),1,1); 0; 0];
yRange = [reshape(pointsPath(2,1:8,:),numel(pointsPath(1,1:8,:)),1,1); 0; 0];
zRange = [reshape(pointsPath(3,1:8,:),numel(pointsPath(1,1:8,:)),1,1); 0; 1.25];
plotRange = [(1-0.2*sign(min(min(xRange))))*min(min(xRange))...
             (1+0.2*sign(max(max(xRange))))*max(max(xRange))...
             (1-0.2*sign(min(min(yRange))))*min(min(yRange))...
             (1+0.2*sign(max(max(yRange))))*max(max(yRange))...
             (1-0.2*sign(min(min(zRange))))*min(min(zRange))...
             (1+0.2*sign(max(max(zRange))))*max(max(zRange))];
figure
hold on
axis equal
plot3(0,0,0,'r*')
plot3(0,0,1.25,'b*')
quiver3(0,0,1.25,0.1,0,0,'b');
axis(plotRange)
view(-120,40)
xlabel('x')
ylabel('y')
zlabel('z')
for ii = 1:size(jointAngles,1)
    plotCube = trimesh(triangles,pointsPath(1,:,ii),pointsPath(2,:,ii),pointsPath(3,:,ii),...
                             'FaceAlpha',0.5,'EdgeColor',[0.1 0.1 0.1]);
    plotPosition = plot3(position(1,ii),position(2,ii),position(3,ii),'b.');
    drawnow
    if ii < size(jointAngles,1)
        delete(plotCube)
    end
end
