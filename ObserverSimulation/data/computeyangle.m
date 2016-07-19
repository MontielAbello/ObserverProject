function [yAngle] = computeyangletop(zAngle,range,side)
%give z angle & range, uses either top/bottom calibration function to
%estimate y angle (elevation)

%CONVERT TO zAngle & Range to point in [x,y] plane
x = range.*cos(zAngle);
y = range.*sin(zAngle);
%Fit to top or bottom to get z
%from estimated z, convert to y-Angle

%TOP HALF
if side
    p00 =       28.97;
    p10 =      -14.93;
    p01 =       1.323;
    p11 =     -0.6643;
    p02 =    -0.02739;
    ySign = -1;
%BOTTOM HALF
else
    p00 =       40.67;
    p10 =      -20.95;
    p01 =       2.057;
    p11 =      -1.038;
    p02 =     0.03455;
    ySign = 1;
end

z = p00 + p10*x + p01*y + p11*x.*y + p02*y.^2;
     
yAngle = ySign*asin(abs(z./range));
yAngle = asin(z./range);

end

