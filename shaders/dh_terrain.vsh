#version 460 compatibility

attribute float mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPos;
uniform float far;

out vec4 blockColor;
out float light;
out float dist_xz;

out vec2 coord0;
out vec2 coord1;

void main() {
	dist_xz = distance(vec3(gl_Vertex.x, 0, gl_Vertex.z), vec3(0)) / far;
	vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;

	pos = (gbufferModelViewInverse * vec4(pos, 1)).xyz;

	gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos, 1);
	gl_FogFragCoord = length(pos);

	vec3 normal = gl_NormalMatrix * gl_Normal;
	normal = (mc_Entity==1.) ? vec3(0, 1, 0) : (gbufferModelViewInverse * vec4(normal, 0)).xyz;
	light = min(normal.x * normal.x * 0.6 + normal.y * normal.y * 0.25 * (3.0f + normal.y) + normal.z * normal.z * 0.8, 1.0);

	blockColor = gl_Color;
	coord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	coord1 = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}
