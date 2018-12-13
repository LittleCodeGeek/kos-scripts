local throttleValue is 0.
local n is nextnode.
sas off.
lock throttle to throttleValue.

if n:eta > (60 * 10) {
	warpto(time:seconds + n:eta - (60 * 5) - 2).
	wait until n:eta < (60 * 5).
}

lock steering to lookdirup(n:burnvector, ship:facing:topvector).

// wait for steering to be within 1 degree.
wait until abs(vdot(ship:facing:forevector, n:burnvector:normalized)) > cos(1).
wait 3. // give it some more time to stabilize.

// calculate how much time we need to perform the burn
lock acceleration to max(0.1, ship:availableThrust / ship:mass).
local burnTime is n:deltav:mag / acceleration.

warpto(time:seconds + n:eta - (burnTime / 2) - 5).

wait until n:eta < (burnTime / 2).

set throttleValue to 1.
lock isNodeForward to vdot(ship:facing:forevector, n:deltav:normalized) > 0.

until n:deltav:mag < 0.01 or not isNodeForward {
	set throttleValue to min(1, n:deltav:mag / acceleration).
	wait until true.
}

set throttleValue to 0.

remove n.
