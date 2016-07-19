clear all
close all
%%
%initial and final axis-angle => interpolate to get all orientations
%N orientations are 3xN matrix, each row is orientation
%convert each row into a rotation matrix, store in 1xN cell array

%%
%input of 2 1xN cell arrays or rotation matrices, rotate all and output 1xN
%cell array of rotation matrices

%%
%input 1xN cell array of rotation matrices and 3xN matrix of N vectors
%rotate all vectors with rotation matrices and output 3xN matrix of new
%vectors