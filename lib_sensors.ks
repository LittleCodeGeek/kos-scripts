// FUNCTION LIBRARY

function currentGravity {
	return (ship:body:mu / ship:body:radius ^ 2) / ((ship:altitude + ship:body:radius) / ship:body:radius) ^ 2.
}.

function currentGravityVector {
	local gravityVector to v(1, 0, 0).
	set gravityVector:mag to currentGravity().
	set gravityVector:direction to heading(0, -90).
	return gravityVector.
}

function currentAccelerationVector {
	if not ship:partsnamed("sensorAccelerometer"):length = 0
		return ship:sensors:acc.

	local accVector is v(1, 0, 0).
	set accVector:mag to (ship:availablethrustat(currentAtmosphere()) / ship:mass) * throttle.

	return accVector + currentGravityVector().
}
