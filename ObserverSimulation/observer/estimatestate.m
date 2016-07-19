function [state1] = estimatestate(state0,frames,dt)
%ESTIMATESTATE internal model estimates state after time dt

state1 = cell(4,1);
switch frames
    case 'body-fixed'
        state1{1} = state0{1}*expm(dt*state0{2});
    case 'inertial'
        state1{1}(1:3,1:3) = state0{1}(1:3,1:3)*expm(dt*state0{2}(1:3,1:3));
        state1{1}(1:3,4) = state0{1}(1:3,4) + dt*state0{2}(1:3,4);
        state1{1}(4,1:4) = [0 0 0 1];
end %end switch
state1{2} = state0{2} + dt*state0{3};
state1{3} = state0{3}; %constant acceleration
state1{4} = state0{4};

%%
% p0 = state0{1};
% v0 = state0{2};
% a0 = state0{3};
% R0 = state0{4};
% omega0 = state0{5};
% alpha0 = state0{6};
% s0 = state0{7};
% 
% state1 = cell(7,1);
% 
% %linear
% state1{3} = a0;
% %state1{2} = v0 + R0*a0*dt;
% state1{1} = p0 + R0*v0*dt;
% state1{2} = v0 + a0*dt;
% %state1{1} = p0 + v0*dt;
% 
% %angular
% state1{6} = alpha0; %constant for now
% %state1{5} = omega0; %constant for now
% state1{5} = omega0 + dt*alpha0;
% state1{4} = R0*expm(dt*skew_symmetric(omega0));
% 
% %size
% state1{7} = s0;

end %function

