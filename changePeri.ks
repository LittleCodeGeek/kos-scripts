// CHANGE PERIGEE SCRIPT

run lib_orbit.

local obt is ship:obt.

parameter newPeri.
local newSemiMajor is (obt:apoapsis + newPeri + ship:body:radius * 2) / 2.

local velocityAtApo is sqrt(obt:body:mu * (2 / (obt:apoapsis + obt:body:radius) - 1 / obt:semimajoraxis)).

local targetVelocity is sqrt(obt:body:mu * (2 / (obt:apoapsis + obt:body:radius) - 1 / newSemiMajor)).

local node is node(time:seconds + eta:apoapsis, 0, 0, targetVelocity - velocityAtApo).

add node.
