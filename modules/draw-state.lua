local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat
local mat4 = mathsies.mat4

local consts = require("consts")
local assets = require("assets")

local normalMatrix = require("modules.graphics.normal-matrix")
local drawBeam = require("modules.graphics.draw-beam")
local normaliseOrZero = require("modules.maths.normalise-or-zero")
local getGunRay = require("modules.util.get-gun-ray")
local getTeamRelation = require("modules.util.get-team-relation")

local function drawState(state, graphicsObjects)
	local cameraEntity = state.player
	assert(cameraEntity, "Can't draw without camera")

	local dummyTexture = graphicsObjects.dummyTexture
	local lineMesh, lineShader = graphicsObjects.lineMesh, graphicsObjects.lineShader
	local radarPlaneMesh, radarShader, solidShader = graphicsObjects.radarPlaneMesh, graphicsObjects.radarShader, graphicsObjects.solidShader
	local shipShader, backgroundShader = graphicsObjects.shipShader, graphicsObjects.backgroundShader
	local HUDShader = graphicsObjects.HUDShader
	local worldCanvas = graphicsObjects.worldCanvas
	local worldCanvasSetup = graphicsObjects.worldCanvasSetup
	local HUDCanvas = graphicsObjects.HUDCanvas
	local HUDCanvasSetup = graphicsObjects.HUDCanvasSetup
	local outputCanvas = graphicsObjects.outputCanvas

	-- Render world canvas

	love.graphics.setCanvas(worldCanvasSetup)
	love.graphics.clear()

	local projectionMatrix = mat4.perspectiveLeftHanded(
		love.graphics.getWidth() / love.graphics.getHeight(),
		cameraEntity.class.verticalFov,
		consts.farPlaneDistance,
		consts.nearPlaneDistance
	)
	local viewPosition = cameraEntity.position + vec3.rotate((cameraEntity.class.cameraOffset or vec3()) * cameraEntity.class.scale, cameraEntity.orientation)
	local cameraMatrix = mat4.camera(
		viewPosition,
		cameraEntity.orientation
	) -- For objects
	local cameraMatrixStationary = mat4.camera(vec3(), cameraEntity.orientation) -- For background

	-- Draw sky
	local clipToSkyMatrix = mat4.inverse(projectionMatrix * cameraMatrixStationary)
	love.graphics.setDepthMode("always", false)
	love.graphics.setShader(backgroundShader)
	backgroundShader:send("time", state.time)
	backgroundShader:send("clipToSky", {mat4.components(clipToSkyMatrix)})
	backgroundShader:send("starAngularRadius", consts.starAngularRadius)
	backgroundShader:send("starHaloAngularRange", consts.starHaloAngularRange)
	backgroundShader:send("starDirection", {vec3.components(consts.starDirection)})
	backgroundShader:send("starColour", consts.starColour)
	backgroundShader:send("skyStarColourMultiplier", consts.skyStarColourMultiplier)
	love.graphics.draw(dummyTexture, 0, 0, 0, worldCanvas:getDimensions())

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
		if entity ~= cameraEntity then
			local modelToWorldMatrix = mat4.transform(entity.position, entity.orientation, entity.class.scale)
			local modelToClipMatrix = projectionMatrix * cameraMatrix * modelToWorldMatrix

			shipShader:send("shipAlbedo", entity.class.shipAsset.albedo)
			shipShader:send("skyMultiplier", consts.shipShaderSkyMultiplier)
			shipShader:send("ambientLight", {vec3.components(vec3(consts.ambientLightIntensity))})
			shipShader:send("modelToWorld", {mat4.components(modelToWorldMatrix)})
			shipShader:send("modelToClip", {mat4.components(modelToClipMatrix)})
			shipShader:send("modelToWorldNormal", {normalMatrix(mat4.transform(entity.position, entity.orientation))})

			love.graphics.draw(entity.class.shipAsset.meshBundle.mesh)
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

	-- Render HUD canvas

	love.graphics.setCanvas(HUDCanvasSetup)
	love.graphics.clear()
	love.graphics.setDepthMode("always", false)
	love.graphics.setBlendMode("add", "premultiplied")
	love.graphics.setShader(HUDShader)

	HUDShader:send("clipToSky", {mat4.components(clipToSkyMatrix)})
	love.graphics.setColor(1, 1, 1)
	if cameraEntity.currentTarget then
		HUDShader:send("drawTargetSphereOutline", true)

		HUDShader:send("targetSphereOutlineColour", cameraEntity.class.displayObjectColoursByRelation[getTeamRelation(cameraEntity, cameraEntity.currentTarget)])
		local relativePosition = cameraEntity.currentTarget.position - viewPosition
		local sphereRadius = cameraEntity.currentTarget.class.shipAsset.meshBundle.radius * cameraEntity.currentTarget.class.scale + consts.targettingCircleMeshRadiusPadding
		local angularRadius = math.asin(sphereRadius / #relativePosition)
		HUDShader:send("targetSphereAngularRadius", angularRadius)
		HUDShader:send("targetSphereRelativePosition", {vec3.components(relativePosition)})

		HUDShader:send("targetSphereOutlineAngularDistanceThreshold", consts.targetSphereOutlineAngularDistanceThreshold)
		HUDShader:send("targetSphereOutlineFadePortion", consts.targetSphereOutlineFadePortion)
	else
		HUDShader:send("drawTargetSphereOutline", false)
	end

	HUDShader:send("drawRotationCursor", true)
	HUDShader:send("rotationCursorColour", consts.rotationCursorColour)
	HUDShader:send("rotationCursorDirection", {vec3.components(
		vec3.rotate(
			consts.forwardVector,
			cameraEntity.orientation * quat.fromAxisAngle(consts.rotationCursorDisplayMultiplier * state.rotationCursor)
		)
	)})
	HUDShader:send("rotationCursorAngularRadius", consts.rotationCursorAngularRadius)

	HUDShader:send("drawCentreDot", true)
	HUDShader:send("centreDotColour", consts.centreDotColour)
	HUDShader:send("centreDotDirection", {vec3.components(
		vec3.rotate(
			consts.forwardVector,
			cameraEntity.orientation
		)
	)})
	HUDShader:send("centreDotAngularRadius", consts.centreDotAngularRadius)

	love.graphics.draw(dummyTexture, 0, 0, 0, HUDCanvas:getDimensions())

	love.graphics.setBlendMode("alpha", "alphamultiply")
	love.graphics.setDepthMode("lequal", true)
	if cameraEntity.class.radar then
		-- Draw radar blips and stalks
		local radarOscillation = math.sin(state.time * cameraEntity.class.radar.yOscillationFrequency) * cameraEntity.class.radar.yOscillationAmplitude
		local radarTransform = mat4.transform(
			cameraEntity.class.radar.position + vec3(0, radarOscillation, 0),
			quat(),
			cameraEntity.class.radar.scale
		)
		local function drawRadarObject(relativePosition, colour)
			local distance = #relativePosition
			love.graphics.setShader(solidShader)
			if distance <= cameraEntity.class.scannerRange then
				local direction = normaliseOrZero(relativePosition)
				local newDirection = vec3.rotate(direction, quat.inverse(cameraEntity.orientation))
				local newDistance = (distance / cameraEntity.class.scannerRange) ^ cameraEntity.class.radar.exponent
				local posInRadarSpace = newDirection * newDistance

				love.graphics.setColor(colour)

				solidShader:send("modelToClip", {mat4.components(projectionMatrix * radarTransform * mat4.transform(
					posInRadarSpace, quat(), cameraEntity.class.radar.blipRadius
				))})
				love.graphics.draw(assets.meshes.icosahedron)

				drawBeam(
					posInRadarSpace * vec3(1, 0, 1),
					posInRadarSpace * vec3(0, 1, 0),
					cameraEntity.class.radar.stalkRadius,
					projectionMatrix * radarTransform
				)

				-- love.graphics.setShader(lineShader)
				-- love.graphics.setWireframe(true)
				-- lineShader:send("origin", {vec3.components(posInRadarSpace * vec3(1, 0, 1))})
				-- lineShader:send("lineVector", {vec3.components(posInRadarSpace * vec3(0, 1, 0))})
				-- lineShader:send("worldToClip", {mat4.components(projectionMatrix * radarTransform)})
				-- love.graphics.draw(lineMesh)
				-- love.graphics.setWireframe(false)
			end
		end
		for entity in state.entities:elements() do
			if entity ~= cameraEntity then
				local cameraToEntity = entity.position - cameraEntity.position
				drawRadarObject(cameraToEntity, cameraEntity.class.displayObjectColoursByRelation[getTeamRelation(cameraEntity, entity)])
			end
		end
		-- Draw radar (last, because it's transparent)
		love.graphics.setColor(cameraEntity.class.radar.colour)
		love.graphics.setShader(radarShader)
		radarShader:send("planeToClip", {mat4.components(projectionMatrix * radarTransform)})
		radarShader:send("exponent", cameraEntity.class.radar.exponent)
		radarShader:send("distanceCircleCount", cameraEntity.class.radar.distanceCircleCount)
		radarShader:send("lineThickness", cameraEntity.class.radar.lineThickness)
		radarShader:send("angleLineCount", cameraEntity.class.radar.angleLineCount)
		love.graphics.draw(radarPlaneMesh)
	end
	love.graphics.setColor(1, 1, 1)

	love.graphics.setShader()
	love.graphics.setDepthMode("always", false)
	love.graphics.setCanvas(outputCanvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(worldCanvas)
	love.graphics.draw(HUDCanvas)
	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha")
end

return drawState
