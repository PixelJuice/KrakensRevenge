shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D tex;
varying vec3 worldUV;

void vertex() {
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 text = texture(tex, UV);
	ALBEDO = text.rgb;
	ALPHA = text.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
