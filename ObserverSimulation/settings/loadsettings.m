function [io,config,switchupdatestate,settings] = loadsettings(settings)
%this function used to load desired settings file
%also used to keep track of the testing cases that have been saved
%naming convention: RT_NF_OPS
    % R - cube rotating
    % T - cube translating
    % N - number of cube faces visible to sensor
    % O - nonzero orientation error
    % P - nonzero position error
    % S - nonzero size error
    % x - field not used, ie xx_1F_Oxx = stationary cube, 1 face visible,
    %     orientation error, no noise
    
if nargin == 0
    settings = 'default'; %*ENTER DESIRED SETTINGS FILE HERE
end

switch settings
    case 'default'; [io,config] = settings_default();   switchupdatestate = @updatestate;
    case 'new';     [io,config] = settings_new();       switchupdatestate = @updatestate;
end

end %end function

