classdef RangeSensor
    %RANGESENSOR class to represent 2D scanning laser rangefinder
    %   Detailed explanation goes here
    
    properties
        trajectory
        state
        startDirection
        spinDirection
        scanAngles
        scanDirections
        scanStart
        scanEnd
        nSteps
        rangesTrue
        rangesMeasured
        rangesMeasuredTarget
        incidenceAngles
        iTriangleHit
        objectHitSurfaceProperties
    end
    
    methods
        %% AddNoise - add random walk
        function rangesMeasured = addnoise(Sensor,sensortype,simulationLength,nScans,movement)
            switch sensortype
                case 'UBG-04LX-F01-default'
                    rangesSurface = generatesurfacenoise(Sensor.rangesTrue,Sensor.objectHitSurfaceProperties,simulationLength,nScans,movement);
                    rangesMeasured = generateUBGnoise(rangesSurface,Sensor.incidenceAngles,Sensor.objectHitSurfaceProperties);
                    %1mm resolution
                    rangesMeasured = round(rangesMeasured,3);
                    %min and max range
                    rangesMeasured((rangesMeasured<0.06)|(rangesMeasured>4.095)) = NaN;
                case 'UTM-30LX-EW-default'
                    rangesSurface = generatesurfacenoise(Sensor.rangesTrue,Sensor.objectHitSurfaceProperties,simulationLength,nScans,movement);
                    rangesMeasured = generateUTMnoise(rangesSurface,Sensor.incidenceAngles,Sensor.objectHitSurfaceProperties);
                    %1mm resolution
                    rangesMeasured = round(rangesMeasured,3);
                    %min and max range
                    rangesMeasured((rangesMeasured<0.1)|(rangesMeasured>30)) = NaN;

            end %end switch
        end %end function
    end
    
end

