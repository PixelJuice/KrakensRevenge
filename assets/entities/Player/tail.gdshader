shader_type spatial;

uniform vec3 shadow_colour : source_color;
uniform float max_alpha : hint_range(0.0, 1., .01) = .5;
uniform sampler2D texture_shape_01;
uniform sampler2D texture_shape_02;
uniform sampler2D texture_mask;


uniform float distortion : hint_range(0.0, 1., .01) = .01;
uniform float distortion_scale : hint_range(0.0, 100., 1.) = 1.;
uniform float distortion_speed : hint_range(0.0, 1.0, .01) = .1;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform vec2 normal_direction = vec2(2.0, 0.0);
uniform vec2 normal_direction2 = vec2(0.0, 1.0);

varying vec3 worldUV;

void vertex() {
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = worldUV.xz * .005;
	vec4 mask = texture(texture_mask, UV);
	vec4 first_normal = texture(texture_normal, UV * distortion_scale + (TIME * normal_direction));
	vec4 second_normal = texture(texture_normal2, UV * distortion_scale + (TIME * normal_direction2));
	first_normal = (first_normal * 2.) - 1.;
	second_normal = (second_normal * 2.) - 1.;
	vec4 distortion_mix = mix(first_normal, second_normal, .5);
	
	first_normal = texture(texture_normal, UV * distortion_scale + (TIME * normal_direction) + 2.5);
	second_normal = texture(texture_normal2, UV * distortion_scale + (TIME * normal_direction2) + 2.5);
	first_normal = (first_normal * 2.) - 1.;
	second_normal = (second_normal * 2.) - 1.;
	vec4 distortion_mix2 = mix(first_normal, second_normal, .5);
	
	vec4 first_shape = texture(texture_shape_01, UV + ((distortion_mix.rg * mask.r) * distortion));
	vec4 second_shape = texture(texture_shape_02, UV + ((distortion_mix2.rg * mask.r) * distortion));
	vec4 color = max(second_shape, first_shape);
	ALBEDO = shadow_colour;
	ALPHA = min(color.r, max_alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
