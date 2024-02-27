uniform mat4 modelToScreen;

vec4 position(mat4 loveTransform, vec4 homogenVertexPosition) {;
	return modelToScreen * homogenVertexPosition;
}
