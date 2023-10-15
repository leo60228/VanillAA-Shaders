#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

//Diffuse (color) texture.
uniform sampler2D texture;
//Lighting from day/night + shadows + light sources.
uniform sampler2D lightmap;

//Vertex color.
varying vec4 color;
//Diffuse and lightmap texture coordinates.
varying vec2 coord0;
varying vec2 coord1;

void main()
{
    //Sample texture times lighting.
    vec4 col = color * texture2D(lightmap,coord1) * texture2D(texture,coord0);

    //Output the result.
    /*DRAWBUFFERS:0*/
    gl_FragData[0] = col;
}
