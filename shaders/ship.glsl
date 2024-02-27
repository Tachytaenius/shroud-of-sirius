// This shader must be loaded with the lib/simplex3d include glsl file concatenated to the beginning

varying vec3 fragmentNormal;
varying vec3 fragmentPosition;

#ifdef VERTEX

uniform mat4 modelToWorld;
uniform mat3 modelToWorldNormal;
uniform mat4 modelToScreen;

attribute vec3 VertexNormal;

vec4 position(mat4 loveTransform, vec4 homogenVertexPosition) {
	fragmentNormal = normalize(modelToWorldNormal * VertexNormal); // TODO: Does this need normalising?

	fragmentPosition = (modelToWorld * homogenVertexPosition).xyz;

	return modelToScreen * homogenVertexPosition;
}

#endif

#ifdef PIXEL

uniform float time;
uniform vec3 cameraPosition;
uniform sampler2D shipAlbedo;
uniform float skyMultiplier;
uniform vec3 ambientLight;
uniform vec3 starDirection;
uniform vec3 starColour;
uniform float starAngularRadius;
uniform float starHaloAngularRange;
uniform float skyStarColourMultiplier;

vec4 effect(vec4 colour, sampler2D image, vec2 textureCoords, vec2 windowCoords) {
	vec3 skyEffect = skyMultiplier * sampleSky(
		reflect(
			normalize(fragmentPosition - cameraPosition),
			fragmentNormal
		),
		time,
		starColour,
		starDirection,
		starAngularRadius,
		starHaloAngularRange,
		skyStarColourMultiplier
	);

	vec3 albedo = Texel(shipAlbedo, textureCoords).rgb;

	vec3 starlight = starColour * max(dot(fragmentNormal, starDirection), 0.0);
	vec3 lighting = starlight + ambientLight;

	return colour * vec4(
		skyEffect + lighting * albedo,
		1.0
	);
}

#endif
