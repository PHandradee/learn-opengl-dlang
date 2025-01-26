#version 330 core
out vec4 FragColor;  
in vec3 ourColor;
in vec3 ourPos;
in vec2 TexCoord;

// texture sampler
uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
	vec2 flippedTexCoord = vec2(TexCoord.s * -1.0, TexCoord.t);
	FragColor = mix(texture(texture1, TexCoord), texture(texture2, flippedTexCoord), 0.2);
}