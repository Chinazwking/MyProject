#version 330 core

layout (location = 0) in vec3 apos;
layout (location = 1) in vec2 atex;

out vec2 texcoords;

void main()
{
    texcoords = atex;
    gl_Position = vec4(apos, 1);
}
