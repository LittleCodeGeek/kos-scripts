// LAUNCH SCRIPT
// launch into orbit at full throttle

// == PREAMBLE ==

set ship:control:pilotmainthrottle to 0.

run lib_launch.

local throttleValue is 1.
local steeringValue is r(0, 0, 0).
parameter targetApoapsis is 90.
set targetApoapsis to targetApoapsis * 1000.
parameter steeringDirection is 90.
local steeringPitch is 90.
local maxAngleOfAttack is 15.
local shouldStageAtSeaPeriapsis is true.
local earlyStagingThreshold is 300.
local activeEngines is list().

function updateActiveEngines {
	activeEngines:clear().
	local allEngines is 0.
	list engines in allEngines.
	for eng in allEngines {
		if eng:ignition and not eng:flameout
			activeEngines:add(eng).
	}
}

function shouldStage {
	for eng in activeEngines {
		if eng:flameout
			return true.
	}

	return activeEngines:length = 0.
}

function checkStage {
	if stage:ready and shouldStage() {
		print "Staging...".
		stage.
		updateActiveEngines().
	}
}

function updateSteeringPitch {
	local desiredPitch is desiredPitchForAtmosphere().
	local currentPrograde is ship:srfprograde.
	local deltaPitch is vdot(currentPrograde:forevector, heading(steeringDirection, desiredPitch):forevector).
	set deltaPitch to max(-1, min(1, deltaPitch)).
	set deltaPitch to max(0, arccos(deltaPitch) - maxAngleOfAttack).
	set steeringPitch to desiredPitch + deltaPitch.
}

// == FIRST PHASE : LIFT OFF ==

clearscreen.
lock steeringValue to lookdirup(heading(steeringDirection, steeringPitch):forevector, ship:facing:topvector).
lock steering to steeringValue.
updateActiveEngines().
lock throttle to throttleValue.

if activeEngines:length = 0 {
	print "Counting down:".
	wait 1.
	from {local countdown is 3.} until countdown = 0 step {set countdown to countdown - 1.} do {
		print "..." + countdown.
		wait 1.
	}
	stage.
	updateActiveEngines().
}

print " ".
print "Lift off!".
print " ".

wait until alt:radar > 100.
legs off.
set steeringPitch to 85.

// == SECOND PHASE : GRAVITY TURN ==

until alt:radar > 500 and ship:altitude > 1000 {
	checkStage().
	wait until true.
}

until ship:altitude > ship:body:atm:height and ship:apoapsis > targetApoapsis {
	updateSteeringPitch().
	checkStage().
	if ship:apoapsis > targetApoapsis {
		set throttleValue to 0.
		set warpmode to "physics".
		set warp to 1.
	} else {
		set throttleValue to 1.
	}
	wait until true.
}

set warp to 0.
set warpmode to "rails".

set throttleValue to 0.
wait 2.

// == THIRD PHASE : ORBITAL INSERTION ==

doPostAtmosphereDeployment().
if calculateStageDeltaV() < earlyStagingThreshold {
	print "Staging...".
	stage.
	updateActiveEngines().
}

local currentOrbit is ship:patches[0].
local velocityAtApoapsis is sqrt(currentOrbit:body:mu * (2 / (currentOrbit:apoapsis + currentOrbit:body:radius) - 1 / (currentOrbit:semimajoraxis))).
local circularVelocity is sqrt(currentOrbit:body:mu * (1 / (currentOrbit:apoapsis + currentOrbit:body:radius))).
local circDV is circularVelocity - velocityAtApoapsis.
local circNode is node(time:seconds + eta:apoapsis, 0, 0, circDV).
add circNode.

lock steeringValue to lookdirup(circNode:burnvector, ship:facing:topvector).

// wait for steering to be within 1 degree.
wait until abs(vdot(ship:facing:forevector, circNode:burnvector:normalized)) > cos(1).
wait 3. // give it some more time to stabilize.

// calculate how much time we need to perform the burn
local acceleration is 0. lock acceleration to max(0.1, ship:availableThrust) / ship:mass.
local burnTime is circDV / acceleration.

warpto(time:seconds + circNode:eta - (burnTime / 2) - 5).

if shouldStageAtSeaPeriapsis and (calculateStageDeltaV() - circDV) < earlyStagingThreshold {
	when ship:periapsis > 0 then if stage:number > 0 {
		print "Staging...".
		for engine in activeEngines
			engine:shutdown().
		stage.
		updateActiveEngines().
	}
}

wait until circNode:eta < (burnTime / 2).

set throttleValue to 1.
lock isNodeForward to vdot(ship:facing:forevector, circNode:deltav:normalized) > 0.

until circNode:deltav:mag < 0.01 or not isNodeForward {
	checkStage().
	set throttleValue to min(1, circNode:deltav:mag / acceleration).
	wait until true.
}

set throttleValue to 0.

remove circNode.

// == END OF SCRIPT ==
