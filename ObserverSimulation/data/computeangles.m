clear all
close all
addpath(genpath('C:\Users\Monty Abello\Documents\Uni\2016\ENGN4718\Simulation\ObserverSimulation'))

%load data - range var from cubepose
%determine field of view to use in fitting
    %use cube poses and joint positions from cubepose script for each trial
%determine z-value of each scan
%from z-value, compute angle
%append to data set

scans = load('experimental/hokuyo/ranges/trial_01/scans.txt');
time_range = load('experimental/hokuyo/ranges/trial_01/time_range.txt');


