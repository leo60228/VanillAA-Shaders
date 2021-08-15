#version 130

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif

#include "settings.glsl"

uniform sampler2D colortex1;

uniform float viewWidth;
uniform float viewHeight;

in vec2 coord0;

out vec4 fragColor;

/*
const int colortex0Format = R11F_G11F_B10F; //main scene
const int colortex1Format = RGB8; //raw translucent, bloom, final scene
const int colortex2Format = RGBA16; //temporal data
*/

#if SHARPENING == 0
// Off
void SharpenFilter(inout vec3 color, vec2 coord) {}
#elif SHARPENING == 1
// Unsharp Mask
#include "bsl_lib/unsharp_mask.glsl"
#elif SHARPENING == 2
// CAS
// LICENSE
// =======
// Copyright (c) 2017-2019 Advanced Micro Devices, Inc. All rights reserved.
// -------
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// -------
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
// -------
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#define textureLod0Offset(img, coord, offset) textureLodOffset(img, coord, 0.0f, offset)
#define textureLod0(img, coord) textureLod(img, coord, 0.0f)

void SharpenFilter(inout vec3 color, vec2 textureCoord) {
    // fetch a 3x3 neighborhood around the pixel 'e',
    //  a b c
    //  d(e)f
    //  g h i
    vec3 a = textureLod0Offset(colortex1, textureCoord, ivec2(-1,-1)).rgb;
    vec3 b = textureLod0Offset(colortex1, textureCoord, ivec2( 0,-1)).rgb;
    vec3 c = textureLod0Offset(colortex1, textureCoord, ivec2( 1,-1)).rgb;
    vec3 d = textureLod0Offset(colortex1, textureCoord, ivec2(-1, 0)).rgb;
    vec3 e = color;
    vec3 f = textureLod0Offset(colortex1, textureCoord, ivec2( 1, 0)).rgb;
    vec3 g = textureLod0Offset(colortex1, textureCoord, ivec2(-1, 1)).rgb;
    vec3 h = textureLod0Offset(colortex1, textureCoord, ivec2( 0, 1)).rgb;
    vec3 i = textureLod0Offset(colortex1, textureCoord, ivec2( 1, 1)).rgb;

    // Soft min and max.
    //  a b c             b
    //  d e f * 0.5  +  d e f * 0.5
    //  g h i             h
    // These are 2.0x bigger (factored out the extra multiply).

    vec3 mnRGB  = min(min(min(d,e),min(f,b)),h);
    vec3 mnRGB2 = min(min(min(mnRGB,a),min(g,c)),i);
    mnRGB += mnRGB2;

    vec3 mxRGB  = max(max(max(d,e),max(f,b)),h);
    vec3 mxRGB2 = max(max(max(mxRGB,a),max(g,c)),i);
    mxRGB += mxRGB2;

    // Smooth minimum distance to signal limit divided by smooth max.

    vec3 rcpMxRGB = vec3(1)/mxRGB;
    vec3 ampRGB = clamp((min(mnRGB,2.0-mxRGB) * rcpMxRGB),0,1);

    // Shaping amount of sharpening.
    ampRGB = inversesqrt(ampRGB);
    float peak = 8.0 - 3.0 * CAS_AMOUNT;
    vec3 wRGB = -vec3(1)/(ampRGB * peak);
    vec3 rcpWeightRGB = vec3(1)/(1.0 + 4.0 * wRGB);

    //                          0 w 0
    //  Filter shape:           w 1 w
    //                          0 w 0  

    vec3 window = (b + d) + (f + h);
    vec3 outColor = clamp((window * wRGB + e) * rcpWeightRGB,0,1);

    color = outColor;
}
#endif

void main()
{
    vec3 color = texture2DLod(colortex1, coord0, 0).rgb;

    SharpenFilter(color, coord0);

    fragColor = vec4(color, 1.0);
}
