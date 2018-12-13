// Calculate Stage Delta V

function calculateStageDeltaV {
	local stageTanks is list().
	local stageEngines is list().
	local iteratedParts is list().
	local allEngines is 0.
	local stageNumber is stage:number.

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
		local engineThrust is engine:maxthrust.
		set allThrustSum to allThrustSum + engineThrust.
		set allThrustPerIspSum to allThrustPerIspSum + (engineThrust / engine:visp).
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
