#version 120

varying vec4 color;
varying vec2 texCoord;

void main()
{
    gl_Position = ftransform();

    color = gl_Color;
    texCoord = (gl_MultiTexCoord0).xy;
}
