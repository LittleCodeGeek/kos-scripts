// Print Stage Delta V
run lib_deltav.
local sdv is calculateStageDeltaV().
print "Stage DeltaV is: " + round(sdv).
