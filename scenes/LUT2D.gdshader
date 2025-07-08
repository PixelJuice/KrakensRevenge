shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture; // The screen
uniform sampler2D lut_texture; // The LUT PNG
uniform float lut_size = 16.0; // Usually 16, 32, etc.
uniform float intensity : hint_range(0.0, 1.0) = 1.0; // Effect strength

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    vec3 clamped_color = clamp(color.rgb, 0.0, 1.0);

    float slice_size = 1.0 / lut_size; // Width of each tile
    float pixel_size = slice_size / lut_size; // Size of each LUT pixel

    // Calculate which LUT slice (tile) to sample based on the blue channel
    float z_slice = floor(clamped_color.b * (lut_size - 1.0));
    float x = clamped_color.r * (lut_size - 1.0);
    float y = clamped_color.g * (lut_size - 1.0);

    // Compute UV within the LUT texture
    float u = (x + z_slice * lut_size) / (lut_size * lut_size);
    float v = y / (lut_size - 1.0);

    vec3 lut_color = texture(lut_texture, vec2(u, v)).rgb;

    // Blend original and LUT result
    vec3 final_color = mix(color.rgb, lut_color, intensity);

    COLOR = vec4(final_color, color.a);
}