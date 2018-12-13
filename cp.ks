// CIRCULARIZE AT PERIGEE SCRIPT

local obt is ship:obt.

local velocityAtPeriapsis is sqrt(obt:body:mu * (2 / (obt:periapsis + obt:body:radius) - 1 / (obt:semimajoraxis))).
local circularVelocity is sqrt(obt:body:mu * (1 / (obt:periapsis + obt:body:radius))).

local circularizationNode is node(time:seconds + eta:periapsis, 0, 0, circularVelocity - velocityAtPeriapsis).
add circularizationNode.
