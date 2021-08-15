#version 130

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

out vec2 coord0;

void main()
{
    gl_Position = ftransform();

    coord0 = (gl_MultiTexCoord0).xy;
}
