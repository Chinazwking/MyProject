#version 330 core

layout (location = 0) in vec3 apos;
layout (location = 1) in vec3 anormal;
layout (location = 2) in vec2 atexcoords;

out vec3 normal;
out vec2 texcoords;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

void main()
{
    normal = anormal;
    texcoords = atexcoords;
    gl_Position = projection * view * model * vec4(apos, 1);
}