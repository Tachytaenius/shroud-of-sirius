// This shader must be loaded with the lib/simplex3d and sky include glsl files concatenated to the beginning, simplex3d first

uniform float time;
uniform mat4 screenToSky;
uniform float nearPlaneDistance;
uniform vec3 starDirection;
uniform vec3 starColour;
uniform float starAngularRadius;
uniform float starHaloAngularRange;

vec4 effect(vec4 colour, sampler2D image, vec2 textureCoords, vec2 windowCoords) {
	// This solution to get the direction was figured out by me
	vec3 direction = normalize(
		(
			screenToSky * vec4( // screenToSky is inverse(perspectiveProjectionMatrix * cameraMatrixAtOriginWithCameraOrientation), and the vec4 is a position on the picture plane (near plane) in homogenous coordinates
				textureCoords * 2.0 - 1.0,
				nearPlaneDistance,
				1.0
			)
		).xyz
	);
	return vec4(sampleSky(
		direction,
		time,
		starColour,
		starDirection,
		starAngularRadius,
		starHaloAngularRange
	), 1.0);
}
