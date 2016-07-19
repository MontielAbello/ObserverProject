
function T = ExpSE3(a)


td = a(1:3);
rd = a(4:6);

I3 = eye(3);
th = sqrt(rd' * rd);
%rd = rd/th;
cd =cos(th);
sd = sin(th);
rx=skew_symmetric(rd);
%Rd = I3  + rx * sd + (1 - cd) *  rx^2;
if th == 0
    Rd = I3  +  rx + (1/2) *  rx^2;
    V = I3 - (1/2) * rx +  (1/6)  * rx^2;
else
    Rd = I3  + (sd/th) * rx + ((1 - cd)/th^2) *  rx^2;
    V = (I3 - ((1 - cd)/(th^2)) * rx +  ((th - sd) / (th^3) )  * rx^2);
end
td = V * td;

T = [Rd td];
