// PHASE TO TARGET ON SAME ORBIT

parameter targetAngle is 0.
parameter orbitsToPhase is 1.

run lib_orbit.

function getAngleToTarget {
	local bodyShipVector is ship:position - ship:body:position.
	local bodyTargetVector is target:position - ship:body:position.
	local periShipVector is getUnitVectorToPeri(ship:orbit).
	local planeNormal is getOrbitNormal(ship:obt).
	local shipTargetCross is vcrs(bodyShipVector, bodyTargetVector):normalized.

	local shipTargetDotProduct is vdot(bodyShipVector:normalized, bodyTargetVector:normalized).
	local angle is arccos(shipTargetDotProduct).
	if vdot(planeNormal, shipTargetCross) > 0 set angle to 360 - angle.

	return getMeanAnomalyFromTrueAnomaly(angle, ship:obt).
}

local angle is 0.
if hastarget
	set angle to getAngleToTarget().
local deltaAngle is targetAngle - angle.
local deltaTime is (ship:obt:period / 360) * deltaAngle / orbitsToPhase.
local targetPeriod is ship:obt:period + deltaTime.
local targetSMA is (ship:obt:body:mu / ((2 * constant:pi / targetPeriod) ^ 2)) ^ (1/3.0).
print (targetSMA * 2 - (ship:obt:periapsis + ship:body:radius)) - ship:body:radius.

// change the apoapsis
local velocityAtPeri is sqrt(ship:obt:body:mu * (2 / (ship:obt:periapsis + obt:body:radius) - 1 / ship:obt:semimajoraxis)).
local targetVelocity is sqrt(ship:obt:body:mu * (2 / (ship:obt:periapsis + ship:obt:body:radius) - 1 / targetSMA)).
local node is node(time:seconds + eta:periapsis, 0, 0, targetVelocity - velocityAtPeri).
add node.
set node to node(time:seconds + eta:periapsis + (targetPeriod * orbitsToPhase) , 0, 0, velocityAtPeri - targetVelocity).
add node.
