float calculateFogFactor(float dist, float maxDist, float fogFadeLength) { // More fog the further you are
	if (fogFadeLength == 0.0) { // Avoid dividing by zero
		return dist < maxDist ? 0.0 : 1.0;
	}
	return clamp((dist - maxDist + fogFadeLength) / fogFadeLength, 0.0, 1.0);
}

float calculateFogFactor2(float dist, float fogFadeLength) { // More fog the closer you are
	if (fogFadeLength == 0.0) { // Avoid dividing by zero
		return 1.0; // Immediate fog
	}
	return clamp(1 - dist / fogFadeLength, 0.0, 1.0);
}

uniform mat4 clipToSky;

uniform bool drawTargetSphereOutline;
uniform vec3 targetSphereOutlineColour;
uniform float targetSphereAngularRadius;
uniform vec3 targetSphereRelativePosition;
uniform float targetSphereOutlineAngularDistanceThreshold;
uniform float targetSphereOutlineFadePortion;

uniform bool drawRotationCursor;
uniform vec3 rotationCursorColour;
uniform vec3 rotationCursorDirection;
uniform float rotationCursorAngularRadius;

uniform bool drawCentreDot;
uniform vec3 centreDotColour;
uniform vec3 centreDotDirection;
uniform float centreDotAngularRadius;

vec4 effect(vec4 colour, sampler2D image, vec2 textureCoords, vec2 windowCoords) {
	// This solution to get the direction was figured out by me
	// Commented version in background.glsl
	vec3 direction = normalize(
		(
			clipToSky * vec4(
				textureCoords * 2.0 - 1.0,
				-1.0,
				1.0
			)
		).xyz
	);

	vec3 outColour = vec3(0.0);

	if (drawTargetSphereOutline) {
		float dotResult = dot(direction, normalize(targetSphereRelativePosition));
		float dotResultClamped = clamp(dotResult, -1.0, 1.0); // Clamping because, at least on the CPU, sometimes precision would cause dot to return a result outside of [-1, 1], breaking acos
		float angleDistance = abs(acos(dotResult));

		float angularDistanceToOutline = abs(angleDistance - targetSphereAngularRadius);
		float alpha = 1.0 - calculateFogFactor(angularDistanceToOutline, targetSphereOutlineAngularDistanceThreshold, targetSphereOutlineAngularDistanceThreshold * targetSphereOutlineFadePortion);

		outColour += targetSphereOutlineColour * alpha;
	}

	if (drawRotationCursor) {
		float dotResult = dot(direction, normalize(rotationCursorDirection));
		float dotResultClamped = clamp(dotResult, -1.0, 1.0);
		float angleDistance = abs(acos(dotResult));

		float alpha = angleDistance <= rotationCursorAngularRadius ? 1.0 : 0.0;
		outColour += rotationCursorColour * alpha;
	}

	if (drawCentreDot) {
		float dotResult = dot(direction, normalize(centreDotDirection));
		float dotResultClamped = clamp(dotResult, -1.0, 1.0);
		float angleDistance = abs(acos(dotResult));

		float alpha = angleDistance <= centreDotAngularRadius ? 1.0 : 0.0;
		outColour += centreDotColour * alpha;
	}

	return colour * vec4(outColour, 1.0);
}
