// CIRCULARIZE AT APOGEE SCRIPT

local obt is ship:obt.

local velocityAtApoapsis is sqrt(obt:body:mu * (2 / (obt:apoapsis + obt:body:radius) - 1 / (obt:semimajoraxis))).
local circularVelocity is sqrt(obt:body:mu * (1 / (obt:apoapsis + obt:body:radius))).

local circularizationNode is node(time:seconds + eta:apoapsis, 0, 0, circularVelocity - velocityAtApoapsis).
add circularizationNode.
