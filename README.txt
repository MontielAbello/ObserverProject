author: Montiel Abello
email:	montiel.abello@gmail.com

Matlab toolbox for simulation of range measurements of rigid bodies and cube state observers.
This simulation was developed to test observer schemes as part of the ENGN4718 course at the ANU.

Instructions:
1. Navigate to main in 'ObserverSimulation' folder.
2. On line 15 of main or line 4 of 'settings/loadsettings.m', choose desired settings file
	2.1. settings_default: default settings
	2.2. settings_1: load stationary, noiseless measurements. Adjust initial conditions and observer update function in settings file to test observers.
	2.3. settings_2: load stationary, noisy measurements.  Adjust initial conditions and observer update function in settings file to test observers.
	2.4. settings_3: load results and display
3. settings_new: create new settings. 
	3.1. To load measurements, provide foldername in io.nameMeas and set io.loadMeas = 1.
	3.2. To save measurements, provide foldername in io.nameMeas and set io.saveMeas = 1.
	3.3. load results, provide foldername in io.nameRes and set io.loadRes = 1.
	3.4. To save results, provide foldername in io.nameRes and set io.saveRes = 1.
	3.5. Turn observer update functions on/off by setting config.orientationUpdate, config.positionUpdate etc as 1/0
	3.6. adjust config.updateScale to tune update function
	3.7. Object and sensor trajectories can be defined by waypoints or initial conditions.
		3.7.1. Example - set config.sensorPath  = 'waypoints' and define config.sensorWaypoints 
			   OR set config.sensorPath = 'initialconditions' and define config.sensorInitial
		3.7.2. when using waypoints for sensor trajectory, also define config.sensorLoops as number of times sensor pans up/down
	3.8. config.nSeconds determines total simulation time.
	3.9. config.observer turns observer simulation on/off
	3.10. config.animation turns animation on/off		   
4. Run main to simulate