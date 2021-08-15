#version 130

out vec2 coord0;

void main()
{
    gl_Position = ftransform();

    coord0 = (gl_MultiTexCoord0).xy;
}
