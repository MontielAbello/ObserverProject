clear all
close all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))
%%
trialNo = '01/';
rFolderPath = 'data/experimental/hokuyo/ranges/trial_';
cFolderPath = 'data/experimental/kinova/trial_';
load(strcat(rFolderPath,trialNo,'fulltime.mat'),'t');
jointAngles = load(strcat(cFolderPath,trialNo,'joint_angles.txt'));
tCube = jointAngles(:,1)*10^-9;

iStart = find(tCube<t(1));
iStart = iStart(end);
iEnd = find(tCube>t(end));
iEnd = iEnd(1);

jointAnglesClipped = jointAngles(iStart:iEnd,:);
jointAnglesClipped(:,1) = jointAnglesClipped(:,1)*10^-9;

save(strcat(cFolderPath,trialNo,'jointAnglesClipped.mat'),'jointAnglesClipped');
