local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat
local mat4 = mathsies.mat4

local consts = require("consts")

local normalMatrix = require("modules.normal-matrix")
local drawBeam = require("modules.draw-beam")
local normaliseOrZero = require("modules.normalise-or-zero")
local getGunRay = require("modules.get-gun-ray")

local function drawState(state, graphicsObjects)
	local camera = state.player
	-- camera = state.entities:get(2)
	assert(camera, "Can't draw without camera")

	local dummyTexture = graphicsObjects.dummyTexture
	local lineMesh, lineShader = graphicsObjects.lineMesh, graphicsObjects.lineShader
	local radarPlaneMesh, radarShader, solidShader = graphicsObjects.radarPlaneMesh, graphicsObjects.radarShader, graphicsObjects.solidShader
	local shipShader, backgroundShader = graphicsObjects.shipShader, graphicsObjects.backgroundShader
	local icosahedronMesh = graphicsObjects.icosahedronMesh
	local outputCanvas = graphicsObjects.outputCanvas
	local outputCanvasSetup = graphicsObjects.outputCanvasSetup

	love.graphics.setCanvas(outputCanvasSetup)
	love.graphics.clear()

	local projectionMatrix = mat4.perspectiveLeftHanded(
		love.graphics.getWidth() / love.graphics.getHeight(),
		camera.verticalFov,
		consts.farPlaneDistance,
		consts.nearPlaneDistance
	)
	local viewPosition = camera.position + vec3.rotate((camera.cameraOffset or vec3()) * camera.scale, camera.orientation)
	local cameraMatrix = mat4.camera(
		viewPosition,
		camera.orientation
	) -- For objects
	local cameraMatrixStationary = mat4.camera(vec3(), camera.orientation) -- For background

	-- Draw sky
	local screenToSkyMatrix = mat4.inverse(projectionMatrix * cameraMatrixStationary)
	love.graphics.setDepthMode("lequal", false)
	love.graphics.setShader(graphicsObjects.backgroundShader)
	backgroundShader:send("time", state.time)
	backgroundShader:send("nearPlaneDistance", consts.nearPlaneDistance)
	backgroundShader:send("screenToSky", {mat4.components(screenToSkyMatrix)})
	backgroundShader:send("starAngularRadius", consts.starAngularRadius)
	backgroundShader:send("starHaloAngularRange", consts.starHaloAngularRange)
	backgroundShader:send("starDirection", {vec3.components(consts.starDirection)})
	backgroundShader:send("starColour", consts.starColour)
	backgroundShader:send("skyStarColourMultiplier", consts.skyStarColourMultiplier)
	love.graphics.draw(dummyTexture, 0, 0, 0, love.graphics.getDimensions())

	-- Draw entities
	love.graphics.setDepthMode("lequal", true)
	love.graphics.setShader(shipShader)
	shipShader:send("time", state.time)
	shipShader:send("starAngularRadius", consts.starAngularRadius)
	shipShader:send("starHaloAngularRange", consts.starHaloAngularRange)
	shipShader:send("starDirection", {vec3.components(consts.starDirection)})
	shipShader:send("starColour", consts.starColour)
	shipShader:send("skyStarColourMultiplier", consts.skyStarColourMultiplier)
	shipShader:send("cameraPosition", {vec3.components(viewPosition)})
	for entity in state.entities:elements() do
		if entity ~= camera then
			local modelToWorldMatrix = mat4.transform(entity.position, entity.orientation, entity.scale)
			local modelToScreenMatrix = projectionMatrix * cameraMatrix * modelToWorldMatrix

			shipShader:send("shipAlbedo", entity.albedoTexture)
			shipShader:send("skyMultiplier", consts.shipShaderSkyMultiplier)
			shipShader:send("ambientLight", {vec3.components(vec3(consts.ambientLightIntensity))})
			shipShader:send("modelToWorld", {mat4.components(modelToWorldMatrix)})
			shipShader:send("modelToScreen", {mat4.components(modelToScreenMatrix)})
			shipShader:send("modelToWorldNormal", {normalMatrix(mat4.transform(entity.position, entity.orientation))})

			love.graphics.draw(entity.mesh)
		end
	end

	-- Draw beams
	love.graphics.setShader(solidShader)
	for entity in state.entities:elements() do
		for _, gun in ipairs(entity.guns) do
			if gun.firing then
				love.graphics.setColor(gun.beamColour)
				local rayStart, ray = getGunRay(entity, gun)
				drawBeam(
					rayStart,
					ray * (gun.beamHitT or 1),
					gun.beamRadius,
					projectionMatrix * cameraMatrix
				)
			end
		end
	end
	love.graphics.setColor(1, 1, 1)

	-- Draw radar blips and stalks
	local radarTransform = mat4.transform(
		vec3(0, -1.1 - math.sin(state.time * 0.5) * 0.05, 2),
		quat(),
		0.75
	)
	local radarRange = 1000
	local radarExponent = 0.5
	local function drawRadarObject(relativePosition, colour)
		local distance = #relativePosition
		love.graphics.setShader(solidShader)
		if distance <= radarRange then
			local direction = normaliseOrZero(relativePosition)
			local newDirection = vec3.rotate(direction, quat.inverse(camera.orientation))
			local newDistance = (distance / radarRange) ^ radarExponent
			local posInRadarSpace = newDirection * newDistance

			love.graphics.setColor(colour)

			solidShader:send("modelToScreen", {mat4.components(projectionMatrix * radarTransform * mat4.transform(
				posInRadarSpace, quat(), consts.radarBlipRadius
			))})
			love.graphics.draw(icosahedronMesh)

			drawBeam(
				posInRadarSpace * vec3(1, 0, 1),
				posInRadarSpace * vec3(0, 1, 0),
				consts.radarStalkRadius,
				projectionMatrix * radarTransform
			)

			-- love.graphics.setShader(lineShader)
			-- love.graphics.setWireframe(true)
			-- lineShader:send("origin", {vec3.components(posInRadarSpace * vec3(1, 0, 1))})
			-- lineShader:send("lineVector", {vec3.components(posInRadarSpace * vec3(0, 1, 0))})
			-- lineShader:send("worldToScreen", {mat4.components(projectionMatrix * radarTransform)})
			-- love.graphics.draw(lineMesh)
			-- love.graphics.setWireframe(false)
		end
	end
	for entity in state.entities:elements() do
		if entity ~= camera then
			local cameraToEntity = entity.position - camera.position
			drawRadarObject(cameraToEntity, consts.radarObjectColoursByRelation[camera.team.relations[entity.team] or "neutral"])
		end
	end
	-- Draw radar (last, because it's transparent)
	love.graphics.setColor(consts.radarColour)
	love.graphics.setShader(radarShader)
	radarShader:send("planeToScreen", {mat4.components(projectionMatrix * radarTransform)})
	radarShader:send("exponent", radarExponent)
	radarShader:send("distanceCircleCount", 6)
	radarShader:send("lineThickness", 0.015)
	radarShader:send("angleLineCount", 10)
	love.graphics.draw(radarPlaneMesh)
	love.graphics.setColor(1, 1, 1)

	love.graphics.setShader()
	love.graphics.setCanvas()
end

return drawState
