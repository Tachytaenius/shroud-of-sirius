// This shader must be loaded with the lib/simplex3d and sky include glsl files concatenated to the beginning, simplex3d first

varying vec3 directionPreNormalize;
varying vec2 modelSpaceXY;

#ifdef VERTEX

uniform mat4 clipToSky;

vec4 position(mat4 loveTransform, vec4 modelSpacePos) {
	// This solution to get the direction was figured out by me
	directionPreNormalize = (
		clipToSky * vec4( // clipToSky is inverse(perspectiveProjectionMatrix * cameraMatrixAtOriginWithCameraOrientation), the vec4 is a position in clip space, and the result of the multiplication is a position on a plane slice through the view frustum in world space (except camera translation is ignored)
			VertexTexCoord.xy * 2.0 - 1.0, // Clip space x and y go from -1 to 1, not 0 to 1
			-1.0, // This can actually be anything, all it defines is the length; we normalise anyway. I pick -1 because then it lands on the near plane which is what I was going for originally, though it could be the far plane (1) or whatever.
			1.0 // Appears to affect FOV for the background. 0.5 is an increased FOV and 2.0 is a decreased FOV
		)
	).xyz; // No need to divide by w, but if we did the varying would be a position on the near plane
	return loveTransform * modelSpacePos;
}

#endif

#ifdef PIXEL

uniform float time;
uniform vec3 starDirection;
uniform vec3 starColour;
uniform float starAngularRadius;
uniform float starHaloAngularRange;
uniform float skyStarColourMultiplier;

vec4 effect(vec4 colour, sampler2D image, vec2 textureCoords, vec2 windowCoords) {
	vec3 direction = normalize(directionPreNormalize);
	return vec4(sampleSky(
		direction,
		time,
		starColour,
		starDirection,
		starAngularRadius,
		starHaloAngularRange,
		skyStarColourMultiplier
	), 1.0);
}

#endif
