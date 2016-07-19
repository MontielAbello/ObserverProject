function [q] = quatspace(q0,q1,n)
%QUATSPACE performs quaternion interpolation
%   q0 and q1 are 1x4 quaternions
%   n is an integer
%   q is nx4 matrix, each row a quaternion. quaternions are linearly
%   interpolated from q0 to q1

if isequal(q0,q1)
    q = repmat(q0,n,1);
else
    t = linspace(0,1,n)';
    a0 = dot(q0,q1);
    theta = acos(a0);
    q = (sin((1-t)*theta)*q0 + sin(t*theta)*q1)/(sin(theta));
end

end

