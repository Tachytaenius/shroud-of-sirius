local vec3 = require("lib.mathsies").vec3

local consts = require("consts")

local shallowClone = require("modules.shallow-clone")

local function generateBaseCylinder(verticesPerSlice)
	local slices = {}
	local numSlices = 2
	for i = 1, numSlices do
		slices[i] = {}
		for j = 0, verticesPerSlice - 1 do
			local roundProgress = j / verticesPerSlice -- Doesn't reach 1
			local angle = roundProgress * consts.tau

			local upProgress = (i - 1) / (numSlices - 1) -- Reaches 1 at end

			local pos = vec3(
				math.cos(angle) * 1 / 2,
				math.sin(angle) * 1 / 2,
				upProgress
			)

			local u = roundProgress
			local v = upProgress

			local normal = vec3.normalise(pos)

			slices[i][j] = { 
				pos.x, pos.y, pos.z,
				u, v,
				normal.x, normal.y, normal.z
			}
		end
	end

	local vertices = {}
	for i = 2, #slices do
		local previousSliceVertices, thisSliceVertices = slices[i - 1], slices[i]
		for j = 0, verticesPerSlice - 1 do
			-- Form quads bridging slices with matching vertices
			-- Triangle 1
			vertices[#vertices + 1] = thisSliceVertices[j]
			vertices[#vertices + 1] = previousSliceVertices[j]
			vertices[#vertices + 1] = previousSliceVertices[(j + 1) % verticesPerSlice]
			-- Triangle 2
			vertices[#vertices + 1] = thisSliceVertices[j]
			vertices[#vertices + 1] = thisSliceVertices[(j + 1) % verticesPerSlice]
			vertices[#vertices + 1] = previousSliceVertices[(j + 1) % verticesPerSlice]
		end
		-- Handle final pair of triangles specially to avoid weird texture issues with the u coordinate
		-- We modify the vertices which were added using j + 1
		local function modify(amountToGoBack)
			local vertex = shallowClone(vertices[#vertices - amountToGoBack])
			vertex[4] = vertex[4] + 1
			vertices[#vertices - amountToGoBack] = vertex
		end
		modify(3)
		modify(1)
		modify(0)
	end

	-- TODO: Caps

	return love.graphics.newMesh(consts.vertexFormat, vertices, "triangles", "static")
end

return generateBaseCylinder
