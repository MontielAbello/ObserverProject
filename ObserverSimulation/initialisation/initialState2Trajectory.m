function [trajectory,state] = initialState2Trajectory(initialState,frames,simulationLength,dt)

%from initial state, uses numerical integration to compute S,T,W over time
%also computes orientation quaternion, stores trajectory as orientation and
%position

%create empty state
state = cell(3,simulationLength);
%create initial state from config
state{1,1} = [initialState.R0 initialState.p0; 0 0 0 1];
state{2,1} = [skew_symmetric(initialState.omega0) initialState.v0; 0 0 0 0];
state{3,1} = [skew_symmetric(initialState.alpha0) initialState.a0; 0 0 0 0];
%create empty trajectory
trajectory = zeros(7,simulationLength); %each column is p; q
trajectory(1:3,1) = initialState.p0;
trajectory(4:7,1) = a2q(arot(initialState.R0)); %write R2q function!
switch frames
    case 'body-fixed'
        for ii = 1:simulationLength - 1
            %update state
            state{1,ii+1} = state{1,ii}*expm(dt*state{2,ii});
            state{2,ii+1} = state{2,ii} + dt*state{3,ii};
            state{3,ii+1} = state{3,ii}; %constant acceleration
            %update trajectory
            trajectory(1:3,ii+1) = state{1,ii+1}(1:3,4);
            trajectory(4:7,ii+1) = a2q(arot(state{1,ii+1}(1:3,1:3))); %write R2q function!
        end
    case 'inertial' %CHANGE THIS
        for ii = 1:simulationLength - 1
            %update state
            state{1,ii+1}(1:3,1:3) = state{1,ii}(1:3,1:3)*expm(dt*state{2,ii}(1:3,1:3));
            state{1,ii+1}(1:3,4)   = state{1,ii}(1:3,4) + dt*state{2,ii}(1:3,4);
            state{1,ii+1}(4,1:4)   = [0 0 0 1];
            state{2,ii+1} = state{2,ii} + dt*state{3,ii};
            state{3,ii+1} = state{3,ii}; %constant acceleration
            %update trajectory
            trajectory(1:3,ii+1) = state{1,ii+1}(1:3,4);
            trajectory(4:7,ii+1) = a2q(arot(state{1,ii+1}(1:3,1:3))); %write R2q function!
        end
end %end switch
end %end function

