shader_type canvas_item;

uniform float time;
uniform float scanline_strength : hint_range(0, 1);
uniform float scanline_frequency : hint_range(0, 1);
uniform float distortion_strength : hint_range(0, 1);
uniform float distortion_frequency : hint_range(0, 1);

void fragment() {
    // Calculate the scanline effect using the noise function
    float scanline = snoise(UV.y * scanline_frequency + time);
    vec4 scanlineColor = vec4(scanline, scanline, scanline, 1.0) * scanline_strength;

    // Calculate the distortion effect using the noise function
    float noise = snoise(UV * distortion_frequency + time);
    vec2 displacement = vec2(cos(noise), sin(noise)) * distortion_strength;

    // Offset the UV coordinate by the displacement
    vec2 offsetUV = UV + displacement;

    // Sample the color from the image texture
    vec4 texel = textureLod(TEXTURE, offsetUV, 0);

    // Combine the scanline and distortion effects with the texture color
    COLOR = texel + scanlineColor;
}