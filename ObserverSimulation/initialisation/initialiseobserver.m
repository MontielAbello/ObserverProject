function [Observer] = initialiseobserver(initialState,simulationLength)
%INITIALISEOBSERVER creates class instance to represent state observer
%   uses internal model to estimate state over time
%   uses update to update state estimate based on range measurements
    
    Observer = StateObserver;
    Observer.stateEstimated = cell(4,simulationLength);
    Observer.stateEstimated{1,1} = [initialState.R0 initialState.p0; 0 0 0 1];
    Observer.stateEstimated{2,1} = [skew_symmetric(initialState.omega0) initialState.v0; 0 0 0 0];
    Observer.stateEstimated{3,1} = [skew_symmetric(initialState.alpha0) initialState.a0; 0 0 0 0];
    Observer.stateEstimated{4,1} = initialState.s0;
    %Observer.pointsPathEstimated = zeros(3,4,simulationLength);
    Observer.pointsPathEstimated = zeros(3,8,simulationLength);
    Observer.rangesPredicted = NaN*zeros(1,simulationLength);
    Observer.triangles = [1 2 3
                          2 4 3
                          4 3 7
                          4 8 7
                          5 6 7
                          8 6 7
                          2 6 5
                          2 1 5
                          2 6 8
                          2 4 8
                          1 5 7
                          1 3 7];

end

