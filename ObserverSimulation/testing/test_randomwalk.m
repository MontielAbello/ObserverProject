close all
clear all
%% random walk implementations
figure
hold on
%random walk
y = cumsum(-1 + 2*round(rand(10000,1)),1);
plot(y,'k')


