function [z] = poly44(x,y,coefficients)

switch coefficients
    case 'mean'
        p00 =    -0.06529;
        p10 =      0.2024;
        p01 =      0.2126;
        p20 =     -0.3074;
        p11 =     -0.1906;
        p02 =      -0.533;
        p30 =      0.2053;
        p21 =      0.0228;
        p12 =      0.4006;
        p03 =      0.4629;
        p40 =    -0.04912;
        p31 =     0.01455;
        p22 =     -0.0716;
        p13 =     -0.1791;
        p04 =     -0.1223;
    case 'std'
        p00 =    0.001242;
        p10 =     0.00352;
        p01 =   0.0006711;
        p20 =   -0.005138;
        p11 =    0.006146;
        p02 =    -0.01128;
        p30 =    0.004067;
        p21 =    -0.00626;
        p12 =     0.01021;
        p03 =     0.01162;
        p40 =   -0.001092;
        p31 =    0.001337;
        p22 =  -0.0005068;
        p13 =   -0.007316;
        p04 =   -0.002746;
end
z = p00 + p10*x + p01*y + p20*x.^2 + p11*x.*y + p02*y.^2 + p30*x.^3 + p21*x.^2.*y ... 
        + p12*x.*y.^2 + p03*y.^3 + p40*x.^4 + p31*x.^3.*y + p22*x.^2.*y.^2 ...
        + p13*x.*y.^3 + p04*y.^4;


end
