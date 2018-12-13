// MATCH PLANE OF TARGET SCRIPT

run lib_orbit.

local orbitA is ship:orbit.
local orbitB is target:orbit.
local n is constant:pi / orbitA:period.
local ascNode is getNodeBetweenOrbits(orbitA, orbitB).
local descNode is ascNode - 180.
if descNode < 0 set descNode to ascNode + 180.
local bestNode is getFarthestAngle(ascNode, descNode, orbitA).
local deltaI is arccos(max(-1, min(1, vdot(getOrbitNormal(orbitA), getOrbitNormal(orbitB))))).
if bestNode <> ascNode set deltaI to -deltaI.

local tangentAngle is getTangentAngle(bestNode, orbitA).
local crossAxis is r(0, tangentAngle - bestNode, 0) * v(1, 0, 0).

local startV is v(0, 0, getSpeedAtTrueAnomaly(bestNode, orbitA)).
local targetV is angleaxis(deltaI, crossAxis) * startV.
local deltaV is targetV - startV.

local node is node(time:seconds + getETA2TrueAnomaly(bestNode, orbitA), deltaV:x, deltaV:y, deltaV:z).

add node.
