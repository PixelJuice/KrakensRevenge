shader_type spatial;

uniform vec3 albedo : source_color;

uniform sampler2D texture_bottom;
uniform sampler2D texture_surface;

varying vec3 worldUV;

void vertex() {
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 color = mix(texture(texture_bottom, (worldUV.zx * 0.005) + TIME * .005).rgb, texture(texture_surface, (worldUV.zx * 0.01) - TIME * .05).rgb, texture(texture_surface, (worldUV.zx * 0.01) - TIME * .05).g);
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
