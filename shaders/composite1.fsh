#version 120

#extension GL_ARB_shader_texture_lod : enable

#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif

uniform sampler2D texture;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex1;

uniform float viewWidth, viewHeight, aspectRatio;

uniform vec3 cameraPosition, previousCameraPosition;

uniform mat4 gbufferPreviousProjection, gbufferProjectionInverse;
uniform mat4 gbufferPreviousModelView, gbufferModelViewInverse;

varying vec4 color;
varying vec2 texCoord;

#include "/lib/antialiasing/taa.glsl"

void main()
{
    vec3 color = texture2DLod(colortex1, texCoord, 0.0).rgb;
    vec4 prev = vec4(0.0, 0.0, 0.0, texture2DLod(colortex2, texCoord, 0).a);

    prev = TemporalAA(color, prev.a);

    /*DRAWBUFFERS:12*/
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(prev);
}
