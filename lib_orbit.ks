// ORBITAL FUNCTIONS LIBRARY

function getEccentricAnomalyFromTrueAnomaly {
	parameter trueAnomaly.
	parameter orbit.
	local ecc is orbit:eccentricity.
	local eccentricAnomaly is arccos((ecc + cos(trueAnomaly))/ (1 + ecc * cos(trueAnomaly))).
	if trueAnomaly > 180
		return 360 - eccentricAnomaly.
	return eccentricAnomaly.
}

function getMeanAnomalyFromEccentricAnomaly {
	parameter eccentricAnomaly.
	parameter orbit.
	local ecc is orbit:eccentricity.
	local meanAnomaly is ((eccentricAnomaly * constant:degtorad) - (ecc * sin(eccentricAnomaly))) * constant:radtodeg.
	return meanAnomaly.
}

function getMeanAnomalyFromTrueAnomaly {
	parameter trueAnomaly.
	parameter orbit.
	local eccentricAnomaly is getEccentricAnomalyFromTrueAnomaly(trueAnomaly, orbit).
	return getMeanAnomalyFromEccentricAnomaly(eccentricAnomaly, orbit).
}

function getETA2TrueAnomaly {
	parameter trueAnomaly.
	parameter orbit.
	local n is 360 / orbit:period.
	local meanAnomaly is getMeanAnomalyFromTrueAnomaly(trueAnomaly, orbit).
	//local deltaTime is (meanAnomaly - orbit:meananomalyatepoch) / n.
	local deltaTime is (meanAnomaly - getMeanAnomalyFromTrueAnomaly(orbit:trueanomaly, orbit)) / n.
	if orbit:trueAnomaly > trueAnomaly
		return deltaTime + orbit:period.
	return deltaTime.
}

function getTangentAngle {
	parameter trueAnomaly.
	parameter orbit.
	local eccentricAnomaly is getEccentricAnomalyFromTrueAnomaly(trueAnomaly, orbit).
	local x is cos(eccentricAnomaly) * orbit:semimajoraxis.
	local y is sin(eccentricAnomaly) * orbit:semiminoraxis.
	local tangentAngle is arctan2(y * orbit:semimajoraxis ^ 2, x * orbit:semiminoraxis ^ 2).
	return tangentAngle.
}

function getOrbitNormal {
	parameter orbit.
	return r(0, orbit:lan, orbit:inclination + 90) * v(1, 0, 0).
}

function getUnitVectorToPeri {
	parameter orbit.
	local orbitNormal is getOrbitNormal(orbit).
	return angleaxis(orbit:argumentofperiapsis + 90, orbitNormal) * (r(0, orbit:lan, orbit:inclination) * v(1, 0, 0)).
}

function getUnitVectorTo90 {
	parameter orbit.
	local orbitNormal is getOrbitNormal(orbit).
	return angleaxis(orbit:argumentofperiapsis + 180, orbitNormal) * (r(0, orbit:lan, orbit:inclination) * v(1, 0, 0)).
}

function getNodeBetweenOrbits {
	parameter firstOrbit.
	parameter secondOrbit.
	local firstNormal is getOrbitNormal(firstOrbit).
	local secondNormal is getOrbitNormal(secondOrbit).
	local unitPeri is getUnitVectorToPeri(firstOrbit).
	local unit90 is getUnitVectorTo90(firstOrbit).
	local crossVector is vcrs(firstNormal, secondNormal):normalized.
	local nodeAngle is arccos(max(-1, min(1, vdot(unitPeri, crossVector)))).
	if vdot(unit90, crossVector) < 0 set nodeAngle to 360 - nodeAngle.
	return nodeAngle.
}

function getDistanceAtTrueAnomaly {
	parameter trueAnomaly.
	parameter orbit.
	return orbit:semimajoraxis * (1 - orbit:eccentricity ^ 2) / (1 + orbit:eccentricity * cos(trueAnomaly)).
}

function getSpeedAtTrueAnomaly {
	parameter trueAnomaly.
	parameter orbit.
	local distance is getDistanceAtTrueAnomaly(trueAnomaly, orbit).
	return sqrt(orbit:body:mu * ((2 / distance) - (1 / orbit:semimajoraxis))).
}

function getFarthestAngle {
	parameter trueAnomalyA.
	parameter trueAnomalyB.
	parameter orbit.
	local distanceA is getDistanceAtTrueAnomaly(trueAnomalyA, orbit).
	local distanceB is getDistanceAtTrueAnomaly(trueAnomalyB, orbit).
	if distanceA > distanceB return trueAnomalyA.
	return trueAnomalyB.
}
