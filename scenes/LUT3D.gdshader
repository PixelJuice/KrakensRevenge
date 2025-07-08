shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform samplerCube lut;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 col = texture(screen_texture, SCREEN_UV);
    vec3 corrected = texture(lut, col.rgb).rgb;
    col.rgb = mix(col.rgb, corrected, intensity);
    COLOR = col;
}