// MATCH ORBIT TO TARGET SCRIPT

run lib_orbit.

local orbitA is ship:orbit.
local orbitB is target:orbit.

local normalA is getOrbitNormal(orbitA).
local unitPeriA is getUnitVectorToPeri(orbitA).
local unit90A is getUnitVectorTo90(orbitA).

local normalB is getOrbitNormal(orbitB).
local unitPeriB is getUnitVectorToPeri(orbitB).
local unit90B is getUnitVectorTo90(orbitB).

local crossVector is vcrs(normalA, normalB):normalized.
local deltaI is -arccos(max(-1, min(1, vdot(normalA, normalB)))).

local ascAngleA is arccos(max(-1, min(1, vdot(unitPeriA, crossVector)))).
if vdot(unit90A, crossVector) < 0 set ascAngleA to 360 - ascAngleA.
local descAngleA is ascAngleA - 180.
if descAngleA < 0 set descAngleA to ascAngleA + 180.

local ascAngleB is arccos(max(-1, min(1, vdot(unitPeriB, crossVector)))).
if vdot(unit90B, crossVector) < 0 set ascAngleB to 360 - ascAngleB.
local descAngleB is ascAngleB - 180.
if descAngleB < 0 set descAngleB to ascAngleB + 180.

local farthestAngle is getFarthestAngle(ascAngleB, descAngleB, orbitB).
local farthestDistanceB is getDistanceAtTrueAnomaly(farthestAngle, orbitB).

local startNode is descAngleA.
if farthestAngle <> ascAngleB set startNode to ascAngleA.
else set deltaI to -deltaI.

local tangentAngle is getTangentAngle(startNode, orbitA).
local startDistance is getDistanceAtTrueAnomaly(startNode, orbitA).
local transferSemiMajorAxis is (startDistance + farthestDistanceB) / 2.

local startV is v(0, 0, getSpeedAtTrueAnomaly(startNode, orbitA)).
local targetSpeed is sqrt(ship:body:mu * (2/startDistance - 1/transferSemiMajorAxis)).
local targetV is r(0, tangentAngle - startNode, 0) * v(0, 0, targetSpeed).
local deltaV is targetV - startV.

local nodeA is node(time:seconds + getETA2TrueAnomaly(startNode, orbitA), deltaV:x, deltaV:y, deltaV:z).
add nodeA.

local insertNode is 180.
if farthestDistanceB < startDistance set insertNode to 0.

set tangentAngle to getTangentAngle(farthestAngle, orbitB).

set startV to v(0, 0, getSpeedAtTrueAnomaly(insertNode, nodeA:orbit)).
set targetSpeed to getSpeedAtTrueAnomaly(farthestAngle, orbitB).
set targetV to r(deltaI, 0, 0) * r(0, -tangentAngle + farthestAngle, 0) * v(0, 0, targetSpeed).
set deltaV to targetV - startV.

local nodeB is node(time:seconds + nodeA:eta + constant:pi * sqrt(transferSemiMajorAxis^3 / ship:body:mu), deltaV:x, deltaV:y, deltaV:z).

add nodeB.
