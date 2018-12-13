// LAUNCH SCRIPT
// launch into orbit while limiting acceleration to 2g.

// == PREAMBLE ==

run f0.

set targetApoapsis to 80000.
set steeringDirection to 90.
set steeringPitch to 90.
set maxAngleOfAttack to 7.
set baseRotation to r(0, 0, -90).
set activeEngines to list().

function updateActiveEngines {
    activeEngines:clear().
    local allEngines is 0.
    list engines in allEngines.
    for eng in allEngines {
        if eng:stage >= stage:number
            activeEngines:add(eng).
    }
}

function shouldStage {
    local noEngines is true.
    
    for eng in activeEngines {
        if eng:flameout
            return true.
        if eng:stage = stage:number
            set noEngines to false.
    }
    
    return noEngines.
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

lock steering to heading(steeringDirection, steeringPitch) + baseRotation.
updateActiveEngines().
lock throttle to 1.

if activeEngines:length = 0 {
    print "Counting down:".
    from {local countdown is 3.} until countdown = 0 step {set countdown to countdown - 1.} do {
        print "..." + countdown.
        wait 1.
    }
    stage.
    updateActiveEngines().
}

print "Lift off!".

when shouldStage() and stage:ready then {
    print "Staging...".
    stage.
    updateActiveEngines().
    if stage:number > 0 { preserve. }.
}

wait until alt:radar > 100.
set steeringPitch to 85.

// == SECOND PHASE : GRAVITY TURN ==

wait until alt:radar > 500. // in case we launch from some altitude
wait until ship:altitude > 1000.

set gravity to ship:body:mu / ship:body:radius ^ 2.
lock accelerationVector to currentAccelerationVector() - currentGravityVector().
lock gforce to accelerationVector:mag / gravity.

set gforceSetpoint to 2.
set proportionalFactor to 0.05.
set integralFactor to 0.006.
set derivativeFactor to 0.006.
lock proportionalValue to gforceSetpoint - gforce.
set integralValue to 0.
set derivativeValue to 0.

lock deltaThrottle to proportionalFactor * proportionalValue + integralFactor * integralValue + derivativeFactor * derivativeValue.

lock inDeadband to abs(proportionalValue) < 0.01.

set throttleValue to 1.
lock throttle to throttleValue.

set previousTime to time:seconds.
set previousProportionalValue to proportionalValue.
until currentAtmosphere() < 0.001 or ship:apoapsis > targetApoapsis {
    set currentTime to time:seconds.
    set deltaTime to currentTime - previousTime.
    
    updateSteeringPitch().
        
    if deltaTime > 0 and not inDeadband {
        // calculate integral and derivative
        set integralValue to integralValue + proportionalValue * deltaTime.
        set derivativeValue to (proportionalValue - previousProportionalValue) / deltaTime.
        
        // cap integral in case of windup
        set integralValue to min(1.0/integralFactor, max(-1.0/integralFactor, integralValue)).
        
        // set throttle between 0 and 1
        set throttleValue to min(1, max(0, throttleValue + deltaThrottle)).
        
        // set previous values
        set previousProportionalValue to proportionalValue.
        set previousTime to currentTime.
    }
    wait until true.
}

until ship:altitude > ship:body:atm:height and ship:apoapsis > targetApoapsis {

    updateSteeringPitch().

    if ship:apoapsis > targetApoapsis {
        set throttleValue to 0.
    } else {
        set throttleValue to 1.
    }
    wait until true.
}

lock throttle to 0.

// == THIRD PHASE : ORBITAL INSERTION ==

// warp to one minute before apoapsis
warpto(time:seconds + eta:apoapsis - 60).

// == END PHASE : SHUTDOWN ==

set ship:control:pilotmainthrottle to 0.
