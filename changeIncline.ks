// CHANGE INCLINATION SCRIPT

run lib_orbit.

local orbit is ship:orbit.

parameter newI.
local deltaI is newI - orbit:inclination.

local ascNode is 360 - orbit:argumentofperiapsis.
local descNode is ascNode + 180.
if descNode > 360 set descNode to ascNode - 180.

local bestNode is getFarthestAngle(ascNode, descNode, orbit).
local tangentAngle is getTangentAngle(bestNode, orbit).
local crossAxis is r(0, tangentAngle - bestNode, 0) * v(1, 0, 0).

local startV is v(0, 0, getSpeedAtTrueAnomaly(bestNode, orbit)).
local targetV is angleaxis(deltaI, crossAxis) * startV.
local deltaV is targetV - startV.

local node is node(time:seconds + getETA2TrueAnomaly(bestNode, orbit), deltaV:x, deltaV:y, deltaV:z).

add node.
