// FUNCTION LIBRARY

function currentAtmosphere {
	if not ship:body:atm:exists
		return 0.

	if not ship:partsnamed("sensorBarometer"):length = 0
		return ship:sensors:pres/101.

	local cA is ship:altitude / 1000.0.

	if cA >= 40
		return 0.

	local minA is 0.
	local maxA is 0.
	local minP is 0.
	local maxP is 0.

	if cA < 2.5 {set minA to 0.	set maxA to 2.5.	set maxP to 1.	set minP to 0.681.}
	else if cA < 5 {set minA to 2.5.	set maxA to 5.	set maxP to 0.681.	set minP to 0.450.}
	else if cA < 7.5 {set minA to 5.	set maxA to 7.5.	set maxP to 0.450.	set minP to 0.287.}
	else if cA < 10 {set minA to 7.5.	set maxA to 10.	set maxP to 0.287.	set minP to 0.177.}
	else if cA < 15 {set minA to 10.	set maxA to 15.	set maxP to 0.177.	set minP to 0.066.}
	else if cA < 20 {set minA to 15.	set maxA to 20.	set maxP to 0.066.	set minP to 0.025.}
	else if cA < 25 {set minA to 20.	set maxA to 25.	set maxP to 0.025.	set minP to 0.010.}
	else if cA < 30 {set minA to 25.	set maxA to 30.	set maxP to 0.010.	set minP to 0.004.}
	else if cA < 40 {set minA to 30.	set maxA to 40.	set maxP to 0.004.	set minP to 0.001.}

	local deltaA is maxA - minA.
	local deltaP is maxP - minP.

	return maxP - ((cA - minA) / deltaA) * deltaP.
}

function desiredPitchForAtmosphere {
	local atm is currentAtmosphere().

	if atm > 1
		return 90.

	local maxO is 85.
	local minO is 85.
	local maxP is 1.
	local minP is 1.

	if atm > 0.681 {return 85.}
	else if atm > 0.45 {set maxO to 85.	set minO to 80.	set maxP to 0.681.	set minP to 0.45.}
	else if atm > 0.287 {set maxO to 80.	set minO to 75.	set maxP to 0.45.	set minP to 0.287.}
	else if atm > 0.177 {set maxO to 75.	set minO to 65.	set maxP to 0.287.	set minP to 0.177.}
	else if atm > 0.066 {set maxO to 65.	set minO to 55.	set maxP to 0.177.	set minP to 0.066.}
	else if atm > 0.025 {set maxO to 55.	set minO to 45.	set maxP to 0.066.	set minP to 0.025.}
	else if atm > 0.010 {set maxO to 45.	set minO to 35.	set maxP to 0.025.	set minP to 0.010.}
	else if atm > 0.004 {set maxO to 35.	set minO to 25.	set maxP to 0.010.	set minP to 0.004.}
	else if atm > 0.001 {set maxO to 25.	set minO to 15.	set maxP to 0.004.	set minP to 0.001.}
	else {set maxO to 15.	set minO to 10.	set maxP to 0.001.	set minP to 0.000.}

	local deltaO is maxO - minO.
	local deltaP is maxP - minP.

	return minO + ((atm - minP) / deltaP) * deltaO.
}

function calculateStageDeltaV {
	local stageTanks is list().
	local stageEngines is list().
	local iteratedParts is list().
	local allEngines is 0.
	local stageNumber is stage:number.
	local currentatm is currentAtmosphere().

	local function containsFuel {
		parameter part.
		local fuelResources is list("LiquidFuel", "Oxidizer", "SolidFuel").
		for resource in part:resources {
			if fuelResources:contains(resource:name)
				return true.
		}
		return false.
	}

	local function searchTanks {
		parameter part.
		if part:modules:contains("ModuleDecouple") or iteratedParts:contains(part)
			return.
		iteratedParts:add(part).
		if containsFuel(part)
			stageTanks:add(part).
		for child in part:children {
			searchTanks(child).
		}
		if part:hasparent
			searchTanks(part:parent).
	}

	list engines in allEngines.
	for engine in allEngines {
		if engine:stage >= stageNumber {
			stageEngines:add(engine).
			searchTanks(engine).
		}
	}

	if stageEngines:length = 0
		return 0.

	local allThrustSum is 0.
	local allThrustPerIspSum is 0.
	for engine in stageEngines {
		local engineThrust is engine:maxthrustat(currentatm).
		set allThrustSum to allThrustSum + engineThrust.
		set allThrustPerIspSum to allThrustPerIspSum + (engineThrust / engine:ispat(currentatm)).
	}

	local isp is allThrustSum / allThrustPerIspSum.

	local wetMass is ship:mass.
	local dryMass is ship:mass.
	for tank in stageTanks {
		set dryMass to dryMass - tank:mass + tank:drymass.
	}

	local deltaV is isp * ln(wetMass / dryMass) * 9.82.
	return deltaV.
}

function doPostAtmosphereDeployment {
	// if the next stage contains only fairings then stage.
	local nextStage is stage:number - 1.
	local allowStage is true.
	local fairingConfirmed is false.
	for part in ship:parts {
		if part:stage = nextStage {
			if part:modules:contains("ModuleProceduralFairing") {
				set fairingConfirmed to true.
			}
			if part:modules:contains("ModuleDecouple") {
				set allowStage to false.
				break.
			}
		}
	}

	if allowStage and fairingConfirmed {
		stage.
		wait 2.
	}

	for part in ship:parts {
		if part:modules:contains("ModuleRTAntenna") {
			if part:getmodule("ModuleRTAntenna"):hasevent("activate") {
				part:getmodule("ModuleRTAntenna"):doevent("activate").
			}
		} else if part:modules:contains("ModuleDataTransmitter") {
			if part:modules:contains("ModuleAnimateGeneric") and part:getmodule("ModuleAnimateGeneric"):hasevent("extend") {
				part:getmodule("ModuleAnimateGeneric"):doevent("extend").
			}
		}
		if part:modules:contains("ModuleDeployableSolarPanel") {
			if part:getmodule("ModuleDeployableSolarPanel"):hasevent("extend panels") {
				part:getmodule("ModuleDeployableSolarPanel"):doevent("extend panels").
			}
		}
	}
}
