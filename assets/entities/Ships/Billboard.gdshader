shader_type spatial;
render_mode unshaded;

uniform sampler2D Texture;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	vec4 color = vec4(texture(Texture, UV));
	ALBEDO = color.rgb;
	ALPHA = color.a;
	//DEPTH = d;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}