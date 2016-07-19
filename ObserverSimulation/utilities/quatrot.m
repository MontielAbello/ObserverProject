function [v2] = quatrot(q,v1)
%QUATROT Summary of this function goes here
%   Detailed explanation goes here

v2 = quatmultiply(q,quatmultiply([zeros(size(v1,1),1) v1],quatinv(q)));
v2(:,1) = [];
end

