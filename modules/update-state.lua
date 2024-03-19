local handleTemporaryFrameVariables = require("systems.handle-temporary-frame-variables")
local inputControlEntityMovement = require("systems.input-control-entity-movement")
local inputControlEntityGuns = require("systems.input-control-entity-guns")
local inputControlEntityTargetting = require("systems.input-control-entity-targetting")
local aiControlEntityTargetting = require("systems.ai-control-entity-targetting")
local aiControlEntityMovement = require("systems.ai-control-entity-movement")
local fireGuns = require("systems.fire-guns")
local accelerateToTargetVelocities = require("systems.accelerate-to-target-velocities")
local integrateVelocities = require("systems.integrate-velocities")

local turnEntityToTarget = require("modules.entity.turn-entity-to-target")

local function updateState(state, dt, mouseDx, mouseDy)
	handleTemporaryFrameVariables(state)

	if state.player then
		inputControlEntityMovement(state.player, mouseDx, mouseDy)
		inputControlEntityGuns(state.player)
		inputControlEntityTargetting(state, state.player)
	end

	for entity in state.entities:elements() do
		if entity.aiEnabled and state.player ~= entity then
			aiControlEntityTargetting(state, entity)
			-- aiControlEntityGuns
			aiControlEntityMovement(entity)

			if entity.currentTarget then -- I'd rather set a target angular velocity (TODO), which would put it in aiControlEntityMovement since that controls target velocities, but since the maths for that is beyond me right now, I'm just moving without any acceleration. And because of that, I'm putting it here on its own.
				turnEntityToTarget(entity, entity.currentTarget.position, dt)
			end
		end

		fireGuns(state, entity)

		accelerateToTargetVelocities(entity, dt)
		integrateVelocities(entity, dt)
	end

	state.time = state.time + dt
end

return updateState
