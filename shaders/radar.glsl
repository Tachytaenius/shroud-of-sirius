#ifdef VERTEX

uniform mat4 planeToScreen;

vec4 position(mat4 loveTransform, vec4 homogenVertexPosition) {
	vec4 ret = planeToScreen * homogenVertexPosition;
	return ret;
}

#endif

#ifdef PIXEL

const float tau = 6.28318530718;

// uniform float gridCellSize;
uniform float exponent;
uniform int distanceCircleCount;
uniform int angleLineCount;
uniform float lineThickness;

vec4 effect(vec4 colour, sampler2D image, vec2 textureCoords, vec2 windowCoords) {
	vec4 lineColour = colour; // TODO: Simplex

	vec2 surfaceCoord = textureCoords * 2.0 - 1.0;
	// if (length(surfaceCoord) < 1.0) {
	// 	return lineColour;
	// }
	for (int i = 0; i < distanceCircleCount; i++) {
		float r = pow(
			float(i + 1) / float(distanceCircleCount),
			exponent
		);
		float rL = r - length(surfaceCoord);
		if (0.0 <= rL && rL <= lineThickness) {
			return lineColour;
		}
	}
	if (length(surfaceCoord) <= 1.0) {
		for (int i = 0; i < angleLineCount; i++) {
			float theta = float(i) / float(angleLineCount) * tau + tau / 4.0;
			if (abs(mod(atan(surfaceCoord.y, surfaceCoord.x), tau) - theta) <= lineThickness) {
				return lineColour;
			}
		}
	}

	discard;
}

#endif
