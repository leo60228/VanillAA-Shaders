#version 150 compatibility

uniform sampler2D lightmap;
uniform sampler2D depthtex0;

uniform float viewWidth;
uniform float viewHeight;

uniform int isEyeInWater;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

in vec4 blockColor;
in float light;
in float dist_xz;
in vec2 coord0;
in vec2 coord1;

void main() {
	vec4 albedo = blockColor * texture2D(lightmap, coord1);

	float fogIntense = 4;
	if (isEyeInWater > 0) fogIntense = 1;
	
	float fog = clamp(pow(dist_xz / fogIntense, 1), 0, 1);
	albedo.rgb = mix(albedo.rgb, gl_Fog.color.rgb, fog);

	vec2 depthCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
	float depth = texture(depthtex0, depthCoord).r;
	if (dist_xz < 0.985 || depth != 1.0) discard;

	outColor0 = pow(albedo, vec4(1.25));
}
