
function R = ExpSO3(a)

rd = a;
I3 = eye(3);
th = sqrt(rd' * rd);
%rd = rd/th;
cd =cos(th);
sd = sin(th);
rx=skew_symmetric(rd);
if th == 0
    R = I3  +  rx + (1/2) *  rx^2;
else
    R = I3  + (sd/th) * rx + ((1 - cd)/th^2) *  rx^2;
end

