#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

//Fog mode
uniform int fogMode;
const int GL_LINEAR = 9729;
const int GL_EXP = 2048;

//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

//Vertex color.
varying vec4 color;

void main()
{
    vec4 col = color;

    //Calculate and apply fog intensity.
    if(fogMode == GL_LINEAR){
        float fog = clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);		
        col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);
    } else if(fogMode == GL_EXP || isEyeInWater >= 1.){
        float fog = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
        col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);
    }

    //Output the result.
    /*DRAWBUFFERS:0*/
    gl_FragData[0] = col;
}
