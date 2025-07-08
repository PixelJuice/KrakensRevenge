shader_type spatial;

uniform vec3 albedo : source_color;
uniform float metallic : hint_range(0.0, 1.0, 0.1);
uniform float roughness : hint_range(0.0, 1.0, 0.1);

uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 1.0, 0.005);
varying vec3 worldUV;

void vertex() {
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_direction2) * time_scale;
	vec3 normal = mix(texture(texture_normal, (worldUV.zx * 0.01) + time).rgb, texture(texture_normal2, (worldUV.zx * 0.01) + time2).rgb, 0.5);
	ALBEDO = albedo;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal;
	ALPHA = 0.3;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
