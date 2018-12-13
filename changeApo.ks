// CHANGE APOGEE SCRIPT

run lib_orbit.

local obt is ship:obt.

parameter newApo.
local newSemiMajor is (obt:periapsis + newApo + ship:body:radius * 2) / 2.

local velocityAtPeri is sqrt(obt:body:mu * (2 / (obt:periapsis + obt:body:radius) - 1 / obt:semimajoraxis)).

local targetVelocity is sqrt(obt:body:mu * (2 / (obt:periapsis + obt:body:radius) - 1 / newSemiMajor)).

local node is node(time:seconds + eta:periapsis, 0, 0, targetVelocity - velocityAtPeri).

add node.
