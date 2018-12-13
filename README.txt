HOW TO USE THE SCRIPTS

BOOT SCRIPTS:
These are the scripts that can be set to auto run on a kOS CPU when the craft is launched.
* boot_launch : Setup the device with the required scripts to perform a launch as well as the post launch setup script and await instructs.
* boot_autolaunch : Setup the device with the required scripts to perform a launch as well as the post launch setup script and automatically perform a launch due east with a target apoapsis of 80Km. Run thw post launch setup once the orbit has been circularized.

SETUP SCRIPTS:
* setup : Copy the basic files required for a launch + post launch setup.
* post_launch : Clean the drive from launch files and copy basic operational scripts. See the content of the file for an exaustive list.

UTILITY LIBRARIES:
* lib_launch : Contains utility fonctions used to perform a launch. This includes functions for aproximating the atmosphere density of Kerbin, the desired pitch for a given atmosphere density, calculating delta V, and deploying solar panels and antenas.
* lib_orbit : Contains most of the fonctions that have to do with the vis-viva equation. (https://en.wikipedia.org/wiki/Vis-viva_equation)
* lib_deltav : Contains the logic for calculating the delta V of a stage.
* lib_sensors : Contains functions pertaining to reading values from your instruments (i.g. thermometer, accelerometer). INCOMPLETE FUNCTIONALITY!

UTILITY SCRIPTS:
* ca : Create a circularization node at the Apoapsis.
* cp : Create a circularization node at the Periapsis.
* psdv : ``Print Stage Delta V'' print the current stage's delta V.
* node : Perform the next node burn with utmost precision.
* changePeri : Call with a target value to create a maneuver node that will set your Periapsis to the target value.
* changeApo : Call with a target value to create a maneuver node that will set your Apoapsis to the target value.
* changeIncline : Call with a target value to create a maneuver node that will modify your inclination to the target value.

OPERATIONAl SCRIPTS:
* launch : Run without parameters to perform a launch due eastward with a circularization burn at 80 Km. Call with one parameter to override the target circularization altitude. Call with a second parameter to set the heading direction. E.G.: ``run launch(120).'' will launch eastward with a circularization burn at 120 Km, ``run launch(400, 0)'' will launch north with a circularization burn at 400 Km.
* phaseToTarget : While you have a target on an equivalent orbit as your own, run this script to adjust your angle to the targeted value from the target. Run this script without a target to adjust your position in your orbit by a given angle, usefull when adjusting the position of satellites in Keosynchronous orbits.
* matchPlane : create a maneuver node to change your plane to match that of your target.
* matchOrbit : create a set of maneuver nodes to move yourself to the same orbit as your target. Generally, this scripts works well when going from a inner circular orbit to an other orbit. This script doesn't work well when the two orbits are already very close to one another. Your mileage may vary.
