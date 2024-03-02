uniform mat4 modelToClip;

vec4 position(mat4 loveTransform, vec4 homogenVertexPosition) {;
	return modelToClip * homogenVertexPosition;
}
