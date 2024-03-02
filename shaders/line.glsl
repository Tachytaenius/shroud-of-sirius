uniform vec3 origin;
uniform vec3 lineVector;
uniform mat4 worldToClip;

vec4 position(mat4 loveTransform, vec4 homogenVertexPosition) {
	// homogenVertexPosition.xyz is either 0,0,0 or 1,1,1
	return worldToClip * vec4(origin + homogenVertexPosition.xyz * lineVector, 1.0);
}
