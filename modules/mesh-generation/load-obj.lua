local consts = require("consts")

local vec3 = require("lib.mathsies").vec3

local mul = consts.loadObjCoordMultiplier

return function(path)
	local geometry = {}
	local uv = {}
	local normal = {}
	local outVerts = {}

	local highestVertexDistance
	for line in love.filesystem.lines(path) do
		local item
		local isTri = false
		for word in line:gmatch("%S+") do
			if item then
				if isTri then
					local iterator = word:gmatch("%d+")
					local v = geometry[tonumber(iterator())]
					local vt = uv[tonumber(iterator())]
					local vn = normal[tonumber(iterator())]
					
					local pos = vec3(v[1], v[2], v[3]) * consts.loadObjCoordMultiplier
					local distance = #pos
					if not highestVertexDistance or highestVertexDistance < distance then
						highestVertexDistance = distance
					end
					local vert = { -- see consts.vertexFormat
						pos.x, pos.y, pos.z,
						vt[1], vt[2],
						vn[1] * mul.x, vn[2] * mul.y, vn[3] * mul.z
					}
					outVerts[#outVerts+1] = vert
				else
					item[#item+1] = tonumber(word)
				end
			elseif word == "#" then
				break
			elseif word == "s" then
				break
			elseif word == "v" then
				item = {}
				geometry[#geometry+1] = item
			elseif word == "vt" then
				item = {}
				uv[#uv+1] = item
			elseif word == "vn" then
				item = {}
				normal[#normal+1] = item
			elseif word == "f" then
				item = {}
				isTri = true
			else
				-- error("idk what \"" .. word .. "\" in \"" .. line .. "\" is, sorry")
			end
		end
	end
	return {
		vertices = outVerts,
		mesh = love.graphics.newMesh(consts.vertexFormat, outVerts, "triangles"),
		radius = highestVertexDistance
	}
end
