#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

//Pass vertex information to fragment shader.
varying vec4 color;

uniform int frameCounter;

uniform float viewWidth, viewHeight;

#include "bsl_lib/util/jitter.glsl"

void main()
{
    //Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);

    //Output color to fragment shader.
    color = gl_Color;

    // this is the good code
    do { /* } */ } while (false);

    gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
