local vec3 = require("lib.mathsies").vec3

local consts = require("consts")

local shallowClone = require("modules.util.shallow-clone")

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
				math.cos(angle),
				math.sin(angle),
				upProgress
			)

			local u = roundProgress
			local v = upProgress

			slices[i][j] = { 
				pos.x, pos.y, pos.z,
				u, v,
				-- normal.x, normal.y, normal.z
			}
		end
	end

	local vertices = {}
	for i = 2, #slices do
		local previous, current = slices[i - 1], slices[i] -- Which slice's vertices
		for j = 0, verticesPerSlice - 1 do
			-- Form quads bridging slices with matching vertices
			local nextJ = (j + 1) % verticesPerSlice
			local normal = vec3(
				math.cos((j + 0.5) / verticesPerSlice * consts.tau),
				math.sin((j + 0.5) / verticesPerSlice * consts.tau),
				0
			)
			-- Triangle 1
			vertices[#vertices + 1] = {
				current[j][1], current[j][2], current[j][3],
				current[j][4], current[j][5],
				normal.x, normal.y, normal.z
			}
			vertices[#vertices + 1] = {
				previous[j][1], previous[j][2], previous[j][3],
				previous[j][4], previous[j][5],
				normal.x, normal.y, normal.z
			}
			vertices[#vertices + 1] = {
				previous[nextJ][1], previous[nextJ][2], previous[nextJ][3],
				previous[nextJ][4], previous[nextJ][5],
				normal.x, normal.y, normal.z
			}
			-- Triangle 2
			vertices[#vertices + 1] = {
				current[j][1], current[j][2], current[j][3],
				current[j][4], current[j][5],
				normal.x, normal.y, normal.z
			}
			vertices[#vertices + 1] = {
				current[nextJ][1], current[nextJ][2], current[nextJ][3],
				current[nextJ][4], current[nextJ][5],
				normal.x, normal.y, normal.z
			}
			vertices[#vertices + 1] = {
				previous[nextJ][1], previous[nextJ][2], previous[nextJ][3],
				previous[nextJ][4], previous[nextJ][5],
				normal.x, normal.y, normal.z
			}
		end
		-- Handle final pair of triangles specially to avoid weird texture issues with the u coordinate
		-- We modify the vertices which were added using j + 1
		local function modify(amountToGoBack)
			local vertex = vertices[#vertices - amountToGoBack]
			vertex[4] = vertex[4] + 1
		end
		modify(3)
		modify(1)
		modify(0)
	end
	for normalZ = -1, 1, 2 do --normalZ is either -1 or 1
		local slice = normalZ == -1 and slices[1] or slices[#slices]
		for i = 1, verticesPerSlice - 2 do
			local v1 = slice[0]
			local v2 = slice[i]
			local v3 = slice[i + 1]

			vertices[#vertices + 1] = {
				v1[1], v1[2], v1[3],
				v1[4] * 0.5 + 0.5, v1[5] * 0.5 + 0.5,
				0, 0, normalZ
			}
			vertices[#vertices + 1] = {
				v2[1], v2[2], v2[3],
				v2[4] * 0.5 + 0.5, v2[5] * 0.5 + 0.5,
				0, 0, normalZ
			}
			vertices[#vertices + 1] = {
				v3[1], v3[2], v3[3],
				v3[4] * 0.5 + 0.5, v3[5] * 0.5 + 0.5,
				0, 0, normalZ
			}
		end
	end

	return love.graphics.newMesh(consts.vertexFormat, vertices, "triangles", "static")
end

return generateBaseCylinder
